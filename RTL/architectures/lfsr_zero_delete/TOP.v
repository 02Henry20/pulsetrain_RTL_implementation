// Square crossbar model: X and D vectors share CROSSBAR_DIMENSION lanes.
module TOP #(
    parameter integer CROSSBAR_DIMENSION = 8, // X input lanes and D output/error lanes.
    parameter integer BIT_LENGTH = 32, // Accepted pulse cycles in one complete train set.
    parameter integer STOCHASTIC_VALUE_WIDTH = 16, // Bits per unsigned normalized fixed-point value.
    parameter integer OUTPUT_BUFFER_DEPTH = 10, // Number of queued X/D pulse pairs.
    parameter [STOCHASTIC_VALUE_WIDTH-1:0] LFSR_SEED = 16'hACE1 // Nonzero initial LFSR state.
) (
    input  wire                              CLK, // System clock.
    input  wire                              RST, // Active-low asynchronous reset.
    input  wire                              INPUT_VALID, // Current X/D values and random words are valid.
    input  wire [CROSSBAR_DIMENSION*STOCHASTIC_VALUE_WIDTH-1:0] X_INPUT_VALUES, // Packed normalized X values in [0,1].
    input  wire [CROSSBAR_DIMENSION*STOCHASTIC_VALUE_WIDTH-1:0] D_INPUT_VALUES, // Packed normalized D values in [0,1].
    input  wire [CROSSBAR_DIMENSION*STOCHASTIC_VALUE_WIDTH-1:0] X_RANDOM_VALUES, // Packed X-lane random values in [0,1]; ignored with LFSR.
    input  wire [CROSSBAR_DIMENSION*STOCHASTIC_VALUE_WIDTH-1:0] D_RANDOM_VALUES, // Packed D-lane random values in [0,1]; ignored with LFSR.
    input  wire                              PULSE_DONE, // Consumer accepted the current output pair.
    output wire [CROSSBAR_DIMENSION-1:0]             X_PULSES_OUT, // Buffered X pulse vector.
    output wire [CROSSBAR_DIMENSION-1:0]             D_PULSES_OUT, // Buffered D pulse vector.
    output wire                              VALID_OUT, // Output pulse pair is valid.
    output wire                              READY_IN, // Current set cycle can be accepted; low while draining.
    output wire                              BUFFER_FULL, // Output FIFO has no free entry.
    output wire                              FRAME_DONE // Complete set has drained and been consumed.
);

    ARCH_TOP #(
        .CROSSBAR_DIMENSION       (CROSSBAR_DIMENSION),
        .STOCHASTIC_VALUE_WIDTH   (STOCHASTIC_VALUE_WIDTH),
        .OUTPUT_BUFFER_DEPTH      (OUTPUT_BUFFER_DEPTH),
        .BIT_LENGTH               (BIT_LENGTH),
        .USE_SHARED_LFSR          (1),
        .ENABLE_D_SORT            (0),
        .ENABLE_ZERO_DELETE       (1),
        .ENABLE_D_GROUP_MASK      (0),
        .LFSR_SEED                (LFSR_SEED)
    ) architecture_top (
        .CLK           (CLK),
        .RST           (RST),
        .INPUT_VALID   (INPUT_VALID),
        .X_INPUT_VALUES(X_INPUT_VALUES),
        .D_INPUT_VALUES(D_INPUT_VALUES),
        .X_RANDOM_VALUES(X_RANDOM_VALUES),
        .D_RANDOM_VALUES(D_RANDOM_VALUES),
        .PULSE_DONE    (PULSE_DONE),
        .X_PULSES_OUT  (X_PULSES_OUT),
        .D_PULSES_OUT  (D_PULSES_OUT),
        .VALID_OUT     (VALID_OUT),
        .READY_IN      (READY_IN),
        .BUFFER_FULL   (BUFFER_FULL),
        .FRAME_DONE    (FRAME_DONE)
    );

endmodule
