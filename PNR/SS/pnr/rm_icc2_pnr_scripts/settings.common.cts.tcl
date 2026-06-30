puts "RM-info: Running script [info script]\n"

##########################################################################################
# Tool: IC Compiler II
# Script: settings.common.cts.tcl
# Purpose: Common CTS related settings that can be sourced in clock_opt_cts or place_opt
# Version: N-2017.09-SP2 (February 20, 2018)
# Copyright (C) 2014-2018 Synopsys, Inc. All rights reserved.
##########################################################################################

####################################
## Timer
####################################
## CRPT (RM default is true)
puts "RM-info: Setting time.remove_clock_reconvergence_pessimism to true (tool default false)"
set_app_options -name time.remove_clock_reconvergence_pessimism -value true

####################################
## Power
####################################
## Enable low power improvement techniques during CTS (optional)
puts "RM-info: Setting cts.common.enable_low_power to $CTS_LOW_POWER (tool default false)"
set_app_options -name cts.common.enable_low_power -value $CTS_LOW_POWER

####################################
## CTS max transition and capacitance 
####################################
# Here are the examples :
# set cur_mode [current_mode]
#	foreach_in_collection m [all_modes] {
#		current_mode $m
#		set_max_transition -clock_path 0.15 [all_clocks]
#		set_max_capacitance -clock_path 0.5 [all_clocks]
#	}
# current_mode $cur_mode 

####################################
## CTS target skew and latency 
####################################
# By default CTS targets best skew and latency. These options can be used in case user wants to relax the target.
#	Example : set_clock_tree_options -clocks [get_clocks clk -mode Mode1] -corner Corner1WC -target_latency 1 -target_skew 0.3

####################################
## CTS balance points 
####################################
# To modify the clock tree balancing requirements
#	Example : set_clock_balance_points -delay 2.0 -balance_point gck/CP ;# -clock option is not mandatory

####################################
## CTS skew groups 
####################################
# Create user-defined skew groups which usually are to improve timing
#	Example : 
#	foreach_in_collection m [all_modes] {
#		create_clock_skew_group -name [get_object_name ${m}]_grp1 -mode $m -objects "reg1/clk reg2/clk"
#	}

####################################
## CTS ICDB (Inter-clock delay balancing) constraints
####################################
#  ICDB is performed automatically in build_clock phase of clock_opt
#  Use create_clock_balance_group to control it. For ex,
#	foreach_in_collection m [all_modes] {
#		current_mode $m
#		create_clock_balance_group -objects {clk1 clk2} -name group1 -offset_latencies {0.0 -0.5}
#	}

####################################
## CTS Latency adjustments for compute_clock_latency
####################################
## For clock_opt non-CCD flow, compute_clock_latency is performed automatically in route_clock phase of clock_opt
#  For clock_opt CCD flow, compute_clock_latency is performed automatically during both build_clock and route_clock phases.
#  For place_opt with trial_clock or optimize_icgs enabled, compute_clock_latency is performed automatically during place_opt.
#  However you have to use set_latency_adjustment_options to control it. For ex, to associate virtual clocks to real clocks :

# smkcow !! so important to make latency value to be non-0 at make output, input ports during set_propagated_clocks [all_clocks]
#foreach_in_collection m [all_modes] {
#	current_mode $m
		#set_latency_adjustment_options -reference_clock <real_clock> -clocks_to_update <virtual_clock>
		#set_latency_adjustment_options -reference_clock MAIN_CLOCK -clocks_to_update VCK 
#	}

####################################
## CTS cells and restrictions 
####################################
## derive_clock_cell_references
#  Check non-repeater cells on clock trees and suggest logically equivalent cells for CTS to use
# 	derive_clock_cell_references -output refs.tcl
#  Edit refs.tcl and source it

## The following commands have been set in set_lib_cell_purpose.tcl. If you haven't done so, pls uncomment them here.
## CTS cells 
#	Please make sure you include always-on cells for MV-CTS, clock gate cells (for sizing),
#	and equivalent gates for other types of pre-existing clock cells such as muxes (for sizing).
#	You should also include flops (CCD can size them for timing improvement) in the list.
#	Here's an example if you want to include flops that are already available to optimization :
#	set_lib_cell_purpose -include cts [get_lib_cells */SDFF* -filter "valid_purposes=~*optimization*"]		 
# if {$CTS_LIB_CELL_PATTERN_LIST != "" || $CTS_ONLY_LIB_CELL_PATTERN_LIST != ""} {
# 	set_lib_cell_purpose -exclude cts [get_lib_cells */*]
# }
# 
# if {$CTS_LIB_CELL_PATTERN_LIST != ""} {
# 	set_dont_touch [get_lib_cells $CTS_LIB_CELL_PATTERN_LIST] false ;# In ICC-II, CTS respects dont_touch
# 	set_lib_cell_purpose -include cts [get_lib_cells $CTS_LIB_CELL_PATTERN_LIST]
# } 

## CTS-exclusive cells
#	These are the lib cells to be used by CTS exclusively, such as CTS specific buffers and inverters.
#	Please be aware that these cells will be applied with only cts purpose and nothing else.
#	If you want to use these lib cells for other purposes, such as optimization and hold,
#	specify them in CTS_LIB_CELL_PATTERN_LIST instead.
# if {$CTS_ONLY_LIB_CELL_PATTERN_LIST != ""} {
# 	set_dont_touch [get_lib_cells $CTS_ONLY_LIB_CELL_PATTERN_LIST] false ;# In ICC-II, CTS respects dont_touch
# 	set_lib_cell_purpose -include none [get_lib_cells $CTS_ONLY_LIB_CELL_PATTERN_LIST]
# 	set_lib_cell_purpose -include cts [get_lib_cells $CTS_ONLY_LIB_CELL_PATTERN_LIST]
# }

redirect -file ${REPORTS_DIR}/settings.common.cts.report_lib_cell_purpose.rpt {report_lib_cell -objects [get_lib_cells] -column {full_name:20 valid_purposes}}

# Set CTS dont touch cells	
if {$CTS_DONT_TOUCH_CELL_LIST != ""} {set_dont_touch $CTS_DONT_TOUCH_CELL_LIST true}

# Set CTS dont buffer nets	
if {$CTS_DONT_BUFFER_NET_LIST != ""} {set_dont_touch [get_nets -segments $CTS_DONT_BUFFER_NET_LIST] true}

# set CTS size only cells
if {$CTS_SIZE_ONLY_CELL_LIST != ""} {set_size_only $CTS_SIZE_ONLY_CELL_LIST true}

####################################
## CTS cell spacing 
####################################
# Apply placement based cell to cell spacing rule to avoid EM problem on P/G rails.
# This rule will be applied to the clock buffers/inverters, the clock gating cells only.
#	Example : set_clock_cell_spacing -x_spacing 0.9 -y_spacing 0.4 -lib_cells mylib/BUFFD2BWP

####################################
## CTS hierarchy preservation 
####################################
# To prevent CTS from punching new logical ports for logical hierarchies
#	Example : set_freeze_ports -clocks [get_cells {block1}]

puts "RM-info: Completed script [info script]\n"

