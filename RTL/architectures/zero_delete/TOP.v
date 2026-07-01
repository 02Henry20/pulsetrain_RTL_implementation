module TOP_PREV #(
    parameter NUM_VALUES  = 8,
    parameter VALUE_WIDTH = 16,
    parameter FIFO_DEPTH  = 10
) (
    input  wire                              CLK,
    input  wire                              RSTn,

    input  wire [VALUE_WIDTH-1:0]            X_LFSR_VALUE,
    input  wire [NUM_VALUES*VALUE_WIDTH-1:0] X_INPUT_VALUES,

    input  wire [VALUE_WIDTH-1:0]            D_LFSR_VALUE,
    input  wire [NUM_VALUES*VALUE_WIDTH-1:0] D_INPUT_VALUES,

    input  wire                              PULSE_DONE,

    output wire [NUM_VALUES-1:0]             X_PULSES_OUT,
    output wire [NUM_VALUES-1:0]             D_PULSES_OUT,
    output wire                              VALID_OUT
);

    wire [NUM_VALUES-1:0] generated_x;
    wire [NUM_VALUES-1:0] generated_d;
    wire                  keep_item;

    PULSE_GENERATOR #(
        .NUM_VALUES (NUM_VALUES),
        .VALUE_WIDTH(VALUE_WIDTH)
    ) pulse_generator_x (
        .LFSR_VALUE  (X_LFSR_VALUE),
        .INPUT_VALUES(X_INPUT_VALUES),
        .PULSES      (generated_x)
    );

    PULSE_GENERATOR #(
        .NUM_VALUES (NUM_VALUES),
        .VALUE_WIDTH(VALUE_WIDTH)
    ) pulse_generator_d (
        .LFSR_VALUE  (D_LFSR_VALUE),
        .INPUT_VALUES(D_INPUT_VALUES),
        .PULSES      (generated_d)
    );

    ZERO_DELETE #(
        .NUM_VALUES(NUM_VALUES)
    ) zero_delete (
        .X_PULSES_IN(generated_x),
        .D_PULSES_IN(generated_d),
        .KEEP_ITEM  (keep_item)
    );

    OUTPUT_BUFFER #(
        .NUM_VALUES(NUM_VALUES),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) output_buffer (
        .CLK         (CLK),
        .RSTn        (RSTn),

        .X_PULSES_IN (generated_x),
        .D_PULSES_IN (generated_d),
        .VALID_IN    (keep_item),

        .X_PULSES_OUT(X_PULSES_OUT),
        .D_PULSES_OUT(D_PULSES_OUT),
        .VALID_OUT   (VALID_OUT),

        .PULSE_DONE  (PULSE_DONE)
    );

endmodule