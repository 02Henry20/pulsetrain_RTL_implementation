

### pwr_setup.tcl file              ###





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

# Provide list of Verilog netlist files. It can be compressed --- example "A.v B.v C.v"
set NETLIST_FILES               "../../../PNR/SS/pnr/outputs_icc2/write_data.v.gz \
"

# DESIGN_NAME is checked for existence from common_setup.tcl
if {[string length $DESIGN_NAME] > 0} {
} else {
set DESIGN_NAME                   ""  ;#  The name of the top-level design
}




#######################################
# Non-DMSA Power Analysis Setup Section
#######################################

# switching activity (VCD/SAIF) file 
set ACTIVITY_FILE "../../../SIM/POST/MAX/TOP_PREV.saif"

# strip_path setting for the activity file
set STRIP_PATH "TB_TOP_PREV/U_TOP_PREV"

## name map file
set NAME_MAP_FILE ""




######################################
# Back Annotation File Section
######################################
# The recommended order is to put the block spefs first then the top so that block spefs are read 1st then top
# For example 
# PARASITIC_FILES "blk1.gpd blk2.gpd ... top.gpd"
# PARASITIC_PATHS "u_blk1 u_blk2 ... top"
# If you are loading the node coordinates by setting read_parasitics_load_locations true, it is more efficient
# to read the top first so that block coordinates can be transformed as they are read in
# Each PARASITIC_PATH entry corresponds to the related PARASITIC_FILE for the specific block"  
# For toplevel PARASITIC file please use the toplevel design name in PARASITIC_PATHS variable."   
#set PARASITIC_PATHS "/home/smkcow/QnA/digital/example_smkcow_DC_ICC2_28_2020/memory_wrapper/StarRC/min/results"
#set PARASITIC_FILES "RC_MIN.spef"

set PARASITIC_PATHS	 "TOP_PREV" 

set PARASITIC_PATHS	 "../../../StarRC/max/results/RC_MAX.spef" 

######################################
# Constraint Section Setup
######################################
#set CONSTRAINT_FILES     ""  

set CONSTRAINT_FILES     "../../../PNR/SS/pnr/outputs_icc2/TOP_PREV_mode_norm.OC_rvt_tt_max_1p000v_25c.RC_MAX.sdc"  







######################################
# End
######################################

### End of PrimeTime Runtime Variables ###
puts "RM-Info: Completed script [info script]\n"
