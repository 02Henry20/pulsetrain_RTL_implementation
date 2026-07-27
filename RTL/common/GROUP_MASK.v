// Groups cycles with identical complete D vectors, then emits unary X layers.
module GROUP_MASK #(
    parameter integer CROSSBAR_DIMENSION = 8, // Shared X and D lane count.
    parameter integer BIT_LENGTH = 32 // Maximum input cycles and distinct D groups per set.
) (
    input  wire                          CLK, // System clock.
    input  wire                          RST, // Active-low asynchronous reset.

    input  wire                          INPUT_VALID, // Current preprocessed X/D pair is valid.
    input  wire                          INPUT_KEEP, // Zero delete permits this pair to enter grouping.
    input  wire                          INPUT_LAST, // Current pair closes the input set.
    output wire                          INPUT_READY, // High while the complete set is being captured.
    input  wire [CROSSBAR_DIMENSION-1:0] X_PULSES_IN, // X bits added to the matching D-pattern counters.
    input  wire [CROSSBAR_DIMENSION-1:0] D_PULSES_IN, // Complete D vector used as the group key.

    output reg  [CROSSBAR_DIMENSION-1:0] X_PULSES_OUT, // Current unary layer of accumulated X counts.
    output reg  [CROSSBAR_DIMENSION-1:0] D_PULSES_OUT, // D pattern associated with the current X layer.
    output wire                          OUTPUT_VALID, // Current grouped layer is ready for transfer.
    input  wire                          OUTPUT_READY, // Downstream can accept the current layer.
    output reg                           FRAME_DONE // Pulses after the final grouped layer transfers.
);

    localparam STATE_CAPTURE = 1'b0;
    localparam STATE_DRAIN   = 1'b1;

    localparam integer GROUP_COUNT_WIDTH =
        (BIT_LENGTH <= 1) ? 1 : $clog2(BIT_LENGTH + 1);
    localparam integer GROUP_INDEX_WIDTH =
        (BIT_LENGTH <= 1) ? 1 : $clog2(BIT_LENGTH);
    localparam integer X_COUNT_WIDTH =
        (BIT_LENGTH <= 1) ? 1 : $clog2(BIT_LENGTH + 1);

    reg state;

    // Only valid slots participate in the parallel D-pattern lookup.
    reg [CROSSBAR_DIMENSION-1:0] d_patterns [0:BIT_LENGTH-1];
    reg [CROSSBAR_DIMENSION*X_COUNT_WIDTH-1:0]
        x_lane_counts [0:BIT_LENGTH-1];
    reg [BIT_LENGTH-1:0] group_valid;
    reg [GROUP_COUNT_WIDTH-1:0] group_count;

    // Drain exactly one group and one unary count layer at a time.
    reg [GROUP_INDEX_WIDTH-1:0] drain_group_index;
    reg [X_COUNT_WIDTH-1:0] drain_layer_index;

    // One pending entry separates pattern lookup from the shared counter adders.
    reg pending_valid;
    reg pending_keep;
    reg pending_last;
    reg input_closed;
    reg [CROSSBAR_DIMENSION-1:0] pending_x_pulses;
    reg [CROSSBAR_DIMENSION-1:0] pending_d_pattern;
    reg pending_match_found;
    reg [GROUP_INDEX_WIDTH-1:0] pending_group_index;

    // Stage 1 compares D against all valid groups and registers one target index.
    wire capture_lookup_enable =
        (state == STATE_CAPTURE) && !input_closed &&
        INPUT_VALID && INPUT_KEEP;
    wire [BIT_LENGTH-1:0] pattern_matches;

    genvar lookup_group;
    generate
        for (lookup_group = 0; lookup_group < BIT_LENGTH;
             lookup_group = lookup_group + 1) begin : GEN_PATTERN_MATCH
            assign pattern_matches[lookup_group] =
                capture_lookup_enable &&
                group_valid[lookup_group] &&
                (d_patterns[lookup_group] == D_PULSES_IN);
        end
    endgenerate

    // Convert the guaranteed one-hot match with balanced reduction trees.
    function [BIT_LENGTH-1:0] build_index_mask;
        input integer bit_position;
        integer mask_index;
        begin
            build_index_mask = {BIT_LENGTH{1'b0}};
            for (mask_index = 0; mask_index < BIT_LENGTH;
                 mask_index = mask_index + 1)
                build_index_mask[mask_index] =
                    (mask_index >> bit_position) & 1;
        end
    endfunction

    wire table_match_found = |pattern_matches;
    wire [GROUP_INDEX_WIDTH-1:0] table_match_index;

    genvar encode_bit;
    generate
        for (encode_bit = 0; encode_bit < GROUP_INDEX_WIDTH;
             encode_bit = encode_bit + 1) begin : GEN_MATCH_INDEX
            assign table_match_index[encode_bit] =
                |(pattern_matches & build_index_mask(encode_bit));
        end
    endgenerate

    // Forward a group allocated by the pending entry to a consecutive equal D.
    wire pending_allocates_new_group =
        pending_valid && pending_keep && !pending_match_found;
    wire pending_pattern_match =
        capture_lookup_enable && pending_allocates_new_group &&
        (pending_d_pattern == D_PULSES_IN);
    wire capture_match_found =
        table_match_found || pending_pattern_match;
    wire [GROUP_INDEX_WIDTH-1:0] capture_match_index =
        pending_pattern_match ? pending_group_index : table_match_index;
    wire [GROUP_INDEX_WIDTH-1:0] next_free_group_index =
        group_count[GROUP_INDEX_WIDTH-1:0] +
        pending_allocates_new_group;

    assign INPUT_READY = (state == STATE_CAPTURE) && !input_closed;
    assign OUTPUT_VALID = (state == STATE_DRAIN);

    wire capture_fire = INPUT_VALID && INPUT_READY;
    wire output_fire = OUTPUT_VALID && OUTPUT_READY;

    reg another_layer_available;
    integer output_lane;

    // Only the active group is inspected during drain.
    always @(*) begin
        X_PULSES_OUT = {CROSSBAR_DIMENSION{1'b0}};
        D_PULSES_OUT = {CROSSBAR_DIMENSION{1'b0}};
        another_layer_available = 1'b0;

        if (state == STATE_DRAIN) begin
            D_PULSES_OUT = d_patterns[drain_group_index];

            for (output_lane = 0;
                 output_lane < CROSSBAR_DIMENSION;
                 output_lane = output_lane + 1) begin
                X_PULSES_OUT[output_lane] =
                    x_lane_counts[drain_group_index]
                        [output_lane*X_COUNT_WIDTH +: X_COUNT_WIDTH] >
                    drain_layer_index;

                if (x_lane_counts[drain_group_index]
                        [output_lane*X_COUNT_WIDTH +: X_COUNT_WIDTH] >
                    (drain_layer_index + 1'b1)) begin
                    another_layer_available = 1'b1;
                end
            end
        end
    end

    integer capture_lane;

    always @(posedge CLK or negedge RST) begin
        if (!RST) begin
            state               <= STATE_CAPTURE;
            group_valid         <= {BIT_LENGTH{1'b0}};
            group_count         <= {GROUP_COUNT_WIDTH{1'b0}};
            drain_group_index   <= {GROUP_INDEX_WIDTH{1'b0}};
            drain_layer_index   <= {X_COUNT_WIDTH{1'b0}};
            pending_valid       <= 1'b0;
            pending_keep        <= 1'b0;
            pending_last        <= 1'b0;
            input_closed        <= 1'b0;
            pending_x_pulses    <= {CROSSBAR_DIMENSION{1'b0}};
            pending_d_pattern   <= {CROSSBAR_DIMENSION{1'b0}};
            pending_match_found <= 1'b0;
            pending_group_index <= {GROUP_INDEX_WIDTH{1'b0}};
            FRAME_DONE          <= 1'b0;
        end else begin
            FRAME_DONE <= 1'b0;

            if (state == STATE_CAPTURE) begin
                // Stage 2 commits the previous cycle's lookup result.
                if (pending_valid) begin
                    pending_valid <= 1'b0;

                    if (pending_keep) begin
                        if (pending_match_found) begin
                            // The encoded index selects only the eight shared adders.
                            for (capture_lane = 0;
                                 capture_lane < CROSSBAR_DIMENSION;
                                 capture_lane = capture_lane + 1) begin
                                x_lane_counts[pending_group_index]
                                    [capture_lane*X_COUNT_WIDTH +: X_COUNT_WIDTH]
                                    <=
                                x_lane_counts[pending_group_index]
                                    [capture_lane*X_COUNT_WIDTH +: X_COUNT_WIDTH]
                                    + pending_x_pulses[capture_lane];
                            end
                        end else begin
                            d_patterns[pending_group_index] <= pending_d_pattern;
                            group_valid[pending_group_index] <= 1'b1;

                            for (capture_lane = 0;
                                 capture_lane < CROSSBAR_DIMENSION;
                                 capture_lane = capture_lane + 1) begin
                                x_lane_counts[pending_group_index]
                                    [capture_lane*X_COUNT_WIDTH +: X_COUNT_WIDTH]
                                    <=
                                {{(X_COUNT_WIDTH-1){1'b0}},
                                 pending_x_pulses[capture_lane]};
                            end

                            group_count <= group_count + 1'b1;
                        end
                    end

                    if (pending_last) begin
                        input_closed <= 1'b0;
                        if ((group_count != {GROUP_COUNT_WIDTH{1'b0}}) ||
                            pending_keep) begin
                            // The committed final entry is visible when drain begins.
                            state             <= STATE_DRAIN;
                            drain_group_index <= {GROUP_INDEX_WIDTH{1'b0}};
                            drain_layer_index <= {X_COUNT_WIDTH{1'b0}};
                        end else begin
                            // Zero delete removed the entire set.
                            group_valid <= {BIT_LENGTH{1'b0}};
                            group_count <= {GROUP_COUNT_WIDTH{1'b0}};
                            FRAME_DONE  <= 1'b1;
                        end
                    end
                end

                // Stage 1 accepts one new pair every clock until INPUT_LAST.
                if (capture_fire) begin
                    pending_valid       <= 1'b1;
                    pending_keep        <= INPUT_KEEP;
                    pending_last        <= INPUT_LAST;
                    pending_x_pulses    <= X_PULSES_IN;
                    pending_d_pattern   <= D_PULSES_IN;
                    pending_match_found <= capture_match_found;
                    pending_group_index <= capture_match_found ?
                        capture_match_index : next_free_group_index;

                    if (INPUT_LAST)
                        input_closed <= 1'b1;
                end
            end else if (output_fire) begin
                if (another_layer_available) begin
                    drain_layer_index <= drain_layer_index + 1'b1;
                end else if (drain_group_index < (group_count - 1'b1)) begin
                    drain_group_index <= drain_group_index + 1'b1;
                    drain_layer_index <= {X_COUNT_WIDTH{1'b0}};
                end else begin
                    // The final layer was accepted; invalidate all stored groups at once.
                    state             <= STATE_CAPTURE;
                    group_valid       <= {BIT_LENGTH{1'b0}};
                    group_count       <= {GROUP_COUNT_WIDTH{1'b0}};
                    drain_group_index <= {GROUP_INDEX_WIDTH{1'b0}};
                    drain_layer_index <= {X_COUNT_WIDTH{1'b0}};
                    FRAME_DONE        <= 1'b1;
                end
            end
        end
    end

endmodule