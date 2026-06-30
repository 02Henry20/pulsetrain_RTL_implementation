##########################################################################################
# Tool: IC Compiler II
# Script: route_auto.tcl
# Version: N-2017.09-SP2 (February 20, 2018)
# Copyright (C) 2014-2018 Synopsys, Inc. All rights reserved.
##########################################################################################

source -e ./rm_setup/icc2_pnr_setup.tcl 

open_lib $DESIGN_LIBRARY
if {$USE_RM_BLOCK_NAME_AS_LABEL} {
	copy_block -from ${DESIGN_NAME}/${CLOCK_OPT_OPTO_BLOCK_NAME} -to ${DESIGN_NAME}/${ROUTE_AUTO_BLOCK_NAME}
	current_block ${DESIGN_NAME}/${ROUTE_AUTO_BLOCK_NAME}
} else {
	copy_block -from ${CLOCK_OPT_OPTO_BLOCK_NAME} -to ${ROUTE_AUTO_BLOCK_NAME}
	current_block ${ROUTE_AUTO_BLOCK_NAME}
}
link_block

## The following only applies to hierarchical designs
## Swap abstracts if abstracts specified for clock_opt_opto and route_auto are different
if {$DESIGN_STYLE == "hier"} {
	if {$USE_ABSTRACTS_FOR_BLOCKS != "" && ($BLOCK_ABSTRACT_FOR_ROUTE_AUTO != $BLOCK_ABSTRACT_FOR_CLOCK_OPT_OPTO)} {
		puts "RM-info: Swapping from $BLOCK_ABSTRACT_FOR_CLOCK_OPT_OPTO to $BLOCK_ABSTRACT_FOR_ROUTE_AUTO abstracts for all blocks."
		change_abstract -references $USE_ABSTRACTS_FOR_BLOCKS -label $BLOCK_ABSTRACT_FOR_ROUTE_AUTO
		report_abstracts
	}
}


if {$ROUTE_AUTO_ACTIVE_SCENARIO_LIST == "rm_activate_all_scenarios"} {
	set_scenario_status -active true [all_scenarios]
} elseif {$ROUTE_AUTO_ACTIVE_SCENARIO_LIST != ""} {
	set_scenario_status -active false [get_scenarios -filter active]
	set_scenario_status -active true $ROUTE_AUTO_ACTIVE_SCENARIO_LIST
}

## For non-persistent settings that need to be re-applied in a new ICC-II session
puts "RM-info: Sourcing [which settings.common.non_persistent.tcl]"
source -e settings.common.non_persistent.tcl

## For common optimization settings that can impact multiple steps across the flow, refer to settings.common.opt.tcl  
#  (sourced in place_opt step)
#	puts "RM-info: Sourcing [which settings.common.opt.tcl]"
#	source -e settings.common.opt.tcl

## For common routing settings, refer to settings.common.routing.tcl
#  (sourced in place_opt step)  
#	puts "RM-info: Sourcing [which settings.common.routing.tcl]"
#	source -e settings.common.routing.tcl

## For route_auto step related settings, refer to settings.step.route_auto.tcl
puts "RM-info: Sourcing [which settings.step.route_auto.tcl]"
source -e settings.step.route_auto.tcl

####################################
## Pre-route_auto customizations	
####################################
if {[file exists [which $TCL_USER_ROUTE_AUTO_PRE_SCRIPT]]} {
	puts "RM-info: Sourcing [which $TCL_USER_ROUTE_AUTO_PRE_SCRIPT]"
	source $TCL_USER_ROUTE_AUTO_PRE_SCRIPT
} elseif {$TCL_USER_ROUTE_AUTO_PRE_SCRIPT != ""} {
	puts "RM-error: TCL_USER_ROUTE_AUTO_PRE_SCRIPT($TCL_USER_ROUTE_AUTO_PRE_SCRIPT) is invalid. Please correct it."
}

####################################
## Routing	
####################################
## Create shields before signal routing
if {$ROUTE_AUTO_CREATE_SHIELDS == "before_route_auto"} {
	create_shields ;# without specifying -nets option, all nets with shielding rules will be shielded 
	set_extraction_options -virtual_shield_extraction false
}

redirect -tee -file ${REPORTS_DIR}/${ROUTE_AUTO_BLOCK_NAME}.report_app_options.start {report_app_options -non_default *}
redirect -file ${REPORTS_DIR}/${ROUTE_AUTO_BLOCK_NAME}.report_lib_cell_purpose.rpt {report_lib_cell -objects [get_lib_cells] -column {full_name:20 valid_purposes}}

## The following only applies to designs with physical hierarchy
## Ignore the sub-blocks (bound to abstracts) internal timing paths
if {$DESIGN_STYLE == "hier" && $PHYSICAL_HIERARCHY_LEVEL != "bottom"} {
	set_timing_paths_disabled_blocks  -all_sub_blocks
}

if {[file exists [which $TCL_USER_ROUTE_AUTO_SCRIPT]]} {
        puts "RM-info: Sourcing [which $TCL_USER_ROUTE_AUTO_SCRIPT]"
        source $TCL_USER_ROUTE_AUTO_SCRIPT
} elseif {$TCL_USER_ROUTE_AUTO_SCRIPT != ""} {
	puts "RM-error: TCL_USER_ROUTE_AUTO_SCRIPT($TCL_USER_ROUTE_AUTO_SCRIPT) is invalid. Please correct it."
} else {


## Global route based optimization
#  Note: 1. Global route in route_global or route_auto will be automatically skipped if this feature is enabled
#        2. All global route related settings should be applied before the command
if {$CLOCK_OPT_GLOBAL_ROUTE_OPT} {
	## Main switch to enable Global Route Based Optimization
	puts "RM-info: Setting clock_opt.flow.enable_global_route_opt to true (tool default false)"
	set_app_options -name clock_opt.flow.enable_global_route_opt -value true 

	## Enable power optimization during Global Route Based Optimization
	puts "RM-info: Setting route_opt.flow.enable_power true (tool default false)"
	set_app_options -name route_opt.flow.enable_power -value true ;# global-scoped

	## Include clock_opt_opto scenarios, if specified
	set RM_current_active_scenarios [get_scenarios -filter active]
	if {$CLOCK_OPT_OPTO_ACTIVE_SCENARIO_LIST == "rm_activate_all_scenarios"} {
		set_scenario_status -active true [all_scenarios]
#smkcow
        set_scenario_status * -active true -all
	} elseif {$CLOCK_OPT_OPTO_ACTIVE_SCENARIO_LIST != ""} {
		set_scenario_status -active true $CLOCK_OPT_OPTO_ACTIVE_SCENARIO_LIST
#smkcow
        set_scenario_status * -active true -all
	}
	
	puts "RM-info: Running clock_opt -from global_route_opt command"
	clock_opt -from global_route_opt

	## Restore the scenarios prior to the "clock_opt -from global_route_opt" command
	if {$CLOCK_OPT_OPTO_ACTIVE_SCENARIO_LIST != ""} {
#smkcow
        set_scenario_status * -active true -all
		set_scenario_status -active false [get_scenarios -filter active]
		set_scenario_status -active true $RM_current_active_scenarios
	}
} else {
	puts "RM-info: Running route_global"
	route_global
}

if {$USE_RM_BLOCK_NAME_AS_LABEL} {
	save_block -as ${DESIGN_NAME}/${ROUTE_AUTO_BLOCK_NAME}_global_route
} else {
	save_block -as ${ROUTE_AUTO_BLOCK_NAME}_global_route
}

puts "RM-info: Running update_timing and route_track"
update_timing
route_track

if {$USE_RM_BLOCK_NAME_AS_LABEL} {
	save_block -as ${DESIGN_NAME}/${ROUTE_AUTO_BLOCK_NAME}_track_assignment
} else {
	save_block -as ${ROUTE_AUTO_BLOCK_NAME}_track_assignment
}

puts "RM-info: Running update_timing and route_detail"
update_timing
route_detail

}

####################################
## Redundant via insertion 
####################################
## For designs with advanced nodes where DRC convergence could be a concern, we recommended redundant via insertion to be done after route_auto/route_opt
#  Please refer to settings.step.route_auto.tcl for relevant settings
if {$REDUNDANT_VIA_INSERTION} {
	add_redundant_vias
}

## Create shields after signal routing; recommended if DRC convergence is a concern
if {$ROUTE_AUTO_CREATE_SHIELDS == "after_route_auto"} {
	create_shields ;# without specifying -nets option, all nets with shielding rules will be shielded 
	set_extraction_options -virtual_shield_extraction false
}

####################################
## Post-route_auto customizations	
####################################
if {[file exists [which $TCL_USER_ROUTE_AUTO_POST_SCRIPT]]} {
        puts "RM-info: Sourcing [which $TCL_USER_ROUTE_AUTO_POST_SCRIPT]"
        source $TCL_USER_ROUTE_AUTO_POST_SCRIPT
} elseif {$TCL_USER_ROUTE_AUTO_POST_SCRIPT != ""} {
        puts "RM-error: TCL_USER_ROUTE_AUTO_POST_SCRIPT($TCL_USER_ROUTE_AUTO_POST_SCRIPT) is invalid. Please correct it."
}

## Example to resolve short violated nets
#  Note that remove and reroute nets could potentially degrade timing QoR.
#
#  set data [open_drc_error_data -name zroute.err]
#  open_drc_error_data -name zroute.err
#  if { [sizeof_collection [get_drc_errors -quiet -error_data zroute.err -filter "type_name==Short"] ] > 0} {
#      set remove_net ""
#      foreach_in_collection net [get_attribute [get_drc_errors -error_data zroute.err -filter "type_name==Short"] objects] {
#          set net_type [get_attribute $net net_type]
#         if {$net_type=="signal"} {append_to_collection remove_net $net}
#      }
#      remove_routes -detail_route -nets $remove_net
#      route_eco
#  }

## If there are remaining routing DRCs, you can use the following :
check_routes
route_detail -incremental true -initial_drc_from_input true

## smkcow
check_lvs -max_error 2000

if {$TCL_USER_CONNECT_PG_NET_SCRIPT != ""} {
	if {[file exists [which $TCL_USER_CONNECT_PG_NET_SCRIPT]]} {
		puts "RM-info: Sourcing [which $TCL_USER_CONNECT_PG_NET_SCRIPT]"
  		source $TCL_USER_CONNECT_PG_NET_SCRIPT
	} else {
		puts "RM-error: TCL_USER_CONNECT_PG_NET_SCRIPT($TCL_USER_CONNECT_PG_NET_SCRIPT) is invalid. Please correct it."
	}
} else {
	connect_pg_net
	# For non-MV designs with more than one PG, you should use connect_pg_net in manual mode.
}

save_block

####################################
## Create abstract and frame
####################################
## Enabled for hierarchical designs; for bottom and intermediate levels of physical hierarchy
if {$DESIGN_STYLE == "hier"} {
	if {$USE_ABSTRACTS_FOR_POWER_ANALYSIS == "true"} {
		set_app_options -name abstract.annotate_power -value true
   	}
	if { $PHYSICAL_HIERARCHY_LEVEL == "bottom" } {
		create_abstract -read_only
	} elseif { $PHYSICAL_HIERARCHY_LEVEL == "intermediate"} {
            if { $ABSTRACT_TYPE_FOR_MPH_BLOCKS == "nested"} {
                ## Create nested abstract for the intermediate level of physical hierarchy
                create_abstract -read_only
            } elseif { $ABSTRACT_TYPE_FOR_MPH_BLOCKS == "flattened"} {
                ## Create flattened abstract for the intermediate level of physical hierarchy
                create_abstract -read_only -preserve_block_instances false
            }
	}
        create_frame -block_all true
        if {$USE_RM_BLOCK_NAME_AS_LABEL} {
           derive_hier_antenna_property -design ${DESIGN_NAME}/${ROUTE_AUTO_BLOCK_NAME}
        } else {
           derive_hier_antenna_property -design ${ROUTE_AUTO_BLOCK_NAME}
        }
}
#########
#smkcow
        create_abstract -read_only
        create_frame -block_all true
###########
save_lib

####################################
## Report and output
####################################			 
if {$REPORT_QOR} {
	set REPORT_PREFIX $ROUTE_AUTO_BLOCK_NAME
	puts "RM-info: Sourcing [which $REPORT_QOR_SCRIPT]"
	source $REPORT_QOR_SCRIPT
}


print_message_info -ids * -summary
echo [date] > route_auto

exit 


