// Canonical stochastic pulse-train datapath used by every paper architecture.
module ARCH_TOP #(
    parameter integer CROSSBAR_DIMENSION = 8,
    parameter integer MAX_BL = 32,
    parameter integer BL_WIDTH = (MAX_BL <= 1) ? 1 : $clog2(MAX_BL + 1),
    parameter integer STOCHASTIC_VALUE_WIDTH = 16,
    parameter integer OUTPUT_BUFFER_DEPTH = 10,
    parameter integer RAW_REPLAY_MODE = 0,
    parameter integer USE_SHARED_LFSR = 0,
    parameter integer ENABLE_D_SORT = 0,
    parameter integer ENABLE_ZERO_DELETE = 0,
    parameter integer ENABLE_D_GROUP_MASK = 0,
    parameter [STOCHASTIC_VALUE_WIDTH-1:0] LFSR_SEED = 16'hACE1
) (
    input  wire CLK,
    input  wire RST,
    input  wire INPUT_VALID,
    input  wire [BL_WIDTH-1:0] INPUT_BL,
    input  wire [CROSSBAR_DIMENSION*STOCHASTIC_VALUE_WIDTH-1:0] X_INPUT_VALUES,
    input  wire [CROSSBAR_DIMENSION*STOCHASTIC_VALUE_WIDTH-1:0] D_INPUT_VALUES,
    input  wire [CROSSBAR_DIMENSION-1:0] X_RAW_PULSES_IN,
    input  wire [CROSSBAR_DIMENSION-1:0] D_RAW_PULSES_IN,
    input  wire OUTPUT_READY,
    output wire [CROSSBAR_DIMENSION-1:0] X_PULSES_OUT,
    output wire [CROSSBAR_DIMENSION-1:0] D_PULSES_OUT,
    output wire VALID_OUT,
    output wire READY_IN,
    output wire BUFFER_FULL,
    output wire [((OUTPUT_BUFFER_DEPTH <= 1) ? 1 : $clog2(OUTPUT_BUFFER_DEPTH + 1))-1:0] BUFFER_OCCUPANCY,
    output wire GROUP_MASK_BYPASS,
    output wire FRAME_DONE
);

    localparam integer SOURCE_INDEX_WIDTH =
        (MAX_BL <= 1) ? 1 : $clog2(MAX_BL);

    reg [SOURCE_INDEX_WIDTH-1:0] source_index;
    reg source_set_captured;
    reg preprocessing_complete;
    reg frame_done_reg;
    reg deleted_last_tail_wait;

    wire source_path_ready;
    wire source_input_valid = INPUT_VALID && !source_set_captured;
    wire source_last = (source_index == (INPUT_BL - 1'b1));
    wire source_fire = source_input_valid && source_path_ready;
    wire preprocessing_frame_done;

    assign READY_IN = source_path_ready && !source_set_captured;
    assign FRAME_DONE = frame_done_reg;
    assign GROUP_MASK_BYPASS =
        (ENABLE_D_GROUP_MASK != 0) && (INPUT_BL > 8);

    always @(posedge CLK or negedge RST) begin
        if (!RST)
            source_index <= {SOURCE_INDEX_WIDTH{1'b0}};
        else if (source_fire) begin
            if (source_last)
                source_index <= {SOURCE_INDEX_WIDTH{1'b0}};
            else
                source_index <= source_index + 1'b1;
        end
    end

    wire [CROSSBAR_DIMENSION-1:0] x_pulses_generated;
    wire [CROSSBAR_DIMENSION-1:0] d_pulses_generated;
    genvar random_lane;

    // Shared mode contains exactly one LFSR. X sees its current word and D sees
    // the same sequence two accepted candidate positions later. The two reset
    // history words are deterministic and deliberately distinct from the seed.
    generate
        if (RAW_REPLAY_MODE != 0) begin : GEN_RAW_REPLAY
            assign x_pulses_generated = X_RAW_PULSES_IN;
            assign d_pulses_generated = D_RAW_PULSES_IN;
        end else if (USE_SHARED_LFSR) begin : GEN_SHARED_LFSR
            wire [STOCHASTIC_VALUE_WIDTH-1:0] lfsr_value;
            reg  [STOCHASTIC_VALUE_WIDTH-1:0] d_delay_1;
            reg  [STOCHASTIC_VALUE_WIDTH-1:0] d_delay_2;
            localparam [STOCHASTIC_VALUE_WIDTH-1:0] D_HISTORY_1 =
                LFSR_SEED ^ 32'h0000_0001;
            localparam [STOCHASTIC_VALUE_WIDTH-1:0] D_HISTORY_2 =
                LFSR_SEED ^ 32'h0000_0002;

            LFSR #(.WIDTH(STOCHASTIC_VALUE_WIDTH), .SEED(LFSR_SEED)) shared_lfsr (
                .CLK(CLK), .RST(RST), .ENABLE(source_fire), .VALUE(lfsr_value)
            );

            always @(posedge CLK or negedge RST) begin
                if (!RST) begin
                    d_delay_1 <= (D_HISTORY_1 == 0) ? {{(STOCHASTIC_VALUE_WIDTH-1){1'b0}}, 1'b1} : D_HISTORY_1;
                    d_delay_2 <= (D_HISTORY_2 == 0) ? {STOCHASTIC_VALUE_WIDTH{1'b1}} : D_HISTORY_2;
                end else if (source_fire) begin
                    d_delay_1 <= lfsr_value;
                    d_delay_2 <= d_delay_1;
                end
            end

            PULSE_GENERATOR_LFSR #(
                .CROSSBAR_DIMENSION(CROSSBAR_DIMENSION),
                .STOCHASTIC_VALUE_WIDTH(STOCHASTIC_VALUE_WIDTH)
            ) pulse_generator_x (
                .LFSR_VALUE(lfsr_value), .INPUT_VALUES(X_INPUT_VALUES),
                .PULSES(x_pulses_generated)
            );
            PULSE_GENERATOR_LFSR #(
                .CROSSBAR_DIMENSION(CROSSBAR_DIMENSION),
                .STOCHASTIC_VALUE_WIDTH(STOCHASTIC_VALUE_WIDTH)
            ) pulse_generator_d (
                .LFSR_VALUE(d_delay_2), .INPUT_VALUES(D_INPUT_VALUES),
                .PULSES(d_pulses_generated)
            );
        end else begin : GEN_PER_INPUT_LFSRS
            wire [CROSSBAR_DIMENSION*STOCHASTIC_VALUE_WIDTH-1:0] x_random_values;
            wire [CROSSBAR_DIMENSION*STOCHASTIC_VALUE_WIDTH-1:0] d_random_values;

            for (random_lane = 0; random_lane < CROSSBAR_DIMENSION;
                 random_lane = random_lane + 1) begin : GEN_LANE_LFSRS
                localparam [STOCHASTIC_VALUE_WIDTH-1:0] X_SEED_RAW =
                    LFSR_SEED ^ ((2*random_lane + 1) * 32'h9E37_79B9);
                localparam [STOCHASTIC_VALUE_WIDTH-1:0] D_SEED_RAW =
                    LFSR_SEED ^ ((2*random_lane + 2) * 32'h7F4A_7C15);
                localparam [STOCHASTIC_VALUE_WIDTH-1:0] X_SEED =
                    (X_SEED_RAW == 0) ? (random_lane + 1) : X_SEED_RAW;
                localparam [STOCHASTIC_VALUE_WIDTH-1:0] D_SEED =
                    (D_SEED_RAW == 0) ? (CROSSBAR_DIMENSION + random_lane + 1) : D_SEED_RAW;

                LFSR #(.WIDTH(STOCHASTIC_VALUE_WIDTH), .SEED(X_SEED)) x_lfsr (
                    .CLK(CLK), .RST(RST), .ENABLE(source_fire),
                    .VALUE(x_random_values[random_lane*STOCHASTIC_VALUE_WIDTH +: STOCHASTIC_VALUE_WIDTH])
                );
                LFSR #(.WIDTH(STOCHASTIC_VALUE_WIDTH), .SEED(D_SEED)) d_lfsr (
                    .CLK(CLK), .RST(RST), .ENABLE(source_fire),
                    .VALUE(d_random_values[random_lane*STOCHASTIC_VALUE_WIDTH +: STOCHASTIC_VALUE_WIDTH])
                );
            end

            PULSE_GENERATOR #(
                .CROSSBAR_DIMENSION(CROSSBAR_DIMENSION),
                .STOCHASTIC_VALUE_WIDTH(STOCHASTIC_VALUE_WIDTH)
            ) pulse_generator_x (
                .RANDOM_VALUES(x_random_values), .INPUT_VALUES(X_INPUT_VALUES),
                .PULSES(x_pulses_generated)
            );
            PULSE_GENERATOR #(
                .CROSSBAR_DIMENSION(CROSSBAR_DIMENSION),
                .STOCHASTIC_VALUE_WIDTH(STOCHASTIC_VALUE_WIDTH)
            ) pulse_generator_d (
                .RANDOM_VALUES(d_random_values), .INPUT_VALUES(D_INPUT_VALUES),
                .PULSES(d_pulses_generated)
            );
        end
    endgenerate

    wire [CROSSBAR_DIMENSION-1:0] x_pulses_preprocessed;
    wire [CROSSBAR_DIMENSION-1:0] d_pulses_preprocessed;
    wire preprocess_valid;
    wire preprocess_last;
    wire preprocess_ready;

    generate
        if (ENABLE_D_SORT) begin : GEN_SORT
            SORT #(.CROSSBAR_DIMENSION(CROSSBAR_DIMENSION), .MAX_BL(MAX_BL)) sort_d (
                .CLK(CLK), .RST(RST),
                .INPUT_VALID(source_input_valid), .INPUT_LAST(source_last),
                .INPUT_READY(source_path_ready),
                .X_PULSES_IN(x_pulses_generated), .D_PULSES_IN(d_pulses_generated),
                .X_PULSES_OUT(x_pulses_preprocessed), .D_PULSES_OUT(d_pulses_preprocessed),
                .OUTPUT_VALID(preprocess_valid), .OUTPUT_LAST(preprocess_last),
                .OUTPUT_READY(preprocess_ready)
            );
        end else begin : GEN_NO_SORT
            assign x_pulses_preprocessed = x_pulses_generated;
            assign d_pulses_preprocessed = d_pulses_generated;
            assign preprocess_valid = source_input_valid;
            assign preprocess_last = source_last;
            assign source_path_ready = preprocess_ready;
        end
    endgenerate

    wire keep_preprocessed_pair;
    generate
        if (ENABLE_ZERO_DELETE) begin : GEN_ZERO_DELETE
            ZERO_DELETE #(.CROSSBAR_DIMENSION(CROSSBAR_DIMENSION)) zero_delete (
                .X_PULSES_IN(x_pulses_preprocessed),
                .D_PULSES_IN(d_pulses_preprocessed),
                .KEEP_ITEM(keep_preprocessed_pair)
            );
        end else begin : GEN_NO_ZERO_DELETE
            assign keep_preprocessed_pair = 1'b1;
        end
    endgenerate

    wire [CROSSBAR_DIMENSION-1:0] x_pulses_to_buffer;
    wire [CROSSBAR_DIMENSION-1:0] d_pulses_to_buffer;
    wire pulse_pair_valid;
    wire output_buffer_ready;

    generate
        if (ENABLE_D_GROUP_MASK != 0) begin : GEN_GROUP_MASK
            wire group_input_ready;
            wire group_output_valid;
            wire group_frame_done;

            if (ENABLE_D_SORT && (ENABLE_D_GROUP_MASK == 1)) begin : GEN_SORTED_GROUP_MASK
                GROUP_MASK_AFTER_SORTED #(
                    .CROSSBAR_DIMENSION(CROSSBAR_DIMENSION), .MAX_BL(MAX_BL),
                    .BL_WIDTH(BL_WIDTH)
                ) group_mask (
                    .CLK(CLK), .RST(RST), .FRAME_BL(INPUT_BL),
                    .INPUT_VALID(preprocess_valid), .INPUT_KEEP(keep_preprocessed_pair),
                    .INPUT_LAST(preprocess_last), .INPUT_READY(group_input_ready),
                    .X_PULSES_IN(x_pulses_preprocessed), .D_PULSES_IN(d_pulses_preprocessed),
                    .X_PULSES_OUT(x_pulses_to_buffer), .D_PULSES_OUT(d_pulses_to_buffer),
                    .OUTPUT_VALID(group_output_valid), .OUTPUT_READY(output_buffer_ready),
                    .FRAME_DONE(group_frame_done)
                );
            end else begin : GEN_GENERIC_GROUP_MASK
                GROUP_MASK #(
                    .CROSSBAR_DIMENSION(CROSSBAR_DIMENSION), .MAX_BL(MAX_BL),
                    .BL_WIDTH(BL_WIDTH)
                ) group_mask (
                    .CLK(CLK), .RST(RST), .FRAME_BL(INPUT_BL),
                    .INPUT_VALID(preprocess_valid), .INPUT_KEEP(keep_preprocessed_pair),
                    .INPUT_LAST(preprocess_last), .INPUT_READY(group_input_ready),
                    .X_PULSES_IN(x_pulses_preprocessed), .D_PULSES_IN(d_pulses_preprocessed),
                    .X_PULSES_OUT(x_pulses_to_buffer), .D_PULSES_OUT(d_pulses_to_buffer),
                    .OUTPUT_VALID(group_output_valid), .OUTPUT_READY(output_buffer_ready),
                    .FRAME_DONE(group_frame_done)
                );
            end

            assign preprocess_ready = group_input_ready;
            assign pulse_pair_valid = group_output_valid;
            assign preprocessing_frame_done = group_frame_done;
        end else begin : GEN_DIRECT
            assign x_pulses_to_buffer = x_pulses_preprocessed;
            assign d_pulses_to_buffer = d_pulses_preprocessed;
            assign pulse_pair_valid = preprocess_valid && keep_preprocessed_pair;
            assign preprocess_ready = output_buffer_ready ||
                (preprocess_valid && !keep_preprocessed_pair);
            assign preprocessing_frame_done =
                preprocess_valid && preprocess_ready && preprocess_last;
        end
    endgenerate

    wire direct_last_item_deleted =
        (ENABLE_D_GROUP_MASK == 0) && preprocess_valid && preprocess_ready &&
        preprocess_last && !keep_preprocessed_pair;

    OUTPUT_BUFFER #(
        .CROSSBAR_DIMENSION(CROSSBAR_DIMENSION),
        .OUTPUT_BUFFER_DEPTH(OUTPUT_BUFFER_DEPTH)
    ) output_buffer (
        .CLK(CLK), .RST(RST),
        .X_PULSES_IN(x_pulses_to_buffer), .D_PULSES_IN(d_pulses_to_buffer),
        .VALID_IN(pulse_pair_valid),
        .X_PULSES_OUT(X_PULSES_OUT), .D_PULSES_OUT(D_PULSES_OUT),
        .VALID_OUT(VALID_OUT), .READY_IN(output_buffer_ready),
        .FULL(BUFFER_FULL), .OCCUPANCY(BUFFER_OCCUPANCY),
        .OUTPUT_READY(OUTPUT_READY)
    );

    always @(posedge CLK or negedge RST) begin
        if (!RST) begin
            source_set_captured <= 1'b0;
            preprocessing_complete <= 1'b0;
            frame_done_reg <= 1'b0;
            deleted_last_tail_wait <= 1'b0;
        end else begin
            frame_done_reg <= 1'b0;
            if (source_fire && source_last)
                source_set_captured <= 1'b1;
            if (preprocessing_frame_done)
                preprocessing_complete <= 1'b1;
            if (direct_last_item_deleted)
                deleted_last_tail_wait <= 1'b1;
            else if (deleted_last_tail_wait)
                deleted_last_tail_wait <= 1'b0;

            if (preprocessing_complete && !VALID_OUT &&
                !deleted_last_tail_wait) begin
                source_set_captured <= 1'b0;
                preprocessing_complete <= 1'b0;
                frame_done_reg <= 1'b1;
                deleted_last_tail_wait <= 1'b0;
            end
        end
    end
endmodule
