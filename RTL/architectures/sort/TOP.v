module TOP #(
    parameter integer CROSSBAR_DIMENSION = 8,
    parameter integer MAX_BL = 32,
    parameter integer BL_WIDTH = (MAX_BL <= 1) ? 1 : $clog2(MAX_BL + 1),
    parameter integer STOCHASTIC_VALUE_WIDTH = 16,
    parameter integer OUTPUT_BUFFER_DEPTH = 10,
    parameter [STOCHASTIC_VALUE_WIDTH-1:0] LFSR_SEED = 16'hACE1
) (
    input wire CLK,
    input wire RST,
    input wire INPUT_VALID,
    input wire [BL_WIDTH-1:0] INPUT_BL,
    input wire [CROSSBAR_DIMENSION*STOCHASTIC_VALUE_WIDTH-1:0] X_INPUT_VALUES,
    input wire [CROSSBAR_DIMENSION*STOCHASTIC_VALUE_WIDTH-1:0] D_INPUT_VALUES,
    input wire OUTPUT_READY,
    output wire [CROSSBAR_DIMENSION-1:0] X_PULSES_OUT,
    output wire [CROSSBAR_DIMENSION-1:0] D_PULSES_OUT,
    output wire VALID_OUT,
    output wire READY_IN,
    output wire BUFFER_FULL,
    output wire [((OUTPUT_BUFFER_DEPTH <= 1) ? 1 : $clog2(OUTPUT_BUFFER_DEPTH + 1))-1:0] BUFFER_OCCUPANCY,
    output wire GROUP_MASK_BYPASS,
    output wire FRAME_DONE
);
    ARCH_TOP #(
        .CROSSBAR_DIMENSION(CROSSBAR_DIMENSION),
        .MAX_BL(MAX_BL),
        .BL_WIDTH(BL_WIDTH),
        .STOCHASTIC_VALUE_WIDTH(STOCHASTIC_VALUE_WIDTH),
        .OUTPUT_BUFFER_DEPTH(OUTPUT_BUFFER_DEPTH),
        .USE_SHARED_LFSR(0),
        .ENABLE_D_SORT(1),
        .ENABLE_ZERO_DELETE(0),
        .ENABLE_D_GROUP_MASK(0),
        .LFSR_SEED(LFSR_SEED)
    ) architecture_top (
        .CLK(CLK), .RST(RST),
        .INPUT_VALID(INPUT_VALID), .INPUT_BL(INPUT_BL),
        .X_INPUT_VALUES(X_INPUT_VALUES), .D_INPUT_VALUES(D_INPUT_VALUES),
        .OUTPUT_READY(OUTPUT_READY),
        .X_PULSES_OUT(X_PULSES_OUT), .D_PULSES_OUT(D_PULSES_OUT),
        .VALID_OUT(VALID_OUT), .READY_IN(READY_IN),
        .BUFFER_FULL(BUFFER_FULL), .BUFFER_OCCUPANCY(BUFFER_OCCUPANCY),
        .GROUP_MASK_BYPASS(GROUP_MASK_BYPASS), .FRAME_DONE(FRAME_DONE)
    );
endmodule
