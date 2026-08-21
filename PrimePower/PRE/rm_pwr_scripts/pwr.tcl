#################################################################################
# PrimePower Reference Methodology Script
# Script: pwr.tcl
# Version: O-2018.06 (Jul 17, 2018)
# Copyright (C) 2008-2018 Synopsys All rights reserved.
################################################################################




# Please do not modify the sdir variable.
# Doing so may cause script to fail.
set sdir "." 



##################################################################
#    Source common and pwr_setup.tcl File                         #
##################################################################

source $sdir/rm_setup/common_setup.tcl
source $sdir/rm_setup/pwr_setup.tcl


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


  
set power_enable_timing_analysis true 
set power_enable_multi_rail_analysis true 
set power_analysis_mode averaged 

set report_default_significant_digits 3 ;
set sh_source_uses_search_path true ;
set search_path ". $search_path" ;


##################################################################
#    Netlist Reading Section                                     #
##################################################################
set link_path "* $link_path"
read_verilog $NETLIST_FILES

current_design $DESIGN_NAME 
link


##################################################################
#    Back Annotation Section                                     #
##################################################################
if { [info exists PARASITIC_PATHS] && [info exists PARASITIC_FILES] } {
foreach para_path $PARASITIC_PATHS para_file $PARASITIC_FILES {
   if {[string compare $para_path $DESIGN_NAME] == 0} {
      read_parasitics $para_file 
   } else {
      read_parasitics -path $para_path $para_file 
   }
}
}



##################################################################
#    Reading Constraints Section                                 #
##################################################################
if  {[info exists CONSTRAINT_FILES]} {
        foreach constraint_file $CONSTRAINT_FILES {
                if {[file extension $constraint_file] eq ".sdc"} {
                        read_sdc -echo $constraint_file
                } else {
                        source -echo $constraint_file
                }
        }
}











##################################################################
#    Update_timing and check_timing Section                      #
##################################################################

update_timing -full
check_timing -verbose > $REPORTS_DIR/${DESIGN_NAME}_check_timing.report


##################################################################
#    Save_Session Section                                        #
##################################################################
save_session ${DESIGN_NAME}_ss


##################################################################
#    Report_timing Section                                       #
##################################################################
report_global_timing > $REPORTS_DIR/${DESIGN_NAME}_report_global_timing.report
report_clock -skew -attribute > $REPORTS_DIR/${DESIGN_NAME}_report_clock.report 
report_analysis_coverage > $REPORTS_DIR/${DESIGN_NAME}_report_analysis_coverage.report
report_timing -slack_lesser_than 0.0 -delay min_max -nosplit -input -net  > $REPORTS_DIR/${DESIGN_NAME}_report_timing.report


##################################################################  
#    Power Switching Activity Annotation Section                 #  
##################################################################  
read_saif $ACTIVITY_FILE -strip_path $STRIP_PATH        
report_switching_activity -list_not_annotated           

##################################################################
#    Power Analysis Section                                      #
##################################################################
## run power analysis
check_power   > $REPORTS_DIR/${DESIGN_NAME}_check_power.report
update_power  

## report_power
report_power > $REPORTS_DIR/${DESIGN_NAME}_report_power.report


# Clock Gating & Vth Group Reporting Section
report_clock_gate_savings  

# Set Vth attribute for each library if not set already
foreach_in_collection l [get_libs] {
        if {[get_attribute [get_lib $l] default_threshold_voltage_group] == ""} {
                set lname [get_object_name [get_lib $l]]
                set_user_attribute [get_lib $l] default_threshold_voltage_group $lname -class lib
        }
}
report_power -threshold_voltage_group > $REPORTS_DIR/${DESIGN_NAME}_pwr.per_lib_leakage
report_threshold_voltage_group > $REPORTS_DIR/${DESIGN_NAME}_pwr.per_volt_threshold_group





