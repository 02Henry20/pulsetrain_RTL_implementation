puts "RM-info: Running script [info script]\n"

##########################################################################################
# Tool: IC Compiler II
# Script: settings.common.opt.tcl
# Purpose: Common settings applicable to multiple steps across the flow, such as opt, place,
#          and lib cell purpose related. Only sourced in place_opt.tcl.
# Version: N-2017.09-SP2 (February 20, 2018)
# Copyright (C) 2014-2018 Synopsys, Inc. All rights reserved.
##########################################################################################

########################################################################
## PPA - Performance focused features
########################################################################
## Timing optimization effort in preroute flows for better timing (RM default is high)
#  Makes tool spend more efforts on timing optimization
if {$PREROUTE_TIMING_OPTIMIZATION_EFFORT == "low" || $PREROUTE_TIMING_OPTIMIZATION_EFFORT == "medium" || $PREROUTE_TIMING_OPTIMIZATION_EFFORT == "high"} {
	puts "RM-info: Setting opt.timing.effort to $PREROUTE_TIMING_OPTIMIZATION_EFFORT (tool default low)"
	set_app_option -name opt.timing.effort -value $PREROUTE_TIMING_OPTIMIZATION_EFFORT
}
## Preroute automatic timing control placement (RM default is true)
#  Timing driven coarse placement will focus on timing optimization on the most critical timing paths, 
#  to find a good balance between reducing the worst slack and reducing the total negative slack.
#  Note that when enabled, it automatically triggers place.coarse.tns_driven_placement
puts "RM-info: Setting place.coarse.auto_timing_control to $PREROUTE_AUTO_TIMING_CONTROL_PLACEMENT (tool default false)"
set_app_options -name place.coarse.auto_timing_control -value $PREROUTE_AUTO_TIMING_CONTROL_PLACEMENT

## Layer optimization in preroute flows (optional)
#  enables automatic layer optimization that assigns long timing-critical nets to 
#  upper metal layers to improve timing; supported in final_opt stage rebuffering of place_opt,
#  and final path_opt stage of refine_opt; automatically disabled if GRLB is enabled. 
puts "RM-info: Setting place_opt/refine_opt.flow.optimize_layers to $PREROUTE_LAYER_OPTIMIZATION (tool default false)"
set_app_option -name place_opt.flow.optimize_layers -value $PREROUTE_LAYER_OPTIMIZATION
set_app_option -name refine_opt.flow.optimize_layers -value $PREROUTE_LAYER_OPTIMIZATION
if {$PREROUTE_LAYER_OPTIMIZATION_CRITICAL_RANGE != ""} {
	puts "RM-info: Setting place_opt.flow.optimize_layers_critical_range to $PREROUTE_LAYER_OPTIMIZATION_CRITICAL_RANGE (tool default 0.7)"
	set_app_options -name place_opt.flow.optimize_layers_critical_range -value $PREROUTE_LAYER_OPTIMIZATION_CRITICAL_RANGE ;# tool default 0.7
}

## NDR optimization in preroute (optional)
puts "RM-info: Setting place_opt/refine_opt/clock_opt.flow.optimize_ndr to $PREROUTE_NDR_OPTIMIZATION (tool default false)"
set_app_options -name place_opt.flow.optimize_ndr -value $PREROUTE_NDR_OPTIMIZATION ;# tool default false 
set_app_options -name refine_opt.flow.optimize_ndr -value $PREROUTE_NDR_OPTIMIZATION ;# tool default false 
set_app_options -name clock_opt.flow.optimize_ndr -value $PREROUTE_NDR_OPTIMIZATION ;# tool default false

## Set a soft fanout constraint for optimization of data path cells in place_opt and clock_opt (optional)
#  Optimization will try to ensure that cells do not drive more than max_fanout cells.
#  	set_app_options -name opt.common.max_fanout -value 40 ;# tool default 40

########################################################################
## PPA - Power focused features
########################################################################
## Set your threshold_voltage_group attributes. For example:
#  	define_user_attribute -type string -class lib_cell threshold_voltage_group
#  	set_attribute -quiet [get_lib_cells -quiet */*LVT] threshold_voltage_group LVt
#  	set_attribute -quiet [get_lib_cells -quiet */*RVT] threshold_voltage_group RVt
#  	set_attribute -quiet [get_lib_cells -quiet */*HVT] threshold_voltage_group HVt

## set_threshold_voltage_group_type is not persistent and should be defined in settings.common.non_persistent.tcl.
#  Listed here for your reference:
#  	set_threshold_voltage_group_type -type low_vt LVt
#  	set_threshold_voltage_group_type -type normal_vt RVt
#  	set_threshold_voltage_group_type -type high_vt HVt

## Power optimization mode (RM default is total to work on both dynamic and leakage power)
if {$PREROUTE_POWER_OPTIMIZATION_MODE == "leakage" || $PREROUTE_POWER_OPTIMIZATION_MODE == "dynamic" || $PREROUTE_POWER_OPTIMIZATION_MODE == "total" || $PREROUTE_POWER_OPTIMIZATION_MODE == "none"} {
	puts "RM-info: Setting opt.power.mode to $PREROUTE_POWER_OPTIMIZATION_MODE (tool default none)"
	set_app_option -name opt.power.mode -value $PREROUTE_POWER_OPTIMIZATION_MODE
}

## Percentage lvth flow  (optional)
#  By default, leakage optimization is mW-based. To enable percentage lvth flow, do the following:
#  Specifies the maximum percentage of low-threshold-voltage cells.
#	set_max_lvth_percentage %
#  Enable percentage_lvt leakage type
#	set_app_option -name opt.power.leakage_type -value percentage_lvt ;# default conventional

## Power optimization effort level (RM default is high)
if {$PREROUTE_POWER_OPTIMIZATION_EFFORT == "low" || $PREROUTE_POWER_OPTIMIZATION_EFFORT == "medium" || $PREROUTE_POWER_OPTIMIZATION_EFFORT == "high"} {
	puts "RM-info: Setting opt.power.effort to $PREROUTE_POWER_OPTIMIZATION_EFFORT (tool default low)"
	set_app_option -name opt.power.effort -value $PREROUTE_POWER_OPTIMIZATION_EFFORT
}

## Low power placement for preroute flows for better power reduction (RM default is true)
puts "RM-info: Setting place.coarse.low_power_placement to $PREROUTE_LOW_POWER_PLACEMENT (tool default false)"
set_app_option -name place.coarse.low_power_placement -value $PREROUTE_LOW_POWER_PLACEMENT

########################################################################
## PPA - Area focused features
########################################################################
## Area recovery effort for preroute optimization (RM default is high)
#  Note that TNS degradation can occur when set to higher levels
if {$PREROUTE_AREA_RECOVERY_EFFORT == "low" || $PREROUTE_AREA_RECOVERY_EFFORT == "medium" || $PREROUTE_AREA_RECOVERY_EFFORT == "high" || $PREROUTE_AREA_RECOVERY_EFFORT == "ultra"} {
	puts "RM-info: Setting opt.area.effort to $PREROUTE_AREA_RECOVERY_EFFORT (tool default low)"
	set_app_option -name opt.area.effort -value $PREROUTE_AREA_RECOVERY_EFFORT
}

## Buffer area reduction effort for preroute optimization (RM default is ultra) 
#  Note that QoR degradation can occur when set to higher levels
if {$PREROUTE_BUFFER_AREA_EFFORT == "low" || $PREROUTE_BUFFER_AREA_EFFORT == "medium" || $PREROUTE_BUFFER_AREA_EFFORT == "high" || $PREROUTE_BUFFER_AREA_EFFORT == "ultra"} {
	puts "RM-info: Setting opt.common.buffer_area_effort to $PREROUTE_BUFFER_AREA_EFFORT (tool default low)"
	set_app_option -name opt.common.buffer_area_effort -value $PREROUTE_BUFFER_AREA_EFFORT
}

## GR-based layer binning for preroute flows (RM default is true)
#  GR layer aware optimization during preroute for advanced technologies to mitigate pre and post-route mis-correlation.
#  If enabled, remove_route_aware_estimation will be triggered before the route_auto command
puts "RM-info: Setting opt.common.use_route_aware_estimation to $PREROUTE_ROUTE_AWARE_ESTIMATION (tool default false)"
set_app_option -name opt.common.use_route_aware_estimation -value $PREROUTE_ROUTE_AWARE_ESTIMATION

########################################################################
## Congestion and displacement handling features
########################################################################
## Enable keep going legalizer to improve legalizer turn-around time (optional)
#	set_app_option -name place.legalize.limit_legality_checks -value true ;# tool default false

## Channel detect mode in coarse placement (RM default is true)
puts "RM-info: Setting place.coarse.channel_detect_mode to $PREROUTE_PLACEMENT_DETECT_CHANNEL (tool default false)"
set_app_option -name place.coarse.channel_detect_mode -value $PREROUTE_PLACEMENT_DETECT_CHANNEL

## Detour detection during coarse placement (RM default is true)
puts "RM-info: Setting place.coarse.detect_detours to $PREROUTE_PLACEMENT_DETECT_DETOUR (tool default false)"
set_app_option -name place.coarse.detect_detours -value $PREROUTE_PLACEMENT_DETECT_DETOUR

## Automatic density control for the coarse placement (Optional to disable it)
#  Enables coarse placer to use a higher cell density in areas where that does not create routing congestion;
#  if place.coarse.max_density is 0, this feature selects an appropriate value for the maximum cell density;
#  message PLACE-027 is issued to report the selected settings 
puts "RM-info: Setting place.coarse.auto_density_control to $PREROUTE_PLACEMENT_AUTO_DENSITY (tool default true)"
set_app_option -name place.coarse.auto_density_control -value $PREROUTE_PLACEMENT_AUTO_DENSITY

## Coarse placement max density (optional)
#  Sets the maximum density for the coarse placement engine;
#  - when this value is set, coarse placer attempts to limit local cell density to be less than the value; 
#  - when the value is 0 (tool default) and
#	- when place.coarse.auto_density_control is true, tool will auto determine an appropriate value;
#	- when place.coarse.auto_density_control is false, tool will try to spread cells evenly
if {$PREROUTE_PLACEMENT_MAX_DENSITY != ""} {	
	puts "RM-info: Setting place.coarse.max_density to $PREROUTE_PLACEMENT_MAX_DENSITY"
	set_app_option -name place.coarse.max_density -value $PREROUTE_PLACEMENT_MAX_DENSITY
}

## Target routing density for congestion-driven placement (optional)
if {$PREROUTE_PLACEMENT_TARGET_ROUTING_DENSITY != ""} {
	puts "RM-info: Setting place.coarse.target_routing_density to $PREROUTE_PLACEMENT_TARGET_ROUTING_DENSITY"
	set_app_option -name place.coarse.target_routing_density -value $PREROUTE_PLACEMENT_TARGET_ROUTING_DENSITY
}

## Specify the maximum design utilization after congestion driven padding during congestion driven placement (optional)
if {$PREROUTE_PLACEMENT_MAX_UTIL != ""} {
	puts "RM-info: Setting place.coarse.congestion_driven_max_util to $PREROUTE_PLACEMENT_MAX_UTIL" 
	set_app_option -name place.coarse.congestion_driven_max_util -value $PREROUTE_PLACEMENT_MAX_UTIL
}

## Pin density aware placement for preroute flows (optional)
#  For designs with pin access and local density hot spot issues. 
puts "RM-info: Setting place.coarse.pin_density_aware to $PREROUTE_PLACEMENT_PIN_DENSITY_AWARE (tool default false)" 
set_app_option -name place.coarse.pin_density_aware -value $PREROUTE_PLACEMENT_PIN_DENSITY_AWARE

## Congestion-driven restructuring (CDR) effort level
#  (RM sets it to ultra if HIGH_CONNECTIVITY_FOCUSED is true)
if {$HIGH_CONNECTIVITY_FOCUSED} {
	puts "RM-info: Setting place.coarse.cong_restruct_effort to ultra (tool default medium)"
	set_app_option -name place.coarse.cong_restruct_effort -value ultra
}

########################################################################
## Lib cell usage restrictions (set_lib_cell_purpose)
########################################################################
## By default, RM sources set_lib_cell_purpose.tcl to handle lib cell purpose related restrictions,
#  which include dont use, tie cells, hold fixing, CTS and CTS-exclusive cells. 
#  Refer to set_lib_cell_purpose.tcl for complete details.
#  You can also replace it with your own script by specifying the TCL_LIB_CELL_PURPOSE_FILE variable.  
if {[file exists [which $TCL_LIB_CELL_PURPOSE_FILE]]} {
	puts "RM-info: Sourcing [which $TCL_LIB_CELL_PURPOSE_FILE]"
	source $TCL_LIB_CELL_PURPOSE_FILE
} elseif {$TCL_LIB_CELL_PURPOSE_FILE != ""} {
	puts "RM-error: TCL_LIB_CELL_PURPOSE_FILE($TCL_LIB_CELL_PURPOSE_FILE) is invalid. Pls correct it."
}

## The following variables which handle dont use, tie cells, hold fixing, CTS and CTS-exclusive cells,
#  are only valid if set_lib_cell_purpose.tcl is used. If you are using your own script for
#  TCL_LIB_CELL_PURPOSE_FILE, the following variables will not take effect 
if {$TCL_LIB_CELL_PURPOSE_FILE != "set_lib_cell_purpose.tcl"} {
	if {$TCL_LIB_CELL_DONT_USE_FILE != ""} {
		puts "RM-warning: TCL_LIB_CELL_DONT_USE_FILE is specified but TCL_LIB_CELL_PURPOSE_FILE is not set to set_lib_cell_purpose.tcl."
		puts "RM-warning: TCL_LIB_CELL_DONT_USE_FILE will not apply."
	}
	if {$TIE_LIB_CELL_PATTERN_LIST != ""} {
		puts "RM-warning:  TIE_LIB_CELL_PATTERN_LIST is specified but TCL_LIB_CELL_PURPOSE_FILE is not set to set_lib_cell_purpose.tcl."
		puts "RM-warning:  TIE_LIB_CELL_PATTERN_LIST will not apply."
	}
	if {$HOLD_FIX_LIB_CELL_PATTERN_LIST != ""} {
		puts "RM-warning:  HOLD_FIX_LIB_CELL_PATTERN_LIST is specified but TCL_LIB_CELL_PURPOSE_FILE is not set to set_lib_cell_purpose.tcl."
		puts "RM-warning:  HOLD_FIX_LIB_CELL_PATTERN_LIST will not apply."
	}
	if {$CTS_LIB_CELL_PATTERN_LIST != ""} {
		puts "RM-warning:  CTS_LIB_CELL_PATTERN_LIST is specified but TCL_LIB_CELL_PURPOSE_FILE is not set to set_lib_cell_purpose.tcl."
		puts "RM-warning:  CTS_LIB_CELL_PATTERN_LIST will not apply."
	}
	if {$CTS_ONLY_LIB_CELL_PATTERN_LIST != ""} {
		puts "RM-warning:  CTS_ONLY_LIB_CELL_PATTERN_LIST is specified but TCL_LIB_CELL_PURPOSE_FILE is not set to set_lib_cell_purpose.tcl."
		puts "RM-warning:  CTS_ONLY_LIB_CELL_PATTERN_LIST will not apply."
	}
}

########################################################################
## Additional optimization related settings
########################################################################
## To ensure no Verilog assigns in the output netlist of place_opt (RM default is true)
puts "RM-info: Setting opt.port.eliminate_verilog_assign to true (tool default false)"
set_app_options -name opt.port.eliminate_verilog_assign -value true

## Allow coarse placement to continue if there's no valid SCANDEF loaded in the design (optional)
## smkcow :: this options is important. Otherwise, there will be an error ::: the place_opt failed during congestion-mode timing-driven placement.
        set_app_options -name place.coarse.continue_on_missing_scandef -value true ;# tool default false
#	set_app_options -name place.coarse.continue_on_missing_scandef -value true ;# tool default false

## To disable DFT optimization (optional)
#	set_app_options -name opt.dft.optimize_scan_chain -value false ;# tool default true

## To invoke clock driver aware DFT optimization in clock_opt final_opto phase  (optional)
#  Typically results in scan connection structure with reduced hold violations along scan path,
#  at cost of increased total scan net length and potentially degraded timing
#	set_app_options -name  opt.dft.clock_aware_scan -value true ;# tool default false

## To prevent optimization from modifying the ports  (optional)
#  Specify a list of cells, such as clock gen or customized logics, where existing ports should be preserved or new ports should not be punched.
#  Useful if you do formal verification by modules.
if {$OPTIMIZATION_FREEZE_PORT_LIST != ""} {
	puts "RM-info: Setting opt.dft.hier_preservation to true (tool default false)"
	set_app_options -name opt.dft.hier_preservation -value true ;# honors hierarchy port preservation during dft optimization
	set_freeze_port -all [get_cells $OPTIMIZATION_FREEZE_PORT_LIST] ;# sets freeze_clock_ports and freeze_data_ports attributes on the specified cells
}

########################################################################
## Legalization related settings
########################################################################
## Placement spacing labels and rules 
#  Example : set_placement_spacing_label -name X -side both -lib_cells [get_lib_cells -of [get_cells]]
#  Example : set_placement_spacing_rule -labels {X SNPS_BOUNDARY} {0 1}
if {[file exists [which $TCL_PLACEMENT_SPACING_LABEL_RULE_FILE]]} {
	puts "RM-info: Sourcing [which $TCL_PLACEMENT_SPACING_LABEL_RULE_FILE]"
	source $TCL_PLACEMENT_SPACING_LABEL_RULE_FILE
} elseif {$TCL_PLACEMENT_SPACING_LABEL_RULE_FILE != ""} {
	puts "RM-error: TCL_PLACEMENT_SPACING_LABEL_RULE_FILE($TCL_PLACEMENT_SPACING_LABEL_RULE_FILE) is invalid. Pls correct it."
}

## Soft blockage enhancement : to prevent incremental coarse placer from moving cells out of soft blockages
#	set_app_options -name place.coarse.enable_enhanced_soft_blockages -value true

## Stream placement (optional)
#  For each large displacement cell, it attempts to move out other cells to make room,
#  such that a single very large displacement is replaced by a stream of small displacements
puts "RM-info: Setting place.legalize.stream_place to $PREROUTE_PLACEMENT_STREAM_LEGALIZER (tool default false)"
set_app_options -name place.legalize.stream_place -value $PREROUTE_PLACEMENT_STREAM_LEGALIZER

## Orientation optimization (optional)
#  Legalizer will consider flipping the orientations of cells in order to reduce displacements during legalization.
puts "RM-info: Setting place.legalize.optimize_orientations to $PREROUTE_PLACEMENT_ORIENTATION_OPTIMIZATION (tool default false)"
set_app_options -name place.legalize.optimize_orientations -value $PREROUTE_PLACEMENT_ORIENTATION_OPTIMIZATION

## Uncomment below for designs with fishbone PG structure, to support PDC checking with EoL rule
#  and VIA enclosure for pin access point, uncomment to apply the following
#	set_app_options -name place.legalize.use_eol_spacing_for_access_check -value true ;# tool default false


########################################################################
## Repeatability settings 
########################################################################
## Here are the recommeded settings to produce repeatable results with respect to multicore runs
#  Refer to SolvNet #2724517 for complete details
#	# place_opt repeatability
#		set_app_options -name place_opt.flow.repeatability -value true ;# tool default true
#	# refine_opt repeatability
#		set_app_options -name refine_opt.flow.repeatability -value true ;# tool default true
#	# clock_opt repeatability (note: run time impact expected)
#		set_app_options -name clock_opt.flow.repeatability -value true ;# tool default false
#	# route_global repeatability
#		set_app_options -name route.global.deterministic -value on ;# tool default off

####################################
## Clock NDR settings and examples
####################################
# There are different ways to use either RM predefined rules or your own rules
#  (1) To use RM predefined NDR rules and let RM associate the rules:
#      - Specify an RM predefined rule name for CTS_NDR_RULE_NAME and/or CTS_LEAF_NDR_RULE_NAME in icc2_pnr_setup.tcl
#	 Script will then create and associate the rules
#  (2) To use your own NDR rules and let RM assocuate the rules:
#      a. Specify your own CTS_NDR_RULE_NAME and/or CTS_LEAF_NDR_RULE_NAME in icc2_pnr_setup.tcl
#      b. create the rules before running the script
#      c. provide the rule creation scripts through TCL_CTS_NDR_RULE_FILE/TCL_CTS_LEAF_NDR_RULE_FILE
#      Your rules will then be created/used and associated automatically by the script

# ++++++++++++++++++++++++++++++++++
# NDR for root and internal nets
# ++++++++++++++++++++++++++++++++++
# - specify icc2rm_2w2s for CTS_NDR_RULE_NAME to create a double width and double spacing rule
# - specify icc2rm_2w2s_shield_default for CTS_NDR_RULE_NAME to create a double width and spacing + shielding with default width and spacing rule
# - specify icc2rm_2w2s_shield_list for CTS_NDR_RULE_NAME to create a double width and spacing + shielding with customized width and spacing rule

## Rule creation (create_routing_rule) for root and internal nets ##
if {$CTS_NDR_RULE_NAME != ""} {
	redirect -var x {report_routing_rules $CTS_NDR_RULE_NAME}
	if {[regexp "Error" $x]} {
		## Create the NDR if it is not present
		if {$CTS_NDR_RULE_NAME == "icc2rm_2w2s"} {
			create_routing_rule $CTS_NDR_RULE_NAME -default_reference_rule -multiplier_width 2 -multiplier_spacing 2
		} elseif {$CTS_NDR_RULE_NAME == "icc2rm_2w2s_shield_default"} {
			create_routing_rule $CTS_NDR_RULE_NAME -default_reference_rule -multiplier_width 2 -multiplier_spacing 2 -shield
		} elseif {$CTS_NDR_RULE_NAME == "icc2rm_2w2s_shield_list"} {
			if {$CTS_NDR_SHIELDING_LAYER_WIDTH_LIST != "" || $CTS_NDR_SHIELDING_LAYER_SPACING_LIST != ""} {
				set create_routing_rule_cmd "create_routing_rule $CTS_NDR_RULE_NAME -default_reference_rule -multiplier_width 2 -multiplier_spacing 2"
				if {$CTS_NDR_SHIELDING_LAYER_WIDTH_LIST != ""} {lappend create_routing_rule_cmd -shield_widths $CTS_NDR_SHIELDING_LAYER_WIDTH_LIST} 
				if {$CTS_NDR_SHIELDING_LAYER_SPACING_LIST != ""} {lappend create_routing_rule_cmd -shield_spacings $CTS_NDR_SHIELDING_LAYER_SPACING_LIST}
				puts "RM-info: $create_routing_rule_cmd"
			eval ${create_routing_rule_cmd}
			} else {
				puts "RM-error : CTS_NDR_SHIELDING_LAYER_WIDTH_LIST or CTS_NDR_SHIELDING_LAYER_SPACING_LIST not specified which is required by $CTS_NDR_RULE_NAME"
			}
		} else {
			if {[file exists [which $TCL_CTS_NDR_RULE_FILE]]} {
				puts "RM-info: Sourcing [which $TCL_CTS_NDR_RULE_FILE]"
				source -e $TCL_CTS_NDR_RULE_FILE
			} elseif {$TCL_CTS_NDR_RULE_FILE != ""} {
				puts "RM-error: TCL_CTS_NDR_RULE_FILE($TCL_CTS_NDR_RULE_FILE) is invalid. Pls correct it!"
			} else {
				puts "RM-error: TCL_CTS_NDR_RULE_FILE is not specified to create CTS_NDR_RULE_NAME($CTS_NDR_RULE_NAME). Pls correct it!"
			}
		}
	} else {
		puts "RM-info: CTS_NDR_RULE_NAME($CTS_NDR_RULE_NAME) already exists. Rule creation skipped."
	}
}

## Rule association (set_clock_routing_rules) for root and internal nets ##
if {$CTS_NDR_RULE_NAME != ""} {
	# Check if the rule has been created properly
	redirect -var x {report_routing_rules $CTS_NDR_RULE_NAME}
	if {![regexp "Error" $x]} {
		# set_clock_routing_rules on root nets
		set set_clock_routing_rules_cmd_root "set_clock_routing_rules -net_type root -rule $CTS_NDR_RULE_NAME"
		if {$CTS_NDR_MIN_ROUTING_LAYER != ""} {lappend set_clock_routing_rules_cmd_root -min_routing_layer $CTS_NDR_MIN_ROUTING_LAYER}
		if {$CTS_NDR_MAX_ROUTING_LAYER != ""} {lappend set_clock_routing_rules_cmd_root -max_routing_layer $CTS_NDR_MAX_ROUTING_LAYER}
		puts "RM-info: $set_clock_routing_rules_cmd_root"
			eval ${set_clock_routing_rules_cmd_root}
		
		# set_clock_routing_rules on internal nets
		set set_clock_routing_rules_cmd_internal "set_clock_routing_rules -net_type internal -rule $CTS_NDR_RULE_NAME"
		if {$CTS_NDR_MIN_ROUTING_LAYER != ""} {lappend set_clock_routing_rules_cmd_internal -min_routing_layer $CTS_NDR_MIN_ROUTING_LAYER}
		if {$CTS_NDR_MAX_ROUTING_LAYER != ""} {lappend set_clock_routing_rules_cmd_internal -max_routing_layer $CTS_NDR_MAX_ROUTING_LAYER}
		puts "RM-info: $set_clock_routing_rules_cmd_internal"
			eval ${set_clock_routing_rules_cmd_internal}
	} else {
		puts "RM-error: CTS_NDR_RULE_NAME($CTS_NDR_RULE_NAME) hasn't been created yet. Can not associate it with root and internal nets!"
	}
}

# ++++++++++++++++++++++++++++++++++
# NDR for leaf (sink) nets
# ++++++++++++++++++++++++++++++++++
# - specify icc2rm_leaf for CTS_LEAF_NDR_RULE_NAME to create a default reference rule for leaf nets

## Rule creation (create_routing_rule) for leaf nets ##
if {$CTS_LEAF_NDR_RULE_NAME != ""} {
	redirect -var x {report_routing_rules $CTS_LEAF_NDR_RULE_NAME}
	if {[regexp "Error" $x]} {
		## Create the NDR if it is not present
		if {$CTS_LEAF_NDR_RULE_NAME == "icc2rm_leaf"} {
			create_routing_rule $CTS_LEAF_NDR_RULE_NAME -default_reference_rule
		} else {
			if {[file exists [which $TCL_CTS_LEAF_NDR_RULE_FILE]]} {
				puts "RM-info: Sourcing [which $TCL_CTS_LEAF_NDR_RULE_FILE]"
				source -e $TCL_CTS_LEAF_NDR_RULE_FILE
			} elseif {$TCL_CTS_LEAF_NDR_RULE_FILE != ""} {
				puts "RM-error: TCL_CTS_LEAF_NDR_RULE_FILE($TCL_CTS_LEAF_NDR_RULE_FILE) is invalid. Pls correct it!"
			} else {
				puts "RM-error: TCL_CTS_LEAF_NDR_RULE_FILE is not specified to create CTS_LEAF_NDR_RULE_NAME($CTS_LEAF_NDR_RULE_NAME). Pls correct it!"
			}
		}
	} else {
		puts "RM-info: CTS_LEAF_NDR_RULE_NAME($CTS_LEAF_NDR_RULE_NAME) already exists. Rule creation skipped"
	}
}

## Rule association (set_clock_routing_rules) for leaf nets ##
if {$CTS_LEAF_NDR_RULE_NAME != ""} {
	# Check if the rule has been created properly
	redirect -var x {report_routing_rules $CTS_LEAF_NDR_RULE_NAME}
	if {![regexp "Error" $x]} {
		set set_clock_routing_rules_cmd_leaf "set_clock_routing_rules -net_type sink -rule $CTS_LEAF_NDR_RULE_NAME"
		if {$CTS_LEAF_NDR_MIN_ROUTING_LAYER != ""} {lappend set_clock_routing_rules_cmd_leaf -min_routing_layer $CTS_LEAF_NDR_MIN_ROUTING_LAYER}
		if {$CTS_LEAF_NDR_MAX_ROUTING_LAYER != ""} {lappend set_clock_routing_rules_cmd_leaf -max_routing_layer $CTS_LEAF_NDR_MAX_ROUTING_LAYER}
		puts "RM-info: $set_clock_routing_rules_cmd_leaf"
		eval $set_clock_routing_rules_cmd_leaf
	} else {
		puts "RM-error: CTS_LEAF_NDR_RULE_NAME($CTS_LEAF_NDR_RULE_NAME) hasn't been created yet. Can not associate it with leaf nets!"
	}
}

# ++++++++++++++++++++++++++++++++++
# Report routing rules 
# ++++++++++++++++++++++++++++++++++
redirect -file ${REPORTS_DIR}/settings.common.cts.report_routing_rules.rpt {report_routing_rules -verbose}
redirect -file ${REPORTS_DIR}/settings.common.cts.report_clock_routing_rules.rpt {report_clock_routing_rules}

####################################
## Non-Clock NDR
####################################
if {[file exists [which $TCL_NON_CLOCK_NDR_RULES_FILE]]} {
	puts "RM-info: Sourcing [which $TCL_NON_CLOCK_NDR_RULES_FILE]"
	source $TCL_NON_CLOCK_NDR_RULES_FILE
} elseif {$TCL_NON_CLOCK_NDR_RULES_FILE != ""} {
	puts "RM-error: TCL_NON_CLOCK_NDR_RULES_FILE($TCL_NON_CLOCK_NDR_RULES_FILE) is invalid. Pls correct it."
}

puts "RM-info: Completed script [info script]\n"

