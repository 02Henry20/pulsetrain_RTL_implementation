// Square crossbar model: X and D vectors share CROSSBAR_DIMENSION lanes.
module ARCH_TOP #(
    parameter integer CROSSBAR_DIMENSION = 8, // Shared X-input and D-output lane count.
    parameter integer BIT_LENGTH = 8, // Accepted pulse cycles in one complete train set.
    parameter integer STOCHASTIC_VALUE_WIDTH = 16, // Bits per unsigned normalized fixed-point value.
    parameter integer OUTPUT_BUFFER_DEPTH = 10, // Number of queued pulse-vector pairs.
    parameter integer USE_SHARED_LFSR = 0, // 1: one shared internal LFSR; 0: separate internal LFSRs per X/D lane.
    parameter integer ENABLE_D_SORT = 0, // Temporally front-load each D lane while preserving X order.
    parameter integer ENABLE_ZERO_DELETE = 0, // Remove processed cycles with no X or no D pulse.
    parameter integer ENABLE_D_GROUP_MASK = 0, // 0: disabled; 1: use sort-specialised grouping when sorted; 2: always use generic grouping.
    parameter [STOCHASTIC_VALUE_WIDTH-1:0] LFSR_SEED = 16'hACE1 // Nonzero initial LFSR state.
) (
    input  wire                              CLK, // System clock.
    input  wire                              RST, // Active-low asynchronous reset.

    input  wire                              INPUT_VALID, // Current X/D values are valid.
    input  wire [CROSSBAR_DIMENSION*STOCHASTIC_VALUE_WIDTH-1:0] X_INPUT_VALUES, // Packed normalized X values in [0,1].
    input  wire [CROSSBAR_DIMENSION*STOCHASTIC_VALUE_WIDTH-1:0] D_INPUT_VALUES, // Packed normalized D values in [0,1].
    // Retained for drop-in compatibility with the existing testbench/top wrapper.
    // Both architecture modes now generate their random values internally.
    input  wire [CROSSBAR_DIMENSION*STOCHASTIC_VALUE_WIDTH-1:0] X_RANDOM_VALUES, // Unused legacy input.
    input  wire [CROSSBAR_DIMENSION*STOCHASTIC_VALUE_WIDTH-1:0] D_RANDOM_VALUES, // Unused legacy input.

    input  wire                              PULSE_DONE, // Consumer accepted the current output pair.

    output wire [CROSSBAR_DIMENSION-1:0]     X_PULSES_OUT, // Buffered X pulse vector.
    output wire [CROSSBAR_DIMENSION-1:0]     D_PULSES_OUT, // Buffered D pulse vector.
    output wire                              VALID_OUT, // Output pair is valid.
    output wire                              READY_IN, // Current set cycle can be accepted; low while draining.
    output wire                              BUFFER_FULL, // Output FIFO is full.
    output wire                              FRAME_DONE // Complete set has been consumed by the output interface.
);

    wire [CROSSBAR_DIMENSION-1:0] x_pulses_generated;
    wire [CROSSBAR_DIMENSION-1:0] d_pulses_generated;
    genvar random_lane;

    // Elaborate one of two complete internal random-source architectures:
    //   USE_SHARED_LFSR = 1: one LFSR shared by all X lanes; D receives the
    //                        same sequence delayed by two accepted cycles.
    //   USE_SHARED_LFSR = 0: one LFSR per X lane and one LFSR per D lane.
    // The legacy X_RANDOM_VALUES/D_RANDOM_VALUES ports are intentionally unused.
    generate
        if (USE_SHARED_LFSR) begin : GEN_SHARED_LFSR_PULSE_GENERATION
            wire [STOCHASTIC_VALUE_WIDTH-1:0] lfsr_value;
            reg  [STOCHASTIC_VALUE_WIDTH-1:0] d_lfsr_delay_1;
            reg  [STOCHASTIC_VALUE_WIDTH-1:0] d_lfsr_delay_2;

            LFSR #(
                .WIDTH(STOCHASTIC_VALUE_WIDTH),
                .SEED (LFSR_SEED)
            ) shared_lfsr (
                .CLK   (CLK),
                .RST   (RST),
                .ENABLE(INPUT_VALID && READY_IN),
                .VALUE (lfsr_value)
            );

            // D uses the shared LFSR sequence delayed by exactly two
            // accepted input cycles.
            always @(posedge CLK or negedge RST) begin
                if (!RST) begin
                    d_lfsr_delay_1 <= LFSR_SEED;
                    d_lfsr_delay_2 <= LFSR_SEED;
                end else if (INPUT_VALID && READY_IN) begin
                    d_lfsr_delay_1 <= lfsr_value;
                    d_lfsr_delay_2 <= d_lfsr_delay_1;
                end
            end

            PULSE_GENERATOR_LFSR #(
                .CROSSBAR_DIMENSION    (CROSSBAR_DIMENSION),
                .STOCHASTIC_VALUE_WIDTH(STOCHASTIC_VALUE_WIDTH)
            ) pulse_generator_x (
                .LFSR_VALUE  (lfsr_value),
                .INPUT_VALUES(X_INPUT_VALUES),
                .PULSES      (x_pulses_generated)
            );

            PULSE_GENERATOR_LFSR #(
                .CROSSBAR_DIMENSION    (CROSSBAR_DIMENSION),
                .STOCHASTIC_VALUE_WIDTH(STOCHASTIC_VALUE_WIDTH)
            ) pulse_generator_d (
                .LFSR_VALUE  (d_lfsr_delay_2),
                .INPUT_VALUES(D_INPUT_VALUES),
                .PULSES      (d_pulses_generated)
            );
        end else begin : GEN_INDEPENDENT_LFSR_PULSE_GENERATION
            wire [CROSSBAR_DIMENSION*STOCHASTIC_VALUE_WIDTH-1:0]
                x_random_values_internal;
            wire [CROSSBAR_DIMENSION*STOCHASTIC_VALUE_WIDTH-1:0]
                d_random_values_internal;

            for (random_lane = 0;
                 random_lane < CROSSBAR_DIMENSION;
                 random_lane = random_lane + 1) begin : GEN_LANE_RANDOM_SOURCES

                // Every X and D lane receives a separate LFSR instance.
                // Different nonzero seeds avoid all instances starting in
                // the same sequence phase. Constant arithmetic is evaluated
                // at elaboration and therefore adds no runtime hardware.
                localparam [STOCHASTIC_VALUE_WIDTH-1:0] X_SEED_RAW =
                    LFSR_SEED ^ ((2*random_lane + 1) * 32'h9E37_79B9);
                localparam [STOCHASTIC_VALUE_WIDTH-1:0] D_SEED_RAW =
                    LFSR_SEED ^ ((2*random_lane + 2) * 32'h7F4A_7C15);
                localparam [STOCHASTIC_VALUE_WIDTH-1:0] X_LANE_SEED =
                    (X_SEED_RAW == {STOCHASTIC_VALUE_WIDTH{1'b0}}) ?
                    {{(STOCHASTIC_VALUE_WIDTH-1){1'b0}}, 1'b1} :
                    X_SEED_RAW;
                localparam [STOCHASTIC_VALUE_WIDTH-1:0] D_LANE_SEED =
                    (D_SEED_RAW == {STOCHASTIC_VALUE_WIDTH{1'b0}}) ?
                    {{(STOCHASTIC_VALUE_WIDTH-1){1'b0}}, 1'b1} :
                    D_SEED_RAW;

                LFSR #(
                    .WIDTH(STOCHASTIC_VALUE_WIDTH),
                    .SEED (X_LANE_SEED)
                ) x_lane_lfsr (
                    .CLK   (CLK),
                    .RST   (RST),
                    .ENABLE(INPUT_VALID && READY_IN),
                    .VALUE (x_random_values_internal[
                        random_lane*STOCHASTIC_VALUE_WIDTH +:
                        STOCHASTIC_VALUE_WIDTH])
                );

                LFSR #(
                    .WIDTH(STOCHASTIC_VALUE_WIDTH),
                    .SEED (D_LANE_SEED)
                ) d_lane_lfsr (
                    .CLK   (CLK),
                    .RST   (RST),
                    .ENABLE(INPUT_VALID && READY_IN),
                    .VALUE (d_random_values_internal[
                        random_lane*STOCHASTIC_VALUE_WIDTH +:
                        STOCHASTIC_VALUE_WIDTH])
                );
            end

            PULSE_GENERATOR #(
                .CROSSBAR_DIMENSION    (CROSSBAR_DIMENSION),
                .STOCHASTIC_VALUE_WIDTH(STOCHASTIC_VALUE_WIDTH)
            ) pulse_generator_x (
                .RANDOM_VALUES(x_random_values_internal),
                .INPUT_VALUES (X_INPUT_VALUES),
                .PULSES       (x_pulses_generated)
            );

            PULSE_GENERATOR #(
                .CROSSBAR_DIMENSION    (CROSSBAR_DIMENSION),
                .STOCHASTIC_VALUE_WIDTH(STOCHASTIC_VALUE_WIDTH)
            ) pulse_generator_d (
                .RANDOM_VALUES(d_random_values_internal),
                .INPUT_VALUES (D_INPUT_VALUES),
                .PULSES       (d_pulses_generated)
            );
        end
    endgenerate

    // One set is accepted, processed, and fully consumed before the next set.
    // This gate also keeps a ready sorter idle while grouping or FIFO drain continues.
    localparam integer SOURCE_INDEX_WIDTH =
        (BIT_LENGTH <= 1) ? 1 : $clog2(BIT_LENGTH);
    localparam [SOURCE_INDEX_WIDTH-1:0] LAST_SOURCE_INDEX =
        BIT_LENGTH - 1;

    reg  [SOURCE_INDEX_WIDTH-1:0] source_index;
    reg                           source_set_captured;
    reg                           preprocessing_complete;
    reg                           frame_done_reg;
    // Prevent a deleted final position from shortening direct-path frame
    // completion by one cycle relative to an otherwise identical kept item.
    reg                           deleted_last_tail_wait;

    wire                          source_path_ready;
    wire                          source_input_valid =
        INPUT_VALID && !source_set_captured;
    wire                          source_last =
        (source_index == LAST_SOURCE_INDEX);
    wire                          source_fire =
        source_input_valid && source_path_ready;
    wire                          preprocessing_frame_done;

    always @(posedge CLK or negedge RST) begin
        if (!RST) begin
            source_index <= {SOURCE_INDEX_WIDTH{1'b0}};
        end else if (source_fire) begin
            if (source_last)
                source_index <= {SOURCE_INDEX_WIDTH{1'b0}};
            else
                source_index <= source_index + 1'b1;
        end
    end

    assign READY_IN = source_path_ready && !source_set_captured;
    assign FRAME_DONE = frame_done_reg;

    wire [CROSSBAR_DIMENSION-1:0] x_pulses_preprocessed;
    wire [CROSSBAR_DIMENSION-1:0] d_pulses_preprocessed;
    wire                          preprocess_valid;
    wire                          preprocess_last;
    wire                          preprocess_ready;

    // SORT buffers X unchanged and temporally front-loads each individual D lane.
    generate
        if (ENABLE_D_SORT) begin : GEN_TEMPORAL_D_SORT
            SORT #(
                .CROSSBAR_DIMENSION(CROSSBAR_DIMENSION),
                .BIT_LENGTH       (BIT_LENGTH)
            ) sort_d (
                .CLK          (CLK),
                .RST          (RST),
                .INPUT_VALID  (source_input_valid),
                .INPUT_LAST   (source_last),
                .INPUT_READY  (source_path_ready),
                .X_PULSES_IN  (x_pulses_generated),
                .D_PULSES_IN  (d_pulses_generated),
                .X_PULSES_OUT (x_pulses_preprocessed),
                .D_PULSES_OUT (d_pulses_preprocessed),
                .OUTPUT_VALID (preprocess_valid),
                .OUTPUT_LAST  (preprocess_last),
                .OUTPUT_READY (preprocess_ready)
            );
        end else begin : GEN_NO_D_SORT
            assign x_pulses_preprocessed = x_pulses_generated;
            assign d_pulses_preprocessed = d_pulses_generated;
            assign preprocess_valid      = source_input_valid;
            assign preprocess_last       = source_last;
            assign source_path_ready     = preprocess_ready;
        end
    endgenerate

    // Zero delete examines the processed pair before group-table activity.
    wire keep_preprocessed_pair;

    generate
        if (ENABLE_ZERO_DELETE) begin : GEN_ZERO_DELETE
            ZERO_DELETE #(
                .CROSSBAR_DIMENSION(CROSSBAR_DIMENSION)
            ) zero_delete (
                .X_PULSES_IN(x_pulses_preprocessed),
                .D_PULSES_IN(d_pulses_preprocessed),
                .KEEP_ITEM  (keep_preprocessed_pair)
            );
        end else begin : GEN_NO_ZERO_DELETE
            assign keep_preprocessed_pair = 1'b1;
        end
    endgenerate

    wire [CROSSBAR_DIMENSION-1:0] x_pulses_to_buffer;
    wire [CROSSBAR_DIMENSION-1:0] d_pulses_to_buffer;
    wire                          pulse_pair_valid;
    wire                          output_buffer_ready;
    generate
        if (ENABLE_D_GROUP_MASK != 0) begin : GEN_D_PATTERN_GROUPING
            wire group_input_ready;
            wire group_output_valid;
            wire group_frame_done;

            // Mode 1 uses the smaller specialised grouper after sorting.
            // Mode 2 deliberately keeps the generic full-pattern grouper,
            // even when D sorting is enabled.
            if (ENABLE_D_SORT && (ENABLE_D_GROUP_MASK == 1)) begin : GEN_GROUP_MASK_AFTER_SORTED
                GROUP_MASK_AFTER_SORTED #(
                    .CROSSBAR_DIMENSION(CROSSBAR_DIMENSION),
                    .BIT_LENGTH       (BIT_LENGTH)
                ) group_mask_after_sorted (
                    .CLK          (CLK),
                    .RST          (RST),
                    .INPUT_VALID  (preprocess_valid),
                    .INPUT_KEEP   (keep_preprocessed_pair),
                    .INPUT_LAST   (preprocess_last),
                    .INPUT_READY  (group_input_ready),
                    .X_PULSES_IN  (x_pulses_preprocessed),
                    .D_PULSES_IN  (d_pulses_preprocessed),
                    .X_PULSES_OUT (x_pulses_to_buffer),
                    .D_PULSES_OUT (d_pulses_to_buffer),
                    .OUTPUT_VALID (group_output_valid),
                    .OUTPUT_READY (output_buffer_ready),
                    .FRAME_DONE   (group_frame_done)
                );
            end else begin : GEN_GENERIC_GROUP_MASK
                GROUP_MASK #(
                    .CROSSBAR_DIMENSION(CROSSBAR_DIMENSION),
                    .BIT_LENGTH       (BIT_LENGTH)
                ) group_mask (
                    .CLK          (CLK),
                    .RST          (RST),
                    .INPUT_VALID  (preprocess_valid),
                    .INPUT_KEEP   (keep_preprocessed_pair),
                    .INPUT_LAST   (preprocess_last),
                    .INPUT_READY  (group_input_ready),
                    .X_PULSES_IN  (x_pulses_preprocessed),
                    .D_PULSES_IN  (d_pulses_preprocessed),
                    .X_PULSES_OUT (x_pulses_to_buffer),
                    .D_PULSES_OUT (d_pulses_to_buffer),
                    .OUTPUT_VALID (group_output_valid),
                    .OUTPUT_READY (output_buffer_ready),
                    .FRAME_DONE   (group_frame_done)
                );
            end

            assign preprocess_ready         = group_input_ready;
            assign pulse_pair_valid         = group_output_valid;
            assign preprocessing_frame_done = group_frame_done;
        end else begin : GEN_DIRECT_TO_BUFFER
            assign x_pulses_to_buffer = x_pulses_preprocessed;
            assign d_pulses_to_buffer = d_pulses_preprocessed;
            assign pulse_pair_valid   =
                preprocess_valid && keep_preprocessed_pair;

            // A deleted pair consumes no FIFO entry, even if the FIFO is full.
            assign preprocess_ready =
                output_buffer_ready ||
                (preprocess_valid && !keep_preprocessed_pair);

            assign preprocessing_frame_done =
                preprocess_valid && preprocess_ready && preprocess_last;
        end
    endgenerate

    // In the non-grouped path, a deleted final item does not enter the FIFO.
    // Without a tail barrier, FRAME_DONE could therefore assert one cycle
    // earlier than for the same frame with a retained final item.  That would
    // make zero deletion appear to reduce digital processing latency even
    // though every source position is still examined.
    wire direct_last_item_deleted =
        (ENABLE_D_GROUP_MASK == 0) &&
        preprocess_valid && preprocess_ready && preprocess_last &&
        !keep_preprocessed_pair;

    OUTPUT_BUFFER #(
        .CROSSBAR_DIMENSION (CROSSBAR_DIMENSION),
        .OUTPUT_BUFFER_DEPTH(OUTPUT_BUFFER_DEPTH)
    ) output_buffer (
        .CLK         (CLK),
        .RST         (RST),

        .X_PULSES_IN (x_pulses_to_buffer),
        .D_PULSES_IN (d_pulses_to_buffer),
        .VALID_IN    (pulse_pair_valid),

        .X_PULSES_OUT(X_PULSES_OUT),
        .D_PULSES_OUT(D_PULSES_OUT),
        .VALID_OUT   (VALID_OUT),
        .READY_IN    (output_buffer_ready),
        .FULL        (BUFFER_FULL),

        .PULSE_DONE  (PULSE_DONE)
    );

    // Release the set only after preprocessing is done and the FIFO is empty.
    always @(posedge CLK or negedge RST) begin
        if (!RST) begin
            source_set_captured    <= 1'b0;
            preprocessing_complete <= 1'b0;
            frame_done_reg         <= 1'b0;
            deleted_last_tail_wait <= 1'b0;
        end else begin
            frame_done_reg <= 1'b0;

            if (source_fire && source_last)
                source_set_captured <= 1'b1;

            if (preprocessing_frame_done)
                preprocessing_complete <= 1'b1;

            // Emulate the one-cycle FIFO tail that a retained final item would
            // create. This keeps the direct-path digital frame latency fixed
            // whether ZERO_DELETE keeps or removes the last source position.
            if (direct_last_item_deleted)
                deleted_last_tail_wait <= 1'b1;
            else if (deleted_last_tail_wait)
                deleted_last_tail_wait <= 1'b0;

            if (preprocessing_complete && !VALID_OUT &&
                !deleted_last_tail_wait) begin
                // FIFO count zero makes any old memory contents unreachable.
                source_set_captured    <= 1'b0;
                preprocessing_complete <= 1'b0;
                frame_done_reg         <= 1'b1;
                deleted_last_tail_wait <= 1'b0;
            end
        end
    end
endmodule