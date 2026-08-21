// Generates stochastic pulses from one independent random word per lane.
module PULSE_GENERATOR #(
    parameter integer CROSSBAR_DIMENSION = 8, // Number of lanes in this X or D vector.
    parameter integer STOCHASTIC_VALUE_WIDTH = 16 // Bits per unsigned normalized fixed-point value.
) (
    input  wire [CROSSBAR_DIMENSION*STOCHASTIC_VALUE_WIDTH-1:0] RANDOM_VALUES, // Packed independent random values in [0,1].
    input  wire [CROSSBAR_DIMENSION*STOCHASTIC_VALUE_WIDTH-1:0] INPUT_VALUES, // Packed normalized X or D values in [0,1].
    output wire [CROSSBAR_DIMENSION-1:0] PULSES // One stochastic pulse bit per lane.
);

    genvar lane;
    generate
        for (lane = 0; lane < CROSSBAR_DIMENSION;
             lane = lane + 1) begin : GEN_PULSE
            // Both operands use the same unsigned normalized [0,1] encoding.
            assign PULSES[lane] =
                RANDOM_VALUES[
                    lane*STOCHASTIC_VALUE_WIDTH +: STOCHASTIC_VALUE_WIDTH] <
                INPUT_VALUES[
                    lane*STOCHASTIC_VALUE_WIDTH +: STOCHASTIC_VALUE_WIDTH];
        end
    endgenerate

endmodule