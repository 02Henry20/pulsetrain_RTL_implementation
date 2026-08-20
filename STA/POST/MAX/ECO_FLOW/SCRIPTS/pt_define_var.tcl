#-/home/smkcow/QnA/digital/example_smkcow_DC_ICC2_28/f--------------------------------------------------
# PT
# Define PT variables for PT_RM
# after got data from ICC and STAR_RC
# Developed by Thi Nguyen
#-----------------------------------------------------
#
proc define_pt_variables {} {
#
  global root
  global NETLIST_FILES
  global PARASITIC_FILES
  global PARASITIC_PATHS
  global DEF_FILES
  global SDIR
  global env
  global CFG
  global PT
#
# Initialize variable
set DMSA 0    ;
#
# Loading ICC Variables for PT_RM
#
  source $CFG
  source $root/ECO_FLOW/MISC/incr_setup.tcl
#
#  Check the config for DMSA corners 
#
  if { [regexp {master} $PT] } {
  if { [info exists dmsa_corners] } {
   if { [lindex $dmsa_corners 0] ne "" } {
      set DMSA 1
   }
  }
}
#
# Defines DEF and Verilogs out
#
   set DEF_FILES $root/ECO_FLOW/ICC/OUTPUTS/$def_out
   set NETLIST_FILES $root/ECO_FLOW/ICC/OUTPUTS/$verilog_out
   echo "
   ECO_FLOW DEFINES:
   -------------------------------
   set DEF_FILES		\t$DEF_FILES
   set NETLIST_FILES	\t$NETLIST_FILES " ;
#
# for NON DMSA (all in RUN_0 directory) flat run
#
if {$DMSA == 0} {
   set spef "$root/ECO_FLOW/STAR_RC/OUTPUTS/RUN_0_$spef_out"
   set gpd "$root/ECO_FLOW/STAR_RC/OUTPUTS/RUN_0_$gpd_out"
   set PARASITIC_FILES $gpd
   if { [file exists $gpd] == 0} { set PARASITIC_FILES $spef }
   set PARASITIC_PATHS $DESIGN_NAME
#
# Checking to see file exists
#
if { [file exists $DEF_FILES] == 0} { puts "Error: File $DEF_FILES is not existed. ICC did not generate the file"; exit}
if { [file exists $NETLIST_FILES] == 0} { puts "Error: File $NETLIST_FILES is not existed. ICC did not generate the file"; exit}
set test { [file exists $gpd] || [file exists $gpd] }
if {  $test == 0 } { puts "Error: Parasitic file is not existed. STAR_RC did not generate the file $test"; exit}
#
echo "
   set PARASITIC_FILES	\t$PARASITIC_FILES
   set PARASITIC_PATHS	\t$PARASITIC_PATHS
    -------------------------------
";
} else {
# This is for DMSA Mode
# dmsa_corners is defined in pt_setup.tcl. run0, run1 and runx follows the order
# of the list dmsa_corners. 
# the parasitics variables are aaray in DMSA
#
  set dmsa_file "$root/ECO_FLOW/MISC/dmsa_var.tcl"
  set dmsa_var [open "$dmsa_file" "w"]
  puts $dmsa_var "set   DEF_FILES		\t$DEF_FILES\n";
  puts $dmsa_var "set NETLIST_FILES	\t$NETLIST_FILES\n" ;
#
  set mode [array size MAPPING_FILE]
  for {set i 0} {$i < $mode} {incr i} {
  #
    set corner [lindex $dmsa_corners $i]
    set gpd "$root/ECO_FLOW/STAR_RC/OUTPUTS/RUN_$i\_$gpd_out"
    set spef "$root/ECO_FLOW/STAR_RC/OUTPUTS/RUN_$i\_$spef_out"
    set PARASITIC_FILES($corner) $gpd
     if { [file exists $gpd] == 0} {set PARASITIC_FILES($corner) $spef }
    set PARASITIC_PATHS($corner) $DESIGN_NAME
    echo "
    set PARASITIC_FILES($corner)	\t$PARASITIC_FILES($corner)
    set PARASITIC_PATHS($corner)	\t$PARASITIC_PATHS($corner)";
#
    puts $dmsa_var "set PARASITIC_FILES($corner)	\t$PARASITIC_FILES($corner)\n";
    puts $dmsa_var "set PARASITIC_PATHS($corner)	\t$PARASITIC_PATHS($corner)\n";
 }
#
    puts $dmsa_var "#----------------------\n";
    close $dmsa_var
#
# copy dmsa_file to rm_setup directory
   if { [file exists $root/rm_setup/pt_eco_flow_setup.tcl] } { file delete -force $root/rm_setup/pt_eco_flow_setup.tcl }
   file copy -force $dmsa_file $root/rm_setup/pt_eco_flow_setup.tcl 
#
# check to see scenario set up if yes send all variables to the slave
#
  redirect -variable jnk {report_multi_scenario}
   regsub -all " " $jnk "" jnk
   if { ![regexp "Notdefined" $jnk] } {
       set_distributed_variables { [current_scenario] dmsa_file}
#
# Passing the variable to the child for DMSA
#
       remote_execute -v {
          echo "Passing Variables from Master to slave"
           source $dmsa_file
        }
#
    }
  }
echo "    -------------------------------";
#
#  --------------Finish------------------
#
return
}
