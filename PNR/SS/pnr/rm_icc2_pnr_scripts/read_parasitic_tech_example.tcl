puts "RM-info: Running script [info script]\n"

##########################################################################################
# Tool: IC Compiler II
# Script: read_parasitic_tech_example.tcl
# Version: N-2017.09-SP2 (February 20, 2018)
# Copyright (C) 2014-2018 Synopsys, Inc. All rights reserved.
##########################################################################################

##############################################################################################
# The following is a sample script to read two TLU+ files, 
# which you can expand to accomodate your design.
##############################################################################################

########################################
## Variables
########################################
## Parasitic tech files for read_parasitic_tech command; expand the section as needed
########################################
set parasitic1                          "28lpp_7U1x_2T8x_LB_SigRCmax_detailed" ;# name of parasitic tech model 1
set tluplus_file($parasitic1)           "$REFLIB_PATH/tech/TECH/LN28LPP_ICC_S00-V2.0.8.0/7U1x_2T8x_LB/28lpp_7U1x_2T8x_LB_SigRCmax_detailed.tlup" ;# TLU+ files to read for parasitic 1
set layer_map_file($parasitic1)         "$REFLIB_PATH/tech/TECH/LN28LPP_ICC_S00-V2.0.8.0/7U1x_2T8x_LB/28lpp_7U1x_2T8x_LB.map" ;# layer mapping file between ITF and tech for parasitic 1

set parasitic2                          "28lpp_7U1x_2T8x_LB_SigRCmin_detailed" ;# name of parasitic tech model 2
set tluplus_file($parasitic2)           "$REFLIB_PATH/tech/TECH/LN28LPP_ICC_S00-V2.0.8.0/7U1x_2T8x_LB/28lpp_7U1x_2T8x_LB_SigRCmin_detailed.tlup" ;# TLU+ files to read for parasitic 2
set layer_map_file($parasitic2)         "$REFLIB_PATH/tech/TECH/LN28LPP_ICC_S00-V2.0.8.0/7U1x_2T8x_LB/28lpp_7U1x_2T8x_LB.map" ;# layer mapping file between ITF and tech for parasitic 2

## Read parasitic files
########################################
## Read in the TLUPlus files first.
#  Later on in the corner constraints, you can then refer to these parasitic models.
foreach p [array name tluplus_file] {  
	puts "RM-info: read_parasitic_tech -tlup $tluplus_file($p) -layermap $layer_map_file($p) -name $p"
	read_parasitic_tech -tlup $tluplus_file($p) -layermap $layer_map_file($p) -name $p
}

puts "RM-info: Completed script [info script]\n"


