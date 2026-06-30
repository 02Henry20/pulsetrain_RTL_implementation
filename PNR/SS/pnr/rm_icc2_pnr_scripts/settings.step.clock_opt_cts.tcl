puts "RM-info: Running script [info script]\n"

##########################################################################################
# Tool: IC Compiler II
# Script: settings.step.clock_opt_cts.tcl
# Purpose: Settings recommended to be enabled at the start of clock_opt_cts
# Version: N-2017.09-SP2 (February 20, 2018)
# Copyright (C) 2014-2018 Synopsys, Inc. All rights reserved.
##########################################################################################

####################################
## PPA - Performance focused features
####################################
## clock_opt CCD (RM default true)
#  Enables concurrent clock and data optimization (CCD) during clock_opt
#  Note: CCD flow by default enables local skew CTS/CTO under the hood.
#  For non-CCD flow, to improve local skew of timing critical register pairs,
#  uncomment the following to enable local skew optimization during CTS and CTO:
#	set_app_options -name cts.compile.enable_local_skew -value true
#	set_app_options -name cts.optimize.enable_local_skew -value true
puts "RM-info: Setting clock_opt.flow.enable_ccd to $CLOCK_OPT_CCD (tool default false)"
set_app_option -name clock_opt.flow.enable_ccd -value $CLOCK_OPT_CCD

#  Note: clock_opt CCD by default also enables the clock SI prevention feature in CTS
#  in order to minimize the impact of SI from/on clock nets at postroute.
#  For non-CCD flow, the same feature can be turned on by uncommenting the following application
#  options:
#	set_app_options -name cts.optimize.enable_congestion_aware_ndr_promotion -value true

####################################
## PPA - Power focused features
####################################
## Enable power or area recovery from clock cells and registers during clock_opt (optional)
#  By default, it is set to auto which means in CCD flow, power recovery is on for the wns phase of clock_opt; 
#  while in non-CCD flow, auto means none.
puts "RM-info: Setting clock_opt.flow.enable_clock_power_recovery to $CLOCK_OPT_POWER_RECOVERY (tool default auto)"
set_app_option -name clock_opt.flow.enable_clock_power_recovery -value $CLOCK_OPT_POWER_RECOVERY

####################################
## Congestion focused features
####################################
if {$HIGH_CONNECTIVITY_FOCUSED} {
	## GR-based CTS: congestion estimation and congestion-aware path finder for clock_opt build_clock phase
	#  Enabled for better congestion estimation
	puts "RM-info: Setting cts.compile.enable_global_route to true (tool default false)" 
	set_app_option -name cts.compile.enable_global_route -value true

	## Coarse placement effort for clock_opt final_opto phase
	#  Enabled for better placement quality
	puts "RM-info: Setting clock_opt.place.effort to high (tool default medium)"
	set_app_option -name clock_opt.place.effort -value high

	## Congestion effort for clock_opt final_opto phase
	#  Enabled for better congestion alleviation
	puts "RM-info: Setting clock_opt.congestion.effort to high (tool default medium)"
	set_app_option -name clock_opt.congestion.effort -value high
}

puts "RM-info: Completed script [info script]\n"

