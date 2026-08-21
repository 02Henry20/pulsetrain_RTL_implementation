##########################################################################################
# Tool: IC Compiler II
# Script: in_design_pnr_rail_analysis.tcl
# Version: N-2017.09-SP2 (February 20, 2018)
# Copyright (C) 2018 Synopsys, Inc. All rights reserved.
##########################################################################################

source -e ./rm_setup/icc2_pnr_setup.tcl 

open_lib $DESIGN_LIBRARY 
open_block $PRIMERAIL_ANALYSIS_FROM_BLOCK_NAME 

read_parasitic_tech -tlup $PRIMERAIL_TLUPLUS_FILE -layermap $PRIMERAIL_MAP_FILE -name parasictic_specA

set_parasitic_parameters -corners [$PRIMERAIL_PARASITIC_CORNER] -early_spec parasictic_specA -late_spec parasictic_specA

if {$PRIMERAIL_HOST_MACHINE != ""} {
	set_host_options -name $PRIMERAIL_HOST_MACHINE
}

if {$PRIMERAIL_DIR == ""} {
	set PRIMERAIL_DIR [file dirname [sh which pr_shell]]
}

if {[which $PRIMERAIL_DIR/pr_shell] == "" } {
	puts "RM-error: Unable to find pr_shell at \"$PRIMERAIL_DIR\". Exiting...."
	exit 
}

set_app_options -name rail.pr_shell_path -value $PRIMERAIL_DIR 

if {[file exists [which $PRIMERAIL_PAD_FILE]]} {
	create_taps -import $PRIMERAIL_PAD_FILE
} else {
	create_taps -top_pg
}

start_gui

#############################################################
## Define Integrity Strategies                             ##
#############################################################
set_rail_integrity_strategy Floating_Shape \
	-nets $PRIMERAIL_ANALYSIS_NETS  \
	-non_ideal_sourced_floating_shapes \
	-core \
	-area_edge_condition touching

set_rail_integrity_strategy Floating_Pin_Shape \
	-nets $PRIMERAIL_ANALYSIS_NETS \
	-error_data Floating_Pin_Shape \
	-pg_pin_floating_connection_check maximal \
	-core \
	-area_edge_condition touching

## Users to enter the metals to check for disconnectivity.  Below, the example is "ALL" (for all metal layers).
set_rail_integrity_strategy Disconn \
	-nets  $PRIMERAIL_ANALYSIS_NETS  \
	-core \
	-area_edge_condition touching \
	-enable_discontinuous_connection_check \
	-discontinuous_connection_threshold { {ALL 10 } } \
	-discontinuous_connection_directionality { {ALL HV } }


## Users to enter the 2 metal layers to be checked for missing vias.  Below, the example is "ALL" (for all metal layers).
set_rail_integrity_strategy missing_via \
	-nets  $PRIMERAIL_ANALYSIS_NETS \
	-missing_via_rule { {ALL} ALL {ALL} ALL } \
	-via_existence_check_partially_enclosed \
	-core \
	-missing_via_net_shape_direction perpendicular \
	-existing_stacked_via_check_mode via_cut \
	-area_edge_condition touching

set_rail_integrity_strategy dangling_pin_shapes \
	-nets  $PRIMERAIL_ANALYSIS_NETS \
	-dangling_pin_shape_edge_check

set_rail_integrity_strategy dangling_vias \
	-nets  $PRIMERAIL_ANALYSIS_NETS \
	-ideal_sourced_dangling_vias


## Run Integrity Analysis ###
verify_rail_integrity -integrity_layout_strategies {Floating_Shape Floating_Pin_Shape Disconn missing_via dangling_pin_shapes dangling_vias}

## Report and Write Integrity Strategies ###
report_rail_integrity_strategy
write_rail_integrity_strategy -output integrity_strategies.tcl

## gui_close_window -all

print_message_info -ids * -summary
echo [date] > in_design_pnr_rail_analysis

exit 


