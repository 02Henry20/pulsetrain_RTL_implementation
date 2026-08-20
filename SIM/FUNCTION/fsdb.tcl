# Example of TB file expression
#$fsdbSuppress ("my_suppress_list.txt");
#$fsdbDumpfile("test.fsdb");
#
#fsdbDumpVars("+all"); : too long time don't use
#fsdbDumpVars(1, testbench);
#fsdbDumpVars(0, testbench);
#fsdbDumpVars(0, testbench.i_dut);
#fsdbDumpVars(0, testbench.i_dut.pram.mem, +all);
#end
#

call {$fsdbDumpfile ("TOP_PREV.fsdb")};
call {$fsdbDumpvars (0, TB_TOP_PREV, "+mda")};
#call {$fsdbDumpvars (0, TB_TOP_PREV)};
run
exit

