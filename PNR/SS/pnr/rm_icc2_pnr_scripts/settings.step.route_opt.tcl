puts "RM-info: Running script [info script]\n"

##########################################################################################
# Script: settings.step.route_opt.tcl
# Version: N-2017.09-SP2 (February 20, 2018)
# Copyright (C) 2014-2018 Synopsys, Inc. All rights reserved.
##########################################################################################

####################################
## Timing
####################################
## Enable delay calculation using CCS receiver model during timing analysis (RM default true)
puts "RM-info: Setting time.enable_ccs_rcv_cap to true (tool default false)"
set_app_options -name time.enable_ccs_rcv_cap -value true

## Enable CCS waveform analysis (AWP) on the entire design
#  Recommended for designs with advanced technology nodes.
#  Note :
#  - CCS waveform analysis requires libraries that contain CCS timing and CCS noise data.
#    Contact Synopsys if you require assistance to fine tune AWP usage on your design.
#	set_app_options -name time.delay_calc_waveform_analysis_mode -value full_design
#  
#  - To make use of the new AWP algorithm, please set the following.
#    Default true enables original AWP engine. Set it to false enables new engine that is more aligned to primetime results.
#	set_app_options -name time.awp_compatibility_mode -value false ;# tool default true

####################################
## PPA - Performance focused features
####################################
## route_opt CCD and buffer removal during CCD (RM default true)
#  Note: Global-scoped and needs to be re-applied in a new session
puts "RM-info: Setting route_opt.flow.enable_ccd and ccd.post_route_buffer_removal to $ROUTE_OPT_CCD (tool default false)"
set_app_option -name route_opt.flow.enable_ccd -value $ROUTE_OPT_CCD
set_app_option -name ccd.post_route_buffer_removal -value $ROUTE_OPT_CCD

####################################
## PPA - Power focused features
####################################
## Leakage optimization during route_opt (RM default true)
#  Global-scoped and needs to be re-applied in a new session
puts "RM-info: Setting route_opt.flow.enable_power to $ROUTE_OPT_LEAKAGE_POWER_OPTIMIZATION (tool default false)"
set_app_options -name route_opt.flow.enable_power -value $ROUTE_OPT_LEAKAGE_POWER_OPTIMIZATION

## Enable power or area recovery from clock cells and registers during route_opt (RM default power)
puts "RM-info: Setting route_opt.flow.enable_clock_power_recovery to $ROUTE_OPT_POWER_RECOVERY (tool default none)"
set_app_option -name route_opt.flow.enable_clock_power_recovery -value $ROUTE_OPT_POWER_RECOVERY

####################################
## route_opt CTO for non-CCD flow
####################################
if {$ROUTE_OPT_CTO && !$ROUTE_OPT_CCD} {
	puts "RM-info: Setting route_opt.flow.enable_cto to true (tool default false)"
	set_app_options -name route_opt.flow.enable_cto -value true ;# global-scoped and needs to be re-applied in a new session
}

####################################
## ECO route 
####################################
## To disable soft-rule-based timing optimization during ECO routing, uncomment the following.
#  This is to limit spreading which can impact convergence by touching multiple routes.
#	set_app_options -name route.detail.eco_route_use_soft_spacing_for_timing_optimization -value false

## ECO router control : 
#  route_opt default is 5. The following adds more S&R for each iteration of eco route in route_opt. 
#  This is useful at 20nm and below for better DRC reduction and less calls to router 
puts "RM-info: Setting route.detail.eco_max_number_of_iterations to 10 (tool default -1)"
set_app_options -name route.detail.eco_max_number_of_iterations -value 10 

####################################
## Incremental reshielding 
####################################
if {$ROUTE_AUTO_CREATE_SHIELDS != "none" && $ROUTE_OPT_RESHIELD == "incremental"} {
	puts "RM-info: Setting route.common.reshield_modified_nets to reshield (tool default off)"
	set_app_options -name route.common.reshield_modified_nets -value reshield
}

puts "RM-info: Completed script [info script]\n"

