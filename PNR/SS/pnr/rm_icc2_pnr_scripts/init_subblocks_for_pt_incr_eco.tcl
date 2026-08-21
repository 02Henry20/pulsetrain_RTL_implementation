##########################################################################################
# Tool: IC Compiler II
# Script: load_block_budgets.tcl
# Version: N-2017.09-SP2 (February 20, 2018)
# Copyright (C) 2014-2018 Synopsys, Inc. All rights reserved.
##########################################################################################

#Send jobID back to parent for tracking purposes
if {[info exist env(JOB_ID)]} {
	puts "Block: $block_refname JobID: $env(JOB_ID) - START"
}

open_lib $block_libfilename
if {$USE_RM_BLOCK_NAME_AS_LABEL} {
        copy_block -from ${block_refname} -to ${block_refname_no_label}/${PT_ECO_INCREMENTAL_1_BLOCK_NAME}
        current_block ${block_refname_no_label}/${PT_ECO_INCREMENTAL_1_BLOCK_NAME}
} else {
        copy_block -from ${block_refname} -to ${PT_ECO_INCREMENTAL_1_BLOCK_NAME}
        current_block ${PT_ECO_INCREMENTAL_1_BLOCK_NAME}
}

link_block

record_signoff_eco_changes -init -def
write_lef -design ${block_refname_no_label}/${PT_ECO_INCREMENTAL_1_BLOCK_NAME} ${block_refname_no_label}.lef

close_lib -save
puts "Block: $block_refname - FINISHED"

