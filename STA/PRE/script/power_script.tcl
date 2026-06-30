##################################################################
#    setup, read design and library                              #
##################################################################
#read_ddc ../../SYN/output/fifo_mapped.ddc 
#
#current_design fifo
#link

restore_session TOP_ss_timing

##################################################################
#    Setting Derate and CRPR Section                             #
##################################################################

set timing_remove_clock_reconvergence_pessimism true

##################################################################
#    POWER ANALYSIS	                                         #
##################################################################
set power_enable_analysis true

##################################################################
#    load_upf				                         #
##################################################################

#load_upf

##################################################################
#    read_sdc and read_parasitics				                         #
##################################################################

#read_sdc
#read_parasitics

##################################################################
#    read_saif				                         #
##################################################################

#read_vcd

#read_saif rtl.saif -rtl_direct -strip_path tb/top_inst 
# rtl_direct is for rtl saif
read_saif  ../../SIM/PRE/TOP.saif -strip_path TB_TOP/U_TOP





##################################################################
#    Update_timing and check_timing Section                      #
##################################################################

update_power
update_timing -full
check_timing -verbose > rpt/power/00_check_timing.report

##################################################################
#    Save_Session Section                                        #
##################################################################
#save_session fifo_ss_timing
#save_session fifo_ss_power


##################################################################
#    Report_timing Section                                       #
##################################################################
report_global_timing > rpt/power/01_report_global_timing
report_clock -skew -attribute > rpt/power/02_report_clock
report_analysis_coverage > rpt/power/03_report_analysis_coverage
report_timing -slack_lesser_than 0.0 -delay min_max -nosplit -input -net  > rpt/power/04_report_timing

# generates average cycle waveforms
# this is available for newer version
#create_power_waveforms

# reports average power results
report_power -verbose > rpt/power/05_report_power

report_annotated_power > ./rpt/power/06_pad_TOP.report.annotated_power
# below command the same but it is from DC
#report_saif -hierarchy -missing -rtl_saif > ./rpt/power/pad_TOP.report.saif

#report_analysis_coverage
#write_sdf pad_TOP.sdf_PT


