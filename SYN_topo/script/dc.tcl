
#################################################################################
# Design Compiler Reference Methodology Script for Top-Down MCMM Flow
# Script: dc.tcl
# Version: M-2016.12-SP4 (July 17, 2017)
# Copyright (C) 2007-2016 Synopsys, Inc. All rights reserved.
#################################################################################
set ENABLE_DFT false
# Design Compiler must be run in topographical mode for MCMM flow support
# MCMM also requires a license for Design Compiler Graphical
if {![shell_is_in_topographical_mode]} {
  puts "RM-Error: dc_shell must be run in topographical mode for MCMM support."
  exit 1
}

# Design Compiler must be run in topographical mode for SPG flow support
# SPG also requires a license for Design Compiler Graphical
if {![shell_is_in_topographical_mode]} {
  puts "RM-Error: dc_shell must be run in topographical mode for SPG support."
  exit 1
}

#################################################################################
# Additional Variables
#
# Add any additional variables needed for your flow here.
#################################################################################


################################################################################
# You can enable inference of multibit registers from the buses defined in the RTL.
# The replacement of single-bit cells with multibit library cells occurs during execution 
# of the compile_ultra command. This variable has to be set before reading the RTL
#
# set_app_var hdlin_infer_multibit default_all
#################################################################################

if { $OPTIMIZATION_FLOW == "hplp"} {
 set_app_var hdlin_infer_multibit default_all
}

# Enable the support of via resistance for RC estimation to improve the timing 
# correlation with IC Compiler
set_app_var spg_enable_via_resistance_support true

if {[file exists [which ${LIBRARY_DONT_USE_PRE_COMPILE_LIST}]]} {
  puts "RM-Info: Sourcing script file [which ${LIBRARY_DONT_USE_PRE_COMPILE_LIST}]\n"
  source -echo -verbose $LIBRARY_DONT_USE_PRE_COMPILE_LIST
}

#################################################################################
# Setup for Formality Verification
#################################################################################

# In the event of an inconclusive (or hard) verification, we recommend using
# the set_verification_priority commands provided from the analyze_points command
# in Formality. The set_verification_priority commands target specific
# operators to reduce verification complexity while minimizing QoR impact.
# The set_verification_priority commands should be applied after the design
# is read and elaborated.

# For designs that don't have tight QoR constraints and don't have register retiming,
# you can use the following variable to enable the highest productivity single pass flow.
# This flow modifies the optimizations to make verification easier.
# This variable setting should be applied prior to reading in the RTL for the design.

# set_app_var simplified_verification_mode true

# For more information about facilitating formal verification in the flow, refer
# to the following SolvNet article:
# "Resolving Inconclusive and Hard Verifications in Design Compiler"
# https://solvnet.synopsys.com/retrieve/033140.html

# Define the verification setup file for Formality
set_svf ${RESULTS_DIR}/${DCRM_SVF_OUTPUT_FILE}

#################################################################################
# Read in the RTL Design
#
# Read in the RTL source files or read in the elaborated design (.ddc).
#################################################################################

define_design_lib WORK -path ./WORK

analyze -format verilog ${RTL_SOURCE_FILES}

set ELABORATION_PARAMETERS [list]
foreach PARAMETER_NAME {
    CROSSBAR_DIMENSION MAX_BL STOCHASTIC_VALUE_WIDTH OUTPUT_BUFFER_DEPTH
    RAW_REPLAY_MODE LFSR_SEED
} {
    if {[info exists ::env($PARAMETER_NAME)]} {
        lappend ELABORATION_PARAMETERS \
            "${PARAMETER_NAME}=$::env($PARAMETER_NAME)"
    }
}
if {[llength $ELABORATION_PARAMETERS] > 0} {
    elaborate ${DESIGN_NAME} \
        -parameters [join $ELABORATION_PARAMETERS ","]
} else {
    elaborate ${DESIGN_NAME}
}

#set uniquify_naming_style "${DESIGN_NAME}_%s_%d"
#uniquify -force

#read_ddc VECTOR.mapped.ddc
#read_ddc MEMSET.mapped.ddc
#read_ddc CORE.mapped.ddc



#read_ddc memory_wrapper.mapped.ddc
#read_ddc fifo.mapped.ddc

# elaborate leaves the selected (and possibly parameterized) design current.
link

# Record RTL names so a later read_saif can annotate the mapped netlist.
# This does not feed activity into compile_ultra, so area/fmax stay unchanged.
catch {saif_map -start}

# Capture the elaborated, pre-optimization hierarchy so the no-replay
# synthesis configuration can be audited for RNG and pulse-generator logic.
report_hierarchy > ${REPORTS_DIR}/precompile_hierarchy.rpt

# OR

# You can read an elaborated design from the same release.
# Using an elaborated design from an older release will not give the best results.

# read_ddc ${DCRM_ELABORATED_DESIGN_DDC_OUTPUT_FILE}
write -hierarchy -format ddc -output ${RESULTS_DIR}/${DCRM_ELABORATED_DESIGN_DDC_OUTPUT_FILE}

#################################################################################
# sets the multibit_mode attribute
#################################################################################
if { $OPTIMIZATION_FLOW == "hplp"} {
  # Enable mapping to multibit only if the timing is not degraded.
  set_multibit_options -mode timing_driven
}

#################################################################################
# Reports pre-synthesis congestion analysis.
#################################################################################
if { $OPTIMIZATION_FLOW == "hc"} {
  #Analyze the RTL constructs which may lead to congestion
  analyze_rtl_congestion > ${REPORTS_DIR}/${DCRM_ANALYZE_RTL_CONGESTION_REPORT_FILE}
}

#################################################################################
# Apply Logical Design Constraints
#################################################################################

# For MCMM, do not apply the constraints here.  Constraints should be
# applied for each scenario in the ${DCRM_MCMM_SCENARIOS_SETUP_FILE}

#################################################################################
# Apply The Operating Conditions
#################################################################################

# For MCMM, do not apply the operating conditions here.  Operating conditions
# should be applied for each scenario in the ${DCRM_MCMM_SCENARIOS_SETUP_FILE}

#################################################################################
# Set Up the Multicorner Multimode (MCMM) Scenarios
#
# Note: The MCMM flow is only supported in topographical mode and it requires
#       a license for Design Compiler Graphical. 
#################################################################################

# Use the dc.mcmm.scenarios.tcl example file as as reference for
# what should be included in the ${DCRM_MCMM_SCENARIOS_SETUP_FILE}

# Smkcow
# So important at TOP module
# Or, scenarios is duplicated and make compile errors
# Clear any default-scenario constraints once.  Calling reset_design from an
# individual MCMM constraint file erases scenarios that were created earlier.
reset_design
remove_scenario -all

puts "RM-Info: Sourcing script file [which ${DCRM_MCMM_SCENARIOS_SETUP_FILE}]\n"
source -echo -verbose ${DCRM_MCMM_SCENARIOS_SETUP_FILE}
redirect -tee -file ${REPORTS_DIR}/${DESIGN_NAME}.check_timing {check_timing}

# To get the best memory and runtime performance, only define scenarios
# needed for optimization in Design Compiler.
# If additional scenarios are also included, use the following command to
# select the set of desired scenarios for optimization.

# set_active_scenarios <list of scenarios for synthesis optimization>


##################################################################################
# MCMM constraints and operating conditions are applied exactly once by:
#   ${DCRM_MCMM_SCENARIOS_SETUP_FILE}
#
# Do not read the same SDC files again here.
##################################################################################


report_scenarios > ${REPORTS_DIR}/${DCRM_MCMM_SCENARIOS_REPORT}
check_scenarios -output ${REPORTS_DIR}

redirect -tee -file ${REPORTS_DIR}/${DESIGN_NAME}.report_port.reports {report_port -verbose}

# smkcow addition ::
#When you use multiple libraries, if library cells with the same name are not functionally identical or do not have identical sets of library pins with the same name and order, the tool issues a warning stating that the libraries are inconsistent.
#You should run the check_library command before running a multicorner-multimode flow, as shown in the following example,

set_check_library_options -mcmm

check_library -logic_library_name { \
sc9_cmos28lpp_base_rvt_ff_nominal_min_1p100v_m40c_sadhm.db \
sc9_cmos28lpp_base_rvt_tt_nominal_max_1p000v_25c.db \
}

# continuing from the above :::::
#When you use the -mcmm option with the set_check_library_options command, the check_library command performs multicorner-multimode specific checks, such as determining operating condition or power-down inconsistencies. When inconsistencies are detected, the tool generates a report that lists the inconsistencies. In addition, the tool issues the following summary information message:
#Information: Logic library consistency check FAILED for MCMM. 
#(LIBCHK-360)


#################################################################################
# Create Default Path Groups
#
# Separating these paths can help improve optimization.
# Remove these path group settings if user path groups have already been defined.
#################################################################################

set current_scenario_saved [current_scenario]
foreach scenario [all_active_scenarios] {
  current_scenario ${scenario}
  set ports_clock_root [filter_collection [get_attribute [get_clocks] sources] object_class==port]
  group_path -name REGOUT -to [all_outputs] 
  group_path -name REGIN -from [remove_from_collection [all_inputs] ${ports_clock_root}] 
  group_path -name FEEDTHROUGH -from [remove_from_collection [all_inputs] ${ports_clock_root}] -to [all_outputs]
}
current_scenario ${current_scenario_saved}

#################################################################################
# Power Optimization Section
#################################################################################

    #############################################################################
    # Clock Gating Setup
    #############################################################################

    # If your design has instantiated clock gates, you should use identify_clock_gating
    # command to identify and the report_clock_gating -multi_stage to report them.

    # identify_clock_gating
    # report_clock_gating -multi_stage -nosplit > ${REPORTS_DIR}/${DCRM_INSTANTIATE_CLOCK_GATES_REPORT}

    # If you do not want clock-gating to optimize your user instantiated
    # clock-gating cells, you should set the pwr_preserve_cg attribute upon
    # those clock-gating cells.

    # set_preserve_clock_gate [get_cell <user_clock_gating_cells>]

    # Infer ICG for clock-enable registers (LFSR ENABLE=source_fire, shared delays).
    # integrated = library ICG cell, not a combinational AND on CLK.
    set_clock_gating_style -positive_edge_logic {integrated} -minimum_bitwidth 1
    set compile_clock_gating_through_hierarchy true

    # For better timing optimization of enable logic, clock latency for 
    # clock gating cells can be optionally specified.

    # set_clock_gate_latency -clock <clock_name> -stage <stage_num> \
    #         -fanout_latency {fanout_range1 latency_val1 fanout_range2 latency_val2 ...}

    # You can use "set_self_gating_options" command to specify self-gating 
    # options when -self_gating option is used in addition to -gate_clock 
    # option at the compile_ultra command. To inserts self-gate on clock-gated
    # registers, uncomment the following line:
    # set_self_gating_options -interaction_with_clock_gating insert

    # To improve enable timing in high performance designs, physically aware clock gating 
    # is available in Design Compiler topographical for Synopsys Physical Guidance (SPG) 
    # flow. This flow works best with a corresponding IC Compiler  SPG flow. To enable 
    # physically aware clock gating in Design Compiler Graphical, uncomment the 
    # following setting:

    #set_app_var power_cg_physically_aware_cg true
    set_app_var power_cg_physically_aware_cg true
    
    #############################################################################
    # Apply Power Optimization Constraints
    #############################################################################

    # For MCMM, do not apply the SAIF file here.  The SAIF file should be read in
    # for each scenario in the ${DCRM_MCMM_SCENARIOS_SETUP_FILE}

    if {[shell_is_in_topographical_mode]} {
      # For multi-Vth design, replace the following to set the threshold voltage groups in the libraries.

      # set_attribute <my_hvt_lib> default_threshold_voltage_group HVT -type string
      # set_attribute <my_lvt_lib> default_threshold_voltage_group LVT -type string
    }

    # Starting in J-2014.09, leakage optimization is the default flow and is always enabled.
    # For MCMM, include a leakage scenario in the ${DCRM_MCMM_SCENARIOS_SETUP_FILE}.

    # Power prediction with clock tree estimation is not supported with MCMM.
    # Do not use the set_power_prediction command with MCMM designs.

if {[shell_is_in_topographical_mode]} {

  ##################################################################################
  # Apply Physical Design Constraints
  #
  # Optional: Floorplan information can be read in here if available.
  # This is highly recommended for irregular floorplans.
  #
  # Floorplan constraints can be provided from one of the following sources:
  # * extract_physical_constraints with a DEF file
  #	* read_floorplan with a floorplan file (written by write_floorplan)
  #	* User generated Tcl physical constraints
  #
  ##################################################################################

  # Specify ignored layers for routing to improve correlation
  # Use the same ignored layers that will be used during place and route

  if { ${MIN_ROUTING_LAYER} != ""} {
    set_ignored_layers -min_routing_layer ${MIN_ROUTING_LAYER}
  }
  if { ${MAX_ROUTING_LAYER} != ""} {
    set_ignored_layers -max_routing_layer ${MAX_ROUTING_LAYER}
  }

  report_ignored_layers

  # If the macro names change after mapping and writing out the design due to
  # ungrouping or Verilog change_names renaming, it may be necessary to translate 
  # the names to correspond to the cell names that exist before compile.

  # During DEF constraint extraction, extract_physical_constraints automatically
  # matches DEF names back to precompile names in memory using standard matching rules.
  # read_floorplan will also automatically perform this name matching.

  # Modify set_query_rules if other characters are used for hierarchy separators
  # or bus names. 

  # set_query_rules  -hierarchical_separators {/ _ .} \
  #                  -bus_name_notations {[] __ ()}   \
  #                  -class {cell pin port net}       \
  #                  -wildcard                        \
  #                  -regsub_cumulative               \
  #                  -show

  ## For DEF floorplan input

  # The DEF file for Design Compiler Topographical can be written from IC Compiler using the following 
  # recommended options:
  # icc_shell> write_def -version 5.7 -rows_tracks_gcells -fixed -pins -blockages -specialnets \
  #                      -vias -regions_groups -verbose -output ${DCRM_DCT_DEF_INPUT_FILE}

  if {[file exists [which ${DCRM_DCT_DEF_INPUT_FILE}]]} {
    # If you have physical only cells as a part of your floorplan DEF file, you can use
    # the -allow_physical_cells option with extract_physical_constraints to include
    # the physical only cells as a part of the floorplan in Design Compiler to improve correlation.
    #
    # Note: With -allow_physical_cells, new logical cells in the DEF file
    #       that have a fixed location will also be added to the design in memory.
    #       See the extract_physical_constraints manpage for more information about
    #       identifying the cells added to the design when using -allow_physical_cells.
  
    # extract_physical_constraints -allow_physical_cells ${DCRM_DCT_DEF_INPUT_FILE}

    puts "RM-Info: Reading in DEF file [which ${DCRM_DCT_DEF_INPUT_FILE}]\n"
    extract_physical_constraints ${DCRM_DCT_DEF_INPUT_FILE}
    if { $OPTIMIZATION_FLOW == "hplp"} {
	extract_physical_constraints -allow_physical_cells ${DCRM_DCT_DEF_INPUT_FILE}  
    }
  }
  
  # OR

  ## For floorplan file input

  # The floorplan file for Design Compiler Topographical can be written from IC Compiler using the following 
  # recommended options:
  # Note: IC Compiler requires the use of -placement {terminal} with -create_terminal beginning in the
  #       D-2010.03-SP1 release.
  # icc_shell> write_floorplan -placement {io terminal hard_macro soft_macro} -create_terminal \
  #                            -row -create_bound -preroute -track ${DCRM_DCT_FLOORPLAN_INPUT_FILE}

  # Read in the secondary floorplan file, previously written by write_floorplan in Design Compiler,
  # to restore physical-only objects back to the design, before reading the main floorplan file.

  if {[file exists [which ${DCRM_DCT_FLOORPLAN_INPUT_FILE}.objects]]} {
    puts "RM-Info: Reading in secondary floorplan file [which ${DCRM_DCT_FLOORPLAN_INPUT_FILE}.objects]\n"
    read_floorplan ${DCRM_DCT_FLOORPLAN_INPUT_FILE}.objects
  }

  if {[file exists [which ${DCRM_DCT_FLOORPLAN_INPUT_FILE}]]} {
    puts "RM-Info: Reading in floorplan file [which ${DCRM_DCT_FLOORPLAN_INPUT_FILE}]\n"
    read_floorplan ${DCRM_DCT_FLOORPLAN_INPUT_FILE}
  }

  # OR

  ## For Tcl file input

  # For Tcl constraints, the name matching feature must be explicitly enabled
  # and will also use the set_query_rules setttings. This should be turned off
  # after the constraint read in order to minimize runtime.

  if {[file exists [which ${DCRM_DCT_PHYSICAL_CONSTRAINTS_INPUT_FILE}]]} {
    set_app_var enable_rule_based_query true
    puts "RM-Info: Sourcing script file [which ${DCRM_DCT_PHYSICAL_CONSTRAINTS_INPUT_FILE}]\n"
    source -echo -verbose ${DCRM_DCT_PHYSICAL_CONSTRAINTS_INPUT_FILE}
    set_app_var enable_rule_based_query false 
  }


  # Use write_floorplan to save the applied floorplan.

  # Note: A secondary floorplan file ${DCRM_DCT_FLOORPLAN_OUTPUT_FILE}.objects
  #       might also be written to capture physical-only objects in the design.
  #       This file should be read in before reading the main floorplan file.

  write_floorplan -all ${RESULTS_DIR}/${DCRM_DCT_FLOORPLAN_OUTPUT_FILE}

  # Verify that all the desired physical constraints have been applied
  # Add the -pre_route option to include pre-routes in the report
  report_physical_constraints > ${REPORTS_DIR}/${DCRM_DCT_PHYSICAL_CONSTRAINTS_REPORT}
}

#################################################################################
# Apply Additional Optimization Constraints
#################################################################################

# Prevent assignment statements in the Verilog netlist.
set_fix_multiple_port_nets -all -buffer_constants

#################################################################################
# Save the compile environment snapshot for the Consistency Checker utility.
#
# This utility checks for inconsistent settings between Design Compiler and
# IC Compiler which can contribute to correlation mismatches.
#
# Download this utility from SolvNet.  See the following SolvNet article for
# complete details:
#
# https://solvnet.synopsys.com/retrieve/026366.html
#
# The article is titled: "Using the Consistency Checker to Automatically Compare
# Environment Settings Between Design Compiler and IC Compiler"
#################################################################################

# Uncomment the following to snapshot the environment for the Consistency Checker
# for each active scenario.  You will also need to run the Consistency Checker
# utility for each scenario environment snapshot.

# set current_scenario_saved [current_scenario]
# foreach scenario [all_active_scenarios] {
#   current_scenario ${scenario}
#   write_environment -consistency -output ${REPORTS_DIR}/[dcrm_mcmm_filename ${DCRM_CONSISTENCY_CHECK_ENV_FILE} ${scenario}]
# }
# current_scenario ${current_scenario_saved}

#################################################################################
# Check for Design Problems 
#################################################################################

# Check the current design for consistency
check_design -summary
check_design > ${REPORTS_DIR}/${DCRM_CHECK_DESIGN_REPORT}

# The analyze_datapath_extraction command can help you to analyze why certain data 
# paths are no extracted, uncomment the following line to report analyisis.

# analyze_datapath_extraction > ${REPORTS_DIR}/${DCRM_ANALYZE_DATAPATH_EXTRACTION_REPORT}


#################################################################################
# Multibit Register Reports pre-compile_ultra
#################################################################################

#################################################################################
# Uncomment the next line to verify that the desired bussed registers are grouped as multibit components 
# These multibit components are mapped to multibit registers during compile_ultra
#
# redirect ${REPORTS_DIR}/${DCRM_MULTIBIT_COMPONENTS_REPORT} {report_multibit -hierarchical }
#################################################################################


#################################################################################
# Compile the Design
#
# Recommended Options:
#
#     -scan
#     -gate_clock (-self_gating)
#     -retime
#     -spg
#
# Use compile_ultra as your starting point. For test-ready compile, include
# the -scan option with the first compile and any subsequent compiles.
#
# Use -gate_clock to insert clock-gating logic during optimization.  This
# is now the recommended methodology for clock gating.
#
# Use -self_gating option in addition to -gate_clock for potentially saving 
# additional dynamic power, in topographical mode only. Registers that are 
# not clock gated will be considered for XOR self gating.
# XOR self gating should be performed along with clock gating, using -gate_clock
# and -self_gating options. XOR self gates will be inserted only if there is 
# potential power saving without degrading the timing.
# An accurate switching activity annotation either by reading in a saif 
# file or through set_switching_activity command is recommended.
# You can use "set_self_gating_options" command to specify self-gating 
# options.
#
# Use -retime to enable adaptive retiming optimization for further timing benefit.
#
# Use the -spg option to enable Design Compiler Graphical physical guidance flow.
# The physical guidance flow improves QoR, area and timing correlation, and congestion.
# It also improves place_opt runtime in IC Compiler.
#
# Note: In addition to -spg option you can enable the support of via resistance for 
#       RC estimation to improve the timing correlation with IC Compiler by using the 
#       following setting:
#
#       set_app_var spg_enable_via_resistance_support true
#
# You can selectively enable or disable the congestion optimization on parts of 
# the design by using the set_congestion_optimization command.
# This option requires a license for Design Compiler Graphical.
#
# The constant propagation is enabled when boundary optimization is disabled. In 
# order to stop constant propagation you can do the following
#
# set_compile_directives -constant_propagation false <object_list>
#
# Note: Layer optimization is on by default in Design Compiler Graphical, to 
#       improve the the accuracy of certain net delay during optimization.
#       To disable the the automatic layer optimization you can use the 
#       -no_auto_layer_optimization option.
#
#################################################################################
## RM+ Variable and Command Settings before first compile_ultra
#################################################################################
if { $OPTIMIZATION_FLOW == "hplp"} {
    if {[shell_is_in_topographical_mode]} {

	# The following variable, when set to true, runs additional optimizations to improve the timing of  
	# the design at the cost of additional run time.
	set_app_var compile_timing_high_effort true

	# The following variable enables a mode of coarse placement in which cells are not distributed  
	# evenly  across the surface but are allowed to clump together for better QoR     
	set_app_var placer_max_cell_density_threshold 0.75        

	# The following variable, when set to true, enables very high effort optimization to fix total negative slack 
	# Setting following variable to true may affect run time
	set_app_var psynopt_tns_high_effort true

	# Use the following variable to enable the physically aware clock gating 
	set_app_var power_cg_physically_aware_cg true
	
	#The following variable helps to reduce the total negative slack of the design
	set_app_var placer_tns_driven true

	# Enable low power placement.  
	# Low power placement affects the placement of cells, pulls them closer together, 
	# on nets with high switching activity to reduce the overall dynamic power of your design.  
        set_app_var power_low_power_placement true

        # In MCMM flow use set_scenario_options -dynamic_power true 
	set_dynamic_optimization true
	
	# The following variable enables register replication across the hierarchy by creating new ports
	# on the instances of the subdesigns if it is necessary to improve the timing of the design
	set_app_var compile_register_replication_across_hierarchy true 
    }
}
if { $OPTIMIZATION_FLOW == "hc"} {
   if {[shell_is_in_topographical_mode]} {

       # This command enables congestion aware Global buffering based on Zroutebased estimation,
       # reducing congestion along narrow channels across macros. Enabling this feature may have 
       # runtime and QOR impact. Enable this variable on macro intensive designs with narrow channels.
       # set_ahfs_options -global_route true


       # With the following variables set, Zroute-based congestion-driven placement is enabled
       # instead of virtual route based estimation. 
       # Enabling this feature may have runtime impact. Enable this for highly congested designs
       # set_app_var placer_congestion_effort medium
       # set_app_var placer_enable_enhanced_router true

       # Enabling the variable can lead to lower congestion for designs that have congestion due to
       # multiplexing logic in the RTL. This variable is supported only in the initial compile step,
       # Not supported in incremental compile.
       set_app_var compile_prefer_mux true
   }
}
if { $OPTIMIZATION_FLOW == "rtm_exp"} {
  if {[shell_is_in_topographical_mode]} {
  
      set_host_options -max_cores 8
      # The following command overrides runtime-intensive user settings with settings designed
      # to improve runtime. Since the run time intensive optimizations are turned off it might 
      # impact QoR. You can use this as an exploration flow when run time is a concern.
      compile_prefer_runtime
  }
}
if {[shell_is_in_topographical_mode]} {
  # Use the "-check_only" option of "compile_ultra" to verify that your
  # libraries and design are complete and that optimization will not fail
  # in topographical mode.  Use the same options as will be used in compile_ultra.

  # compile_ultra -scan -gate_clock -spg -check_only
}

set_host_options -max_cores 8 

compile_ultra -gate_clock -spg -no_autoungroup > ${REPORTS_DIR}/${DESIGN_NAME}.compile_ultra.rpt
#compile_ultra -spg -no_autoungroup 

#################################################################################
# Save Design after First Compile
#################################################################################

write -format ddc -hierarchy -output ${RESULTS_DIR}/${DCRM_COMPILE_ULTRA_DDC_OUTPUT_FILE}

if {$OPTIMIZATION_FLOW != "rtm_exp"} {
#################################################################################
# Performing placement aware multibit banking
#################################################################################

#################################################################################
if {[shell_is_in_topographical_mode]} {
       # You can use placement aware multibit banking to group single-bit register cells that are
       # physically near each other into a multibit registers. 
       # This has to be done before DFT insertion in Design Compiler
       # These commands require a Design Compiler Graphical license
       #
       # identify_register_banks -output ${RESULTS_DIR}/${DCRM_MULTIBIT_CREATE_REGISTER_BANK_FILE}
       # redirect ${REPORTS_DIR}/${DCRM_MULTIBIT_CREATE_REGISTER_BANK_REPORT} {source -echo -verbose ${RESULTS_DIR}/${DCRM_MULTIBIT_CREATE_REGISTER_BANK_FILE}}
}
#################################################################################


################################################################################
## RM+ Variable and Command Settings before incremental compile
################################################################################
if { $OPTIMIZATION_FLOW == "hplp" } {
    if {[shell_is_in_topographical_mode]} {
	# You can use placement aware multibit banking to group single-bit register cells that 
	# are physically near each other into a multibit registers
	identify_register_banks -output \
	    ${RESULTS_DIR}/${DCRM_MULTIBIT_CREATE_REGISTER_BANK_FILE}
	source -echo -verbose ${RESULTS_DIR}/${DCRM_MULTIBIT_CREATE_REGISTER_BANK_FILE}
    }
}
#################################################################################
# DFT Compiler Optimization Section
#################################################################################

    #############################################################################
    # Verilog Libraries for Test Design Rule Checking
    #############################################################################

    # For complex cells that do not have functional models in .lib format,
    # you can supply a list of TetraMAX-compatible Verilog libraries 
    # for test design rule checking.
    # Set the following variable in the dc_setup.tcl file:
    
    # set_app_var test_simulation_library <list of Verilog library files>

    #############################################################################
    # DFT Signal Type Definitions
    #
    # These are design-specific settings that should be modified.
    # The following are only examples and should not be used.
    #############################################################################

    # Define all global DFT signals in this section. If you define any Top-down DFT partitions, 
    # specify DFT signals in the DFT partitions section.
    # It is recommended that top-level test ports be defined as a part of the
    # RTL design and included in the netlist for floorplanning.

    # If you create test ports here and they are not in your floorplan, you should use
    # create_terminal for these additional test ports for topographical mode synthesis.

    if {[shell_is_in_topographical_mode]} {
      # create_terminal -layer "layer_name" -bounding_box {x1 y1 x2 y2} -port ScanPortName ... (repeat for each new test port)
    }

    # If you are using the internal pins flow, it is recommended to run the
    # change_names command before set_dft_signal to avoid problems after DFT insertion.
    # In this case, set_dft_signal pins should be based on pin names after change_names.
    #   -  Use the "-view existing_dft" for already connected DFT signals which must be 
    #      understood for the design to pass "dft_drc".
    #   -  Use the "-view spec" for DFT signals that DFT Compiler will use during
    #      "insert_dft" when making new scan connections.

    # change_names -rules verilog -hierarchy

    # set_dft_signal -view spec -type ScanDataOut -port SO
    # set_dft_signal -view spec -type ScanDataIn -port SI
    # set_dft_signal -view spec -type ScanEnable -port SCAN_ENABLE
    # set_dft_signal -view existing_dft -type ScanClock -port [list CLK] -timing {45 55}
    # set_dft_signal -view existing_dft -type Reset -port RESET -active 0

    if {$ENABLE_DFT} {

            puts "RM-Info: Sourcing script file [which ${DCRM_DFT_SIGNAL_SETUP_INPUT_FILE}]\n"
            source -echo -verbose ${DCRM_DFT_SIGNAL_SETUP_INPUT_FILE}

            #############################################################################
            # DFT for Clock Gating
            #
            # This section includes variables and commands used only when clock gating
            # has been performed in the design.
            #############################################################################

            # Use the following command to initialize clock gating cells for test that are
            # made transparent with a signal held constant for testing, e.g. of type 'Constant'.
            # The value set depends on the hierarchy depth of the clock-gating cells.
            # This setting is not needed where clock-gating cells are controlled with scan enable.

            # set_dft_drc_configuration -clock_gating_init_cycles 1

            # To specify a dedicated ScanEnable/TestMode signal to be used for clock gating,
            # use the "-usage clock_gating" option of the "set_dft_signal" command

            # set_dft_signal -view spec -type <ScanEnable|TestMode> -port <dedicated port> -usage clock_gating

            # You can specify the clock-gating connectivity of the ScanEnable/TestMode signals
            # after they are predefined with set_dft_signal -usage clock_gating

            # set_dft_connect <LABEL> -type clock_gating_control -source <DFT signal> [-target ...]

            #############################################################################
            # DFT Configuration
            #############################################################################

            # Preserve the design name when writing to the database during DFT insertion. 
            set_dft_insertion_configuration -preserve_design_name true

            # Do not perform synthesis optimization during DFT insertion. 
            set_dft_insertion_configuration -synthesis_optimization none

            # Multibit cell handling
            # Specify -preserve_multibit_segment to false to treat the cells inside a
            # multibit component as discrete sequential cells. This improves balancing
            # of scan chains.
            # Starting I-2013.12 release, the default setting is false
            # set_scan_configuration -preserve_multibit_segment false

            ## DFT Clock Mixing Specification
            # For a hierarchical flow, don't mix clocks at the block level:
            # set_scan_configuration -clock_mixing no_mix

            # For a top-down methodology clock mixing is recommended, if possible:
            set_scan_configuration -clock_mixing mix_clocks

            #############################################################################
            # DFT AutoFix Configuration
            #############################################################################

            # Please refer to the DFT Compiler, DFTMAX, and DFTMAX Ultra User Guide, Chapter 12,
            # "Advanced DFT Architecture Methodologies", "Using AutoFix" section.

            # Please refer to the dc.dft_autofix_config.tcl file included with the
            # Design Compiler Reference Methodology scripts for an example of a
            # design-specific AutoFix configuration.

            # Create a design-specific Autofix configuration file and uncomment the
            # following line to source this file.

            # source -echo -verbose ${DCRM_DFT_AUTOFIX_CONFIG_INPUT_FILE}

            #############################################################################
            # DFTMAX Compression Configuration 
            #############################################################################

            # Starting with Reference Methodology Scripts version G-2012.06
            # DFTMAX Compression is enabled in the default flow configuration.

            # Comment out the following command or change the option to "-scan_compression disable"
            # to disable DFTMAX Compression during DFT insertion.

            set_dft_configuration -scan_compression enable

            # DFTMAX Compression Options:
            # 
            #  -min_power true
            #     This specifies that compressor inputs are to be gated for functional power
            #     saving. 
            #     It also reduces glitching during functional and capture operations
            #     Default for -min_power option is false. Recommend that you set this to
            #     true. 
            #
            #  -xtolerance: value is set to tool default. 
            #     Specify "high" to generate DFTMAX compression architecture that has 100% X-tolerance.
            #
            #  -minimum_compression: tool default is a target compression ratio of 10,
            #
            #  -location <compressor_decompressor_location>
            #      Specifies the instance name in which the compressor and decompressor 
            #      will be instantiated.
            #      The default location is the top level of the current design.
            # 
            # For details on these and other DFTMAX compression options, please refer to the
            # DFT Compiler, DFTMAX, and DFTMAX Ultra User Guide, Chapter 18, "Using DFTMAX Compression"
            # and Chapter 20, "Managing X Values in Scan Compression".
     
            set_scan_compression_configuration -xtolerance high -min_power true;

    } else {
        puts "RM-Info: DFT flow disabled (ENABLE_DFT=false)."
    }

    # Use the following to define the test-mode signal to be used for DFTMAX  
    # compression. Ensure that that test mode signals to be used for clockgating have 
    # been configured with set_dft_signal -usage clock_gating.

    # set_dft_signal -view spec -type TestMode -port scan_compression_enable


    #############################################################################
    # Shift Power Groups Configuration
    #############################################################################

    # Starting L-2016.03-SP2 release, DFTMAX Compression supports insertion of Shift Power Groups
    # to reduce power consumption during scan shift.
    # Please refer to the DFT Compiler, DFTMAX, and DFTMAX Ultra User Guide, Chapter 18,
    # "Reducing Power Consumption in Compressed Scan Designs", 
    # "Reducing Scan Shift Power Using Shift Power Groups" section.
    # 
    # To insert Shift Power Groups, do the following:
    # 
    # If you do not insert On-Chip Clocking (OCC), specify:
   
    # set_scan_compression_configuration
    # -shift_power_groups true
    # -shift_power_chain_length <l> | -shift_power_chain_ratio <r>
    # -shift_power_clock <clk>
    # 
    # Specify only one of -shift_power_chain_length or -shift_power_chain_ratio but not both.
    # 
    # Specify the signal to disable the shift power groups
      
    # set_dft_signal -view spec -type TestControl -port <p>
    # set_scan_compression_configuration -shift_power_disable <p>
      
    # Specify the scan-in and scan-out signals to use for the Shift Power Control chain
    # Note the name of the chain specified in the set_scan_path command. This name needs to be specified
    # in TetraMAX set_drc command (refer to TMAX-RM for details) 
    # 
    # set_scan_path shift_power_control_chain -class spc \
    # -scan_data_in SPC_IN \
    # -scan_data_out SPC_OUT \ 
    # -test_mode all
    # 
    # 
    # If you insert On-Chip Clocking (OCC), then specify:
    # 
    # set_scan_compression_configuration
    # -shift_power_groups true
    # -shift_power_chain_length <l> | -shift_power_chain_ratio <r>
    # 
    # Specify only one of -shift_power_chain_length or -shift_power_chain_ratio but not both.
    # Do not specify -shift_power_clock option. In OCC flows, the clock chain clock is automatically used.
     
    # Specify an external clock chain if you plan to use On-Chip Clocking together with Shift Power Control chain
    
    # set_scan_path OCC -class occ \
    # -scan_data_in  OCC_IN \
    # -scan_data_out  OCC_OUT \
    # -test_mode all



    #############################################################################
    # DFT Pipelined Scan Data Configuration
    #############################################################################

   # Use set_pipeline_scan_data_configuration to control how Pipelined Scan Data Registers
   # should be inserted

   # We recommend that you use the head_scan_flop true option to create head pipeline registers that 
   # hold their state during the capture cycle. 
   # You should also constrain ScanEnable to its inactive value during capture in ScanCompression modes


   # Note: if you select the head_scan_flop true option, you can share the scan clock with the head_pipeline_clock. 
   #  If you do not select head_scan_flop true option, then you must use a dedicated head pipeline clock.


    # Options:
    #  -head_scan_flop true
    #  -head_pipeline_clock  <name of clock for head pipeline registers>
    #  -tail_pipeline_clock  <name of clock for tail pipeline registers>
    #  -head_pipeline_stages <desired number of head pipeline stages>
    #  -tail_pipeline_stages <desired number of tail pipeline stages>

    # Example:

    # set_pipeline_scan_data_configuration -head_pipeline_clock <clock_name> \
    #   -tail_pipeline_clock <clock_name> \
    #   -head_scan_flop true \
    #   -head_pipeline_stages <x> \
    #   -tail_pipeline_stages <y>
    #############################################################################
    # DFT Additional Setup
    #############################################################################

    # Add any additional design-specific DFT constraints here

    #############################################################################
    # Defining Multiple Test modes
    #############################################################################
    
    # Use the define_test_mode command to define additional test modes that you wish to build.
    #
    # If you have enabled DFTMAX or DFTMAX Ultra Compression, the tool will build two test modes by 
    # default: ScanCompression_mode and Internal_scan. 
    #
    # If you wish to override the default test modes, you need to define the purpose of that test mode, 
    # then use the -base_mode and -test_mode options of set_scan_compression_configuration or 
    # set_streaming_compression_configuration command to define the correspondence between the two modes.
    #  
    # Design Compiler shell switches to that test mode after a define_test_mode command.
    #
    # To define DFT signals or scan configuration for a particular test mode, specify -test_mode option 
    # for each modes that you have defined.
    #  
    # At top level, use define_test_mode -target to specify the block level test mode that should be active in 
    # that mode. Please refer to the DFT Compiler, DFTMAX, and DFTMAX Ultra User Guide Chapter 18, 
    # "Using DFTMAX Compression", "DFTMAX Scan Compression and Multiple Test Modes" section.
    #
    # Block level Example with DFTMAX Compression:
    # Defining the test modes at block level
    # define_test_mode MY_internal_scan -usage scan 
    # define_test_mode MY_compression -usage scan_compression
    # 
    # Specifying the DFT signals for each mode using the -test_mode option:
    # set_dft_signal -port scan_input_port_1  -type ScanDataIn  -view spec -test_mode MY_internal_scan
    # set_dft_signal -port scan_input_port_1  -type ScanDataIn  -view spec -test_mode MY_compression
    # set_dft_signal -port scan_output_port_1 -type ScanDataOut -view spec -test_mode MY_internal_scan
    # set_dft_signal -port scan_output_port_1 -type ScanDataOut -view spec -test_mode MY_compression
    #
    # Specifying the scan configuration for each test mode:
    # set_scan_configuration -chain_count <scan mode chain count> -test_mode MY_internal_scan
    # set_scan_configuration -chain_count <compression mode chain count> -test_mode MY_compression
    #
    # Specify the correspondence between user-defined internal scan mode and user-defined compression mode
    # set_scan_compression_configuration -chain_count <compression mode chain count>  -base_mode MY_internal_scan -test_mode MY_compression

    # Top level example with DFTMAX Compression:
    # define_test_mode MY_top_internal_scan -usage scan -target [list core1:MY_internal_scan core2:MY_internal_scan top]
    # define_test_mode MY_top_compression -usage scan_compression -target [list core1:MY_compression core2:MY_compression top]
    #
    ###########################################################################
    # Defining DFT partitions
    ###########################################################################
    # Use the define_dft_partition command to define a set of clock domains, design references,
    # hierarchical cells, or sequential leaf cells that you can specify scan and compression configuration.
    # Then use the current_dft_partition command to set the current partition, then apply one or more
    # supported test configuration commands to configure scan for that partition.
    # Define any partition specific DFT signals in this section.
    #
    # Be sure to define any global scan and compression configuration and signals before define_dft_partition command.
    #
    # Please refer to the DFT Compiler, DFTMAX, and DFTMAX Ultra User Guide, Chapter 18,
    # "Using DFTMAX Compression", "Top-Down Flat Compressed Scan Flow with Partitions" section.
    #
    # define_dft_partition <partition_1>       \
    #   -include <list_of_cells_or_references> \
    #   -clocks  <list of_clocks>
    #
    # define_dft_partition <partition_2>       \
    #   -include <list_of_cells_or_references> \
    #   -clocks  <list of_clocks>
    #
    # current_dft_partition <partition_1>
    # <Scan and Compression configuration for partition_1>
    # If you have defined multiple test modes, you must use -test_mode option when defining DFT signals.
    # <DFT signals specific to partition_1>
    #
    # current_dft_partition <partition_2>
    # <Scan and Compression configuration for partition_2>
    # If you have defined multiple test modes, you must use -test_mode option when defining DFT signals.
    # <DFT signals specific to partition_2>
    
    #############################################################################
    # DFT Test Protocol Creation
    #############################################################################
# smkcow 
#    create_test_protocol

    #############################################################################
    # DFT Insertion
    #############################################################################

    # Use the -verbose version of dft_drc to assist in debugging if necessary
    
#    dft_drc                                
#    dft_drc -verbose                           > ${REPORTS_DIR}/${DCRM_DFT_DRC_CONFIGURED_VERBOSE_REPORT}
#    report_scan_configuration                  > ${REPORTS_DIR}/${DCRM_DFT_SCAN_CONFIGURATION_REPORT}
#    report_scan_compression_configuration      > ${REPORTS_DIR}/${DCRM_DFT_COMPRESSION_CONFIGURATION_REPORT}
#    report_dft_insertion_configuration         > ${REPORTS_DIR}/${DCRM_DFT_PREVIEW_CONFIGURATION_REPORT}
#
#    # Use the -show all version to preview_dft for more detailed report
#    preview_dft                                > ${REPORTS_DIR}/${DCRM_DFT_PREVIEW_DFT_SUMMARY_REPORT}
#    preview_dft -show all -test_points all     > ${REPORTS_DIR}/${DCRM_DFT_PREVIEW_DFT_ALL_REPORT}
#
#    insert_dft
#
    #################################################################################
    # Re-create Default Path Groups
    #
    # In case of ports being created during insert_dft they need to be added
    # to those path groups.
    # Separating these paths can help improve optimization.
    #################################################################################
    
    set current_scenario_saved [current_scenario]
    foreach scenario [all_active_scenarios] {
      current_scenario ${scenario}
      set ports_clock_root [filter_collection [get_attribute [get_clocks] sources] object_class==port]
      group_path -name REGOUT -to [all_outputs]
      group_path -name REGIN -from [remove_from_collection [all_inputs] ${ports_clock_root}]
      group_path -name FEEDTHROUGH -from [remove_from_collection [all_inputs] ${ports_clock_root}] -to [all_outputs]
    }
    current_scenario ${current_scenario_saved}


################################################################################
## RM+ Variable and Command Settings before incremental compile
################################################################################
if { $OPTIMIZATION_FLOW == "hplp" } {
  # Creating path groups to reduce TNS
 create_auto_path_groups -mode mapped
}
if { (${OPTIMIZATION_FLOW} == "hc") || (${OPTIMIZATION_FLOW} == "hplp") } {
    if {[shell_is_in_topographical_mode]} {

	# Enable congestion-driven  placement  in incremental compile to improve congestion    
	# while preserving quality of results
	set_app_var spg_congestion_placement_in_incremental_compile true
    }
}

if {[file exists [which ${LIBRARY_DONT_USE_PRE_INCR_COMPILE_LIST}]]} {
  puts "RM-Info: Sourcing script file [which ${LIBRARY_DONT_USE_PRE_INCR_COMPILE_LIST}]\n"
  source -echo -verbose $LIBRARY_DONT_USE_PRE_INCR_COMPILE_LIST
}

#########################################################################
# Incremental compile is required if netlist and/or constraints are 
# changed after first compile
# Example: DFT insertion, Placement aware multibit banking etc.       
# Incremental compile is also recommended for final QoR signoff as well
#########################################################################   

set_fix_hold [all_clocks]

compile_ultra -incremental -gate_clock -spg -no_autoungroup > ${REPORTS_DIR}/${DESIGN_NAME}_compile_ultra_incremental.rpt
#compile_ultra -incremental -spg -no_autoungroup


################################################################################
# Remove the path groups generated by create_path_groups command. 
# This does not remove user created path groups
################################################################################
if { $OPTIMIZATION_FLOW == "hplp" } {
    remove_auto_path_groups
}
#################################################################################
# High-effort area optimization
#
# optimize_netlist -area command, was introduced in I-2013.12 release to improve
# area of gate-level netlists. The command performs monotonic gate-to-gate 
# optimization on mapped designs, thus improving area without degrading timing or
# leakage. 
#################################################################################

optimize_netlist -area

}
#################################################################################
# Write Out Final Design and Reports
#
#        .ddc:   Recommended binary format used for subsequent Design Compiler sessions
#    Milkyway:   Recommended binary format for IC Compiler
#        .v  :   Verilog netlist for ASCII flow (Formality, PrimeTime, VCS)
#       .spef:   Topographical mode parasitics for PrimeTime
#        .sdf:   SDF backannotated topographical mode timing for PrimeTime
#        .sdc:   SDC constraints for ASCII flow
#
#################################################################################

# smkcow : below 2 lines will be executed after remove design 
#change_names -rules verilog -hierarchy

#write_icc2_files -force  -output ${RESULTS_DIR}/${DCRM_FINAL_DESIGN_ICC2}

    #############################################################################
    # DFT Write out Test Protocols and Reports
    #############################################################################

    # write_scan_def adds SCANDEF information to the design database in memory, so 
    # this command must be performed prior to writing out the design database 
    # containing binary SCANDEF.

    if {$ENABLE_DFT} {

            write_scan_def -output ${RESULTS_DIR}/${DCRM_DFT_FINAL_SCANDEF_OUTPUT_FILE}
            check_scan_def > ${REPORTS_DIR}/${DCRM_DFT_FINAL_CHECK_SCAN_DEF_REPORT}
            write_test_model -format ctl -output ${RESULTS_DIR}/${DCRM_DFT_FINAL_CTL_OUTPUT_FILE}

            report_dft_signal > ${REPORTS_DIR}/${DCRM_DFT_FINAL_DFT_SIGNALS_REPORT}

            # DFT outputs for standard scan mode

            write_test_protocol -test_mode Internal_scan -output ${RESULTS_DIR}/${DCRM_DFT_FINAL_PROTOCOL_OUTPUT_FILE}
            current_test_mode Internal_scan
            report_scan_path > ${REPORTS_DIR}/${DCRM_DFT_FINAL_SCAN_PATH_REPORT}
            dft_drc
            dft_drc -verbose > ${REPORTS_DIR}/${DCRM_DFT_DRC_FINAL_REPORT}

            # DFT outputs for compressed scan mode
            # If you have defined you own test modes, change the name of the test mode from 
            # "ScanCompression_mode" to the one that you have specified using define_test_mode command.

            write_test_protocol -test_mode ScanCompression_mode -output ${RESULTS_DIR}/${DCRM_DFT_FINAL_SCAN_COMPR_PROTOCOL_OUTPUT_FILE}
            current_test_mode ScanCompression_mode
            report_scan_path > ${REPORTS_DIR}/${DCRM_DFT_FINAL_SCAN_COMPR_SCAN_PATH_REPORT}
            dft_drc 
            dft_drc -verbose > ${REPORTS_DIR}/${DCRM_DFT_DRC_FINAL_SCAN_COMPR_REPORT}

    } else {
        puts "RM-Info: Skipping DFT test-model, scan, and protocol outputs."
    }

#################################################################################
# Write out Design Data
#################################################################################

if {[shell_is_in_topographical_mode]} {

  # Note: A secondary floorplan file ${DCRM_DCT_FINAL_FLOORPLAN_OUTPUT_FILE}.objects
  #       might also be written to capture physical-only objects in the design.
  #       This file should be read in before reading the main floorplan file.

  write_floorplan -all ${RESULTS_DIR}/${DCRM_DCT_FINAL_FLOORPLAN_OUTPUT_FILE}

  # If the DCRM_DCT_SPG_PLACEMENT_OUTPUT_FILE variable has been set in dc_setup_filenames.tcl
  # file then the standard cell physical guidance is being created to support SPG ASCII hand-off
  # to IC Compiler by the write_def command.
  # Invoking write_def commands requires a Design Compiler Graphical license or an IC Compiler
  # Design Planning license.

  if {[info exists DCRM_DCT_SPG_PLACEMENT_OUTPUT_FILE]} {
    write_def -components -output ${RESULTS_DIR}/${DCRM_DCT_SPG_PLACEMENT_OUTPUT_FILE}
  }

  # Do not write out net RC info into SDC
  set_app_var write_sdc_output_lumped_net_capacitance false
  set_app_var write_sdc_output_net_resistance false

  set all_active_scenario_saved [all_active_scenarios]
  set current_scenario_saved [current_scenario]
  set_active_scenarios -all
  foreach scenario [all_active_scenarios] {
    current_scenario ${scenario}
    # Constraints are already active for this scenario; do not read SDC again.

    # Write parasitics data from Design Compiler Topographical placement for static timing analysis
    write_parasitics -output ${RESULTS_DIR}/[dcrm_mcmm_filename ${DCRM_DCT_FINAL_SPEF_OUTPUT_FILE} ${scenario}]

    # Write SDF backannotation data from Design Compiler Topographical placement for static timing analysis
    write_sdf ${RESULTS_DIR}/[dcrm_mcmm_filename ${DCRM_DCT_FINAL_SDF_OUTPUT_FILE} ${scenario}]

    # W-2024.09 supports SDC through version 2.1.
    write_sdc -version 2.1 -nosplit ${RESULTS_DIR}/[dcrm_mcmm_filename ${DCRM_FINAL_SDC_OUTPUT_FILE} ${scenario}]
  }

  current_scenario ${current_scenario_saved}
  set_active_scenarios ${all_active_scenario_saved}

  change_names -rules verilog -hierarchy
  write_icc2_files -force  -output ${RESULTS_DIR}/${DCRM_FINAL_DESIGN_ICC2}
}


# If SAIF is used, write out SAIF name mapping file for PrimeTime-PX
# This is for PT-PX
saif_map -type ptpx -write_map ${RESULTS_DIR}/${DESIGN_NAME}.mapped.SAIF.namemap

#################################################################################
# Generate Final Reports
#################################################################################


#################################################################################
# Scenario-Specific Timing and Constraint Reports
#################################################################################

set SAVED_REPORT_SCENARIO [current_scenario]

foreach SCENARIO [all_active_scenarios] {
    current_scenario $SCENARIO

    redirect -tee \
        -file "${REPORTS_DIR}/${DESIGN_NAME}.${SCENARIO}.check_timing.rpt" {
            check_timing
        }

    redirect -tee \
        -file "${REPORTS_DIR}/${DESIGN_NAME}.${SCENARIO}.constraints.rpt" {
            report_constraint -all_violators
        }

    redirect -tee \
        -file "${REPORTS_DIR}/${DESIGN_NAME}.${SCENARIO}.timing_max.rpt" {
            report_timing \
                -delay_type max \
                -transition_time \
                -nets \
                -attributes \
                -max_paths 20 \
                -nosplit
        }

    redirect -tee \
        -file "${REPORTS_DIR}/${DESIGN_NAME}.${SCENARIO}.timing_min.rpt" {
            report_timing \
                -delay_type min \
                -transition_time \
                -nets \
                -attributes \
                -max_paths 20 \
                -nosplit
        }
}

current_scenario $SAVED_REPORT_SCENARIO


redirect -tee -file ${REPORTS_DIR}/${DESIGN_NAME}.report_constraint.reports {report_constraint -all_violators}
report_constraint -all_violators -verbose >> ${REPORTS_DIR}/${DESIGN_NAME}.report_constraint.reports

if { $OPTIMIZATION_FLOW  == "rtm_exp"} {
  set_host_options -max_cores 8
  update_timing

  parallel_execute [list \
  "report_qor > ${REPORTS_DIR}/${DCRM_FINAL_QOR_REPORT}" \
  "report_timing -transition_time -nets -attributes -nosplit > ${REPORTS_DIR}/${DCRM_FINAL_TIMING_REPORT}" \
  "report_area -nosplit > ${REPORTS_DIR}/${DCRM_FINAL_AREA_REPORT}" \
  "report_clock_gating -nosplit > ${REPORTS_DIR}/${DCRM_FINAL_CLOCK_GATING_REPORT}" \
  ]

} else {
report_qor > ${REPORTS_DIR}/${DCRM_FINAL_QOR_REPORT}

report_timing -scenarios [all_active_scenarios] -transition_time -nets -attributes -nosplit > ${REPORTS_DIR}/${DCRM_FINAL_TIMING_REPORT}
report_tlu_plus_files

if {[shell_is_in_topographical_mode]} {
  report_area -physical -nosplit -hierarchy > ${REPORTS_DIR}/${DCRM_FINAL_AREA_REPORT}
} else {
  report_area -nosplit > ${REPORTS_DIR}/${DCRM_FINAL_AREA_REPORT}
}
report_area -designware  > ${REPORTS_DIR}/${DCRM_FINAL_DESIGNWARE_AREA_REPORT}
report_resources -hierarchy > ${REPORTS_DIR}/${DCRM_FINAL_RESOURCES_REPORT}
report_clock_gating -nosplit > ${REPORTS_DIR}/${DCRM_FINAL_CLOCK_GATING_REPORT}
}

#################################################################################
# Post-map SAIF power for CUSTOM replay activity. Compile QoR is unchanged.
#################################################################################
proc ss28_to_watts {value unit} {
  switch -- [string tolower $unit] {
    pw { return [expr {double($value) * 1e-12}] }
    nw { return [expr {double($value) * 1e-9}] }
    uw { return [expr {double($value) * 1e-6}] }
    mw { return [expr {double($value) * 1e-3}] }
    w  { return [expr {double($value)}] }
    kw { return [expr {double($value) * 1e3}] }
    default { return {} }
  }
}
proc ss28_parse_power_field {text pattern} {
  set re [format {%s\s*=\s*([0-9.eE+-]+)\s*([pnumk]?W)} $pattern]
  if {[regexp -nocase -- $re $text -> num unit]} {
    return [ss28_to_watts $num $unit]
  }
  return {}
}
proc ss28_parse_mapped_power {text} {
  set internal [ss28_parse_power_field $text {Cell Internal Power}]
  set switching [ss28_parse_power_field $text {Net Switching Power}]
  set dynamic [ss28_parse_power_field $text {Total Dynamic Power}]
  set leakage [ss28_parse_power_field $text {Cell Leakage Power}]
  set total [ss28_parse_power_field $text {Total Power}]
  if {$internal eq {} || $switching eq {} || $dynamic eq {} || $leakage eq {} || $total eq {}} {
    if {[regexp -nocase {\nTotal[[:space:]]+([0-9.eE+-]+)[[:space:]]*([pnumk]?W)[[:space:]]+([0-9.eE+-]+)[[:space:]]*([pnumk]?W)[[:space:]]+([0-9.eE+-]+)[[:space:]]*([pnumk]?W)[[:space:]]+([0-9.eE+-]+)[[:space:]]*([pnumk]?W)} $text -> in_n in_u sw_n sw_u lk_n lk_u tot_n tot_u]} {
      set internal [ss28_to_watts $in_n $in_u]
      set switching [ss28_to_watts $sw_n $sw_u]
      set leakage [ss28_to_watts $lk_n $lk_u]
      set total [ss28_to_watts $tot_n $tot_u]
      if {$internal ne {} && $switching ne {}} {
        set dynamic [expr {$internal + $switching}]
      }
    }
  }
  return [list $internal $switching $dynamic $leakage $total]
}
proc ss28_saif_duration_ns {filename} {
  if {![file exists $filename]} { return {} }
  set fh [open $filename r]
  set timescale_ns 1.0
  set timescale_valid 1
  set duration {}
  while {[gets $fh line] >= 0} {
    if {[regexp {\(TIMESCALE\s+([0-9.]+)\s*([A-Za-z]+)\)} $line -> val unit]} {
      switch -- [string tolower $unit] {
        ps { set timescale_ns [expr {double($val) * 0.001}] }
        ns { set timescale_ns [expr {double($val)}] }
        us { set timescale_ns [expr {double($val) * 1e3}] }
        ms { set timescale_ns [expr {double($val) * 1e6}] }
        s  { set timescale_ns [expr {double($val) * 1e9}] }
        fs { set timescale_ns [expr {double($val) * 1e-6}] }
        default { set timescale_valid 0 }
      }
    }
    if {[regexp {\(DURATION\s+([0-9.eE+-]+)\)} $line -> dur]} {
      set duration $dur
    }
    if {$duration ne {} && [regexp {INSTANCE} $line]} { break }
  }
  close $fh
  if {$duration eq {} || !$timescale_valid} { return {} }
  return [expr {double($duration) * $timescale_ns}]
}
proc ss28_write_power_summary {csv values} {
  set fh [open $csv w]
  puts $fh "metric,value,unit"
  foreach {m v u} $values {
    # read_saif errors can contain commas and newlines.  Quote every field so a
    # failed power point still produces a valid CSV that Python can diagnose.
    set qm [string map [list \" \"\"] $m]
    set qv [string map [list \" \"\"] $v]
    set qu [string map [list \" \"\"] $u]
    puts $fh "\"${qm}\",\"${qv}\",\"${qu}\""
  }
  close $fh
}
proc ss28_require_clock_gating {} {
  global REPORTS_DIR
  catch {identify_clock_gating}
  set rpt [file join ${REPORTS_DIR} ss28.clock_gating.rpt]
  redirect $rpt { report_clock_gating -nosplit }
  set text {}
  if {[catch {set fh [open $rpt r]; set text [read $fh]; close $fh}]} {
    error "cannot read clock gating report ${rpt}"
  }
  set elements 0
  set gated 0
  set ungated 0
  regexp {Number of Clock gating elements\s+\|\s+([0-9]+)} $text -> elements
  regexp {Number of Gated registers\s+\|\s+([0-9]+)} $text -> gated
  regexp {Number of Ungated registers\s+\|\s+([0-9]+)} $text -> ungated
  set csv [file join ${REPORTS_DIR} clock_gating.summary.csv]
  set out [open $csv w]
  puts $out "metric,value,unit"
  set icg_cells [get_cells -quiet -hierarchical -filter {
    ref_name =~ *ICG* || ref_name =~ *PREICG* || ref_name =~ *CKLN*
  }]
  set icg_count [sizeof_collection $icg_cells]
  set icg_refs {}
  set icg_area 0.0
  foreach_in_collection cell $icg_cells {
    lappend icg_refs [get_attribute -quiet $cell ref_name]
    set a [get_attribute -quiet $cell area]
    if {$a ne {} && [string is double -strict $a]} {
      set icg_area [expr {$icg_area + $a}]
    }
  }
  set icg_refs [lsort -unique $icg_refs]
  set lfsr_ffs [get_cells -quiet -hierarchical -filter {
    is_sequential == true && (full_name =~ *VALUE_reg* || full_name =~ *d_delay_1_reg* || full_name =~ *d_delay_2_reg*)
  }]
  set lfsr_total [sizeof_collection $lfsr_ffs]
  set lfsr_direct_clk 0
  foreach_in_collection ff $lfsr_ffs {
    set ck [get_pins -quiet -of_objects $ff -filter {name == CK || name == CLK}]
    if {[sizeof_collection $ck] == 0} { continue }
    set nets [get_nets -quiet -of_objects $ck]
    foreach_in_collection net $nets {
      set net_name [get_attribute -quiet $net full_name]
      if {[string match *CLK $net_name] && ![string match *gated* $net_name] &&
          ![string match *ICG* $net_name] && ![string match *ck_gate* $net_name]} {
        incr lfsr_direct_clk
      }
    }
  }
  redirect [file join ${REPORTS_DIR} ss28.lfsr_clock.rpt] {
    echo "ICG_REF_NAMES ${icg_refs}"
    echo "ICG_CELL_COUNT ${icg_count}"
    echo "ICG_AREA ${icg_area}"
    echo "LFSR_OR_DELAY_FFS ${lfsr_total}"
    echo "LFSR_OR_DELAY_CK_NETS_NAMED_CLK ${lfsr_direct_clk}"
    report_clock_gating -gating_element -nosplit
  }
  puts $out "\"clock_gating_cells\",\"${elements}\",\"count\""
  puts $out "\"gated_registers\",\"${gated}\",\"count\""
  puts $out "\"ungated_registers\",\"${ungated}\",\"count\""
  puts $out "\"icg_library_cells\",\"${icg_count}\",\"count\""
  puts $out "\"icg_cell_area\",\"${icg_area}\",\"um2\""
  puts $out "\"icg_ref_names\",\"[join $icg_refs {;} ]\",\"name\""
  puts $out "\"lfsr_or_delay_ffs\",\"${lfsr_total}\",\"count\""
  puts $out "\"lfsr_or_delay_ck_named_clk\",\"${lfsr_direct_clk}\",\"count\""
  close $out
  puts "RM-Info: clock_gating cells=${elements} gated_regs=${gated} ungated_regs=${ungated} icg_refs=${icg_refs}"
  if {![string is integer -strict $elements] || $elements <= 0 ||
      ![string is integer -strict $gated] || $gated <= 0} {
    error "clock gating requested but no ICG cells were inserted (elements=${elements} gated=${gated})"
  }
  if {$icg_count <= 0} {
    error "clock gating requested but no library ICG cells were found in the mapped netlist"
  }
}
proc ss28_dump_saif_coverage {power_dir pulse} {
  set saif_rpt [file join $power_dir ${pulse}ns.saif.rpt]
  catch {redirect $saif_rpt {report_saif}}
  catch {redirect [file join $power_dir ${pulse}ns.saif_missing.rpt] {report_saif -missing}}
  catch {redirect [file join $power_dir ${pulse}ns.switching.rpt] {report_switching_activity}}
  set lfsr_cells [get_cells -quiet -hierarchical -filter {full_name =~ *VALUE_reg*}]
  set total [sizeof_collection $lfsr_cells]
  set annotated 0
  foreach_in_collection cell $lfsr_cells {
    set tog {}
    catch {set tog [get_attribute -quiet $cell toggle_rate]}
    if {$tog ne {} && $tog != 0 && $tog != 0.0} {
      incr annotated
    }
  }
  set csv [file join $power_dir ${pulse}ns.rng_coverage.csv]
  set out [open $csv w]
  puts $out "metric,value,unit"
  puts $out "\"lfsr_registers_total\",\"${total}\",\"count\""
  puts $out "\"lfsr_registers_toggle_nonzero\",\"${annotated}\",\"count\""
  puts $out "\"lfsr_registers_default_zero\",\"[expr {$total - $annotated}]\",\"count\""
  close $out
  puts "RM-Info: LFSR VALUE regs total=${total} toggle_nonzero=${annotated}"
  return [list $total $annotated]
}
proc ss28_try_read_saif {saif_file} {
  if {[info exists ::env(SAIF_INSTANCE)] && $::env(SAIF_INSTANCE) ne ""} {
    set instance $::env(SAIF_INSTANCE)
  } else {
    set instance {TB_REPLAY/dut}
  }
  if {[catch {read_saif -auto_map_names -input $saif_file -instance $instance -verbose} err]} {
    error "read_saif failed for instance ${instance}: $err"
  }
  puts "RM-Info: read_saif instance ${instance}"
  return $instance
}
proc ss28_set_clock_period {period_ns} {
  if {![string is double -strict $period_ns] || $period_ns <= 0} {
    error "clock period must be a positive number, got '${period_ns}'"
  }
  if {[catch {set scenario [current_scenario]} err] || $scenario eq {}} {
    error "cannot determine the current MCMM scenario: $err"
  }
  set clk_port [get_ports -quiet CLK]
  if {[sizeof_collection $clk_port] != 1} {
    error "expected exactly one CLK port in scenario ${scenario}"
  }

  # Clocks are scenario-specific in this MCMM flow.  This dc_shell release does
  # not support get_clocks -of_objects, so use the clock name established by all
  # four scenario constraint files.  Allow an empty scenario, but reject an
  # unexpected differently named clock rather than silently replacing it.
  set old_clocks [get_clocks -quiet MAIN_CLOCK]
  if {[sizeof_collection $old_clocks] > 1} {
    error "multiple MAIN_CLOCK objects found in scenario ${scenario}"
  }
  if {[sizeof_collection $old_clocks] == 0 &&
      [sizeof_collection [get_clocks -quiet *]] > 0} {
    error "MAIN_CLOCK missing while other clocks exist in scenario ${scenario}"
  }
  if {[sizeof_collection $old_clocks] == 1} {
    remove_clock $old_clocks
  }
  if {[catch {
    create_clock -name MAIN_CLOCK -period $period_ns $clk_port
  } err]} {
    error "create_clock failed in scenario ${scenario}: $err"
  }
  if {[catch {
    set clocks [get_clocks -quiet MAIN_CLOCK]
  } err]} {
    error "cannot query MAIN_CLOCK in scenario ${scenario}: $err"
  }
  if {[sizeof_collection $clocks] != 1} {
    error "expected exactly one MAIN_CLOCK after create_clock in scenario ${scenario}"
  }
  set actual_period [lindex [get_attribute $clocks period] 0]
  if {![string is double -strict $actual_period] ||
      abs(double($actual_period) - double($period_ns)) > 1.0e-9} {
    error "MAIN_CLOCK period verification failed in scenario ${scenario}: requested ${period_ns}, got ${actual_period}"
  }
  puts "RM-Info: MAIN_CLOCK period=${actual_period} ns scenario=${scenario}"
  return $actual_period
}
proc ss28_report_tb_energy {} {
  global REPORTS_DIR
  if {![info exists ::env(POWER_SAIF_LIST)] || $::env(POWER_SAIF_LIST) eq ""} {
    puts "RM-Info: POWER_SAIF_LIST empty; skipping SAIF power"
    return 0
  }
  if {![info exists ::env(DIGITAL_CLOCK_NS)] || $::env(DIGITAL_CLOCK_NS) <= 0} {
    error "DIGITAL_CLOCK_NS must be positive for SAIF power"
  }
  if {![info exists ::env(SYNTH_TARGET_PERIOD_NS)] || $::env(SYNTH_TARGET_PERIOD_NS) <= 0} {
    error "SYNTH_TARGET_PERIOD_NS must be positive to restore the synthesis clock"
  }
  set power_dir [file join ${REPORTS_DIR} power]
  file mkdir $power_dir
  if {[catch {set_app_var power_default_toggle_rate 0} err]} {
    error "cannot set power_default_toggle_rate to zero: $err"
  }
  if {[catch {set saved_scenario [current_scenario]} err] ||
      $saved_scenario eq {}} {
    error "cannot save the current MCMM scenario: $err"
  }
  set typical mode_norm.OC_rvt_tt_max_1p000v_25c.RC_MAX
  if {[catch {current_scenario $typical} err]} {
    error "cannot select required power scenario ${typical}: $err"
  }
  set power_scenario [current_scenario]
  set clock_ok 0
  set clock_error {}
  if {[catch {
    ss28_set_clock_period $::env(DIGITAL_CLOCK_NS)
  } clock_error]} {
    puts "RM-Power-Error: clock setup failed: $clock_error"
  } else {
    set clock_ok 1
  }
  set failures 0
  array set seen_pulses {}
  foreach item [split $::env(POWER_SAIF_LIST) ";"] {
    set item [string trim $item]
    if {$item eq ""} { continue }
    set split_at [string first "=" $item]
    if {$split_at < 1} {
      puts "RM-Warning: malformed POWER_SAIF_LIST entry: $item"
      incr failures
      continue
    }
    set pulse [string range $item 0 [expr {$split_at - 1}]]
    set saif_file [string range $item [expr {$split_at + 1}] end]
    if {![regexp {^[1-9][0-9]*$} $pulse] || $saif_file eq ""} {
      puts "RM-Warning: invalid pulse or SAIF path in POWER_SAIF_LIST: $item"
      incr failures
      continue
    }
    if {[info exists seen_pulses($pulse)]} {
      puts "RM-Warning: duplicate SAIF power point for ${pulse} ns"
      incr failures
      continue
    }
    set seen_pulses($pulse) 1
    set summary [file join $power_dir ${pulse}ns.summary.csv]
    set report [file join $power_dir ${pulse}ns.power.rpt]
    puts "RM-Info: SAIF power T_pulse=${pulse} ns"
    if {!$clock_ok} {
      ss28_write_power_summary $summary [list status FAIL none error "clock_setup_failed: $clock_error" none pulse_time_ns $pulse ns saif_file $saif_file path power_scenario $power_scenario scenario]
      incr failures
      continue
    }
    if {![file exists $saif_file]} {
      ss28_write_power_summary $summary [list status FAIL none error missing_saif none pulse_time_ns $pulse ns saif_file $saif_file path power_scenario $power_scenario scenario]
      incr failures
      continue
    }
    catch {reset_switching_activity}
    if {[catch {set instance [ss28_try_read_saif $saif_file]} err]} {
      ss28_write_power_summary $summary [list status FAIL none error $err none pulse_time_ns $pulse ns saif_file $saif_file path]
      incr failures
      continue
    }
    set lfsr_cov [list 0 0]
    catch {set lfsr_cov [ss28_dump_saif_coverage $power_dir $pulse]}
    set lfsr_total [lindex $lfsr_cov 0]
    set lfsr_annot [lindex $lfsr_cov 1]
    if {$lfsr_total > 0 && $lfsr_annot == 0} {
      ss28_write_power_summary $summary [list status FAIL none error lfsr_activity_unannotated none pulse_time_ns $pulse ns saif_file $saif_file path saif_instance $instance path lfsr_registers_total $lfsr_total count lfsr_registers_toggle_nonzero $lfsr_annot count]
      incr failures
      continue
    }
    if {[catch {redirect $report {report_power -nosplit}} err]} {
      ss28_write_power_summary $summary [list status FAIL none error $err none pulse_time_ns $pulse ns saif_file $saif_file path saif_instance $instance path]
      incr failures
      continue
    }
    set power_text {}
    catch {set fh [open $report r]; set power_text [read $fh]; close $fh}
    set mapped_power [ss28_parse_mapped_power $power_text]
    set internal [lindex $mapped_power 0]
    set switching [lindex $mapped_power 1]
    set dynamic [lindex $mapped_power 2]
    set leakage [lindex $mapped_power 3]
    set total [lindex $mapped_power 4]
    if {$total eq {} && $dynamic ne {} && $leakage ne {}} {
      set total [expr {$dynamic + $leakage}]
    }
    set annotated {}
    regexp -nocase {([0-9.]+)\s*%[^\n]*annotat} $power_text -> annotated
    set duration_ns [ss28_saif_duration_ns $saif_file]
    set status PASS
    set error_text {}
    if {$total eq {} || $total <= 0 || $dynamic eq {} || $leakage eq {}} {
      set status FAIL
      set error_text missing_power_fields
    } elseif {$duration_ns eq {} || $duration_ns <= 0} {
      set status FAIL
      set error_text missing_saif_duration
    }
    if {$status ne "PASS"} {
      incr failures
    }
    ss28_write_power_summary $summary [list status $status none error $error_text none pulse_time_ns $pulse ns saif_file $saif_file path saif_instance $instance path power_scenario $power_scenario scenario clock_period_ns $::env(DIGITAL_CLOCK_NS) ns saif_duration_ns $duration_ns ns cell_internal_power_w $internal W net_switching_power_w $switching W dynamic_power_w $dynamic W leakage_power_w $leakage W total_power_w $total W annotated_percent $annotated percent]
  }
  if {[catch {
    ss28_set_clock_period $::env(SYNTH_TARGET_PERIOD_NS)
  } restore_error]} {
    puts "RM-Power-Error: cannot restore synthesis clock: $restore_error"
    incr failures
  }
  if {[catch {current_scenario $saved_scenario} restore_scenario_error]} {
    puts "RM-Power-Error: cannot restore scenario ${saved_scenario}: $restore_scenario_error"
    incr failures
  }
  return $failures
}
if {[catch {ss28_require_clock_gating} ss28_cg_error]} {
  puts "RM-Error: ${ss28_cg_error}"
}
puts "RM-Info: SS28 post-map power begin"
set ss28_power_failures 0
if {[catch {set ss28_power_failures [ss28_report_tb_energy]} ss28_power_error]} {
  puts "RM-Power-Error: SAIF power analysis aborted: ${ss28_power_error}"
  set ss28_power_failures -1
} elseif {$ss28_power_failures > 0} {
  puts "RM-Power-Error: ${ss28_power_failures} SAIF power point(s) failed"
}
puts "RM-Info: SS28 post-map power end"
# Create a QoR snapshot of timing, physical, constraints, clock, power data, and routing on 
# active scenarios and stores it in the location  specified  by  the icc_snapshot_storage_location 
# variable. 

if {[shell_is_in_topographical_mode]} {
  set icc_snapshot_storage_location ${REPORTS_DIR}/${DCRM_DCT_FINAL_QOR_SNAPSHOT_FOLDER}
  create_qor_snapshot -name ${DCRM_DCT_FINAL_QOR_SNAPSHOT_REPORT} > ${REPORTS_DIR}/${DCRM_DCT_FINAL_QOR_SNAPSHOT_REPORT}
}


# Uncomment the next line to report all the multibit registers and the banking ratio in the design
# redirect ${REPORTS_DIR}/${DCRM_MULTIBIT_BANKING_REPORT} {report_multibit_banking -nosplit }


report_clock_gating -nosplit > ${REPORTS_DIR}/${DCRM_FINAL_CLOCK_GATING_REPORT}

# Uncomment the next line if you include the -self_gating to the compile_ultra command
# to report the XOR Self Gating information.
# report_self_gating  -nosplit > ${REPORTS_DIR}/${DCRM_FINAL_SELF_GATING_REPORT}

# Uncomment the next line to reports the number, area, and  percentage  of cells 
# for each threshold voltage group in the design.
# report_threshold_voltage_group -nosplit > ${REPORTS_DIR}/${DCRM_THRESHOLD_VOLTAGE_GROUP_REPORT}

if {[shell_is_in_topographical_mode]} {
  # report_congestion (topographical mode only) uses zroute for estimating and reporting 
  # routing related congestion which improves the congestion correlation with IC Compiler.
  # Design Compiler Topographical supports create_route_guide command to be consistent with IC
  # Compiler after topographical mode synthesis.
  # Those commands require a license for Design Compiler Graphical.

  report_congestion > ${REPORTS_DIR}/${DCRM_DCT_FINAL_CONGESTION_REPORT}

  # Use the following to generate and write out a congestion map from batch mode
  # This requires a GUI session to be temporarily opened and closed so a valid DISPLAY
  # must be set in your UNIX environment.

  if {[info exists env(DISPLAY)]} {
    gui_start

    # Create a layout window
    set MyLayout [gui_create_window -type LayoutWindow]

    # Build congestion map in case report_congestion was not previously run
    report_congestion -build_map

    # Display congestion map in layout window
    gui_show_map -map "Global Route Congestion" -show true

    # Zoom full to display complete floorplan
    gui_zoom -window [gui_get_current_window -view] -full

    # Write the congestion map out to an image file
    # You can specify the output image type with -format png | xpm | jpg | bmp

    # The following saves only the congestion map without the legends
    gui_write_window_image -format png -file ${REPORTS_DIR}/${DCRM_DCT_FINAL_CONGESTION_MAP_OUTPUT_FILE}

    # The following saves the entire congestion map layout window with the legends
    gui_write_window_image -window ${MyLayout} -format png -file ${REPORTS_DIR}/${DCRM_DCT_FINAL_CONGESTION_MAP_WINDOW_OUTPUT_FILE}

    gui_stop
  } else {
    puts "Information: The DISPLAY environment variable is not set. Congestion map generation has been skipped."
  }
}

#################################################################################
# Write out Design after remove_design
#################################################################################

## smkcow 
# remove_design -hierarchy (MODULE_NAME)
#remove_design -hierarchy {"/home/smkcow/QnA/digital/example_smkcow_DC_ICC2_simple_scenario/memory_wrapper/SYN_topo/results/memory_wrapper.mapped.ddc:memory_wrapper"}
#remove_design -hierarchy {"/home/smkcow/QnA/digital/example_smkcow_DC_ICC2_simple_scenario/fifo/SYN_topo/results/fifo.mapped.ddc:fifo"}

#remove_design -hierarchy memory_wrapper
#remove_design -hierarchy fifo

#remove_design -hierarchy VECTOR
#remove_design -hierarchy MEMSET
#remove_design -hierarchy CORE

change_names -rules verilog -hierarchy
set verilogout_no_tri true
##########################################################################

write -format verilog -hierarchy -output ${RESULTS_DIR}/${DCRM_FINAL_VERILOG_OUTPUT_FILE}

write -format ddc     -hierarchy -output ${RESULTS_DIR}/${DCRM_FINAL_DDC_OUTPUT_FILE}


# Write and close SVF file and make it available for immediate use
set_svf -off
# smkcow : Now, you should add fifo, memory_wrapper ddc files on FM stage



#################################################################################
# Write out Milkyway Design for Top-Down Flow
#
# This should be the last step in the script
#################################################################################

if {[shell_is_in_topographical_mode]} {
  # write_milkyway uses mw_design_library variable from dc_setup.tcl
#smkcow : below is disable it is not for ICC2
  #write_milkyway -overwrite -output ${DCRM_FINAL_MW_CEL_NAME}
}

exit

# Below is for icc2 execute 
#set_icc2_options -ref_libs " \
$PDK/io/gpio/BE/NDM/io_synopsys/io_gppr_cmos28lpp_t18.ndm \
$PDK/io/gpio/BE/NDM/io_synopsys/io_synopsys_frame.ndm \
$PDK/sc/BE/NDM/base_rvt_c130_frame.ndm \
$PDK/sc/BE/NDM/base_rvt_c130_physical_only.ndm \
$PDK/sc/BE/NDM/sc9_cmos28lpp_base_rvt.ndm \
$PDK/memory/BE/USERLIB.ndm \
$PDK/memory/BE/cmos28lpp_ra1w_hd_1024x17m8_frame.ndm \
"   -technology $LIB_DIR/sc9_lnr28lpp_7U1x_2T8x_LB.icc2.tf -work_dir my_work_dir -icc2_executable /tools/synopsys/ICC2/N-2017.09-SP5/bin/icc2_shell

#start_icc2
