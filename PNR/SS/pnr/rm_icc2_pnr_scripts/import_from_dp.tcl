# Tool: IC Compiler II
# Script: import_from_dp.tcl
# Version: N-2017.09-SP2 (February 20, 2018)
# Copyright (C) 2014-2018 Synopsys, Inc. All rights reserved.
##########################################################################################

## Copy design library from ICC2 DP RM release area

if {![file exists ./${DESIGN_NAME}${LIBRARY_SUFFIX}]} {
	if {[file exists ${RELEASE_DIR_DP}/${DESIGN_NAME}${LIBRARY_SUFFIX}]} {
		puts "RM-info: Copying ${RELEASE_DIR_DP}/${DESIGN_NAME}${LIBRARY_SUFFIX} to ./"
		file copy ${RELEASE_DIR_DP}/${DESIGN_NAME}${LIBRARY_SUFFIX} ./
	} else {
		puts "RM-error: Copying ${RELEASE_DIR_DP}/${DESIGN_NAME}${LIBRARY_SUFFIX} to ./ but it doesn't exist. Exiting"
	}
} else {
	puts "RM-error: Copying ${DESIGN_NAME}${LIBRARY_SUFFIX} to ./ but it already exists. Pls correct it. Exiting"
	exit 
}	

