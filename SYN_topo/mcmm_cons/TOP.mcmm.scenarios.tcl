#################################################################################
# Design Compiler MCMM Scenarios Setup File Reference
# Script: dc.mcmm.scenarios.tcl
# Version: M-2016.12-SP4 (July 17, 2017)
# Copyright (C) 2011-2017 Synopsys, Inc. All rights reserved.
#################################################################################

#################################################################################
# This is an example of the MCMM scenarios setup file for Design Compiler.
# Please note that this file will not work as given and must be edited for your
# design.
#
# Create this file for each design in your MCMM flow and configure the filename
# with the value of the ${DCRM_MCMM_SCENARIOS_SETUP_FILE} in
# rm_setup/dc_setup_filenames.tcl
#
# It is recommended to use a minimum set of worst case setup scenarios
# and a worst case leakage scenario in Design Compiler.
# Further refinement to optimize across all possible scenarios is recommended
# to be done in IC Compiler.
#################################################################################

#################################################################################
# Additional Notes
#################################################################################
#
# In MCMM, good leakage and dynamic power optimization results can be obtained by
# using a worst case leakage scenario along with scenario-independent clock gating
# (compile_ultra -gate_clock).
#
# A recommended scenario naming convention (used by Lynx) is the following:
#
# <MM_TYPE>.<OC_TYPE>.<RC_TYPE>
#
# MM_TYPE - Label that identifies the operating mode or set of timing constraints
#           Example values: mode_norm, mode_slow, mode_test
#
# OC_TYPE - Label that identifies the library operating conditions or PVT corner
#           Example values: OC_WC, OC_BC, OC_TYP, OC_LEAK, OC_TEMPINV
#
# RC_TYPE - Label that identifies an extraction corner (TLUPlus files)
#           Example values: RC_MAX_1, RC_MIN_1, RC_TYP
#################################################################################
# Define additional setup scenarios here as needed, using the same format.
#################################################################################
# Worst Case Setup Scenario
#################################################################################

set scenario mode_norm.OC_rvt_tt_max_1p000v_25c.RC_MAX

create_scenario ${scenario}

# Read in scenario-specific constraints file

puts "RM-Info: Sourcing script file [which [dcrm_mcmm_filename ${DCRM_CONSTRAINTS_INPUT_FILE} ${scenario}]]\n"
source [dcrm_mcmm_filename ${DCRM_CONSTRAINTS_INPUT_FILE} ${scenario}]

#puts "RM-Info: Reading SDC file [which [dcrm_mcmm_filename ${DCRM_SDC_INPUT_FILE} ${scenario}]]\n"
##read_sdc [dcrm_mcmm_filename ${DCRM_SDC_INPUT_FILE} ${scenario}]

#set_operating_conditions -max_library <OC_WC_LIB_NAME> -max <OC_WC>
set_operating_conditions tt_1p000v_25c -library sc9_cmos28lpp_base_rvt_tt_nominal_max_1p000v_25c -analysis_type on_chip_variation

write_sdc -nosplit ${RESULTS_DIR}/[dcrm_mcmm_filename ${DCRM_FINAL_SDC_OUTPUT_FILE} ${scenario}]

#puts "RM-Info: Reading SDC file [which [dcrm_mcmm_filename ${DCRM_SDC_INPUT_FILE} ${scenario}]]\n"
#read_sdc [dcrm_mcmm_filename ${DCRM_SDC_INPUT_FILE} ${scenario}]

#set_tlu_plus_files -max_tluplus <OC_WC_TLUPLUS_MAX_FILE> \
                   -tech2itf_map ${MAP_FILE}
set_tlu_plus_files -max_tluplus $TLUPLUS_MAX_FILE \
		   -min_tluplus $TLUPLUS_MIN_FILE \
                   -tech2itf_map ${MAP_FILE}

check_tlu_plus_files

# Include scenario specific SAIF file, if possible, for power analysis.
# Otherwise, the default toggle rate of 0.1 will be used for propagating
# switching activity.

# read_saif -auto_map_names -input ${DESIGN_NAME}.${scenario}.saif -instance < DESIGN_INSTANCE > -verbose
   # read_saif -auto_map_names -input ../SIM/FUNCTION/${DESIGN_NAME}.saif -instance TB_${DESIGN_NAME}/U_${DESIGN_NAME} -verbose

# Set options for worst case setup scenario
set_scenario_options -setup true -hold false -leakage_power true  -dynamic_power true

report_scenario_options

### Define additional setup scenarios here as needed, using the same format.
###################################################################################
### Worst Case Setup Scenario
###################################################################################
#
set scenario mode_norm.OC_rvt_ff_min_1p100v_m40c.RC_MIN

create_scenario ${scenario}

# Read in scenario-specific constraints file

puts "RM-Info: Sourcing script file [which [dcrm_mcmm_filename ${DCRM_CONSTRAINTS_INPUT_FILE} ${scenario}]]\n"
source [dcrm_mcmm_filename ${DCRM_CONSTRAINTS_INPUT_FILE} ${scenario}]

#puts "RM-Info: Reading SDC file [which [dcrm_mcmm_filename ${DCRM_SDC_INPUT_FILE} ${scenario}]]\n"
##read_sdc [dcrm_mcmm_filename ${DCRM_SDC_INPUT_FILE} ${scenario}]

#set_operating_conditions -max_library <OC_WC_LIB_NAME> -max <OC_WC>
#set_operating_conditions ff_1p32v_m40c -library scmetro_cmos10lp_rvt_ff_1p32v_m40c_sadhm -analysis_type on_chip_variation
set_operating_conditions ff_1p100v_m40c -library sc9_cmos28lpp_base_rvt_ff_nominal_min_1p100v_m40c_sadhm -analysis_type on_chip_variation


write_sdc -nosplit ${RESULTS_DIR}/[dcrm_mcmm_filename ${DCRM_FINAL_SDC_OUTPUT_FILE} ${scenario}]

#puts "RM-Info: Reading SDC file [which [dcrm_mcmm_filename ${DCRM_SDC_INPUT_FILE} ${scenario}]]\n"
#read_sdc [dcrm_mcmm_filename ${DCRM_SDC_INPUT_FILE} ${scenario}]

#set_tlu_plus_files -max_tluplus <OC_WC_TLUPLUS_MAX_FILE> \
                   -tech2itf_map ${MAP_FILE}
set_tlu_plus_files -max_tluplus $TLUPLUS_MAX_FILE \
		   -min_tluplus $TLUPLUS_MIN_FILE \
                   -tech2itf_map ${MAP_FILE}

check_tlu_plus_files

# Include scenario specific SAIF file, if possible, for power analysis.
# Otherwise, the default toggle rate of 0.1 will be used for propagating
# switching activity.

# read_saif -auto_map_names -input ${DESIGN_NAME}.${scenario}.saif -instance < DESIGN_INSTANCE > -verbose
   # read_saif -auto_map_names -input ../SIM/FUNCTION/${DESIGN_NAME}.saif -instance TB_${DESIGN_NAME}/U_${DESIGN_NAME} -verbose

# Set options for worst case setup scenario
set_scenario_options -setup false -hold true -leakage_power true  -dynamic_power true

report_scenario_options

