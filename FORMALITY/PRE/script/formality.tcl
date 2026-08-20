set_app_var hdlin_dwroot /tools/Synopsys/DesignCompiler/syn/M-2016.12-SP5
set synopsys_auto_setup true
set verification_verify_unread_tech_cell_pins true

set_host_options -max_cores 8
set_app_var verification_timeout_limit 72:0:0

set_svf -append { ../../SYN_topo/results/TOP_PREV.mapped.svf } 


read_verilog -container r -libname WORK -05 { \
/data/SCRIPTS/COMMON_VERILOG/REGISTER.v \
/data/SCRIPTS/COMMON_VERILOG/DEMUX.v \
/data/SCRIPTS/COMMON_VERILOG/MUX.v \
/data/SCRIPTS/COMMON_VERILOG/MemModel.v \
../../RTL/TOP.v \
../../../VECTOR/RTL/VECTOR.v \
../../../MEMSET/RTL/MEMSET.v \
../../../CORE/RTL/CORE.v \
}

#read_ddc -container r { ../../SYN_topo/results/TOP_PREV.mapped.ddc \
} 

read_db { \
/data/S28/library/ln28lpp_sc_9t_base_rvt_c130_V1.00c_pkg/FE-Common_sec190802_0203/LIBERTY/sc9_cmos28lpp_base_rvt_ff_nominal_min_1p100v_m40c_sadhm.db \
/data/S28/library/ln28lpp_sc_9t_base_rvt_c130_V1.00c_pkg/FE-Common_sec190802_0203/LIBERTY/sc9_cmos28lpp_base_rvt_tt_nominal_max_1p000v_25c.db \
/data/S28/library/ln28lpp_gpio_1p8v_V1.00a_pkg/FE-Common_sec190321_0300/LIBERTY/synopsys/io_gppr_cmos28lpp_t18_ff_1p155v_1p950v_m40c.db \
/data/S28/library/ln28lpp_gpio_1p8v_V1.00a_pkg/FE-Common_sec190321_0300/LIBERTY/synopsys/io_gppr_cmos28lpp_t18_tt_1p000v_1p800v_25c.db \
/data/S28/library/memory/batch_script/FE-Common_sec190812_0141/MemoryCompiler_FE/batch_script/bin/cmos28lpp_rf1_hd_1024x32m4/cmos28lpp_rf1_hd_1024x32m4_tt_1p000v_1p000v_25c.db \
/data/S28/library/memory/batch_script/FE-Common_sec190812_0141/MemoryCompiler_FE/batch_script/bin/cmos28lpp_rf1_hd_512x32m2/cmos28lpp_rf1_hd_512x32m2_tt_1p000v_1p000v_25c.db \
} 

set_top r:/WORK/TOP_PREV 

read_ddc -container i { ../../SYN_topo/results/TOP_PREV.mapped.ddc \
} 

set_top i:/WORK/TOP_PREV 

match 

verify 
