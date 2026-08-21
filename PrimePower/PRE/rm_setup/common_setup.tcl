puts "RM-Info: Running script [info script]\n"

set_host_option -max_cores 16

##########################################################################################
# Variables common to all reference methodology scripts
# Script: common_setup.tcl
# Version: M-2017.06-SP2 (Nov 9, 2017)
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

#set icc2_output_path ../../../PNR/SS/pnr/outputs_icc2 

set PDK /data/S28 

set std_library_path $PDK/library/ln28lpp_sc_9t_base_rvt_c130_V1.00c_pkg/FE-Common_sec190802_0203/LIBERTY

set io_library_path $PDK/library/ln28lpp_gpio_1p8v_V1.00a_pkg/FE-Common_sec190321_0300/LIBERTY/synopsys

set RAM_path "$PDK/library/memory/batch_script/FE-Common_sec190812_0141/MemoryCompiler_FE/batch_script/bin/cmos28lpp_rf1_hd_1024x32m4 \
$PDK/library/memory/batch_script/FE-Common_sec190812_0141/MemoryCompiler_FE/batch_script/bin/cmos28lpp_rf1_hd_512x32m2 \
"
 

# For the following variables, use a blank space to separate multiple entries.
# Example: set TARGET_LIBRARY_FILES "lib1.db lib2.db lib3.db"

#set ADDITIONAL_SEARCH_PATH        "$icc2_output_path 
set ADDITIONAL_SEARCH_PATH        "$std_library_path \
                                   $io_library_path \
				   $RAM_path"


set TARGET_LIBRARY_FILES 	"sc9_cmos28lpp_base_rvt_ff_nominal_min_1p100v_m40c_sadhm.db \
				sc9_cmos28lpp_base_rvt_tt_nominal_max_1p000v_25c.db \
"

set ADDITIONAL_LINK_LIB_FILES "* $TARGET_LIBRARY_FILES \
				io_gppr_cmos28lpp_t18_ff_1p155v_1p950v_m40c.db \
				io_gppr_cmos28lpp_t18_tt_1p000v_1p800v_25c.db \
				cmos28lpp_rf1_hd_1024x32m4_tt_1p000v_1p000v_25c.db \
				cmos28lpp_rf1_hd_512x32m2_tt_1p000v_1p000v_25c.db \
"

set LIB_DIR                        $PDK/tech

set MIN_LIBRARY_FILES             ""  ;#  List of max min library pairs "max1 min1 max2 min2 max3 min3"...

#smkcow : no MW
#set MW_REFERENCE_LIB_DIRS         "$LIB_DIR/MilkyWay/ICC/cmos10lprvt_m \
                                   $LIB_DIR/MilkyWay/ICC/Power_IO "
#  Milkyway reference libraries (include IC Compiler ILMs here)
#set MW_REFERENCE_LIB_DIRS         ""  ;#  Milkyway reference libraries (include IC Compiler ILMs here)

set MW_REFERENCE_CONTROL_FILE     ""  ;#  Reference Control file to define the Milkyway reference libs

set TECH_FILE                   "$LIB_DIR/TECH/LN28LPP_ICC_S00-V2.0.8.0/7U1x_2T8x_LB/sc9_cmos28lpp_7U1x_2T8x_LB.icc2.tf"

set MAP_FILE                    "$LIB_DIR/TECH/LN28LPP_ICC_S00-V2.0.8.0/7U1x_2T8x_LB/28lpp_7U1x_2T8x_LB.map"

set TLUPLUS_MAX_FILE            "$LIB_DIR/TECH/LN28LPP_ICC_S00-V2.0.8.0/7U1x_2T8x_LB/28lpp_7U1x_2T8x_LB_SigRCmax_detailed.tlup"

set TLUPLUS_MIN_FILE            "$LIB_DIR/TECH/LN28LPP_ICC_S00-V2.0.8.0/7U1x_2T8x_LB/28lpp_7U1x_2T8x_LB_SigRCmin_detailed.tlup"


#set TECH_FILE                     ""  ;#  Milkyway technology file
#set MAP_FILE                      ""  ;#  Mapping file for TLUplus
#set TLUPLUS_MAX_FILE              ""  ;#  Max TLUplus file
#set TLUPLUS_MIN_FILE              ""  ;#  Min TLUplus file

set MIN_ROUTING_LAYER            "M1"   ;# Min routing layer
set MAX_ROUTING_LAYER            "M7"   ;# Max routing layer

set LIBRARY_DONT_USE_FILE        ""   ;# Tcl file with library modifications for dont_use

##########################################################################################
# Multivoltage Common Variables
#
# Define the following multivoltage common variables for the reference methodology scripts 
# for multivoltage flows. 
# Use as few or as many of the following definitions as needed by your design.
##########################################################################################

set PD1                          ""           ;# Name of power domain/voltage area  1
set VA1_COORDINATES              {}           ;# Coordinates for voltage area 1
set MW_POWER_NET1                "VDD1"       ;# Power net for voltage area 1

set PD2                          ""           ;# Name of power domain/voltage area  2
set VA2_COORDINATES              {}           ;# Coordinates for voltage area 2
set MW_POWER_NET2                "VDD2"       ;# Power net for voltage area 2

set PD3                          ""           ;# Name of power domain/voltage area  3
set VA3_COORDINATES              {}           ;# Coordinates for voltage area 3
set MW_POWER_NET3                "VDD3"       ;# Power net for voltage area 3

set PD4                          ""           ;# Name of power domain/voltage area  4
set VA4_COORDINATES              {}           ;# Coordinates for voltage area 4
set MW_POWER_NET4                "VDD4"       ;# Power net for voltage area 4

puts "RM-Info: Completed script [info script]\n"

