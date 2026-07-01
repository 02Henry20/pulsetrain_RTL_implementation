module ZERO_DELETE #(
    parameter NUM_VALUES = 8
) (
    input  wire [NUM_VALUES-1:0] X_PULSES_IN,
    input  wire [NUM_VALUES-1:0] D_PULSES_IN,
    output wire                  KEEP_ITEM
);

    assign KEEP_ITEM =
        (|X_PULSES_IN) &&
        (|D_PULSES_IN);

endmodule