#vcs -full64 -debug_all
vcs -full64 -debug_access+all -kdb -lca -cm line+tgl+assert+branch+cond+fsm \
+define+function_sim \
+define+mem_sim \
+incdir+../../RTL \
+incdir+../TESTBENCH \
+incdir+../../REF \
+incdir+/data/S28/library/ln28lpp_sc_9t_base_rvt_c130_V1.00c_pkg/FE-Common_sec190802_0203/MODEL \
+incdir+/data/S28/library/ln28lpp_gpio_1p8v_V1.00a_pkg/FE-Common_sec190321_0300/MODEL \
+incdir+/tools/Synopsys/DesignCompiler/syn/M-2016.12-SP5/dw/sim_ver \
+v2k \
+libext+.v\
-y /tools/Synopsys/DesignCompiler/syn/M-2016.12-SP5/dw/sim_ver \
-f filenames.f \
-l func_sim.log \
-override_timescale=1ns/10ps


