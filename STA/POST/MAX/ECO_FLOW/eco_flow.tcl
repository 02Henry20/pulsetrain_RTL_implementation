#
#----------------------------------
# ECO Flow 
#----------------------------------
#
# PT ECO FLOW 
# Running ICC and STAR_RC
#
#
#------------------------------------
#       read_config
# Read config file write regsub.tcl
# under MISC
#------------------------------------
proc read_config {} {
  global root
  global CFG
  global env
#
## Read the config file and incr_setup file
  exec cat $CFG >> $root/ECO_FLOW/MISC/tem.tcl
##
  set fid [open $root/ECO_FLOW/MISC/tem.tcl r]
  set content [read $fid]
  close $fid
  file delete $root/ECO_FLOW/MISC/tem.tcl
#
  set wid [open $root/ECO_FLOW/MISC/regsub.tcl w]
  puts $wid "source $CFG"
  puts $wid "source $root/ECO_FLOW/MISC/incr_setup.tcl"
## Split into records on newlines
  set lines [split $content "\n"]

## Iterate over the records
  foreach l $lines {
     if {[regexp {^#} $l]} {continue }
     if {![regexp {set } $l]} { continue}
     regsub -all {\s+} $l " "
## Split into fields on colons
     set fields [split $l " "]
     set var [lindex $fields 1]
#
# regsub -all dog $Script cat Script
#
  if { [regexp "\\(.*\\)" $var ix] } {
     regsub -- "\\(" $ix {} ii
     regsub -- "\\)" $ii {} ii
     regsub -- $ix $var {} new_var
     regsub -- "\\(" $new_var {} new_var
     regsub -- "\\)" $new_var {} new_var
     puts -nonewline $wid "regsub -all SUB_$new_var\_$ii \$line \$$var line\n"
  } else {
     puts -nonewline $wid "regsub -all SUB_$var \$line \$$var line\n"
  }
}
## Root directory
  puts -nonewline $wid "regsub -all SUB_ROOT \$line \{$root\} line\n"
  puts $wid "echo"
  close $wid
return
}
#------------------------------------
#       move_file
# Read file under scripts and write it
# to the run dir.
#------------------------------------
#
proc move_file { file run_dir {output_file NONE} {inx -1} } {
  global root
  global env
#
#
  set filename $root/ECO_FLOW/SCRIPTS/$file
  if { [regexp NONE $output_file] } {
     set temp     $run_dir/$file
   } else {
     set temp $run_dir/$output_file
   }
#
  set in  [open $filename r]
  set out [open $temp     w]
#
# line-by-line, read the original file
  while {[gets $in line] != -1} {
    regsub -all {_INX} $line _$inx line
    source $root/ECO_FLOW/MISC/regsub.tcl
    puts $out $line
  }
  close $in
  close $out
#
#
  if { [file exists $temp] } {
    if {[regexp csh $temp]} { file attribute $temp -permission 00777 }
    if {[regexp submit $temp]} { file attribute $temp -permission  00777 }
  }
#
  return
}

#
#------------------------------------
#       
#    Checking all jobs
#------------------------------------ 
#
proc jobs_checking {} {
#
  global root
  global GEN_LEF
  global ICC_2_PT
  global STAR_RC
  global ECO_DB
  global GOT_DATA
#
## Checking when all jobs are done
#
#
# Check to see ECO_DB is running first and return
# Checking the log file to make sure ECO_DB is ruuning.
#
  if {  [file exists "$root/ECO_FLOW/ICC/LOGS/eco_db.log"] } {
   set FIN 0
   set APPLY_DATA 0
   if { [file exists "$root/ECO_FLOW/ICC/RUN/ECO_DB_IS_DONE"] } {
        puts "STATUS: ECO_DB Job is done"
	set FIN 3
        set APPLY_DATA 1
  }
  return $APPLY_DATA
 }
 #---------------------------------
  set FIN 0
  set GEN_LEF  0
  if { [file exists "$root/ECO_FLOW/ICC/RUN/LEF_IS_RUNNING"] } {
#
     if { [file exists "$root/ECO_FLOW/ICC/RUN/LEF_IS_DONE"] } {
        puts "STATUS: Milkyway LEF is done"
        set GEN_LEF  1
	incr FIN
     }
  } else {
        set GEN_LEF  1
	incr FIN
  }
#
   set ICC_2_PT 0
     if { [file exists "$root/ECO_FLOW/ICC/RUN/ICC_2_PTSI_IS_DONE"] } {
        puts "STATUS: ICC Job  is done"
        set ICC_2_PT 1
	incr FIN
      }
#
   set STAR_RC 1
   set RC_DIRS [glob $root/ECO_FLOW/STAR_RC/RUN/RUN_* ]
   foreach dir $RC_DIRS {
#
   regsub -- {.*RUN_} $dir {} i
   if {! [file exists "$root/ECO_FLOW/STAR_RC/RUN/STAR_RC_IS_DONE_$i"] } {
       set STAR_RC 0
     }
  }
  if {$STAR_RC == 1} {
        puts "STATUS: STAR_RC Job(s)  is done"
	incr FIN    
  }
#
## Return
#
   if { $FIN ==3} {
      set GOT_DATA 1
      return 1
   } else {
      set GOT_DATA 0
      return 0
   }
}
#
#------------------------------------
#       
#    wait_for_job
# 
#------------------------------------
#
proc wait_for_job {} {
global NOWAIT
#
    set loop 1
    set time 10
#
   if {$NOWAIT && ![jobs_checking] } {   exit }
#
    while {! [jobs_checking] } {
      exec sleep 10 
      puts " $time seconds: Waiting for all the runs to finish\n"
      incr loop
      set time [expr $loop * 10]
     }
#
}
#
#------------------------------------
#       
#    UI COMMAND get_eco_data
# 
#------------------------------------
#
proc get_eco_data { args } {
#
#  Option:
#       
#       -mwcel <cell name> / default to cell name in the config
#
  global root
  global INDEX
  global GOT_DATA
  global sub
  global LEF_FILES
  global def_files
  global icc_sub
  global star_sub
  global env
  global CFG
   global NETLIST_FILES
  global PARASITIC_FILES
  global PARASITIC_PATHS
  global DEF_FILES
  global SDIR
  global NOWAIT
#
   source $CFG
#
# Checking on all calling option
#
# Option to new mw_cel from ARGS
  if { [ regexp -- {-mwcel} $args] } {
    regsub -- {.*-mwcel} $args {} tmp
    set mw_cel [lindex $tmp 0]
    echo "set input_mw_cel $MW_CEL" >> $root/ECO_FLOW/MISC/incr_setup.tcl
 }
# Option not to wait -nowait (Default is waiting)
  set NOWAIT 0
  if { [ regexp -- {-nowait} $args] } {
    set NOWAIT 1
 }
 # Option  -reset
  if { [ regexp -- {-reset} $args] } {
    reset_all
 }
 #----------------
# Check to see ECO DB has been running 
   if { [file exists "$root/ECO_FLOW/ICC/ECO_DB_IS_RUNNING" ] } {
      if {! [file exists "$root/ECO_FLOW/ICC/ECO_DB_IS_RUNNING" ] } {
         puts "Error: ECO_DB job is not finish\n";
	 puts "Please wait for it to finish OR get_eco_data -reset_all \n"
	 exit;
      }
    }
#----------------
# Check to see Get ECO has been running before with nowait option
   if { [file exists "$root/ECO_FLOW/MISC/GET_ECO_IS_RUNNING" ] } {
      source $root/ECO_FLOW/MISC/incr_setup.tcl
   } else {
#---------------
# Initialize all
#
 init_all
 source $root/ECO_FLOW/MISC/incr_setup.tcl 
#
#---------------
   echo "STATUS: input mw_cel $input_mw_cel"
   echo "STATUS: Run # $INDEX"
# 
## Launching windows
   echo "ICC script is under ECO_FLOW/ICC/RUN" > $root/ECO_FLOW/ICC/LOGS/icc_2_pt.log
   echo "ICC log is under ECO_FLOW/ICC/LOGS" >> $root/ECO_FLOW/ICC/LOGS/icc_2_pt.log
#
   set job [ exec xterm -T "ICC_2_PT Run" -hold -e tail -f $root/ECO_FLOW/ICC/LOGS/icc_2_pt.log & ]	  
   echo "lappend win $job" >> $root/ECO_FLOW/MISC/kill_window.tcl
#
# Launching all jobs
#
#
## Launching ICC job
#
     puts "STATUS: Launching ICC job\n"
     exec $icc_sub  $root/ECO_FLOW/ICC/RUN/icc_2_pt.csh &
      exec sleep 5
#
# Launching all STAR_RC runs
#
     set all_csh [glob $root/ECO_FLOW/STAR_RC/RUN/run_star_*.csh ]
     foreach csh $all_csh {
#
      regsub -- {.*run_star_rc_} $csh {} i
      regsub -- {\.csh} $i {} i
#
      if { ! [ file exists $root/ECO_FLOW/STAR_RC/RUN/RUN_$i ] } { 
         file mkdir $root/ECO_FLOW/STAR_RC/RUN/RUN_$i 
      } 
#
## Copy the STAR_RC csh and cmd files to the run_i directory
#
      set files [glob $root/ECO_FLOW/STAR_RC/RUN/*_$i.*]
      foreach fi $files {
        regsub -- {RUN} $fi "RUN/RUN_$i" ff
	if { [regexp csh $ff] } { set fx $ff}
        file copy -force $fi $ff
      }
#
# Launching the job
#
     puts "STATUS: Launching STAR_RC job\n"
     exec $star_sub $fx &
     exec sleep 5
#-----
      echo "STAR_RC script and log are under /ECO_FLOW/STAR_RC/RUN/RUN_$i" > $root/ECO_FLOW/STAR_RC/RUN/RUN_$i/$input_mw_cel.star_sum
      set job [ exec xterm -T "STAR_RC Run" -hold -e tail -f  $root/ECO_FLOW/STAR_RC/RUN/RUN_$i/$input_mw_cel.star_sum & ]
      echo "lappend win $job" >> $root/ECO_FLOW/MISC/kill_window.tcl
     }
#
     exec touch $root/ECO_FLOW/MISC/GET_ECO_IS_RUNNING
#
  }
#---------------------------------------
# ------   Wait for job to finish
# -------------------------------------
     wait_for_job
#
#
  if {$GOT_DATA == 1} { 
#
# Calling pt_define_var from pt_define_var.tcl to load up all variables
#
    define_pt_variables ;#
#
    file delete -force $root/ECO_FLOW/MISC/GET_ECO_IS_RUNNING
    exec touch $root/ECO_FLOW/MISC/GET_ECO_IS_DONE
  }
##Finish
  puts "----------------------------------------------------------------\n";
  puts "STATUS: Generating ICC data from  Milkyway cell $input_mw_cel\n"
#
#  set spefs {}
#  catch {set spefs [glob $root/ECO_FLOW/STAR_RC/OUTPUTS/*_$INDEX.spef]}
#  if { [llength $spefs] > 0 } {
#     foreach sp $spefs { puts "spef_out: $sp\n" }
#  }
#
  puts "----------------------------------------------------------------\n";
  return
}
#------------------------------------
#       
#    Load ECO file
# 
#------------------------------------
#
proc load_eco_file {} {
global PT
global env
global root
global RESULTS_DIR
global DMSA
global eco_file
#
# Looking for eco_changes.tcl under the run directory
    set loc [exec find $root/ -name eco_changes.tcl]
#
    if { [llength $loc] == 0} {
       echo "ERROR: Can NOT find eco_changes.tcl to apply ECO. Please Generate: eco_changes.tcl"
       exit
     }
#
# Check for the latest by Modify date
#
    set max 0
    foreach l $loc {
      set t [file mtime $l]
      if {$t > $max} { set lf $l; set max $t }
    }
#
     set time [clock format $max]
     echo "STATUS: Using the latest eco file $lf  modified $time"
     file copy -force $lf $root/ECO_FLOW/MISC/$eco_file
 #----------------------
 return
 }
#
#------------------------------------
#       
#    UI COMMAND apply_eco_data
# 
#------------------------------------
#
proc apply_eco_data { args } {
#
#  Option:
#	-wait : waiting for all the jobs are done. (default no wait)
#
  global root
  global INDEX
  global GOT_DATA
  global sub
  global eco_file
  global LEF_FILES
  global def_files
  global icc_sub
  global star_sub
  global CFG
  global env
  global RESULTS_DIR
  global NOWAIT
  global DMSA
  global PT
#
## Move all ICC files 
   foreach ff {eco_db } {
    move_file "$ff.tcl" "$root/ECO_FLOW/ICC/RUN"
    move_file "$ff.csh" "$root/ECO_FLOW/ICC/RUN"
  }
#
# Checking option nowait For apply_eco nowait means return
# Option not to wait -nowait (Default is waiting)
  set NOWAIT 0
  if { [ regexp -- {-nowait} $args] } {
    set NOWAIT 1
 }
 #
# Checking option gui to invoke ICC gui
# Option not to wait -nowait (Default is waiting)
  set env(GUI) 0
  if { [ regexp -- {-gui} $args] } {
  sh echo \"\$(echo 'set GUI 1 \n' | cat - $root/ECO_FLOW/ICC/RUN/eco_db.tcl)\" > $root/ECO_FLOW/ICC/RUN/eco_db.tcl
 }
 #
  if {! [file exists $root/ECO_FLOW/MISC/GET_ECO_IS_DONE] } {
    puts "STATUS: Get eco data is not done"
    return
   } else {
    file delete -force $root/ECO_FLOW/MISC/GET_ECO_IS_DONE
   }
#
  source $CFG
  source $root/ECO_FLOW/MISC/incr_setup.tcl
  set sub "$root/ECO_FLOW/MISC/submit_job"
 #
 # Checking to see is it DMSA Mode
 #
 set DMSA 0
  if { [regexp {master} $PT ] } {
   if { [info exists dmsa_corners] } {
    if { [lindex $dmsa_corners 0] ne "" } {
      set DMSA 1
       }
    }
  }
#
  echo "STATUS: Apply ECO change to $input_mw_cel"
#
  load_eco_file
#
  echo "STATUS: Launching ICC job"
  exec $icc_sub $root/ECO_FLOW/ICC/RUN/eco_db.csh &
#
  echo "Apply ECO to $input_mw_cel and output to $output_mw_cel" > $root/ECO_FLOW/ICC/LOGS/eco_db.log
  set job [exec xterm -T "ICC ECO Run " -hold -e tail -f $root/ECO_FLOW/ICC/LOGS/eco_db.log & ]
  echo "lappend win $job" >> $root/ECO_FLOW/MISC/kill_window.tcl
#
#------
  if {$NOWAIT } {  return }
  wait_for_job
#
## Finish
  puts "----------------------------------------------------------------\n";
  puts "STATUS: ECO applied and saved under Milkyway cell $output_mw_cel\n"
  puts "----------------------------------------------------------------\n";
#
  return
}
#-----------------------------------
# Write Incr_setup file
#-----------------------------------
proc incr_setup {} {
  global INDEX
  global MW_CEL
  global root
  global LEF_FILES
  global env
#
## Check to see Previous Jobs are running
#
  if {$INDEX == 1} {
   set input_mw_cel $MW_CEL
   set output_mw_cel "$MW_CEL\_$INDEX"
   set eco_file "ECO_file_$INDEX"
  } else {
   set prev [expr $INDEX -1]
   set input_mw_cel $MW_CEL\_$prev
   set output_mw_cel "$MW_CEL\_$INDEX"
   set eco_file "ECO_file_$INDEX"
 }
#
## Write incr setup file
#
   set out [open $root/ECO_FLOW/MISC/incr_setup.tcl w]
   puts $out "#---------------------------------"
   puts $out "set input_mw_cel $input_mw_cel"
   puts $out "set output_mw_cel $output_mw_cel"
   puts $out "set eco_file $eco_file"
   puts $out "set verilog_out verilog_$INDEX.v"
   puts $out "set sdc_out sdc_$INDEX.sdc"
   puts $out "set def_out def_$INDEX.def.gz"
   puts $out "set DISPLAY $env(DISPLAY)"
#
   puts $out "set spef_out spef_$INDEX.spef"
   puts $out "set gpd_out gpd_$INDEX.gpd"
   puts $out "set INDEX $INDEX"
   puts $out "#---------------------------------"
   if {![regexp lef $LEF_FILES ] } {
    puts "Error: Undefine lef_files variables\n";
   }
   close $out
#
  exec cat $root/ECO_FLOW/MISC/incr_setup.tcl >> $root/ECO_FLOW/MISC/tem.tcl
  return
}
#
#------------------------------------
#       
#    Kill all windows
# 
#------------------------------------
#
proc kwin {} {
  global root
#
  if { [file exists $root/ECO_FLOW/MISC/kill_window.tcl]} {
     echo "set id \[exec ps\]" >> $root/ECO_FLOW/MISC/kill_window.tcl
     echo "foreach w  \$win \{ if \{\[regexp \$w \$id\]\} \{ exec kill \$w \} \} " >> $root/ECO_FLOW/MISC/kill_window.tcl
     source $root/ECO_FLOW/MISC/kill_window.tcl
     file delete -force $root/ECO_FLOW/MISC/kill_window.tcl 
  }
}
#------------------------------------
#       reset_all
# Reset and clean up all files as original
# Using sh to remove all files
#------------------------------------
proc reset_all {} {
   global root
#
   kwin
#
foreach dd { MISC ICC/RUN ICC/LOGS ICC/OUTPUTS STAR_RC/RUN STAR_RC/LOGS STAR_RC/OUTPUTS} {
     set dir "$root/ECO_FLOW/$dd"
     set file_list [glob -nocomplain "$dir/*"]
      if {[llength $file_list] != 0} {
           puts "STATUS: Delete files under $dir "
	   foreach file [glob -- $dir/*] {file delete -force -- $file}
      } 
  }
}
#
#------------------------------------
#       
#    Initialize all data for rerun
# 
#------------------------------------
#
proc init_all  {} {
#
global root
global INDEX
global sub
global def_files
global LEF_FILES
global icc_sub
global star_sub
global host
global rc_num
global CFG
global MW_CEL
global env
global PT
#
#
##-- Cleaning previous runs
#
  if { [ file exists $root/ECO_FLOW/MISC/kill_window.tcl]  } {
      kwin
     }
#------------- Check to see ECO_DB ran before and cleanup
#
  if { [ file exists $root/ECO_FLOW/ICC/RUN/ECO_DB_IS_RUNNING]  } {
    set ix [expr $INDEX -1]
    file rename -force $root/ECO_FLOW/ICC/LOGS/eco_db.log $root/ECO_FLOW/ICC/LOGS/RUN_$ix\_eco_db.log
  }
#-------
  if { [ file exists $root/ECO_FLOW/ICC/RUN/ICC_2_PTSI_IS_RUNNING]  } {
     eval file delete -force [glob $root/ECO_FLOW/ICC/RUN/ICC_2_PTSI_IS_*]
     }
  if { [ file exists $root/ECO_FLOW/ICC/RUN/ECO_DB_IS_RUNNING]  } {
     eval file delete -force [glob $root/ECO_FLOW/ICC/RUN/ECO_DB_*]
     }
  if { [ file exists $root/ECO_FLOW/STAR_RC/RUN/STAR_RC_IS_RUNNING_0]  } {
     eval file delete -force [glob $root/ECO_FLOW/STAR_RC/RUN/STAR_RC_IS_*]
     exec rm -fr [glob $root/ECO_FLOW/STAR_RC/RUN/RUN_*]
     }
  if { [file exists $root/ECO_FLOW/MISC/GET_ECO_IS_DONE] } {
     file delete -force $root/ECO_FLOW/MISC/GET_ECO_IS_DONE
     }
  if { [file exists $root/ECO_FLOW/MISC/tem.tcl] } {
     file delete -force $root/ECO_FLOW/MISC/tem.tcl
     }
#
#
## Incr setup and index for next loop
#
  incr INDEX 
  incr_setup
  read_config
#
## Move all ICC files 
   foreach ff { icc_2_pt} {
    move_file "$ff.tcl" "$root/ECO_FLOW/ICC/RUN"
    move_file "$ff.csh" "$root/ECO_FLOW/ICC/RUN"
  }
#
# Move submit Job file
   move_file "submit_icc_job" "$root/ECO_FLOW/MISC" 
   move_file "submit_star_job" "$root/ECO_FLOW/MISC"
#
## Move STAR_RC and submit jobs files
#
# get variable MAPPING FILE from CFG file
  set mp [eval exec grep MAPPING_FILE $CFG | grep "set "]
  eval $mp
#
  set rc_num [array size MAPPING_FILE]
  for {set i 0} {$i < $rc_num} {incr i} {
   move_file "run_star_rc.cmd" "$root/ECO_FLOW/STAR_RC/RUN" "run_star_rc_$i.cmd" $i
   move_file "run_star_rc.csh" "$root/ECO_FLOW/STAR_RC/RUN" "run_star_rc_$i.csh" $i
 }
#-----------------
return
}
#------------------------------------
#       
#    check ECO_FLOW sub dir
# 
#------------------------------------
#
proc check_dir  {} {
global root
global CFG
global env
#
# MISC Directory
#
   if { ! [  file isdirectory $root/ECO_FLOW/SCRIPTS ] } {
   	puts "ERROR: Missing ECO_FLOW/SCRIPTS directory\n"
	exit
   }
   #
   if { ! [  file isdirectory $root/ECO_FLOW/MISC ] } {
   	file mkdir $root/ECO_FLOW/MISC
   }
#
# ICC DIRECTORY
#
   if { ! [  file isdirectory $root/ECO_FLOW/ICC ] } {
	file mkdir $root/ECO_FLOW/ICC
	file mkdir $root/ECO_FLOW/ICC/LOGS
	file mkdir $root/ECO_FLOW/ICC/OUTPUTS
	file mkdir $root/ECO_FLOW/ICC/RUN
    }
#
  if { ! [  file isdirectory $root/ECO_FLOW/ICC/LOGS ] } {
  	file mkdir $root/ECO_FLOW/ICC/LOGS
}
#
  if { ! [  file isdirectory $root/ECO_FLOW/ICC/OUTPUTS ] } {
  	file mkdir $root/ECO_FLOW/ICC/OUTPUTS
}
#
  if { ! [  file isdirectory $root/ECO_FLOW/ICC/RUN ] } {
  	file mkdir $root/ECO_FLOW/ICC/RUN
}
#
# STAR RC directory
#
       if { ! [  file isdirectory $root/ECO_FLOW/STAR_RC ] } {
	file mkdir $root/ECO_FLOW/STAR_RC/OUTPUTS
	file mkdir $root/ECO_FLOW/STAR_RC/RUN
    }
#
       if { ! [  file isdirectory $root/ECO_FLOW/STAR_RC/OUTPUTS ] } {
       	 file mkdir $root/ECO_FLOW/STAR_RC/OUTPUTS
       }
#
       if { ! [  file isdirectory $root/ECO_FLOW/STAR_RC/RUN ] } {
       	 file mkdir $root/ECO_FLOW/STAR_RC/RUN
       }
#
}
#
#
#-----------------------------------
#
#   .....Running....
#
#----------------------------------
global root
global SDIR
global INDEX
global sub
global def_files
global LEF_FILES
global icc_sub
global star_sub
global host
global rc_num
global CFG
global env
#
global NETLIST_FILES
global PARASITIC_FILES
global PARASITIC_PATHS
global DEF_FILES
global SDIR
global PT
#
  set root [pwd]
  set ver "Jun_26_2015"
  set PT $pt_shell_mode
#
#
  puts "---------------------------------"
  puts "  ECO Flown"
  puts "  Version $ver"
  puts " Enviroment Display $env(DISPLAY)"
  puts " PT: $PT"
  puts "---------------------------------\n"
#
#
 check_dir
#
#
#Define Submit job file for ICC and STAR
set icc_sub "$root/ECO_FLOW/MISC/submit_icc_job"
set star_sub "$root/ECO_FLOW/MISC/submit_star_job"
#
# Build internal configuration file for ECO flow
#
  set CFG $root/ECO_FLOW/MISC/eco_flow_cfg.tcl
  if {[file exists  $root/rm_setup/pt_setup.tcl ]} {
     file delete -force $CFG
     exec egrep -v RM-Info: $root/rm_setup/common_setup.tcl > $CFG
     exec egrep -v RM-Info: $root/rm_setup/pt_setup.tcl >> $CFG
    } else {
     puts "Error: Could not find  $root/rm_setup/pt_setup.tcl \n";
     exit;
    }
 #
 # Checking all SUB directory under ECO_FLOW
#
  set INDEX 0
  source $root/ECO_FLOW/SCRIPTS/pt_define_var.tcl
#
#
#-----------------------------------
#
#		FINISH
#
#-----------------------------------
