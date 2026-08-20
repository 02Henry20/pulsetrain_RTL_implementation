`timescale 1ns/100ps
`define GROUP_MASK_ARCHITECTURE
`define ARCHITECTURE_NAME "group_mask"

module TB_TOP_GROUP_MASK;
`include "TB_ARCHITECTURE_BODY.vh"
endmodule

`undef ARCHITECTURE_NAME
`undef GROUP_MASK_ARCHITECTURE
