// Group mask specialised for the temporally sorted D stream produced by SORT.
//
// After temporal sorting, every D lane changes only from 1 to 0. Therefore,
// equal D patterns occur in one contiguous run and a pattern never reappears
// after it changes. This implementation exploits that property and keeps only
// one active group instead of a multi-entry associative/direct-address table.
//
// For each contiguous D-pattern run, X pulses are accumulated per lane. When
// the D pattern changes, or the frame ends, the accumulated counts are emitted
// as unary layers. This preserves the coincidence matrix while substantially
// reducing storage, decode, mux, and high-fanout logic versus GROUP_MASK.
module GROUP_MASK_AFTER_SORTED #(
    parameter integer CROSSBAR_DIMENSION = 8,
    parameter integer BIT_LENGTH = 8
) (
    input  wire                          CLK,
    input  wire                          RST, // Active-low asynchronous reset.

    input  wire                          INPUT_VALID,
    input  wire                          INPUT_KEEP,
    input  wire                          INPUT_LAST,
    output wire                          INPUT_READY,
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
        if (BIT_LENGTH > GROUP_MASK_BIT_LENGTH_LIMIT) begin : GEN_BYPASS
            assign X_PULSES_OUT = X_PULSES_IN;
            assign D_PULSES_OUT = D_PULSES_IN;
            assign OUTPUT_VALID = INPUT_VALID && INPUT_KEEP;
            assign INPUT_READY  = !INPUT_VALID || !INPUT_KEEP || OUTPUT_READY;
            assign FRAME_DONE   = INPUT_VALID && INPUT_LAST &&
                                  (!INPUT_KEEP || OUTPUT_READY);
        end else begin : GEN_SORTED_RUN_GROUPING
            localparam integer X_COUNT_WIDTH =
                (BIT_LENGTH <= 1) ? 1 : $clog2(BIT_LENGTH + 1);

            localparam STATE_COLLECT = 1'b0;
            localparam STATE_FLUSH   = 1'b1;

            reg state;
            reg group_active;
            reg frame_closed;
            reg frame_done_reg;

            reg [CROSSBAR_DIMENSION-1:0] current_d_pattern;
            reg [CROSSBAR_DIMENSION*X_COUNT_WIDTH-1:0] x_lane_counts;
            reg [X_COUNT_WIDTH-1:0] emitted_layer;

            // A different kept D pattern marks the end of the current sorted
            // run. The waiting input remains stable while the old run flushes.
            wire pattern_change =
                (state == STATE_COLLECT) &&
                INPUT_VALID && INPUT_KEEP && group_active &&
                (D_PULSES_IN != current_d_pattern);

            // During a pattern-change cycle, begin flushing immediately instead
            // of spending an extra state-transition bubble.
            wire flush_active = (state == STATE_FLUSH) || pattern_change;

            reg [CROSSBAR_DIMENSION-1:0] layer_x;
            reg layer_available;
            reg more_layers_after_current;
            reg [X_COUNT_WIDTH-1:0] next_emitted_layer;

            integer output_lane;
            always @(*) begin
                layer_x                  = {CROSSBAR_DIMENSION{1'b0}};
                layer_available          = 1'b0;
                more_layers_after_current = 1'b0;
                next_emitted_layer       = emitted_layer + 1'b1;

                for (output_lane = 0;
                     output_lane < CROSSBAR_DIMENSION;
                     output_lane = output_lane + 1) begin
                    if (x_lane_counts[
                            output_lane*X_COUNT_WIDTH +: X_COUNT_WIDTH] >
                        emitted_layer) begin
                        layer_x[output_lane] = 1'b1;
                        layer_available = 1'b1;
                    end

                    if (x_lane_counts[
                            output_lane*X_COUNT_WIDTH +: X_COUNT_WIDTH] >
                        next_emitted_layer) begin
                        more_layers_after_current = 1'b1;
                    end
                end
            end

            assign INPUT_READY = (state == STATE_COLLECT) && !pattern_change;

            assign OUTPUT_VALID =
                flush_active && group_active && layer_available;
            assign X_PULSES_OUT = OUTPUT_VALID ?
                layer_x : {CROSSBAR_DIMENSION{1'b0}};
            assign D_PULSES_OUT = OUTPUT_VALID ?
                current_d_pattern : {CROSSBAR_DIMENSION{1'b0}};
            assign FRAME_DONE = frame_done_reg;

            wire input_fire  = INPUT_VALID && INPUT_READY;
            wire output_fire = OUTPUT_VALID && OUTPUT_READY;

            integer capture_lane;

            always @(posedge CLK or negedge RST) begin
                if (!RST) begin
                    state             <= STATE_COLLECT;
                    group_active      <= 1'b0;
                    frame_closed      <= 1'b0;
                    frame_done_reg    <= 1'b0;
                    current_d_pattern <= {CROSSBAR_DIMENSION{1'b0}};
                    x_lane_counts     <= {
                        (CROSSBAR_DIMENSION*X_COUNT_WIDTH){1'b0}};
                    emitted_layer     <= {X_COUNT_WIDTH{1'b0}};
                end else begin
                    frame_done_reg <= 1'b0;

                    if (flush_active) begin
                        // While flushing, the current group state is stable
                        // unless one output layer is accepted.
                        if (group_active && layer_available) begin
                            if (output_fire) begin
                                if (more_layers_after_current) begin
                                    emitted_layer <= emitted_layer + 1'b1;
                                    state <= STATE_FLUSH;
                                end else begin
                                    // Final unary layer of this sorted run.
                                    group_active  <= 1'b0;
                                    emitted_layer <= {X_COUNT_WIDTH{1'b0}};
                                    x_lane_counts <= {
                                        (CROSSBAR_DIMENSION*X_COUNT_WIDTH){1'b0}};
                                    state <= STATE_COLLECT;

                                    if (frame_closed) begin
                                        frame_closed   <= 1'b0;
                                        frame_done_reg <= 1'b1;
                                    end
                                end
                            end else begin
                                state <= STATE_FLUSH;
                            end
                        end else begin
                            // A kept row can still contain no X pulses when
                            // zero deletion is disabled. Such a group has no
                            // layer to emit and is completed immediately.
                            group_active  <= 1'b0;
                            emitted_layer <= {X_COUNT_WIDTH{1'b0}};
                            x_lane_counts <= {
                                (CROSSBAR_DIMENSION*X_COUNT_WIDTH){1'b0}};
                            state <= STATE_COLLECT;

                            if (frame_closed) begin
                                frame_closed   <= 1'b0;
                                frame_done_reg <= 1'b1;
                            end
                        end
                    end else if (input_fire) begin
                        if (INPUT_KEEP) begin
                            if (!group_active) begin
                                group_active      <= 1'b1;
                                current_d_pattern <= D_PULSES_IN;
                                emitted_layer     <= {X_COUNT_WIDTH{1'b0}};

                                for (capture_lane = 0;
                                     capture_lane < CROSSBAR_DIMENSION;
                                     capture_lane = capture_lane + 1) begin
                                    x_lane_counts[
                                        capture_lane*X_COUNT_WIDTH +:
                                        X_COUNT_WIDTH] <=
                                        {{(X_COUNT_WIDTH-1){1'b0}},
                                         X_PULSES_IN[capture_lane]};
                                end
                            end else begin
                                // INPUT_READY guarantees that a kept input can
                                // only reach this branch when its D pattern is
                                // equal to the active sorted run.
                                for (capture_lane = 0;
                                     capture_lane < CROSSBAR_DIMENSION;
                                     capture_lane = capture_lane + 1) begin
                                    x_lane_counts[
                                        capture_lane*X_COUNT_WIDTH +:
                                        X_COUNT_WIDTH] <=
                                    x_lane_counts[
                                        capture_lane*X_COUNT_WIDTH +:
                                        X_COUNT_WIDTH] +
                                    X_PULSES_IN[capture_lane];
                                end
                            end
                        end

                        if (INPUT_LAST) begin
                            if (INPUT_KEEP || group_active) begin
                                // Counts written in this clock are visible when
                                // flushing begins on the next clock.
                                frame_closed <= 1'b1;
                                state        <= STATE_FLUSH;
                            end else begin
                                // Entire frame contained no kept group.
                                frame_done_reg <= 1'b1;
                            end
                        end
                    end
                end
            end
        end
    endgenerate

endmodule
