##########################################################################################
# Tool: IC Compiler II
# Script: place_opt.tcl
# Version: N-2017.09-SP2 (February 20, 2018)
# Copyright (C) 2014-2018 Synopsys, Inc. All rights reserved.
##########################################################################################

source -e ./rm_setup/icc2_pnr_setup.tcl 

open_lib $DESIGN_LIBRARY
if {$USE_RM_BLOCK_NAME_AS_LABEL} {
	copy_block -from ${DESIGN_NAME}/${INIT_DESIGN_BLOCK_NAME} -to ${DESIGN_NAME}/${PLACE_OPT_BLOCK_NAME}
	current_block ${DESIGN_NAME}/${PLACE_OPT_BLOCK_NAME}
} else {
	copy_block -from ${INIT_DESIGN_BLOCK_NAME} -to ${PLACE_OPT_BLOCK_NAME}
	current_block ${PLACE_OPT_BLOCK_NAME}
}
link_block

## For top and intermediate level of hierarchical designs, check the editability of the sub-blocks;
## if the editability is true for any sub-block, set it to false
## In RM, we are setting the editability of all the sub-blocks to false in the init_design.tcl script
## The following check is implemented to ensure that the editability of the sub-blocks is set to false in flows not running the init_design.tcl script

if {$USE_ABSTRACTS_FOR_BLOCKS != ""} {
      	foreach_in_collection c [get_blocks -hierarchical] {
	  	if {[get_editability -blocks ${c}] == true } {
	     	set_editability -blocks ${c} -value false
   	  	}
      	}
	report_editability -blocks [get_blocks -hierarchical]
}


## Active scenarios for place_opt 
#  Include CTS scenarios if you are enabling CTS related features during place_opt,
#  such as PLACE_OPT_OPTIMIZE_ICGS, PLACE_OPT_TRIAL_CTS, or PLACE_OPT_MSCTS
if {$PLACE_OPT_ACTIVE_SCENARIO_LIST == "rm_activate_all_scenarios"} {
	set_scenario_status -active true [all_scenarios]
} elseif {$PLACE_OPT_ACTIVE_SCENARIO_LIST != ""} {
	set_scenario_status -active false [get_scenarios -filter active]
	set_scenario_status -active true $PLACE_OPT_ACTIVE_SCENARIO_LIST
}

#smkcow
                remove_ideal_network *

## For non-persistent settings that need to be re-applied in a new ICC-II session
puts "RM-info: Sourcing [which settings.common.non_persistent.tcl]"
source -e settings.common.non_persistent.tcl

## For common optimization settings that can impact multiple steps across the flow, refer to settings.common.opt.tcl  
puts "RM-info: Sourcing [which settings.common.opt.tcl]"
source -e settings.common.opt.tcl 

## For common routing settings, refer to settings.common.routing.tcl  
puts "RM-info: Sourcing [which settings.common.routing.tcl]"
source -e settings.common.routing.tcl

## For place_opt step related settings, refer to settings.step.place_opt.tcl
## smkcow :: place_opt.flow.do_spg is written settings.step.place_opt.tcl
puts "RM-info: Sourcing [which settings.step.place_opt.tcl]"
source -e settings.step.place_opt.tcl 

## For common CTS settings, refer to settings.common.cts.tcl
#  Normally sourced in clock_opt_cts.tcl. The script will be sourced in place_opt.tcl if PLACE_OPT_OPTIMIZE_ICGS,
#  PLACE_OPT_TRIAL_CTS, or PLACE_OPT_MSCTS is enabled.  
if {$PLACE_OPT_OPTIMIZE_ICGS || $PLACE_OPT_TRIAL_CTS || $PLACE_OPT_MSCTS} {
	puts "RM-info: Sourcing [which settings.common.cts.tcl]"
	source -e settings.common.cts.tcl
}

####################################
## read_saif 
####################################
## read_saif is recommended for features such as PREROUTE_LOW_POWER_PLACEMENT, and PREROUTE_TOTAL_POWER_OPTIMIZATION
if {[file exists [which $SAIF_FILE]]} {
	if {$SAIF_FILE_POWER_SCENARIO != ""} {
		set read_saif_cmd "read_saif $SAIF_FILE -scenarios $SAIF_FILE_POWER_SCENARIO"
	} else {
		set read_saif_cmd "read_saif $SAIF_FILE"
	}
	if {$SAIF_FILE_SOURCE_INSTANCE != ""} {lappend read_saif_cmd -strip_path $SAIF_FILE_SOURCE_INSTANCE}
	if {$SAIF_FILE_TARGET_INSTANCE != ""} {lappend read_saif_cmd -path $SAIF_FILE_TARGET_INSTANCE}
	puts "RM-info: Running $read_saif_cmd"
	eval $read_saif_cmd
} elseif {$SAIF_FILE != ""} {
	puts "RM-error: SAIF_FILE($SAIF_FILE) is invalid. Please correct it."	
}


####################################
## Pre-place_opt customizations
####################################
if {[file exists [which $TCL_USER_PLACE_OPT_PRE_SCRIPT]]} {
	puts "RM-info: Sourcing [which $TCL_USER_PLACE_OPT_PRE_SCRIPT]"
	source $TCL_USER_PLACE_OPT_PRE_SCRIPT
} elseif {$TCL_USER_PLACE_OPT_PRE_SCRIPT != ""} {
	puts "RM-error: TCL_USER_PLACE_OPT_PRE_SCRIPT($TCL_USER_PLACE_OPT_PRE_SCRIPT) is invalid. Please correct it."
}

####################################
## Core command	
####################################
if {$PLACE_OPT_USER_INSTANCE_NAME_PREFIX != ""} {
	set_app_options -name opt.common.user_instance_name_prefix -value $PLACE_OPT_USER_INSTANCE_NAME_PREFIX
	if {$PLACE_OPT_OPTIMIZE_ICGS || $PLACE_OPT_TRIAL_CTS} {
		set_app_options -name cts.common.user_instance_name_prefix -value ${PLACE_OPT_USER_INSTANCE_NAME_PREFIX}_cts
	} 
}

redirect -tee -file ${REPORTS_DIR}/${PLACE_OPT_BLOCK_NAME}.report_app_options.start {report_app_options -non_default *}
redirect -file ${REPORTS_DIR}/${PLACE_OPT_BLOCK_NAME}.report_lib_cell_purpose.rpt {report_lib_cell -objects [get_lib_cells] -column {full_name:20 valid_purposes}}

## The following only applies to designs with physical hierarchy
## Ignore the sub-blocks (bound to abstracts) internal timing paths
if {$DESIGN_STYLE == "hier" && $PHYSICAL_HIERARCHY_LEVEL != "bottom"} {
	set_timing_paths_disabled_blocks  -all_sub_blocks
}

if {[file exists [which $TCL_USER_PLACE_OPT_SCRIPT]]} {
        puts "RM-info: Sourcing [which $TCL_USER_PLACE_OPT_SCRIPT]"
        source $TCL_USER_PLACE_OPT_SCRIPT
} elseif {$TCL_USER_PLACE_OPT_SCRIPT != ""} {
        puts "RM-error:TCL_USER_PLACE_OPT_SCRIPT($TCL_USER_PLACE_OPT_SCRIPT) is invalid. Please correct it."
} else {

###################################
## Clock NDR modeling at place_opt
###################################
## Model the congestion impact of clock NDR 
#  Clock NDRs are created in settings.common.opt.tcl. The mark_clock_trees command makes place_opt recognize them.
if {$PLACE_OPT_MODEL_CLOCK_NDR && !($PLACE_OPT_OPTIMIZE_ICGS || $PLACE_OPT_TRIAL_CTS)} {
	puts "RM-info: Running mark_clock_trees -routing_rules to model clock NDR impact during place_opt"
	mark_clock_trees -routing_rules
}

###################################
## Regular MSCTS at place_opt 
###################################
if {$PLACE_OPT_MSCTS} {
	## Define MSCTS critical scenario as current_scenario as this will be the scenario considered for tap assignment
	if {$PLACE_OPT_MSCTS_CRITICAL_SCENARIO != ""} {
		set cur_scenario [get_object_name [current_scenario]]
		current_scenario $PLACE_OPT_MSCTS_CRITICAL_SCENARIO
	}

	if {[file exists [which $TCL_REGULAR_MSCTS_FILE]]} {
		set_app_options -name place_opt.flow.enable_multisource_clock_trees -value true
	        puts "RM-info: Sourcing [which $TCL_REGULAR_MSCTS_FILE]"
        	source $TCL_REGULAR_MSCTS_FILE
		if {$USE_RM_BLOCK_NAME_AS_LABEL} {
			save_block -as ${DESIGN_NAME}/${PLACE_OPT_BLOCK_NAME}_MSCTS
		} else {
			save_block -as ${PLACE_OPT_BLOCK_NAME}_MSCTS
		}

	} elseif {$TCL_REGULAR_MSCTS_FILE != ""} {
        	puts "RM-error: TCL_REGULAR_MSCTS_FILE($TCL_REGULAR_MSCTS_FILE) is invalid. Please correct it."
	}

	if {$PLACE_OPT_MSCTS_CRITICAL_SCENARIO != ""} {current_scenario $cur_scenario}
}

####################################
## Two pass place_opt
####################################	

	########################################################################
	## First pass
	########################################################################
	if {!$PLACE_OPT_SPG_FLOW} {
	## Flow with non-SPG inputs ($PLACE_OPT_SPG_FLOW set to false)
		puts "RM-info: Running create_placement"
		create_placement
		if {$PLACE_OPT_BUFFERING_AWARE_PLACEMENT} {
			puts "RM-info: Running create_placement -buffering_aware_timing_driven"
			create_placement -buffering_aware_timing_driven
		}

		puts "RM-info: Running place_opt -from initial_drc -to initial_drc"
		place_opt -from initial_drc -to initial_drc
		puts "RM-info: Running update_timing -full"
		update_timing -full
	} 

	if {$PLACE_OPT_SPG_FLOW} {
	## Flow with SPG inputs ($PLACE_OPT_SPG_FLOW set to true); depends on whether HIGH_CONNECTIVITY_FOCUSED is enabled
		if {!$HIGH_CONNECTIVITY_FOCUSED} {
		## RM default		
			puts "RM-info: For designs starting with SPG input, seed placement comes from SPG, so the first pass is skipped."
		} else {
		## For high-connectivity designs
			puts "RM-info: Running create_placement -incremental"
			create_placement -incremental ;# runs embedded CDR
		}
	}

	########################################################################
	## Second pass: by using create_placement -incremental and place_opt -from initial_drc	
	########################################################################
	## Trial clock tree  (optional)
	#  Enabled only if PLACE_OPT_OPTIMIZE_ICGS is not enabled since tool will enable this feature automatically,
	#  if PLACE_OPT_OPTIMIZE_ICGS is enabled
	if {$PLACE_OPT_TRIAL_CTS && !$PLACE_OPT_OPTIMIZE_ICGS} {
		set_app_options -name place_opt.flow.trial_clock_tree -value true ;# default false
	}

	## ICG optimization  (optional)
	#  Automatic ICG optimization that performs early clock synthesis (starting in initial_drc phase), 
	#  timing-driven ICG splitting (initial_opto phase), and clock-aware placement (final_place phase)
	if {$PLACE_OPT_OPTIMIZE_ICGS} {
		set_app_option -name place_opt.flow.optimize_icgs -value true ;# default false
		if {$PLACE_OPT_OPTIMIZE_ICGS_CRITICAL_RANGE != ""} {
			set_app_options -name place_opt.flow.optimize_icgs_critical_range -value $PLACE_OPT_OPTIMIZE_ICGS_CRITICAL_RANGE ;# default 0.75
		}
	}

	puts "RM-info: Running create_placement -incremental -timing_driven -congestion"
	# Note: to increase the congestion alleviation effort, add -congestion_effort high
	create_placement -incremental -timing_driven -congestion
	if {$USE_RM_BLOCK_NAME_AS_LABEL} {
		save_block -as ${DESIGN_NAME}/${PLACE_OPT_BLOCK_NAME}_two_pass_placement
	} else {
		save_block -as ${PLACE_OPT_BLOCK_NAME}_two_pass_placement
	}

	puts "RM-info: Running place_opt -from initial_drc -to initial_opto"
	place_opt -from initial_drc -to initial_opto

	## Multi-bit banking (optional) 
	if {$PLACE_OPT_MULTIBIT_BANKING} {
		set identify_multibit_cmd "identify_multibit -register -no_dft_opt -apply"
		if {$PLACE_OPT_MULTIBIT_BANKING_CELL_INSTANCE_LIST != ""} {
			lappend identify_multibit_cmd -cells $PLACE_OPT_MULTIBIT_BANKING_CELL_INSTANCE_LIST
		}
		if {$PLACE_OPT_MULTIBIT_BANKING_EXCLUDED_INSTANCE_LIST != ""} {
			lappend identify_multibit_cmd -exclude_instance $PLACE_OPT_MULTIBIT_BANKING_EXCLUDED_INSTANCE_LIST
		}
		puts "RM-info: Running $identify_multibit_cmd"
		eval $identify_multibit_cmd
	}

	puts "RM-info: Running place_opt -from final_place"
	place_opt -from final_place

	## Multi-bit de-banking (optional)
	if {$PLACE_OPT_MULTIBIT_DEBANKING} {
		set split_multibit_cmd "split_multibit -slack_threshold 0"
		if {$PLACE_OPT_MULTIBIT_DEBANKING_CELL_INSTANCE_LIST != ""} {
			lappend split_multibit_cmd -cells $PLACE_OPT_MULTIBIT_DEBANKING_CELL_INSTANCE_LIST
		}
		if {$PLACE_OPT_MULTIBIT_DEBANKING_EXCLUDED_INSTANCE_LIST != ""} {
			lappend split_multibit_cmd -exclude_instance $PLACE_OPT_MULTIBIT_DEBANKING_EXCLUDED_INSTANCE_LIST
		}
		puts "RM-info: Running $split_multibit_cmd"
		eval $split_multibit_cmd

		puts "RM-info: Running refine_opt"
		refine_opt
	}

}

####################################
## Post-place_opt customizations
####################################
if {[file exists [which $TCL_USER_PLACE_OPT_POST_SCRIPT]]} {
        puts "RM-info: Sourcing [which $TCL_USER_PLACE_OPT_POST_SCRIPT]"
        source $TCL_USER_PLACE_OPT_POST_SCRIPT
} elseif {$TCL_USER_PLACE_OPT_POST_SCRIPT != ""} {
        puts "RM-error:TCL_USER_PLACE_OPT_POST_SCRIPT($TCL_USER_PLACE_OPT_POST_SCRIPT) is invalid. Please correct it."
}

####################################
## refine_opt	
####################################
## Optional command to further optimize the placement and the netlist.
if {$PLACE_OPT_REFINE_OPT == "refine_opt" || $PLACE_OPT_REFINE_OPT == "path_opt" || $PLACE_OPT_REFINE_OPT == "power" || $PLACE_OPT_REFINE_OPT == "area"} {
	if {$PLACE_OPT_REFINE_OPT_USER_INSTANCE_NAME_PREFIX != ""} {
		set_app_options -name opt.common.user_instance_name_prefix -value $PLACE_OPT_REFINE_OPT_USER_INSTANCE_NAME_PREFIX
	}
	if {$USE_RM_BLOCK_NAME_AS_LABEL} {
		save_block -as ${DESIGN_NAME}/${PLACE_OPT_BLOCK_NAME}_pre_refine_opt
	} else {
		save_block -as ${PLACE_OPT_BLOCK_NAME}_pre_refine_opt
	}
	if {$PLACE_OPT_REFINE_OPT == "refine_opt"} {
		puts "RM-info: Running refine_opt command"
		## refine_opt -end_points <pins | ports> or refine_opt -path_groups <pathgroups> will be more helpful
		refine_opt
	} elseif {$PLACE_OPT_REFINE_OPT == "path_opt"} {
		puts "RM-info: Running refine_opt -from final_path_opt command"
		refine_opt -from final_path_opt
	} elseif {$PLACE_OPT_REFINE_OPT == "power"} {
		puts "RM-info: Running refine_opt exclusive power optimization"
		set_app_options -name refine_opt.flow.exclusive -value power
		refine_opt
	} elseif {$PLACE_OPT_REFINE_OPT == "area"} {
		puts "RM-info: Running refine_opt exclusive area recovery"
		set_app_options -name refine_opt.flow.exclusive -value area
		refine_opt 
	}
}



if {$TCL_USER_CONNECT_PG_NET_SCRIPT != ""} {
	if {[file exists [which $TCL_USER_CONNECT_PG_NET_SCRIPT]]} {
		puts "RM-info: Sourcing [which $TCL_USER_CONNECT_PG_NET_SCRIPT]"
  		source $TCL_USER_CONNECT_PG_NET_SCRIPT
	} else {
		puts "RM-error: TCL_USER_CONNECT_PG_NET_SCRIPT($TCL_USER_CONNECT_PG_NET_SCRIPT) is invalid. Pls correct it."
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
        set REPORT_PREFIX $PLACE_OPT_BLOCK_NAME
	puts "RM-info: Sourcing [which $REPORT_QOR_SCRIPT]"
	source $REPORT_QOR_SCRIPT
}


if {$REPORT_QOR_REPORT_CONGESTION} {
	if {!$REPORT_QOR} {set REPORT_PREFIX $PLACE_OPT_BLOCK_NAME} 
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
echo [date] > place_opt

exit 


