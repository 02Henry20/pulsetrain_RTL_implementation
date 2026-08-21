##########################################################################################
# Tool: IC Compiler II
# Script: route_opt.tcl
# Version: N-2017.09-SP2 (February 20, 2018)
# Copyright (C) 2014-2018 Synopsys, Inc. All rights reserved.
##########################################################################################

source -e ./rm_setup/icc2_pnr_setup.tcl 

open_lib $DESIGN_LIBRARY
if {$USE_RM_BLOCK_NAME_AS_LABEL} {
	copy_block -from ${DESIGN_NAME}/${ROUTE_AUTO_BLOCK_NAME} -to ${DESIGN_NAME}/${ROUTE_OPT_BLOCK_NAME}
	current_block ${DESIGN_NAME}/${ROUTE_OPT_BLOCK_NAME}
} else {
	copy_block -from ${ROUTE_AUTO_BLOCK_NAME} -to ${ROUTE_OPT_BLOCK_NAME}
	current_block ${ROUTE_OPT_BLOCK_NAME}
}
link_block

## The following only applies to hierarchical designs
## Swap abstracts if abstracts specified for route_auto and route_opt are different
if {$DESIGN_STYLE == "hier"} {
	if {$USE_ABSTRACTS_FOR_BLOCKS != "" && ($BLOCK_ABSTRACT_FOR_ROUTE_OPT != $BLOCK_ABSTRACT_FOR_ROUTE_AUTO)} {
		puts "RM-info: Swapping from $BLOCK_ABSTRACT_FOR_ROUTE_AUTO to $BLOCK_ABSTRACT_FOR_ROUTE_OPT abstracts for all blocks."
		change_abstract -references $USE_ABSTRACTS_FOR_BLOCKS -label $BLOCK_ABSTRACT_FOR_ROUTE_OPT
		report_abstracts
	}
}

if {$ROUTE_OPT_ACTIVE_SCENARIO_LIST == "rm_activate_all_scenarios"} {
	set_scenario_status -active true [all_scenarios]
#smkcow
        set_scenario_status * -active true -all
        set_propagated_clock [all_clocks]
} elseif {$ROUTE_OPT_ACTIVE_SCENARIO_LIST != ""} {
	set_scenario_status -active false [get_scenarios -filter active]
	set_scenario_status -active true $ROUTE_OPT_ACTIVE_SCENARIO_LIST
#smkcow
        set_scenario_status * -active true -all
        set_propagated_clock [all_clocks]
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

## For route_auto step related settings,refer to settings.step.route_auto.tcl 
#  (sourced in route_auto step)
#       puts "RM-info: Sourcing [which settings.step.route_auto.tcl]"
#       source -e settings.step.route_auto.tcl

## For route_opt step related settings,refer to settings.step.route_opt.tcl
puts "RM-info: Sourcing [which settings.step.route_opt.tcl]"
source -e settings.step.route_opt.tcl

####################################
## Pre-route_opt customizations
####################################
if {[file exists [which $TCL_USER_ROUTE_OPT_PRE_SCRIPT]]} {
        puts "RM-info: Sourcing [which $TCL_USER_ROUTE_OPT_PRE_SCRIPT]"
        source $TCL_USER_ROUTE_OPT_PRE_SCRIPT
# smkcow :: The below lines are used at dp/rm../pre_timing.tcl
#set_scenario_status mode_norm.OC_rvt_ss_1p08v_125c.RC_MAX -leakage_power true 
#set_scenario_status mode_norm.OC_rvt_ss_1p08v_125c.RC_MIN -leakage_power true

# For post-route analysis activate all scenarios and enable all analyses:
set_scenario_status * -active true -all

} elseif {$TCL_USER_ROUTE_OPT_PRE_SCRIPT != ""} {
	puts "RM-error : TCL_USER_ROUTE_OPT_PRE_SCRIPT($TCL_USER_ROUTE_OPT_PRE_SCRIPT) is invalid. Please correct it."
}

####################################
## Post route optimization	
####################################
compute_clock_latency

if {$ROUTE_OPT_USER_INSTANCE_NAME_PREFIX != ""} {
	set_app_options -name opt.common.user_instance_name_prefix -value $ROUTE_OPT_USER_INSTANCE_NAME_PREFIX
}
if {$ROUTE_OPT_CTO_USER_INSTANCE_NAME_PREFIX != ""} {
	set_app_options -name cts.common.user_instance_name_prefix -value $ROUTE_OPT_CTO_USER_INSTANCE_NAME_PREFIX
}

redirect -tee -file ${REPORTS_DIR}/${ROUTE_OPT_BLOCK_NAME}.report_app_options.start {report_app_options -non_default *}
redirect -file ${REPORTS_DIR}/${ROUTE_OPT_BLOCK_NAME}.report_lib_cell_purpose.rpt {report_lib_cell -objects [get_lib_cells] -column {full_name:20 valid_purposes}}

## The following only applies to designs with physical hierarchy
## Ignore the sub-blocks (bound to abstracts) internal timing paths
if {$DESIGN_STYLE == "hier" && $PHYSICAL_HIERARCHY_LEVEL != "bottom"} {
	set_timing_paths_disabled_blocks  -all_sub_blocks
}

if {[file exists [which $TCL_USER_ROUTE_OPT_SCRIPT]]} {
        puts "RM-info: Sourcing [which $TCL_USER_ROUTE_OPT_SCRIPT]"
        source $TCL_USER_ROUTE_OPT_SCRIPT
} elseif {$TCL_USER_ROUTE_OPT_SCRIPT != ""} {
	puts "RM-error: TCL_USER_ROUTE_OPT_SCRIPT($TCL_USER_ROUTE_OPT_SCRIPT) is invalid. Please correct it."
} else {

########################################################################
## route_opt commands
########################################################################
## First route_opt
puts "RM-info: Running first route_opt"
route_opt

if {$USE_RM_BLOCK_NAME_AS_LABEL} {
	save_block -as ${DESIGN_NAME}/${ROUTE_OPT_BLOCK_NAME}_1
} else {
	save_block -as ${ROUTE_OPT_BLOCK_NAME}_1
}

## To disable soft-rule-based timing optimization during ECO routing, uncomment the following.
#  This is to limit spreading which can touch multiple routes and impact convergence.
#	set_app_options -name route.detail.eco_route_use_soft_spacing_for_timing_optimization -value false


## Second route_opt
puts "RM-info: Running second route_opt"
route_opt
if {$USE_RM_BLOCK_NAME_AS_LABEL} {
	save_block -as ${DESIGN_NAME}/${ROUTE_OPT_BLOCK_NAME}_2
} else {
	save_block -as ${ROUTE_OPT_BLOCK_NAME}_2
}
	
## CCD is disabled for the last route_opt; you can enable it if the timing can benefit from skew optimization
if {[get_app_option_value -name route_opt.flow.enable_ccd]} {
	set_app_options -name route_opt.flow.enable_ccd -value false
}
## CTO for non-CCD flow is disabled for the last route_opt
if {[get_app_option_value -name route_opt.flow.enable_cto]} {
	set_app_options -name route_opt.flow.enable_cto -value false
}

## power recovery from clock cells and registers during route_opt is disabled for the last route_opt
if {[get_app_option_value -name route_opt.flow.enable_clock_power_recovery] != "none"} {
	set_app_options -name route_opt.flow.enable_clock_power_recovery -value none
}

## Third route_opt
## Size-only is recommended for the last route_opt in the flow
#  Please uncomment and set the app option to a value appropriate to your library models, 
#  such as footprint, equal, or equal_or_smaller  
set_app_options -name route_opt.flow.size_only_mode -value equal_or_smaller
puts "RM-info: Running third route_opt"
route_opt

}

####################################
## Targeted endpoint optimization	
####################################
## To optimize specific endpoints for setup, hold, or max_tran, specify the endpoints in a file 
#  by using the -setup_endpoints, -hold_endpoints, or -max_transition options
#  For ex, 
#	set_route_opt_target_endpoints -setup_endpoints $your_setup_endpoints_file
#	route_opt

## To adjust the timing at specific endpoints for setup or hold (such as to adjust timing to achieve PT slack), 
#  specify the endpoints and slack information in a file by using the -setup_timing or -hold_timing options
#  For ex, 
#	set_route_opt_target_endpoints -setup_timing $your_setup_timing_file
#	report_qor -summary ;# generate report with adjusted timing before route_opt
#	route_opt
#	report_qor -summary ;# generate report with adjusted timing after route_opt
#	set_route_opt_target_endpoints -reset ;# remove adjusted timing
#	report_qor -summary ;# generate report without adjusted timing after route_opt

##########################################################################################################
## route_opt with StarRC in-design extraction and PrimeTime delay calculation
#  To improve convergence on designs with lower technology nodes, low voltage, AWP, or CCS libraries, etc
#  This route_opt is recommended if you are at the final design closure stage	
##########################################################################################################
if {$ROUTE_OPT_WITH_STARRC_PT} {
	if {[file exists [which $ROUTE_OPT_STARRC_CONFIG_FILE]]} {
		## Enable StarRC in-design extraction
		#  Only recommended for the final route_opt for design closure
		#  Config file is required to properly set up StarRC run
		set_app_options -name extract.starrc_mode -value true
		set_starrc_in_design -config $ROUTE_OPT_STARRC_CONFIG_FILE ;# example: route_opt.starrc_in_design_config_example.txt

		## Enable PrimeTime delay calculation
		#  Only recommended for the final route_opt for design closure
		#  This features uses .db files of the reference libraries in addition to NDM libraries so you must specify paths to .db files,
		#  if they are in different locations
		
		lappend search_path $ROUTE_OPT_PT_DELAY_CALC_DB_LOCATION
		set_app_options -name time.use_pt_delay -value true 

		compute_clock_latency

		route_opt
		## Note :
		#  Once StarRC in-design extraction and PrimeTime delay calculation are enabled, they remain effective through 
		#  the QoR reporting at the end. Turn them off if you want to switch back to regular modes during reporting.
		#	set_app_options -name extract.starrc_mode -value false
		#	set_app_options -name time.use_pt_delay -value false
		#  Please note that extract.starrc_mode is global scoped and will be reset after you exit current ICC2 session.
		#  time.use_pt_delay is block-scoped and will be persistent if not reset.
		#  Script will reset time.use_pt_delay to its default value before save_block. 

	} elseif {$ROUTE_OPT_STARRC_CONFIG_FILE != ""} {
		puts "RM-error: ROUTE_OPT_STARRC_CONFIG_FILE($ROUTE_OPT_STARRC_CONFIG_FILE) is invalid. Please correct it."
		puts "RM-info: ROUTE_OPT_WITH_STARRC_PT is skipped."
	} else {
		puts "RM-error: ROUTE_OPT_STARRC_CONFIG_FILE is not specified. Please correct it."
		puts "RM-info: ROUTE_OPT_WITH_STARRC_PT is skipped."
	}
}

####################################
## Redundant via insertion 
####################################
## For designs with advanced nodes where DRC convergence could be a concern, we recommended redundant via insertion to be done after route_auto/route_opt
#  Please refer to settings.step.route_auto.tcl for relevant settings
if {$REDUNDANT_VIA_INSERTION} {
	add_redundant_vias
}

####################################
## Reshield after route_opt
####################################
if {$ROUTE_AUTO_CREATE_SHIELDS != "none" && $ROUTE_OPT_RESHIELD == "after_route_opt"} {
	create_shields ;# without specifying -nets option, all nets with shielding rules will be shielded 
}

####################################
## Post-route_opt customizations	
####################################
if {[file exists [which $TCL_USER_ROUTE_OPT_POST_SCRIPT]]} {
	puts "RM-info: Sourcing [which $TCL_USER_ROUTE_OPT_POST_SCRIPT]"
        source $TCL_USER_ROUTE_OPT_POST_SCRIPT
} elseif {$TCL_USER_ROUTE_OPT_POST_SCRIPT != ""} {
	puts "RM-error : TCL_USER_ROUTE_OPT_POST_SCRIPT($TCL_USER_ROUTE_OPT_POST_SCRIPT) is invalid. Please correct it."
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
#	check_routes
#	route_detail -incremental true -initial_drc_from_input true

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
           derive_hier_antenna_property -design ${DESIGN_NAME}/${ROUTE_OPT_BLOCK_NAME}
        } else {
           derive_hier_antenna_property -design ${ROUTE_OPT_BLOCK_NAME}
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
	set REPORT_PREFIX $ROUTE_OPT_BLOCK_NAME
	puts "RM-info: Sourcing [which $REPORT_QOR_SCRIPT]"
	source $REPORT_QOR_SCRIPT
}


## Resets time.use_pt_delay to default value before save_block if ROUTE_OPT_WITH_STARRC_PT is enabled 
if {$ROUTE_OPT_WITH_STARRC_PT && [get_app_option_value -name time.use_pt_delay]} {
	puts "RM-info: ROUTE_OPT_WITH_STARRC_PT was enabled. Resetting time.use_pt_delay to its default value.\n"
	reset_app_option time.use_pt_delay
	save_block
	save_lib
}

#smkcow
############################################
# Step 1 
############################################
# report_scenarios
# current_scenario {select !!}

# report_ideal_network
# remove_ideal_network *


############################################
# Step 2
############################################
# report_qor -summary
# report_timing -delay min

# report_scenarios
# current_scenario {select !!}
# report_port -verbose

# compute_clock_latency
# report_timing -delay min

############################################
# Step 3
############################################
# report_clocks ::::: verify all clocks are propagated except Virtual Clocks
# set_propagated_clocks [all_clocks]
# set_app_options -list {clock_opt.hold.effort {high}}
# set_app_options -list {refine_opt.hold.effort {high}}

# route_opt
# report_qor -summary
# report_timing -delay min

#exit 

        save_block
        save_lib
print_message_info -ids * -summary
echo [date] > route_opt


exit


