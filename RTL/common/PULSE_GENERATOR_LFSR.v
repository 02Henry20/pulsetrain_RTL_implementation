// Generates stochastic pulses by sharing one LFSR word across every lane.
module PULSE_GENERATOR_LFSR #(
    parameter integer CROSSBAR_DIMENSION = 8, // Number of lanes in this X or D vector.
    parameter integer STOCHASTIC_VALUE_WIDTH = 16 // Bits per unsigned normalized fixed-point value.
) (
    input  wire [STOCHASTIC_VALUE_WIDTH-1:0] LFSR_VALUE, // Shared normalized random value in [0,1].
    input  wire [CROSSBAR_DIMENSION*STOCHASTIC_VALUE_WIDTH-1:0] INPUT_VALUES, // Packed normalized X or D values in [0,1].
    output wire [CROSSBAR_DIMENSION-1:0] PULSES // One stochastic pulse bit per lane.
);

    genvar lane;
    generate
        for (lane = 0; lane < CROSSBAR_DIMENSION;
             lane = lane + 1) begin : GEN_LFSR_PULSE
            // The shared normalized value directly drives every lane comparator.
            assign PULSES[lane] = LFSR_VALUE <
                INPUT_VALUES[
                    lane*STOCHASTIC_VALUE_WIDTH +: STOCHASTIC_VALUE_WIDTH];
        end
    endgenerate

endmodule