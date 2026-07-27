puts "RM-Info: Running script [info script]\n"

#################################################################################
# Design Compiler Reference Methodology Setup for Top-Down MCMM Flow
# Script: dc_setup.tcl
# Version: M-2016.12-SP4 (July 17, 2017)
#################################################################################

#################################################################################
# Architecture and File-List Setup
#################################################################################

if {![info exists ::env(SYNTH_ARCH)]} {
    puts "RM-Error: The SYNTH_ARCH environment variable is not defined."
    puts "RM-Error: Run synthesis through:"
    puts "RM-Error:   ./run_synthesis <architecture>"
    exit 1
}

set SELECTED_ARCH $::env(SYNTH_ARCH)

if {$SELECTED_ARCH eq ""} {
    puts "RM-Error: SYNTH_ARCH must not be empty."
    exit 1
}

set SYNTH_DIR    [file normalize [pwd]]
set PROJECT_ROOT [file dirname $SYNTH_DIR]

set FUNCTION_DIR \
    [file normalize [file join $PROJECT_ROOT SIM FUNCTION]]

set FILELIST_DIR \
    [file normalize [file join $FUNCTION_DIR filelists]]

set RTL_FILELIST \
    [file normalize \
        [file join $FILELIST_DIR "${SELECTED_ARCH}.f"]]

if {![file exists $RTL_FILELIST]} {
    puts "RM-Error: Architecture file list does not exist:"
    puts "RM-Error:   ${RTL_FILELIST}"
    exit 1
}

if {[info exists ::env(SYNTH_RUN_LABEL)]} {
    set SYNTH_RUN_LABEL $::env(SYNTH_RUN_LABEL)
} else {
    set SYNTH_RUN_LABEL "no_saif"
}
#################################################################################
# Read RTL Source Files from SIM/FUNCTION/filelists/<architecture>.f
#################################################################################

set RTL_SOURCE_FILES [list]

set file_handle [open $RTL_FILELIST r]

while {[gets $file_handle line] >= 0} {

    # Remove leading and trailing whitespace.
    set line [string trim $line]

    # Ignore empty lines.
    if {$line eq ""} {
        continue
    }

    # Ignore full-line comments.
    if {[string match "#*" $line]} {
        continue
    }

    if {[string match "//*" $line]} {
        continue
    }

    # Remove trailing shell/file-list comments beginning with #.
    regsub {#.*$} $line "" line
    set line [string trim $line]

    if {$line eq ""} {
        continue
    }

    # A line may contain one path or several whitespace-separated paths.
    foreach source_entry $line {

        set source_entry [string trim $source_entry]

        if {$source_entry eq ""} {
            continue
        }

        # Synthesis file lists should contain only RTL file paths.
        # Reject simulator-specific options rather than silently ignoring them.
        if {
            [string match "+*" $source_entry] ||
            [string match "-*" $source_entry]
        } {
            puts "RM-Error: Unsupported file-list option:"
            puts "RM-Error:   ${source_entry}"
            puts "RM-Error: File: ${RTL_FILELIST}"
            puts "RM-Error: Synthesis file lists must contain RTL paths only."
            close $file_handle
            exit 1
        }

        # The existing functional-simulation file lists are relative to
        # SIM/FUNCTION. Resolve them against FUNCTION_DIR so both simulation
        # and synthesis interpret the paths identically.
        if {[file pathtype $source_entry] eq "absolute"} {
            set resolved_source [file normalize $source_entry]
        } else {
            set resolved_source \
                [file normalize [file join $FUNCTION_DIR $source_entry]]
        }

        if {![file exists $resolved_source]} {
            puts "RM-Error: RTL source file does not exist:"
            puts "RM-Error:   Original entry : ${source_entry}"
            puts "RM-Error:   Resolved path  : ${resolved_source}"
            puts "RM-Error:   File list      : ${RTL_FILELIST}"
            close $file_handle
            exit 1
        }

        lappend RTL_SOURCE_FILES $resolved_source
    }
}

close $file_handle

if {[llength $RTL_SOURCE_FILES] == 0} {
    puts "RM-Error: No RTL source files were found in:"
    puts "RM-Error:   ${RTL_FILELIST}"
    exit 1
}

#################################################################################
# Architecture- and Activity-Specific Output Directories
#################################################################################

set RUN_DIR \
    [file normalize \
        [file join \
            $SYNTH_DIR \
            runs \
            $SELECTED_ARCH \
            $SYNTH_RUN_LABEL]]

set REPORTS_DIR \
    [file normalize [file join $RUN_DIR reports]]

set RESULTS_DIR \
    [file normalize [file join $RUN_DIR results]]

set LOGS_DIR \
    [file normalize [file join $RUN_DIR logs]]

set ALIB_DIR \
    [file normalize [file join $RUN_DIR alib]]

file mkdir $RUN_DIR
file mkdir $REPORTS_DIR
file mkdir $RESULTS_DIR
file mkdir $LOGS_DIR
file mkdir $ALIB_DIR

#################################################################################
# Print Selected Configuration
#################################################################################

puts "============================================================"
puts "RM-Info: Synthesis configuration"
puts "============================================================"
puts "RM-Info: Architecture : ${SELECTED_ARCH}"
puts "RM-Info: Design name  : ${DESIGN_NAME}"
puts "RM-Info: Run label    : ${SYNTH_RUN_LABEL}"
puts "RM-Info: File list    : ${RTL_FILELIST}"
puts "RM-Info: Run directory: ${RUN_DIR}"
puts "RM-Info: RTL sources:"

foreach rtl_file $RTL_SOURCE_FILES {
    puts "RM-Info:   ${rtl_file}"
}

puts "============================================================"

#################################################################################
# Setup Variables
#################################################################################

set_app_var sh_new_variable_message false

if {$synopsys_program_name == "dc_shell"} {

    # A separate analyzed-library cache is used for every architecture.
    set_app_var alib_library_analysis_path $ALIB_DIR

    # Uncomment only when the required multicore licenses are available.
    # set_host_options -max_cores 4
}

#################################################################################
# Design Compiler Output Configuration
#################################################################################

# Keep a separate physical design database for each architecture.
#
# This overrides the default value loaded from dc_setup_filenames.tcl.
set DCRM_MW_LIBRARY_NAME \
    "MY_DESIGN_LIB_${SELECTED_ARCH}_${SYNTH_RUN_LABEL}"

#################################################################################
# Optimization Flow
#################################################################################

# Available reference-methodology optimization modes:
#
#   hplp    High Performance Low Power
#   hc      High Connectivity
#   rtm_exp Runtime Exploration
#
# Empty string retains the original default flow.
set OPTIMIZATION_FLOW ""

#################################################################################
# Search Path Setup
#################################################################################

set_app_var search_path \
    ". ${ADDITIONAL_SEARCH_PATH} $search_path"

#################################################################################
# Library Setup
#################################################################################

set mw_reference_library ${MW_REFERENCE_LIB_DIRS}
set mw_design_library    ${DCRM_MW_LIBRARY_NAME}

set mw_site_name_mapping {
    {CORE unit}
    {Core unit}
    {core unit}
}

if {$synopsys_program_name == "dc_shell"} {

    set_app_var target_library ${TARGET_LIBRARY_FILES}
    set_app_var synthetic_library dw_foundation.sldb

    if {$OPTIMIZATION_FLOW == "hplp"} {
        # Enabling DesignWare minPower components may require an
        # additional DesignWare-LP license.
        #
        # set_app_var synthetic_library \
        #     "dw_minpower.sldb dw_foundation.sldb"
    }

    set_app_var link_library \
        "* $target_library $ADDITIONAL_LINK_LIB_FILES $synthetic_library"

    # To apply explicit max/min library pairs, populate
    # MIN_LIBRARY_FILES in common_setup.tcl and enable:
    #
    # foreach {max_library min_library} $MIN_LIBRARY_FILES {
    #     set_min_library $max_library -min_version $min_library
    # }

    # Set this only when Verilog library models are required for test DRC:
    #
    # set_app_var test_simulation_library <library files>

    if {[shell_is_in_topographical_mode]} {

        if {![file isdirectory $mw_design_library]} {

            create_mw_lib \
                -technology $TECH_FILE \
                -mw_reference_library $mw_reference_library \
                $mw_design_library

        } else {

            set_mw_lib_reference \
                $mw_design_library \
                -mw_reference_library $mw_reference_library
        }

        open_mw_lib $mw_design_library

        set_check_library_options -mcmm

        check_library \
            > ${REPORTS_DIR}/${DCRM_CHECK_LIBRARY_REPORT}

        # TLUPlus files are configured separately for each MCMM
        # scenario by the scenario setup file.
    }

    #############################################################################
    # Library Modifications
    #############################################################################

    if {[file exists [which ${LIBRARY_DONT_USE_FILE}]]} {
        puts "RM-Info: Sourcing script file [which ${LIBRARY_DONT_USE_FILE}]\n"
        source -echo -verbose $LIBRARY_DONT_USE_FILE
    }
}

puts "RM-Info: Completed script [info script]\n"