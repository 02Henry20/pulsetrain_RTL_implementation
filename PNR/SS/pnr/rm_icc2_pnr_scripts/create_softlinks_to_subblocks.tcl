##########################################################################################
# Tool: IC Compiler II
# Script: create_softlinks_to_subblocks.tcl
# Version: N-2017.09-SP2 (February 20, 2018)
# Copyright (C) 2014-2018 Synopsys, Inc. All rights reserved.
##########################################################################################

	## For top or intermediate level of hier designs, create soft-links to sub-blocks present in ICC2 PNR release area,

	foreach BLOCK $SUB_BLOCK_REFS {
		if {![file exists ./${BLOCK}${LIBRARY_SUFFIX}]} {
			if {[file exists ${RELEASE_DIR_PNR}/${BLOCK}${LIBRARY_SUFFIX}]} {
				puts "RM-info: Creating soft-link to ${RELEASE_DIR_PNR}/${BLOCK}${LIBRARY_SUFFIX} in ./"
				sh ln -s ${RELEASE_DIR_PNR}/${BLOCK}${LIBRARY_SUFFIX}
			} else {
				puts "RM-error: Creating soft-link to ${RELEASE_DIR_PNR}/${BLOCK}${LIBRARY_SUFFIX} in ./ but it doesn't exist. Exiting"
				exit 
			}
		} else {
			puts "RM-error: Creating soft-link to ${BLOCK}${LIBRARY_SUFFIX} in ./ but it already exists. Pls correct it. Exiting"
			exit 
		}
	}


