##########################################################################################
# Tool: IC Compiler II
# Script: clock_opt_opto.tcl
# Version: N-2017.09-SP2 (February 20, 2018)
# Copyright (C) 2014-2018 Synopsys, Inc. All rights reserved.
##########################################################################################

source -e ./rm_setup/icc2_pnr_setup.tcl 

open_lib $DESIGN_LIBRARY
if {$USE_RM_BLOCK_NAME_AS_LABEL} {
	copy_block -from ${DESIGN_NAME}/${CLOCK_OPT_CTS_BLOCK_NAME} -to ${DESIGN_NAME}/${CLOCK_OPT_OPTO_BLOCK_NAME}
	current_block ${DESIGN_NAME}/${CLOCK_OPT_OPTO_BLOCK_NAME}
} else {
	copy_block -from ${CLOCK_OPT_CTS_BLOCK_NAME} -to ${CLOCK_OPT_OPTO_BLOCK_NAME}
	current_block ${CLOCK_OPT_OPTO_BLOCK_NAME}
}
link_block

## The following only applies to hierarchical designs
## Swap abstracts if abstracts specified for clock_opt_cts and clock_opt_opto are different
if {$DESIGN_STYLE == "hier"} {
	if {$USE_ABSTRACTS_FOR_BLOCKS != "" && ($BLOCK_ABSTRACT_FOR_CLOCK_OPT_OPTO != $BLOCK_ABSTRACT_FOR_CLOCK_OPT_CTS)} {
		puts "RM-info: Swapping from $BLOCK_ABSTRACT_FOR_CLOCK_OPT_CTS to $BLOCK_ABSTRACT_FOR_CLOCK_OPT_OPTO abstracts for all blocks."
		change_abstract -references $USE_ABSTRACTS_FOR_BLOCKS -label $BLOCK_ABSTRACT_FOR_CLOCK_OPT_OPTO
		report_abstracts
	}
}

if {$CLOCK_OPT_OPTO_ACTIVE_SCENARIO_LIST != ""} {
	if {$CLOCK_OPT_OPTO_ACTIVE_SCENARIO_LIST == "rm_activate_all_scenarios"} {
		set_scenario_status -active true [all_scenarios]
	} else {
		set_scenario_status -active false [get_scenarios -filter active]
		set_scenario_status -active true $CLOCK_OPT_OPTO_ACTIVE_SCENARIO_LIST
	}
	
	## Propagate clocks and compute IO latencies for modes or corners which are not active during clock_opt_cts step
	synthesize_clock_trees -propagate_only
	compute_clock_latency
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

## For CTS related settings, refer to settings.common.cts.tcl 
#  (sourced in place_opt or clock_opt_cts step)
#       puts "RM-info: Sourcing [which settings.common.cts.tcl]"
#	source -e ./rm_icc2_flat_scripts/settings.common.cts.tcl


####################################
## Pre-opto customizations	
####################################
if {[file exists [which $TCL_USER_CLOCK_OPT_OPTO_PRE_SCRIPT]]} {
	puts "RM-info: Sourcing [which $TCL_USER_CLOCK_OPT_OPTO_PRE_SCRIPT]"
	source $TCL_USER_CLOCK_OPT_OPTO_PRE_SCRIPT
} elseif {$TCL_USER_CLOCK_OPT_OPTO_PRE_SCRIPT != ""} {
	puts "RM-error: TCL_USER_CLOCK_OPT_OPTO_PRE_SCRIPT($TCL_USER_CLOCK_OPT_OPTO_PRE_SCRIPT) is invalid. Please correct it."
}

####################################
## Post-CTS optimization
####################################
if {$CLOCK_OPT_OPTO_USER_INSTANCE_NAME_PREFIX != ""} {
	set_app_options -name opt.common.user_instance_name_prefix -value $CLOCK_OPT_OPTO_USER_INSTANCE_NAME_PREFIX
	if {[get_app_option_value -name clock_opt.flow.enable_ccd]} {
		# If CCD is enabled, set both opt and cts user prefix as CCD can work on both clock and data paths
		set_app_options -name cts.common.user_instance_name_prefix -value ${CLOCK_OPT_OPTO_USER_INSTANCE_NAME_PREFIX}_cts
	}
}

redirect -tee -file ${REPORTS_DIR}/${CLOCK_OPT_OPTO_BLOCK_NAME}.report_app_options.start {report_app_options -non_default *}
redirect -file ${REPORTS_DIR}/${CLOCK_OPT_OPTO_BLOCK_NAME}.report_lib_cell_purpose.rpt {report_lib_cell -objects [get_lib_cells] -column {full_name:20 valid_purposes}}

## The following only applies to designs with physical hierarchy
## Ignore the sub-blocks (bound to abstracts) internal timing paths
if {$DESIGN_STYLE == "hier" && $PHYSICAL_HIERARCHY_LEVEL != "bottom"} {
	set_timing_paths_disabled_blocks  -all_sub_blocks
}

if {[file exists [which $TCL_USER_CLOCK_OPT_OPTO_SCRIPT]]} {
        puts "RM-info: Sourcing [which $TCL_USER_CLOCK_OPT_OPTO_SCRIPT]"
        source $TCL_USER_CLOCK_OPT_OPTO_SCRIPT
} elseif {$TCL_USER_CLOCK_OPT_OPTO_SCRIPT != ""} {
	puts "RM-error: TCL_USER_CLOCK_OPT_OPTO_SCRIPT($TCL_USER_CLOCK_OPT_OPTO_SCRIPT) is invalid. Please correct it."
} else {

puts "RM-info: Running clock_opt -from final_opto -to final_opto command"
clock_opt -from final_opto -to final_opto

}

####################################
## Post-opto customizations	
####################################
if {[file exists [which $TCL_USER_CLOCK_OPT_OPTO_POST_SCRIPT]]} {
        puts "RM-info: Sourcing [which $TCL_USER_CLOCK_OPT_OPTO_POST_SCRIPT]"
        source $TCL_USER_CLOCK_OPT_OPTO_POST_SCRIPT
} elseif {$TCL_USER_CLOCK_OPT_OPTO_POST_SCRIPT != ""} {
        puts "RM-error: TCL_USER_CLOCK_OPT_OPTO_POST_SCRIPT($TCL_USER_CLOCK_OPT_OPTO_POST_SCRIPT) is invalid. Please correct it."
}

####################################
## Clock route patching	
####################################
## Starting from M-2016.12 release, clock_opt "final_opto" phase by default includes clock route patching step,
#  so there's no need to run "route_group -all_clock_nets" right after clock_opt.
#  However, if you manually add a refine_opt command after clock_opt, you should still run route_group
#  to patch the clock routes. For ex,
#	refine_opt
#	route_group -all_clock_nets

####################################
## Post-route clock tree optimization for non-CCD flow	
####################################
if {$CLOCK_OPT_OPTO_CTO && ![get_app_option_value -name clock_opt.flow.enable_ccd]} {
	if {$CLOCK_OPT_OPTO_CTO_USER_INSTANCE_NAME_PREFIX != ""} {
		set_app_options -name cts.common.user_instance_name_prefix -value ${CLOCK_OPT_OPTO_CTO_USER_INSTANCE_NAME_PREFIX}
	}
	if {$USE_RM_BLOCK_NAME_AS_LABEL} {
		save_block -as ${DESIGN_NAME}/${CLOCK_OPT_OPTO_BLOCK_NAME}_pre_cto
	} else {
		save_block -as ${CLOCK_OPT_OPTO_BLOCK_NAME}_pre_cto
	}
	synthesize_clock_trees -postroute -routed_clock_stage detail
}

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
	set REPORT_PREFIX $CLOCK_OPT_OPTO_BLOCK_NAME
	puts "RM-info: Sourcing [which $REPORT_QOR_SCRIPT]"
	source $REPORT_QOR_SCRIPT
}


if {$REPORT_QOR_REPORT_CONGESTION} {
	if {!$REPORT_QOR} {set REPORT_PREFIX $CLOCK_OPT_OPTO_BLOCK_NAME}
	redirect -tee -file ${REPORTS_DIR}/${REPORT_PREFIX}.report_congestion.rpt {report_congestion -layers [get_layers -filter "layer_type==interconnect"] -rerun_global_router -nosplit}
	if {[info exists env(DISPLAY)]} {
		gui_start
		#gui_execute_menu_item -menu "View->Layout View"
		gui_execute_menu_item -menu "View->Map->Global Route Congestion"
		gui_write_window_image -format png -file ${REPORTS_DIR}/${REPORT_PREFIX}.report_congestion.png
		gui_stop
	} else {
		puts "RM-info: env(DISPLAY) is not defined. Global route congestion map snapshot is skipped."
	}
}

print_message_info -ids * -summary
echo [date] > clock_opt_opto

exit 


