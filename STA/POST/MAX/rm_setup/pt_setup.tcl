

### pt_setup.tcl file              ###





puts "RM-Info: Running script [info script]\n"
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
puts "RM-Info: Completed script [info script]\n"
