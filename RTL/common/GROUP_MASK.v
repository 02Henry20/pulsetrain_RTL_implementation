// Groups cycles with identical complete D vectors and emits unary X layers.
// Frames longer than GROUP_MASK_BIT_LENGTH_LIMIT bypass grouping unchanged.
module GROUP_MASK #(
    parameter integer CROSSBAR_DIMENSION = 8,
    parameter integer BIT_LENGTH = 8
) (
    input  wire                          CLK,
    input  wire                          RST, // Active-low asynchronous reset.

    // The surrounding frame controller guarantees one accepted input per
    // asserted INPUT_VALID cycle and sends no new frame until FRAME_DONE.
    input  wire                          INPUT_VALID,
    input  wire                          INPUT_KEEP,
    input  wire                          INPUT_LAST,
    output wire                          INPUT_READY, // High when this input pair can transfer.
    input  wire [CROSSBAR_DIMENSION-1:0] X_PULSES_IN,
    input  wire [CROSSBAR_DIMENSION-1:0] D_PULSES_IN,

    output wire [CROSSBAR_DIMENSION-1:0] X_PULSES_OUT,
    output wire [CROSSBAR_DIMENSION-1:0] D_PULSES_OUT,
    output wire                          OUTPUT_VALID,
    input  wire                          OUTPUT_READY,
    output wire                          FRAME_DONE
);

    localparam integer GROUP_MASK_BIT_LENGTH_LIMIT = 8;

    generate
        // Long frames are forwarded. ARCH_TOP applies downstream backpressure
        // before asserting INPUT_VALID in this bypass configuration.
        if (BIT_LENGTH > GROUP_MASK_BIT_LENGTH_LIMIT) begin : GEN_BYPASS
            assign X_PULSES_OUT = X_PULSES_IN;
            assign D_PULSES_OUT = D_PULSES_IN;
            assign OUTPUT_VALID = INPUT_VALID && INPUT_KEEP;
            // A kept bypass pair transfers only when the output can take it.
            assign INPUT_READY = !INPUT_VALID || !INPUT_KEEP || OUTPUT_READY;
            assign FRAME_DONE = INPUT_VALID && INPUT_LAST &&
                (!INPUT_KEEP || OUTPUT_READY);
        end else begin : GEN_GROUPING
            localparam integer GROUP_COUNT_WIDTH =
                (BIT_LENGTH <= 1) ? 1 : $clog2(BIT_LENGTH + 1);
            localparam integer GROUP_INDEX_WIDTH =
                (BIT_LENGTH <= 1) ? 1 : $clog2(BIT_LENGTH);
            localparam integer X_COUNT_WIDTH =
                (BIT_LENGTH <= 1) ? 1 : $clog2(BIT_LENGTH + 1);

            // Groups are densely allocated in slots [0, group_count-1].
            // Therefore a separate group_valid vector is unnecessary.
            reg [CROSSBAR_DIMENSION-1:0] d_patterns [0:BIT_LENGTH-1];
            reg [CROSSBAR_DIMENSION*X_COUNT_WIDTH-1:0]
                x_lane_counts [0:BIT_LENGTH-1];
            reg [X_COUNT_WIDTH-1:0] emitted_layers [0:BIT_LENGTH-1];
            reg [GROUP_COUNT_WIDTH-1:0] group_count;
            reg frame_closed;
            reg frame_done_reg;

            // Parallel complete-pattern lookup. With the eight-cycle cap this
            // has at most eight comparators and no pending pipeline stage.
            wire lookup_enable = INPUT_VALID && INPUT_KEEP && !frame_closed;
            wire [BIT_LENGTH-1:0] pattern_matches;

            genvar lookup_group;
            for (lookup_group = 0; lookup_group < BIT_LENGTH;
                 lookup_group = lookup_group + 1) begin : GEN_PATTERN_MATCH
                assign pattern_matches[lookup_group] =
                    lookup_enable &&
                    (group_count > lookup_group) &&
                    (d_patterns[lookup_group] == D_PULSES_IN);
            end

            wire table_match_found = |pattern_matches;
            reg [GROUP_INDEX_WIDTH-1:0] table_match_index;
            integer encode_group;

            // The match vector is one-hot. With at most eight entries, a
            // compact procedural encoder is clearer than generated index masks.
            always @(*) begin
                table_match_index = {GROUP_INDEX_WIDTH{1'b0}};
                for (encode_group = 0;
                     encode_group < BIT_LENGTH;
                     encode_group = encode_group + 1) begin
                    if (pattern_matches[encode_group])
                        table_match_index = encode_group;
                end
            end

            wire [GROUP_INDEX_WIDTH-1:0] input_group_index =
                table_match_found ? table_match_index :
                group_count[GROUP_INDEX_WIDTH-1:0];
            wire table_has_space = (group_count < BIT_LENGTH);

            // A full layer is safe to emit before frame end because every X
            // lane already owns one unsent pulse. Residual partial layers are
            // emitted only after INPUT_LAST.
            reg [BIT_LENGTH-1:0] full_layer_available;
            reg [BIT_LENGTH-1:0] any_layer_available;
            reg candidate_valid;
            reg [GROUP_INDEX_WIDTH-1:0] candidate_group_index;
            reg [CROSSBAR_DIMENSION-1:0] candidate_x;
            reg [CROSSBAR_DIMENSION-1:0] candidate_d;

            integer availability_group;
            integer availability_lane;
            integer select_group;
            integer select_lane;

            always @(*) begin
                full_layer_available = {BIT_LENGTH{1'b0}};
                any_layer_available  = {BIT_LENGTH{1'b0}};

                for (availability_group = 0;
                     availability_group < BIT_LENGTH;
                     availability_group = availability_group + 1) begin
                    if (availability_group < group_count) begin
                        full_layer_available[availability_group] = 1'b1;

                        for (availability_lane = 0;
                             availability_lane < CROSSBAR_DIMENSION;
                             availability_lane = availability_lane + 1) begin
                            if (x_lane_counts[availability_group]
                                    [availability_lane*X_COUNT_WIDTH +:
                                     X_COUNT_WIDTH] <=
                                emitted_layers[availability_group]) begin
                                full_layer_available[availability_group] = 1'b0;
                            end

                            if (x_lane_counts[availability_group]
                                    [availability_lane*X_COUNT_WIDTH +:
                                     X_COUNT_WIDTH] >
                                emitted_layers[availability_group]) begin
                                any_layer_available[availability_group] = 1'b1;
                            end
                        end
                    end
                end

                candidate_valid       = 1'b0;
                candidate_group_index = {GROUP_INDEX_WIDTH{1'b0}};
                candidate_x           = {CROSSBAR_DIMENSION{1'b0}};
                candidate_d           = {CROSSBAR_DIMENSION{1'b0}};

                for (select_group = 0;
                     select_group < BIT_LENGTH;
                     select_group = select_group + 1) begin
                    if (!candidate_valid &&
                        ((frame_closed && any_layer_available[select_group]) ||
                         (!frame_closed && full_layer_available[select_group]))) begin
                        candidate_valid = 1'b1;
                        candidate_group_index =
                            select_group[GROUP_INDEX_WIDTH-1:0];
                        candidate_d = d_patterns[select_group];

                        for (select_lane = 0;
                             select_lane < CROSSBAR_DIMENSION;
                             select_lane = select_lane + 1) begin
                            candidate_x[select_lane] = frame_closed ?
                                (x_lane_counts[select_group]
                                    [select_lane*X_COUNT_WIDTH +:
                                     X_COUNT_WIDTH] >
                                 emitted_layers[select_group]) : 1'b1;
                        end
                    end
                end
            end

            // Fall-through holding register: the common ready case has no
            // output bubble, while a stalled output remains stable even as new
            // input counters continue to update.
            reg hold_valid;
            reg [GROUP_INDEX_WIDTH-1:0] hold_group_index;
            reg [CROSSBAR_DIMENSION-1:0] hold_x;
            reg [CROSSBAR_DIMENSION-1:0] hold_d;

            wire active_output_valid = hold_valid || candidate_valid;
            wire [GROUP_INDEX_WIDTH-1:0] active_group_index =
                hold_valid ? hold_group_index : candidate_group_index;

            assign INPUT_READY = !frame_closed;
            assign OUTPUT_VALID = active_output_valid;
            assign X_PULSES_OUT = hold_valid ? hold_x : candidate_x;
            assign D_PULSES_OUT = hold_valid ? hold_d : candidate_d;
            assign FRAME_DONE = frame_done_reg;

            wire output_fire = active_output_valid && OUTPUT_READY;

            integer capture_lane;

            always @(posedge CLK or negedge RST) begin
                if (!RST) begin
                    group_count      <= {GROUP_COUNT_WIDTH{1'b0}};
                    frame_closed     <= 1'b0;
                    frame_done_reg   <= 1'b0;
                    hold_valid       <= 1'b0;
                    hold_group_index <= {GROUP_INDEX_WIDTH{1'b0}};
                    hold_x           <= {CROSSBAR_DIMENSION{1'b0}};
                    hold_d           <= {CROSSBAR_DIMENSION{1'b0}};
                end else begin
                    frame_done_reg <= 1'b0;

                    // Capture and update occur in one clock; no pending entry.
                    if (INPUT_VALID && !frame_closed) begin
                        if (INPUT_KEEP) begin
                            if (table_match_found) begin
                                for (capture_lane = 0;
                                     capture_lane < CROSSBAR_DIMENSION;
                                     capture_lane = capture_lane + 1) begin
                                    x_lane_counts[input_group_index]
                                        [capture_lane*X_COUNT_WIDTH +:
                                         X_COUNT_WIDTH] <=
                                    x_lane_counts[input_group_index]
                                        [capture_lane*X_COUNT_WIDTH +:
                                         X_COUNT_WIDTH] +
                                    X_PULSES_IN[capture_lane];
                                end
                            end else if (table_has_space) begin
                                d_patterns[input_group_index] <= D_PULSES_IN;
                                emitted_layers[input_group_index] <=
                                    {X_COUNT_WIDTH{1'b0}};

                                for (capture_lane = 0;
                                     capture_lane < CROSSBAR_DIMENSION;
                                     capture_lane = capture_lane + 1) begin
                                    x_lane_counts[input_group_index]
                                        [capture_lane*X_COUNT_WIDTH +:
                                         X_COUNT_WIDTH] <=
                                    {{(X_COUNT_WIDTH-1){1'b0}},
                                     X_PULSES_IN[capture_lane]};
                                end

                                group_count <= group_count + 1'b1;
                            end
                        end

                        if (INPUT_LAST)
                            frame_closed <= 1'b1;
                    end

                    // Every accepted output acknowledges exactly one unary
                    // layer for its group. Input increments and this scalar
                    // acknowledgement can safely occur in the same clock.
                    if (output_fire) begin
                        emitted_layers[active_group_index] <=
                            emitted_layers[active_group_index] + 1'b1;
                    end

                    // Capture a blocked combinational candidate so valid/data
                    // obey the ready/valid stability requirement.
                    if (!hold_valid && candidate_valid && !OUTPUT_READY) begin
                        hold_valid       <= 1'b1;
                        hold_group_index <= candidate_group_index;
                        hold_x           <= candidate_x;
                        hold_d           <= candidate_d;
                    end else if (hold_valid && OUTPUT_READY) begin
                        hold_valid <= 1'b0;
                    end

                    // Once the closed frame has no remaining layer and no held
                    // output, invalidate the densely allocated table at once.
                    if (frame_closed && !hold_valid && !candidate_valid) begin
                        group_count    <= {GROUP_COUNT_WIDTH{1'b0}};
                        frame_closed   <= 1'b0;
                        frame_done_reg <= 1'b1;
                    end
                end
            end
        end
    endgenerate

endmodule
