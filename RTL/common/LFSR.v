// Maximum-length pseudo-random source for stochastic pulse comparisons.
module LFSR #(
    parameter integer WIDTH = 16, // Bits in each normalized pseudo-random value.
    parameter [WIDTH-1:0] SEED = 16'hACE1, // Initial nonzero LFSR state.
    parameter [WIDTH-1:0] TAPS = {WIDTH{1'b0}} // Zero selects built-in maximum-length taps.
) (
    input  wire             CLK, // System clock.
    input  wire             RST, // Active-low asynchronous reset.
    input  wire             ENABLE, // Advance only when the source accepts a sample.

    output reg  [WIDTH-1:0] VALUE // Current normalized pseudo-random value in [0,1].
);

    // Primitive-polynomial masks for common stochastic word widths.
    function [WIDTH-1:0] default_taps;
        input integer width;
        begin
            default_taps = {WIDTH{1'b0}};
            case (width)
                2:  default_taps = 32'h00000003;
                3:  default_taps = 32'h00000006;
                4:  default_taps = 32'h0000000C;
                5:  default_taps = 32'h00000014;
                6:  default_taps = 32'h00000030;
                7:  default_taps = 32'h00000060;
                8:  default_taps = 32'h000000B8;
                9:  default_taps = 32'h00000110;
                10: default_taps = 32'h00000240;
                11: default_taps = 32'h00000500;
                12: default_taps = 32'h00000829;
                13: default_taps = 32'h0000100D;
                14: default_taps = 32'h00002015;
                15: default_taps = 32'h00006000;
                16: default_taps = 32'h0000D008;
                17: default_taps = 32'h00012000;
                18: default_taps = 32'h00020400;
                19: default_taps = 32'h00040023;
                20: default_taps = 32'h00090000;
                21: default_taps = 32'h00140000;
                22: default_taps = 32'h00300000;
                23: default_taps = 32'h00420000;
                24: default_taps = 32'h00E10000;
                25: default_taps = 32'h01200000;
                26: default_taps = 32'h02000023;
                27: default_taps = 32'h04000013;
                28: default_taps = 32'h09000000;
                29: default_taps = 32'h14000000;
                30: default_taps = 32'h20000029;
                31: default_taps = 32'h48000000;
                32: default_taps = 32'h80200003;
                default: begin
                    default_taps[WIDTH-1] = 1'b1;
                    default_taps[0] = 1'b1;
                end
            endcase
        end
    endfunction

    // Replace an invalid all-zero seed, which would lock a XOR LFSR.
    localparam [WIDTH-1:0] RESET_VALUE =
        (SEED == {WIDTH{1'b0}}) ? {{(WIDTH-1){1'b0}}, 1'b1} : SEED;
    localparam [WIDTH-1:0] DEFAULT_TAPS =
        default_taps(WIDTH);
    // A nonzero TAPS parameter overrides the built-in width-specific mask.
    localparam [WIDTH-1:0] SELECTED_TAPS =
        (TAPS == {WIDTH{1'b0}}) ? DEFAULT_TAPS : TAPS;

    generate
        if (WIDTH == 1) begin : GEN_ONE_BIT_LFSR
            // Emit a new random word every clock without an enable stage.
            always @(posedge CLK or negedge RST) begin
                if (!RST)
                    VALUE <= RESET_VALUE;
                else if (ENABLE)
                    VALUE <= ~VALUE;
            end
        end else begin : GEN_WIDE_LFSR
            wire feedback;

            // XOR only the state bits selected by the primitive polynomial.
            assign feedback = ^(VALUE & SELECTED_TAPS);

            // Emit a new random word every clock without an enable stage.
            always @(posedge CLK or negedge RST) begin
                if (!RST)
                    VALUE <= RESET_VALUE;
                else if (ENABLE)
                    VALUE <= {VALUE[WIDTH-2:0], feedback};
            end
        end
    endgenerate

endmodule
