// Rejects pulse pairs that cannot produce an X-by-D update.
module ZERO_DELETE #(
    parameter CROSSBAR_DIMENSION = 8 // Shared X and D pulse-vector width.
) (
    input  wire [CROSSBAR_DIMENSION-1:0] X_PULSES_IN, // Current preprocessing-stage X pulse vector.
    input  wire [CROSSBAR_DIMENSION-1:0] D_PULSES_IN, // Current preprocessing-stage D pulse vector.
    output wire                  KEEP_ITEM // Pair can produce at least one outer-product update.
);

    // An outer-product update needs at least one active X and one active D.
    assign KEEP_ITEM =
        (|X_PULSES_IN) &&
        (|D_PULSES_IN);

endmodule