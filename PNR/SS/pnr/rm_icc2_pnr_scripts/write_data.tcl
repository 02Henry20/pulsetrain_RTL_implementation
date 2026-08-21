##########################################################################################
# Tool: IC Compiler II
# Script: write_data.tcl
# Version: N-2017.09-SP2 (February 20, 2018)
# Copyright (C) 2014-2018 Synopsys, Inc. All rights reserved.
##########################################################################################

source -e ./rm_setup/icc2_pnr_setup.tcl 

open_lib $DESIGN_LIBRARY
if {$USE_RM_BLOCK_NAME_AS_LABEL} {
	copy_block -from ${DESIGN_NAME}/${WRITE_DATA_FROM_BLOCK_NAME} -to ${DESIGN_NAME}/${WRITE_DATA_BLOCK_NAME}
	current_block ${DESIGN_NAME}/${WRITE_DATA_BLOCK_NAME}
} else {
	copy_block -from ${WRITE_DATA_FROM_BLOCK_NAME} -to ${WRITE_DATA_BLOCK_NAME}
	current_block ${WRITE_DATA_BLOCK_NAME}
}
link_block

create_net -power VDD
create_net -ground VSS
create_net -power DVDD
create_net -ground DVSS
create_net RTO
create_net SNS

connect_pg_net -net VDD [get_pins */VDD]
connect_pg_net -net VSS [get_pins */VSS]

connect_pg_net -net DVDD [get_pins */DVDD]
connect_pg_net -net DVSS [get_pins */DVSS]

connect_net -net RTO [get_pins */RTO]
connect_net -net SNS [get_pins */SNS]

########################################################################
## change_names
########################################################################
## Purpose : change the names of ports, cells, and nets in a design, in order to make the output netlist, 
#  DEF, SPEF, ... etc conform to specified name rules
#  Note : 
#  - If the current block is a sub cell of another block, make sure no port names are changed during change_names;
#    if there is, you either modify your naming rule to avoid the name change, re-setup the connection between
#    the renamed port and the net at the parent level, or if the blocks are from commit_block then you can run 
#    the same change_names command before commit_block at the parent level.
#  - To preview whether there is any potential port name changes, check the report_names log first
redirect -tee -file ${REPORTS_DIR}/${WRITE_DATA_BLOCK_NAME}.report_names.log {report_names -rules verilog}

change_names -rules verilog -hierarchy

save_block

####################################################################################################
## For current block, write out ASCII Data (verilog, UPF, DEF, scripts/SDC, parasitics, and GDS)  
####################################################################################################
## Set to write out a UPF file compatible for other Synopsys tools
set_app_option -name mv.upf.write_crosstool_wrappers -value true

## write_verilog (no pg, and no physical only cells)
#write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations pg_objects end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells} -hierarchy all ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}.v
write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations pg_objects end_cap_cells well_tap_cells filler_cells physical_only_cells cover_cells} -hierarchy all ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}.v

## write_verilog for comparison with a DC netlist (no pg, no physical only cells, and no diodes)
write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations pg_objects end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells diode_cells} -hierarchy all ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}.dc.v

## write_verilog for PrimeTime (no pg, no physical only cells but with diodes and DCAP for leakage power analysis)
set write_verilog_pt_cmd "write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations pg_objects end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells flip_chip_pad_cells} -hierarchy all ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}.pt.v"
if {$CHIP_FINISH_METAL_FILLER_LIB_CELL_LIST != ""} {
	lappend write_verilog_pt_cmd -force_reference $CHIP_FINISH_METAL_FILLER_LIB_CELL_LIST
}
puts "RM-info: $write_verilog_pt_cmd"
eval $write_verilog_pt_cmd

## write_verilog for LVS (with pg, and with physical only cells)
write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations end_cap_cells well_tap_cells empty_modules} -hierarchy all ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}.lvs.v

## write_verilog for Formality (with pg, no physical only cells, and no supply statements)
write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells supply_statements} -hierarchy all ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}.fm.v

## write_verilog for VC LP (with pg, no physical_only cells, no diodes, and no supply statements)
write_verilog -compress gzip -exclude {scalar_wire_declarations leaf_module_declarations end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells diode_cells supply_statements} -hierarchy all ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}.vc_lp.v

## write_upf
save_upf ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}.upf

## write_def : Enable the following for LEF/DEF based ICC-II to StarRC flow if LEF is from ICC II,
#  since write_lef in ICC-II doesn't currently support WRONGDIRECTION syntax.
#  This is not needed if you are using LEF files which contain the WRONGDIRECTION syntax already.
#	set_app_options -name file.def.wrong_way_wiring_to_special_net -value true
write_def -compress gzip -version 5.8 ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}.def

## write_script
#  writes multiple files to the specified directory. 
#  It writes mode_{mode_name}.tcl for mode specific info, corner_{corner_name}.tcl for corner specific info, 
#  design.tcl for non-mode or corner specific info, cts.tcl for cts options and top.tcl that sources all scripts. 
write_script -compress gzip -output ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}_wscript
#  -format pt generates PT compatible outputs 
write_script -compress gzip -format pt -output ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}_wscript_for_pt

#############################################################
#smkcow :: write_sdc 
# current_scenario is .....MAX so don't define current_scenario at the first time
#############################################################
#current_scenario ..... 
current_scenario mode_norm.OC_rvt_ff_min_1p100v_m40c.RC_MIN
write_sdc -output ${OUTPUTS_DIR}/${DESIGN_NAME}_mode_norm.OC_rvt_ff_min_1p100v_m40c.RC_MIN.sdc
current_scenario mode_norm.OC_rvt_tt_max_1p000v_25c.RC_MAX
write_sdc -output ${OUTPUTS_DIR}/${DESIGN_NAME}_mode_norm.OC_rvt_tt_max_1p000v_25c.RC_MAX.sdc

#########
#smkcow : make frame, abstract 
# create_abstract just do it 
#create_abstract -target_use implementation -timing_level compact
set_scenario_status * -active true -all
create_abstract -estimate_timing -timing_level compact -target_use implementation
create_frame -block_all true
save_block
save_lib
###########
save_lib

## write_parasitics
update_timing
write_parasitics -compress -output ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}

## write_gds
set write_gds_cmd "write_gds -compress -hierarchy all -long_names ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}.gds"


if {[file exists $WRITE_GDS_LAYER_MAP_FILE]} {lappend write_gds_cmd -layer_map $WRITE_GDS_LAYER_MAP_FILE}

## If there's any design mismatches found, write_gds will not write out GDS, since GDS will be used for tape-out.
#  If you still want to write out GDS despite of mismatches, append the -allow_design_mismatch option to the 
#  write_gds command.

puts "RM-info: $write_gds_cmd"
eval $write_gds_cmd

## write_oasis
set write_oasis_cmd "write_oasis -compress 6 -hierarchy all ${OUTPUTS_DIR}/${WRITE_DATA_BLOCK_NAME}.oasis"


if {[file exists $WRITE_OASIS_LAYER_MAP_FILE]} {lappend write_oasis_cmd -layer_map $WRITE_OASIS_LAYER_MAP_FILE}

## If there's any design mismatches found, write_oasis will not write out OASIS, since OASIS will be used for tape-out.
#  If you still want to write out OASIS despite of mismatches, append the -allow_design_mismatch option to the 
#  write_oasis command.

puts "RM-info: $write_oasis_cmd"
eval $write_oasis_cmd


echo [date] > write_data

exit 


