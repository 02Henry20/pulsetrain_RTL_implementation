puts "RM-Info: Running script [info script]\n"

##########################################################################################
# Variables common to all reference methodology scripts
# Script: common_setup.tcl
# Version: M-2016.12-SP4 (July 17, 2017)
##########################################################################################

##########################################################################################
# Architecture and Run Selection
##########################################################################################

if {![info exists ::env(SYNTH_ARCH)]} {
    puts "RM-Error: The SYNTH_ARCH environment variable is not defined."
    puts "RM-Error: Run synthesis through:"
    puts "RM-Error:   ./run_synthesis <architecture> \[testbench\]"
    exit 1
}

set SELECTED_ARCH $::env(SYNTH_ARCH)

if {$SELECTED_ARCH eq ""} {
    puts "RM-Error: SYNTH_ARCH must not be empty."
    exit 1
}

if {[info exists ::env(SYNTH_RUN_LABEL)]} {
    set SYNTH_RUN_LABEL $::env(SYNTH_RUN_LABEL)
} else {
    set SYNTH_RUN_LABEL "no_saif"
}

##########################################################################################
# Design Setup
##########################################################################################

# Every architecture-specific RTL top file must define:
#   module TOP
set DESIGN_NAME "TOP"

# run_synthesis launches dc_shell from SYN_topo.
set SYNTH_DIR    [file normalize [pwd]]
set PROJECT_ROOT [file dirname $SYNTH_DIR]

set DESIGN_REF_DATA_PATH ""

##########################################################################################
# Hierarchical Flow Design Variables
##########################################################################################

set HIERARCHICAL_DESIGNS ""
set HIERARCHICAL_CELLS   ""

##########################################################################################
# Library Setup Variables
##########################################################################################

set dc_source_path "${PROJECT_ROOT}/RTL"

# Samsung 28 nm PDK root.
set PDK /data/S28

set std_library_path \
    "$PDK/library/ln28lpp_sc_9t_base_rvt_c130_V1.00c_pkg/FE-Common_sec190802_0203/LIBERTY"

set gpio_library_path \
    "$PDK/library/ln28lpp_gpio_1p8v_V1.00a_pkg/FE-Common_sec190321_0300/LIBERTY/synopsys"

set ARCH_RESULTS_PATH \
    "${SYNTH_DIR}/runs/${SELECTED_ARCH}/${SYNTH_RUN_LABEL}/results"

set ADDITIONAL_SEARCH_PATH \
"$dc_source_path \
$std_library_path \
$gpio_library_path \
${SYNTH_DIR}/mcmm_cons \
${SYNTH_DIR}/script \
${ARCH_RESULTS_PATH}"

set TARGET_LIBRARY_FILES \
"sc9_cmos28lpp_base_rvt_ff_nominal_min_1p100v_m40c_sadhm.db \
sc9_cmos28lpp_base_rvt_tt_nominal_max_1p000v_25c.db"

# Keep only libraries actually needed by the current block-level design.
# The old memory DB entries were removed because TOP does not instantiate
# those macros and the files were not found by Design Compiler.
set ADDITIONAL_LINK_LIB_FILES \
"io_gppr_cmos28lpp_t18_ff_1p155v_1p950v_m40c.db \
io_gppr_cmos28lpp_t18_tt_1p000v_1p800v_25c.db"

set synthetic_library dw_foundation.sldb

#set SYMBOL_LIBRARY_FILES cmos10lprvt_m.sdb

set hdlin_enable_configurations true
set hdlin_enable_rtldrc_info     true

# Harmless while DFT is disabled in dc.tcl.
set test_default_scan_style multiplexed_flip_flop

set MIN_LIBRARY_FILES ""

set MW_REFERENCE_CONTROL_FILE ""

set MIN_ROUTING_LAYER "M1"
set MAX_ROUTING_LAYER "IB"

##########################################################################################
# Physical Library Setup
##########################################################################################

set LIB_DIR "$PDK/tech"

set all_milky \
"$PDK/library/ln28lpp_sc_9t_base_rvt_c130_V1.00c_pkg/BE-Common_sec190307_0119/MILKYWAY/7U1x_2T8x_LB/casesense/sc9_cmos28lpp_base_rvt"

# Use a separate Milkyway design library for each architecture/activity run.
set MW_DESIGN_LIB \
    "MY_DESIGN_LIB_${SELECTED_ARCH}_${SYNTH_RUN_LABEL}"

set MW_REFERENCE_LIB_DIRS "$all_milky"

set TECH_FILE \
"$LIB_DIR/TECH/LN28LPP_ICC_S00-V2.0.8.0/7U1x_2T8x_LB/sc9_cmos28lpp_7U1x_2T8x_LB.icc2.tf"

set MAP_FILE \
"$LIB_DIR/TECH/LN28LPP_ICC_S00-V2.0.8.0/7U1x_2T8x_LB/28lpp_7U1x_2T8x_LB.map"

set TLUPLUS_MAX_FILE \
"$LIB_DIR/TECH/LN28LPP_ICC_S00-V2.0.8.0/7U1x_2T8x_LB/28lpp_7U1x_2T8x_LB_SigRCmax_detailed.tlup"

set TLUPLUS_MIN_FILE \
"$LIB_DIR/TECH/LN28LPP_ICC_S00-V2.0.8.0/7U1x_2T8x_LB/28lpp_7U1x_2T8x_LB_SigRCmin_detailed.tlup"

set LIBRARY_DONT_USE_FILE                  ""
set LIBRARY_DONT_USE_PRE_COMPILE_LIST      ""
set LIBRARY_DONT_USE_PRE_INCR_COMPILE_LIST ""

##########################################################################################
# Multivoltage Common Variables
##########################################################################################

#set PD1             ""
#set VA1_COORDINATES {}
#set MW_POWER_NET1   "VDD1"
#
#set PD2             ""
#set VA2_COORDINATES {}
#set MW_POWER_NET2   "VDD2"
#
#set PD3             ""
#set VA3_COORDINATES {}
#set MW_POWER_NET3   "VDD3"
#
#set PD4             ""
#set VA4_COORDINATES {}
#set MW_POWER_NET4   "VDD4"

puts "RM-Info: Architecture: ${SELECTED_ARCH}"
puts "RM-Info: Run label:    ${SYNTH_RUN_LABEL}"
puts "RM-Info: Design name:  ${DESIGN_NAME}"
puts "RM-Info: Project root: ${PROJECT_ROOT}"
puts "RM-Info: Completed script [info script]\n"
