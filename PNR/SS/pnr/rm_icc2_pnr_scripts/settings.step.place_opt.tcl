puts "RM-info: Running script [info script]\n"

##########################################################################################
# Tool: IC Compiler II
# Script: settings.step.place_opt.tcl
# Version: N-2017.09-SP2 (February 20, 2018)
# Copyright (C) 2014-2018 Synopsys, Inc. All rights reserved.
##########################################################################################

####################################
## Timing
####################################
## clock-to-data analysis (RM default is true)
puts "RM-info: Setting time.enable_clock_to_data_analysis to true (tool default false)"
set_app_options -name time.enable_clock_to_data_analysis -value true

####################################
## PPA - Performance focused features (place_opt)
####################################
## Path opt (RM default is true)
#  Performs register location optimization for better timing
puts "RM-info: Setting place_opt.flow.do_path_opt to $PLACE_OPT_DO_PATH_OPT (tool default false)"
set_app_option -name place_opt.flow.do_path_opt -value $PLACE_OPT_DO_PATH_OPT

## Final coarse placement effort level (RM default is high)
puts "RM-info: Setting place_opt.final_place.effort to $PLACE_OPT_FINAL_PLACE_EFFORT (tool default medium)"
set_app_option -name place_opt.final_place.effort -value $PLACE_OPT_FINAL_PLACE_EFFORT

## Effort level for congestion alleviation in place_opt (RM default is high)
#  Expect run time increase at high effort.
puts "RM-info: Setting place_opt.congestion.effort to $PLACE_OPT_CONGESTION_EFFORT (tool default medium)"
set_app_option -name place_opt.congestion.effort -value $PLACE_OPT_CONGESTION_EFFORT
 
## GR-based HFS DRC (RM default is enabled) 
#  Run global route based buffering during HFS/DRC fixing. Global routes are deleted after buffering. 
#  This is especially useful for fragmented and narrow-channelled floorplans.
if {$PLACE_OPT_GR_BASED_HFSDRC} {
	puts "RM-info: Setting place_opt.initial_drc.global_route_based to 1 (tool default 0)"; set_app_option -name place_opt.initial_drc.global_route_based -value 1
} else {
	puts "RM-info: Setting place_opt.initial_drc.global_route_based to 0 (tool default 0)"; set_app_option -name place_opt.initial_drc.global_route_based -value 0
}

## RM default runs atomic commands such as "create_placement -use_seed_locs" and 
#  "place_opt -from initial_drc" during place_opt step. To prevent place_opt.flow.do_spg from accidentally being set and 
#  making initial_drc phase skipped during "place_opt -from initial_drc", place_opt.flow.do_spg is reset to false.
puts "RM-info: Resetting place_opt.flow.do_spg"
reset_app_options place_opt.flow.do_spg

## Enable high CPU effort level for coarse placements invoked in refine_opt (optional)
puts "RM-info: Setting refine_opt.place.effort to $PLACE_OPT_REFINE_OPT_EFFORT (tool default medium)"
set_app_options -name refine_opt.place.effort -value $PLACE_OPT_REFINE_OPT_EFFORT

## place_opt CCD (optional)
#  Enables concurrent clock and data optimization (CCD) during place_opt final_opto phase.
#  If PLACE_OPT_OPTIMIZE_ICGS or PLACE_OPT_TRIAL_CTS is also enabled, place_opt CCD
#  will be based on propagated early clocks.
puts "RM-info: Setting place_opt.flow.enable_ccd to $PLACE_OPT_CCD (tool default false)"
set_app_option -name place_opt.flow.enable_ccd -value $PLACE_OPT_CCD

## Auto bound for ICG placement (optional)
#  Can be enabled along with PLACE_OPT_OPTIMIZE_ICGS
puts "RM-info: Setting place.coarse.icg_auto_bound to $PLACE_OPT_ICG_AUTO_BOUND (tool default false)"
set_app_option -name place.coarse.icg_auto_bound -value $PLACE_OPT_ICG_AUTO_BOUND

## Clock-aware placement (optional)
#  Enabled only if PLACE_OPT_OPTIMIZE_ICGS is not enabled since tool will enable this feature automatically,
#  if PLACE_OPT_OPTIMIZE_ICGS is enabled
if {$PLACE_OPT_CLOCK_AWARE_PLACEMENT && !$PLACE_OPT_OPTIMIZE_ICGS} {
	puts "RM-info: Setting place_opt.flow.clock_aware_placement to true (tool default false)"; set_app_options -name place_opt.flow.clock_aware_placement -value true
} elseif {!$PLACE_OPT_CLOCK_AWARE_PLACEMENT} {
	puts "RM-info: Setting place_opt.flow.clock_aware_placement to false (tool default false)"; set_app_options -name place_opt.flow.clock_aware_placement -value false
}

## To create a buffer-only blockage, follow the example below.
#  The area covered by a buffer-only blockage can only be used by buffers and inverters, which is honored by placement.
#  -blocked_percentage 0 means that 100% of the area can be used by buffers and inverters.
#  -blocked_percentage 100 means that 0% of the area can be used by buffers and inverters. 
#   (as a result, no standard cells can be placed under a buffer only blockage with -blocked_percentage 100).
#
#  Example for creating a buffer only blockage with 100% of the area open to repeaters : 
#	create_placement_blockage -name placement_blockage_1 -type allow_buffer_only -blocked_percentage 0 \
#       -boundary { {x1 y1} {x2 y2} }

puts "RM-info: Completed script [info script]\n"

