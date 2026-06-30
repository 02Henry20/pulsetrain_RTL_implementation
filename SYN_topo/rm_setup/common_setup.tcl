puts "RM-Info: Running script [info script]\n"

##########################################################################################
# Variables common to all reference methodology scripts
# Script: common_setup.tcl
# Version: M-2016.12-SP4 (July 17, 2017)
# Copyright (C) 2007-2017 Synopsys, Inc. All rights reserved.
##########################################################################################

set DESIGN_NAME                   "TOP_PREV"  ;#  The name of the top-level design

set DESIGN_REF_DATA_PATH          ""  ;#  Absolute path prefix variable for library/design data.
                                       #  Use this variable to prefix the common absolute path  
                                       #  to the common variables defined below.
                                       #  Absolute paths are mandatory for hierarchical 
                                       #  reference methodology flow.

##########################################################################################
# Hierarchical Flow Design Variables
##########################################################################################

set HIERARCHICAL_DESIGNS           "" ;# List of hierarchical block design names "DesignA DesignB" ...
set HIERARCHICAL_CELLS             "" ;# List of hierarchical block cell instance names "u_DesignA u_DesignB" ...

##########################################################################################
# Library Setup Variables
##########################################################################################

# For the following variables, use a blank space to separate multiple entries.
# Example: set TARGET_LIBRARY_FILES "lib1.db lib2.db lib3.db"

set dc_source_path ../RTL

# Edit this with style of full path
set PDK /data/S28 

set std_library_path $PDK/library/ln28lpp_sc_9t_base_rvt_c130_V1.00c_pkg/FE-Common_sec190802_0203/LIBERTY

set gpio_library_path $PDK/library/ln28lpp_gpio_1p8v_V1.00a_pkg/FE-Common_sec190321_0300/LIBERTY/synopsys

set RAM_path "$PDK/library/memory/batch_script/FE-Common_sec190812_0141/MemoryCompiler_FE/batch_script/bin/cmos28lpp_rf1_hd_1024x32m4 \
$PDK/library/memory/batch_script/FE-Common_sec190812_0141/MemoryCompiler_FE/batch_script/bin/cmos28lpp_rf1_hd_512x32m2
"

set DDC_path	"../../VECTOR/SYN_topo/results \
		../../MEMSET/SYN_topo/results \
		../../CORE/SYN_topo/results \
"


set ADDITIONAL_SEARCH_PATH        "$dc_source_path \
                                   $std_library_path \
                                   $gpio_library_path \
				   ./mcmm_cons \
				   ./script \
				   ./results \
                                   $RAM_path \
"

set TARGET_LIBRARY_FILES          "sc9_cmos28lpp_base_rvt_ff_nominal_min_1p100v_m40c_sadhm.db \
                                   sc9_cmos28lpp_base_rvt_tt_nominal_max_1p000v_25c.db \
"

# ddc files? 
set ADDITIONAL_LINK_LIB_FILES     "io_gppr_cmos28lpp_t18_ff_1p155v_1p950v_m40c.db \
                                   io_gppr_cmos28lpp_t18_tt_1p000v_1p800v_25c.db \
				   cmos28lpp_rf1_hd_1024x32m4_tt_1p000v_1p000v_25c.db \
				   cmos28lpp_rf1_hd_512x32m2_tt_1p000v_1p000v_25c.db \
				
"


set synthetic_library dw_foundation.sldb

#set SYMBOL_LIBRARY_FILES          cmos10lprvt_m.sdb                     ;#  Symbol library file

set hdlin_enable_configurations true
set hdlin_enable_rtldrc_info true
set test_default_scan_style multiplexed_flip_flop



set MIN_LIBRARY_FILES             ""  ;#  List of max min library pairs "max1 min1 max2 min2 max3 min3"...

set MW_REFERENCE_CONTROL_FILE     ""  ;#  Reference Control file to define the Milkyway reference libs

set MIN_ROUTING_LAYER            "M1"   ;# Min routing layer
set MAX_ROUTING_LAYER            "IB"   ;# Max routing layer

#==========================

set LIB_DIR                         "$PDK/tech"

#set SUB_DESIGN_DIR                  "/home/smkcow/QnA/digital/example_smkcow_DC_ICC2"

set all_milky                       "$PDK/library/ln28lpp_sc_9t_base_rvt_c130_V1.00c_pkg/BE-Common_sec190307_0119/MILKYWAY/7U1x_2T8x_LB/casesense/sc9_cmos28lpp_base_rvt"

set MW_DESIGN_LIB                 MY_DESIGN_LIB                         ;# User-defined Milkyway design library name

set MW_REFERENCE_LIB_DIRS         "$all_milky"          ;# Milkyway reference libraries

set TECH_FILE                   "$LIB_DIR/TECH/LN28LPP_ICC_S00-V2.0.8.0/7U1x_2T8x_LB/sc9_cmos28lpp_7U1x_2T8x_LB.icc2.tf"

set MAP_FILE                    "$LIB_DIR/TECH/LN28LPP_ICC_S00-V2.0.8.0/7U1x_2T8x_LB/28lpp_7U1x_2T8x_LB.map"

set TLUPLUS_MAX_FILE            "$LIB_DIR/TECH/LN28LPP_ICC_S00-V2.0.8.0/7U1x_2T8x_LB/28lpp_7U1x_2T8x_LB_SigRCmax_detailed.tlup"

set TLUPLUS_MIN_FILE            "$LIB_DIR/TECH/LN28LPP_ICC_S00-V2.0.8.0/7U1x_2T8x_LB/28lpp_7U1x_2T8x_LB_SigRCmin_detailed.tlup"


set LIBRARY_DONT_USE_FILE        ""   ;# Tcl file with library modifications for dont_use
set LIBRARY_DONT_USE_PRE_COMPILE_LIST ""; #Tcl file for customized don't use list before first compile
set LIBRARY_DONT_USE_PRE_INCR_COMPILE_LIST "";# Tcl file with library modifications for dont_use before incr compile
##########################################################################################
# Multivoltage Common Variables
#
# Define the following multivoltage common variables for the reference methodology scripts 
# for multivoltage flows. 
# Use as few or as many of the following definitions as needed by your design.
##########################################################################################

#set PD1                          ""           ;# Name of power domain/voltage area  1
#set VA1_COORDINATES              {}           ;# Coordinates for voltage area 1
#set MW_POWER_NET1                "VDD1"       ;# Power net for voltage area 1
#
#set PD2                          ""           ;# Name of power domain/voltage area  2
#set VA2_COORDINATES              {}           ;# Coordinates for voltage area 2
#set MW_POWER_NET2                "VDD2"       ;# Power net for voltage area 2
#
#set PD3                          ""           ;# Name of power domain/voltage area  3
#set VA3_COORDINATES              {}           ;# Coordinates for voltage area 3
#set MW_POWER_NET3                "VDD3"       ;# Power net for voltage area 3
#
#set PD4                          ""           ;# Name of power domain/voltage area  4
#set VA4_COORDINATES              {}           ;# Coordinates for voltage area 4
#set MW_POWER_NET4                "VDD4"       ;# Power net for voltage area 4

puts "RM-Info: Completed script [info script]\n"

