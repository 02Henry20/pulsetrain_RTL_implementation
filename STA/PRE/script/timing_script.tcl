##################################################################
#    setup, read design and library                              #
##################################################################
read_ddc ../../SYN_topo/results/TOP_PREV.mapped.ddc 

current_design TOP_PREV 
link

##################################################################
#    Setting Derate and CRPR Section                             #
##################################################################

set timing_remove_clock_reconvergence_pessimism true

##################################################################
#    read_sdc and read_parasitics                                                        #
##################################################################

#read_sdc -version 2.0 ../../SYN_topo/results/TOP_PREV.mapped.mode_norm.OC_rvt_ff_min_1p100v_m40c.RC_MIN.sdc

#read_parasitics

##################################################################
#    Update_timing and check_timing Section                      #
##################################################################
# below line is available after read_vcd 
#update_timing -full 
check_timing -verbose > rpt/timing/00_check_timing

##################################################################
#    Save_Session Section                                        #
##################################################################
save_session TOP_PREV_ss_timing
#save_session pad_TOP_PREV_ss_power


##################################################################
#    Report_timing Section                                       #
##################################################################
report_global_timing > rpt/timing/01_report_global_timing
report_clock -skew -attribute > rpt/timing/02_report_clock
report_analysis_coverage > rpt/timing/03_report_analysis_coverage
report_timing -slack_lesser_than 0.0 -delay min_max -nosplit -input -net -max_paths 30 > rpt/timing/04_report_timing

report_analysis_coverage
write_sdf TOP_PREV.sdf_PT
