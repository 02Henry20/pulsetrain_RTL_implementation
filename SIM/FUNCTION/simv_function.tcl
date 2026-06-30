# 1) just execute dve
#./simv -gui

# 2) execute verdi and this is for coverage analysis
#./simv -verdi -ucli -i fsdb.tcl -cm line+tgl+assert+branch+cond+fsm -l func_simv.log

# 3) step by step
./simv -ucli -i fsdb.tcl -l func_simv.log
#Verdi-SX -ssf TOP.fsdb

#4) verdi  coverage
#./simv -ucli -i fsdb.tcl -cm line+tgl+assert+branch+cond+fsm -l func_simv.log
#verdi -ssf pad_TOP_function.fsdb -cov -covdir simv.vdb

