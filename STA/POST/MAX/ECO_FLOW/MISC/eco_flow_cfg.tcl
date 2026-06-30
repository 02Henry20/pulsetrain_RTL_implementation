
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

set icc2_output_path ../../../PNR/SS/pnr/outputs_icc2

set PDK /data/S28 

set std_library_path $PDK/library/ln28lpp_sc_9t_base_rvt_c130_V1.00c_pkg/FE-Common_sec190802_0203/LIBERTY

set io_library_path $PDK/library/ln28lpp_gpio_1p8v_V1.00a_pkg/FE-Common_sec190321_0300/LIBERTY/synopsys

set RAM_path "$PDK/library/memory/batch_script/FE-Common_sec190812_0141/MemoryCompiler_FE/batch_script/bin/cmos28lpp_rf1_hd_1024x32m4 \
$PDK/library/memory/batch_script/FE-Common_sec190812_0141/MemoryCompiler_FE/batch_script/bin/cmos28lpp_rf1_hd_512x32m2 \
"

# For the following variables, use a blank space to separate multiple entries.
# Example: set TARGET_LIBRARY_FILES "lib1.db lib2.db lib3.db"

set ADDITIONAL_SEARCH_PATH        "$icc2_output_path \
                                   $std_library_path \
                                   $io_library_path \
                                   $RAM_path "

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

#set MW_REFERENCE_LIB_DIRS         "$LIB_DIR/MilkyWay/ICC/cmos10lprvt_m \
                                   $LIB_DIR/MilkyWay/ICC/Power_IO "
#  Milkyway reference libraries (include IC Compiler ILMs here)

set MW_REFERENCE_CONTROL_FILE     ""  ;#  Reference Control file to define the Milkyway reference libs

set TECH_FILE                   "$LIB_DIR/TECH/LN28LPP_ICC_S00-V2.0.8.0/7U1x_2T8x_LB/sc9_cmos28lpp_7U1x_2T8x_LB.icc2.tf"

set MAP_FILE                    "$LIB_DIR/TECH/LN28LPP_ICC_S00-V2.0.8.0/7U1x_2T8x_LB/28lpp_7U1x_2T8x_LB.map"

set TLUPLUS_MAX_FILE            "$LIB_DIR/TECH/LN28LPP_ICC_S00-V2.0.8.0/7U1x_2T8x_LB/28lpp_7U1x_2T8x_LB_SigRCmax_detailed.tlup"

set TLUPLUS_MIN_FILE            "$LIB_DIR/TECH/LN28LPP_ICC_S00-V2.0.8.0/7U1x_2T8x_LB/28lpp_7U1x_2T8x_LB_SigRCmin_detailed.tlup"

set PARASITIC_PATHS "../../../StarRC/max/results"

set PARASITIC_FILES "RC_MAX.spef"

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
#


### pt_setup.tcl file              ###





### Start of PrimeTime Runtime Variables ###

##########################################################################################
# PrimeTime Variables PrimeTime Reference Methodology script
# Script: pt_setup.tcl
# Version: M-2017.06-SP2 (Nov 9, 2017)
# Copyright (C) 2008-2017 Synopsys All rights reserved.
##########################################################################################


######################################
# Report and Results Directories
######################################


set REPORTS_DIR "reports"
set RESULTS_DIR "results"


######################################
# Library and Design Setup
######################################

### Mode : Generic

set search_path ". $ADDITIONAL_SEARCH_PATH $search_path"
set target_library $TARGET_LIBRARY_FILES
set link_path "* $target_library $ADDITIONAL_LINK_LIB_FILES"

# DESIGN_NAME is checked for existence from common_setup.tcl
if {[string length $DESIGN_NAME] > 0} {
} else {
set DESIGN_NAME                   "TOP_PREV"  ;#  The name of the top-level design
}








######################################
# Constraint Section Setup
######################################
set CONSTRAINT_FILES     "../../../PNR/SS/pnr/outputs_icc2/TOP_PREV_mode_norm.OC_rvt_tt_max_1p000v_25c.RC_MAX.sdc"  







######################################
# ECO FLOW Setup
######################################
#
#Tool License Setting
# Tool License (get it from linux enviroment)
#set SNPSLMD_LICENSE_FILE ""
#
# Submit Job to the farm
# Submit Job CSH file. Ex: /remote/sge/cells/snps/common/settings.csh
#set SETTING_QSUB_CSH ""

# Qsub command for STAR_RC. Ex: /remote/sge8/default/bin/lx-amd64/qsub -j y -P bhigh -cwd 
#set STAR_QSUB ""

# Qsub command for ICC. It can be like STAR_QSUB or rsh to the current host.
#set ICC_QSUB ""

#
# Tool executable
# ICC Tool executable. Ex: /tools/icc/bin/icc_shell
set ICC_EXEC "/tools/Synopsys/ICC2/icc2/P-2019.03-SP5/bin/icc2_shell"

# STAR RC Tool executable. EX: /tools/starrc/bin/StarXtract
set STAR_RC_EXEC "/tools/Synopsys/StarRC/starrc/Q-2019.12-SP5-2/bin/StarXtract"

#
#-----------------------------------------
# ICC/ICC2 Seeting
#-----------------------------------------
#
# ICC working directory (Need write permission)
set ICC_DIR "../../../PNR/SS/pnr"

#setup file for ICC/ICC2 (library, tlu+...) canbe RM setup and init files.
set ICC_SETUP "../../../PNR/SS/pnr/rm_setup/icc2_pnr_setup.tcl"

# milkyway lib
set MW_LIB ""

# milkyway Cel for PT
set MW_CEL ""

#NDM lib for ICC2
set NDM_LIB "$ICC_DIR/TOP_PREV"

#NDM BLOCK for ICC2
set NDM_BLOCK "TOP_PREV/write_data"

#
# Variable for current design (It is the same for DESIGN_NAME in common_setup.tcl)
set CURRENT_DESIGN $DESIGN_NAME

#
#-----------------------------------------
# starRC
#-----------------------------------------
#
# Run Multiple corners/Temperatures. Using arrays to define other corners
#-------------------------
# Mapping File
set MAPPING_FILE(0) "/data/S28/tech/starrc/CELL_LEVEL/LN28LPP_StarRC_Cell_S00-V1.1.0.1_SEC2.0.6.0/tcad/7U1x_2T8x_LB/ln28lpp_7U1x_2T8x_LB_Cell.map"

# GRD file
set TCAD_GRD_FILE(0) "/data/S28/tech/starrc/CELL_LEVEL/LN28LPP_StarRC_Cell_S00-V1.1.0.1_SEC2.0.6.0/tcad/7U1x_2T8x_LB/ln28lpp_7U1x_2T8x_LB_SigRCmax_detailed.nxtgrd"

# Additional info. Ex temperature, voltage
set STARRC_ADDITIONAL(0) "mode_norm.OC_rvt_tt_max_1p000v_25c.RC_MAX"

#-------------------------
#
set STAR_RC_PATH "/tools/Synopsys/StarRC/starrc/Q-2019.12-SP5-2/bin"
#


######################################
# End
######################################

### End of PrimeTime Runtime Variables ###
