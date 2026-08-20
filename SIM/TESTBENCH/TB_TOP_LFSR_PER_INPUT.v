`timescale 1ns/100ps
`define PER_INPUT_LFSR_ARCHITECTURE
`define ARCHITECTURE_NAME "lfsr_per_input"

module TB_TOP_LFSR_PER_INPUT;
`include "TB_ARCHITECTURE_BODY.vh"
endmodule
`undef PER_INPUT_LFSR_ARCHITECTURE

`undef ARCHITECTURE_NAME

