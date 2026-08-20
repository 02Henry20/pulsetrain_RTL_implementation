#################################################################################
# PrimeTime Reference Methodology Script
# Script: pt.tcl
# Version: M-2017.06-SP2 (Nov 9, 2017)
# Copyright (C) 2008-2017 Synopsys All rights reserved.
################################################################################

set_app_var auto_wire_load_selection false
set_app_var rc_degrade_min_slew_when_rd_less_than_rnet true
set_app_var si_analysis_logical_correlation_mode false
set_app_var timing_enable_library_max_cap_lookup_table false
set_app_var timing_enable_through_paths true
set_app_var timing_ocvm_enable_distance_analysis false 
set_app_var timing_propagate_through_non_latch_d_pin_arcs true
set_app_var timing_reduce_parallel_cell_arcs true
set_app_var si_enable_multi_valued_coupling_capacitance false
set_app_var timing_save_pin_arrival_and_slack false


# Please do not modify the sdir variable.
# Doing so may cause script to fail.
set sdir "." 



##################################################################
#    Source common and pt_setup.tcl File                         #
##################################################################

source $sdir/rm_setup/common_setup.tcl
source $sdir/rm_setup/pt_setup.tcl
source $sdir/ECO_FLOW/eco_flow.tcl


# make REPORTS_DIR
file mkdir $REPORTS_DIR

# make RESULTS_DIR
file mkdir $RESULTS_DIR 



##################################################################
#    Search Path, Library and Operating Condition Section        #
##################################################################

# Under normal circumstances, when executing a script with source, Tcl
# errors (syntax and semantic) cause the execution of the script to terminate.
# Uncomment the following line to set sh_continue_on_error to true to allow 
# processing to continue when errors occur.
#set sh_continue_on_error true 


  

set report_default_significant_digits 3 ;
set sh_source_uses_search_path true ;
set search_path ". $search_path" ;

##################################################################
#    Get ECO Data from ICC and STAR_RC                           #
##################################################################
# Launch ICC and STAR_RC to get def and parasitic files for PT.
#get_eco_data -wait

##################################################################
#    Netlist Reading Section                                     #
##################################################################
set link_path "* $link_path"

#read_verilog write_data.v.gz

#current_design $DESIGN_NAME 
restore_session ${DESIGN_NAME}_ss_timing
#link

#smkcow 
#pt_check
source pt_checker
#pt_checker -html_gen_exec ./html_gen -pt_duc_rules PT_DUC_Rules

##################################################################
#    Back Annotation Section                                     #
##################################################################
#if { [info exists PARASITIC_PATHS] && [info exists PARASITIC_FILES] } {
#foreach para_path $PARASITIC_PATHS para_file $PARASITIC_FILES {
#   if {[string compare $para_path $DESIGN_NAME] == 0} {
#      read_parasitics $para_file 
#   } else {
#      read_parasitics -path $para_path $para_file 
#   }
#}
#}
#read_parasitics -format SPEF -verbose /home/smkcow/QnA/digital/example_smkcow_DC_ICC2/fifo/StarRC/max/results/fifo_OC_rvt_ss_1p08v_125c.RC_MAX.spef
#
#report_annotated_parasitics -check
#
#
#
#
#
###################################################################
##    Reading Constraints Section                                 #
###################################################################
#if  {[info exists CONSTRAINT_FILES]} {
#        foreach constraint_file $CONSTRAINT_FILES {
#                if {[file extension $constraint_file] eq ".sdc"} {
#                        read_sdc -echo $constraint_file
#                } else {
#                        source -echo $constraint_file
#                }
#        }
#}



# smkcow
# Below line makes IO delay latency 0 because Originally, IO latency was ideal
#set_propagated_clock [all_clocks]


##################################################################
#    Setting Derate and CRPR Section                             #
##################################################################



set timing_remove_clock_reconvergence_pessimism true 

##################################################################
#    POWER ANALYSIS                                              #
##################################################################
set power_enable_analysis true


##################################################################
#    load_upf                                                    #
##################################################################

#load_upf

##################################################################
#    read_saif                                                   #
##################################################################

#read_vcd

#read_saif rtl.saif -rtl_direct -strip_path tb/top_inst
# rtl_direct is for rtl saif
read_saif  ../../../SIM/POST/MAX/TOP_PREV.saif -strip_path TB_TOP_PREV/U_TOP_PREV



##TAG COMMENt: set eco_report_unfixed_reason_max_endpoints for ECO timing(M-2017.06-SP2)
##################################################################
#    Fix ECO Variable Setup                                      #
##################################################################
set timing_save_pin_arrival_and_slack true
set eco_report_unfixed_reason_max_endpoints 10



##################################################################
#    Update_timing and check_timing Section                      #
##################################################################

update_power
update_timing -full
check_timing -verbose > $REPORTS_DIR/power/00_check_timing.report


##################################################################
#    Save_Session Section                                        #
##################################################################
save_session ${DESIGN_NAME}_ss_power

##################################################################
#   Writing an Reduced Resource ECO design                       #
##################################################################
# PrimeTime has the capability to write out an ECO design which 
# is a smaller version of the orginal design ECO can be performed
# with fewer compute resources.
#
# Writes an ECO design  that  preserves  the  specified  violation
# types  compared to those in the original design. You can specify
#  one or more of the following violation types:
#              o setup - Preserves setup timing results.
#              o hold - Preserves hold timing results.
#              o max_transistion - Preserves max_transition results.
#              o max_capacitance - Preserves max_capacitance results.
#              o max_fanout - Preserves max_fanout results.
#              o noise - Preserves noise results.
#              o timing - Preserves setup and hold timing results.
#              o drc  -  Preserves  max_transition,  max_capacitance,  
#                and max fanout results.
# There is also capability to write out specific endpoints with
# the -endpoints options.
#
# In DMSA analyis the RRECO design is written out relative to all
# scenarios enabled for analysis.
# 
# To create a RRECO design the user should perform the following 
# command and include violations types which the user is interested
# in fixing, for example for setup and hold.
# 
# write_eco_design  -type {setup hold} my_RRECO_design
#
# Once the RRECO design is created, the user then would invoke 
# PrimeTIme ECO in a seperate session and access the appropriate
# resourses and then read in the RRECO to perform the ECO
# 
# set_host_options ....
# start_hosts
# read_eco_design my_RRECO_design
# fix_eco...
#
# For more details please see man pages for write_eco_design
# and read_eco design.

##################################################################
#    Report_timing Section                                       #
##################################################################
report_global_timing > $REPORTS_DIR/power/01_report_global_timing
report_clock -skew -attribute > $REPORTS_DIR/power/02_report_clock 
report_analysis_coverage > $REPORTS_DIR/power/03_report_analysis_coverage
report_timing -slack_lesser_than 0.0 -delay min_max -nosplit -input -net  > $REPORTS_DIR/power/04_report_timing


# generates average cycle waveforms
# this is available for newer version
#create_power_waveforms

# reports average power results
report_power > $REPORTS_DIR/power/05_report_power

report_annotated_power > $REPORTS_DIR/power/06_TOP_PREV.report.annotated_power

##################################################################
#    Fix ECO Comments                                            #
##################################################################
# You can use -current_library option of fix_eco_drc and fix_eco_timing to use
# library cells only from the current library that the cell belongs to when sizing
#
# You can control the allowable area increase of the cell during sizing by setting the
# eco_alternative_area_ratio_threshold variable
#
# You can restrict sizing within a group of cells by setting the
# eco_alternative_cell_attribute_restrictions variable
#
# Refer to man page for more details




##################################################################
#    Fix ECO Timing Section                                      #
##################################################################
# Path Based Analysis is supported for setup and hold fixing
#
# You can use -setup_margin and -hold_margin to add margins during 
# setup and hold fixing
# 
# DRC can be ignored while fixing timing violations with -ignore_drc

# Refer to man page for more details
#
# Path specific and PBA based ECO can enabled via -path_selection_options
# See fix_eco_timing man page for more details path specific on PBA based timing fixing
# Reporting options should be changed to reflect path specific and PBA based ECO
#
# fix setup 
#fix_eco_timing -type setup -verbose -slack_lesser_than 0 -estimate_unfixable_reasons 
# fix hold 
#fix_eco_timing -type hold -verbose -slack_lesser_than 0 -estimate_unfixable_reasons  -buffer_list {BUFX2MTR BUFX4MTR BUFX8MTR BUFX10MTR BUFX12MTR BUFX16MTR}
#set_app_var eco_alternative_area_ratio_threshold "5"
#fix_eco_timing -type hold -verbose -slack_lesser_than 0 -buffer_list {BUFX2MTR BUFX4MTR BUFX8MTR BUFX10MTR BUFX12MTR BUFX16MTR}


##################################################################
#    Fix ECO Output Section                                      #
##################################################################
# write netlist changes
#write_changes -format icctcl -output $RESULTS_DIR/eco_changes.tcl
#write_changes -format icc2tcl -output $RESULTS_DIR/eco_changes.tcl

##################################################################
#    Apply ECO Data to ICC                                       #
##################################################################
# Launch ICC and STAR_RC to get def and parasitic files for PT.
#apply_eco_data -wait


##################################################################
#    Final Data Output		                                 #
##################################################################
#report_analysis_coverage
#write_sdf $RESULTS_DIR/fifo_max.sdf_PT



##################################################################
#    Generation of Hierarchical Model Section                    #
#                                                                #
#  Extracted Timing Model (ETM) will contain composite current   #
#  source (CCS) timing models, if design libraries contains both #
#  CCS timing and noise data along with design for which model   #
#  is extracted has waveform propogation enable using variable   #
#  'set delay_calc_waveform_analysis_mode full_design'           # 
##################################################################

#extract_model -library_cell -test_design -output ${RESULTS_DIR}/${DESIGN_NAME} -format {lib db} -block_scope
#extract_model -library_cell -test_design -output ${RESULTS_DIR}/${DESIGN_NAME} -format {lib db}
#write_interface_timing ${REPORTS_DIR}/${DESIGN_NAME}_etm_netlist_interface_timing.report


