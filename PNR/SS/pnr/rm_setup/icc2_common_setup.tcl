puts "RM-info : Running script [info script]\n"

set_host_options -max_cores 16

##########################################################################################
# Tool: IC Compiler II
# Script: icc2_common_setup.tcl
# Version: N-2017.09-SP2 (February 20, 2018)
# Copyright (C) 2014-2018 Synopsys, Inc. All rights reserved.
##########################################################################################

##########################################################################################
## Required variables
## These variables must be correctly filled in for the flow to run properly
##########################################################################################
set DESIGN_NAME 		"TOP_PREV" ;# Name of the design to be worked on
set LIBRARY_SUFFIX		"" ;# Suffix for the design library name ; default is unspecified   
#set LIBRARY_SUFFIX		".dlib" ;# Suffix for the design library name ; default is unspecified   
set DESIGN_LIBRARY 		"${DESIGN_NAME}${LIBRARY_SUFFIX}" ;# Name of the design library; default is ${DESIGN_NAME}${LIBRARY_SUFFIX}

set REFLIB_PATH                 "/data/S28"

set MEM_PATH			"/data/S28/library/memory/batch_script/FE-Common_sec190812_0141/MemoryCompiler_FE/batch_script/bin"

set COMPRESS_LIBS               "false" ;# Save libs as compressed NDM; only used in DP.

#set REFERENCE_LIBRARY 		[list ]	;# A list of reference libraries for the design library.

set REFERENCE_LIBRARY		[list \
	$REFLIB_PATH/library/ln28lpp_gpio_1p8v_V1.00a_pkg/BE-Common_sec190321_0299/NDM/ln28lpp_gpio_1p8v_tt_1p000v_1p800v_25c_ff_1p155v_1p950v_m40c/io_gppr_cmos28lpp_t18.ndm \
	$REFLIB_PATH/library/ln28lpp_gpio_1p8v_V1.00a_pkg/BE-Common_sec190321_0299/NDM/ln28lpp_gpio_1p8v_tt_1p000v_1p800v_25c_ff_1p155v_1p950v_m40c/ln28lpp_gpio_1p8v_tt_1p000v_1p800v_25c_ff_1p155v_1p950v_m40c_frame.ndm \
	$REFLIB_PATH/library/ln28lpp_power_1p8v_7001_7002_2k_V1.00d_pkg/BE-Common_sec190621_0139/NDM/esd_gppr_cmos28lpp_t18.ndm \
	$REFLIB_PATH/library/ln28lpp_power_1p8v_7001_7002_2k_V1.00d_pkg/BE-Common_sec190621_0139/NDM/Power_IO_frame.ndm \
	$REFLIB_PATH/library/ln28lpp_sc_9t_base_rvt_c130_V1.00c_pkg/BE-Common_sec190307_0119/NDM/sc9_cmos28lpp_base_rvt_tt_nominal_max_1p000v_25c_ff_nominal_min_1p100v_m40c_sadhm/sc9_cmos28lpp_base_rvt.ndm \
	$REFLIB_PATH/library/ln28lpp_sc_9t_base_rvt_c130_V1.00c_pkg/BE-Common_sec190307_0119/NDM/sc9_cmos28lpp_base_rvt_tt_nominal_max_1p000v_25c_ff_nominal_min_1p100v_m40c_sadhm/sc9_cmos28lpp_base_rvt_tt_nominal_max_1p000v_25c_ff_nominal_min_1p100v_m40c_sadhm_frame.ndm \
	$REFLIB_PATH/library/ln28lpp_sc_9t_base_rvt_c130_V1.00c_pkg/BE-Common_sec190307_0119/NDM/sc9_cmos28lpp_base_rvt_tt_nominal_max_1p000v_25c_ff_nominal_min_1p100v_m40c_sadhm/sc9_cmos28lpp_base_rvt_tt_nominal_max_1p000v_25c_ff_nominal_min_1p100v_m40c_sadhm_physical_only.ndm \
	$MEM_PATH/cmos28lpp_rf1_hd_512x32m2/cmos28lpp_rf1_hd_512x32m2_tt_1p000v_1p000v_25c.ndm \
	$MEM_PATH/cmos28lpp_rf1_hd_512x32m2/cmos28lpp_rf1_hd_512x32m2_frame.ndm \
	$MEM_PATH/cmos28lpp_rf1_hd_1024x32m4/cmos28lpp_rf1_hd_1024x32m4_tt_1p000v_1p000v_25c.ndm \
	$MEM_PATH/cmos28lpp_rf1_hd_1024x32m4/cmos28lpp_rf1_hd_1024x32m4_frame.ndm \
]	;

#set REFERENCE_LIBRARY 		[list \
        $REFLIB_PATH/io/gpio/BE/NDM/io_synopsys/io_gppr_cmos28lpp_t18.ndm \
        $REFLIB_PATH/io/gpio/BE/NDM/io_synopsys/io_synopsys_frame.ndm \
        $REFLIB_PATH/io/power_io/BE/NDM/Power_IO_frame.ndm \
        $REFLIB_PATH/io/power_io/BE/NDM/esd_gppr_cmos28lpp_t18.ndm \
        $REFLIB_PATH/sc/BE/NDM/sc9_cmos28lpp_base_rvt.ndm \
        $REFLIB_PATH/sc/BE/NDM/base_rvt_c130_frame.ndm \
        $REFLIB_PATH/sc/BE/NDM/base_rvt_c130_physical_only.ndm \
]	;# A list of reference libraries for the design library.	
				       	;# 	for hierarchical designs using bottom-up flows: include subblock design libraries in the list;
					;# 	for hierarchical designs using ETMs: include the ETM library in the list.
					;# 		- If unpack_rm_dirs.pl is used to create dir structures for hierarchical designs, 
					;#		  in order to transition between hierarchical DP and hierarchical PNR flows properly, 
					;#		  absolute paths are a requirement.
					;#	for library assembly flow (LIBRARY_ASSEMBLY_FLOW set to true below): 
					;#		- specify the list of physical source files to be used for library assembly during create_lib


set IMPORT			"../../netlist"
set VERILOG_NETLIST_FILES	"${IMPORT}/${DESIGN_NAME}.mapped.v"	;# Verilog netlist files;
#set IMPORT			"/home/smkcow/QnA/digital/example_smkcow_DC_ICC2/fifo/PNR/netlist"
#set VERILOG_NETLIST_FILES	"${IMPORT}/${DESIGN_NAME}_gate.v"	;# Verilog netlist files;
					;# 	for DP: required
					;# 	for PNR: required if INIT_DESIGN_INPUT is ASCII in icc2_pnr_setup.tcl; not required for DC_ASCII or DP_RM_NDM

#set UPF_FILE 			""	;# A UPF file
set UPF_FILE 			"${IMPORT}/${DESIGN_NAME}.upf"	;# A UPF file
					;# 	for DP: required
					;# 	for PNR: required if INIT_DESIGN_INPUT is ASCII in icc2_pnr_setup.tcl; not required for DC_ASCII or DP_RM_NDM
                                        ;#          for hierarchical designs using ETMs, load the block upf file
                                        ;#          for each sub-block linked to ETM, include the following line in the UPF_FILE 
                			;#              load_upf block.upf -scope block_instance_name


set TCL_PARASITIC_SETUP_FILE	"./rm_icc2_pnr_scripts/read_parasitic_tech_example.tcl"	;# Specify a Tcl script to read in your TLU+ files by using the read_parasitic_tech command;
					;# refer to the example in read_parasitic_tech_example.tcl 

#set TCL_MCMM_SETUP_FILE		"/home/smkcow/QnA/digital/example_smkcow_DC_ICC2/fifo/PNR/SS/pnr/wscript/top.tcl"	;# Specify a Tcl script to create your corners, modes, scenarios and load respective constraints;
set TCL_MCMM_SETUP_FILE		"../../netlist/ICC2_files/${DESIGN_NAME}.MCMM/top.tcl"	;# Specify a Tcl script to create your corners, modes, scenarios and load respective constraints;
					;# two examples are provided in rm_icc2_pnr_scripts: 
					;# mcmm_example.explicit.tcl: provide mode, corner, and scenario constraints; create modes, corners, 
					;# and scenarios; source mode, corner, and scenario constraints, respectively 
					;# mcmm_example.auto_expanded.tcl: provide constraints for the scenarios; create modes, corners, 
					;# and scenarios; source scenario constraints which are then expanded to associated modes and corners
					;# 	for DP: required
					;# 	for PNR: required if INIT_DESIGN_INPUT is ASCII in icc2_pnr_setup.tcl; not required for DC_ASCII or DP_RM_NDM

set TECH_FILE 			"$REFLIB_PATH/tech/TECH/LN28LPP_ICC_S00-V2.0.8.0/7U1x_2T8x_LB/sc9_cmos28lpp_7U1x_2T8x_LB.icc2.tf" 	;# A technology file; TECH_FILE and TECH_LIB are mutually exclusive ways to specify technology information; 
					;# TECH_FILE is recommended, although TECH_LIB is also supported in ICC2 RM. 
set TECH_LIB			""	;# Specify the reference library to be used as a dedicated technology library;
                        		;# as a best practice, please list it as the first library in the REFERENCE_LIBRARY list 
#set TECH_LIB_INCLUDES_TECH_SETUP_INFO true 
set TECH_LIB_INCLUDES_TECH_SETUP_INFO false
					;# Indicate whether TECH_LIB contains technology setup information such as routing layer direction, offset, 
					;# site default, and site symmetry, etc. TECH_LIB may contain this information if loaded during library prep.
					;# true|false; this variable is associated with TECH_LIB. 
set TCL_TECH_SETUP_FILE		"tech_setup.tcl"
					;# Specify a TCL script for setting routing layer direction, offset, site default, and site symmetry list, etc.
					;# tech_setup.tcl is the default. Use it as a template or provide your own script.
					;# This script will only get sourced if the following conditions are met: 
					;# (1) TECH_FILE is specified (2) TECH_LIB is specified && TECH_LIB_INCLUDES_TECH_SETUP_INFO is false 
#set ROUTING_LAYER_DIRECTION_OFFSET_LIST "" 
set ROUTING_LAYER_DIRECTION_OFFSET_LIST "{M1 vertical} {M2 horizontal} {M3 vertical} {M4 horizontal} {M5 vertical} {M6 horizontal} {M7 vertical} {IA horizontal} {IB vertical} {LB horizontal}" 
					;# Specify the routing layers as well as their direction and offset in a list of space delimited pairs;
					;# This variable should be defined for all metal routing layers in technology file;
					;# Syntax is "{metal_layer_1 direction offset} {metal_layer_2 direction offset} ...";
					;# It is required to at least specify metal layers and directions. Offsets are optional. 
					;# Example1 is with offsets specified: "{M1 vertical 0.2} {M2 horizontal 0.0} {M3 vertical 0.2}"
					;# Example2 is without offsets specified: "{M1 vertical} {M2 horizontal} {M3 vertical}"

##########################################################################################
## Optional variables
## Specify these variables if the corresponding functions are desired 
##########################################################################################
set DESIGN_LIBRARY_SCALE_FACTOR	""	;# Specify the length precision for the library. Length precision for the design
					;# library and its ref libraries must be identical. Tool default is 10000, which
					;# implies one unit is one Angstrom or 0.1nm.

set UPF_UPDATE_SUPPLY_SET_FILE	""	;# A UPF file to resolve UPF supply sets

set DEF_FLOORPLAN_FILES		""	;# DEF files which contain the floorplan information;
					;# 	for DP: not required
					;# 	for PNR: required if INIT_DESIGN_INPUT = ASCII in icc2_pnr_setup.tcl and neither TCL_FLOORPLAN_FILE or 
					;#		 initialize_floorplan is used; DEF_FLOORPLAN_FILES and TCL_FLOORPLAN_FILE are mutually exclusive;
					;# 	         not required if INIT_DESIGN_INPUT = DC_ASCII or DP_RM_NDM

set DEF_SCAN_FILE		""	;# A scan DEF file for scan chain information;
					;# 	for PNR: not required if INIT_DESIGN_INPUT = DC_ASCII or DP_RM_NDM, as SCANDEF is expected to be loaded already

set DEF_SITE_NAME_PAIRS		{}	;# A list of site name pairs for read_def -convert; 
					;# specify site name pairs with from_site first followed by to_site;
					;# Example: set DEF_SITE_NAME_PAIRS {{from_site_1 to_site_1} {from_site_2 to_site_2}} 	

set SITE_DEFAULT	""		;# Specify the default site name if there are multiple site defs in the technology file;
					;# this is to be used by initialize_floorplan command; example: set SITE_DEFAULT "unit";
					;# this is applied in the tech_setup.tcl script 
set SITE_SYMMETRY_LIST	""		;# Specify a list of site def and its symmetry value; 
					;# this is to be used by read_def or initialize_floorplan command to control the site symmetry;
					;# example: set SITE_SYMMETRY_LIST "{unit Y} {unit1 Y}"; this is applied in the tech_setup.tcl script 

set MIN_ROUTING_LAYER		"M1"	;# Min routing layer name; normally should be specified; otherwise tool can use all metal layers
set MAX_ROUTING_LAYER		"M7"	;# Max routing layer name; normally should be specified; otherwise tool can use all metal layers

set LIBRARY_ASSEMBLY_FLOW	false	;# Set it to true enables library assembly flow which calls the library manager under the hood to generate .nlibs, 
					;# save them to disk, and automatically link them to the design.
					;# Requires LINK_LIBRARY to be specified with .db files and REFERENCE_LIBRARY to be specified with physical
					;# source files for the library assembly flow. Also search_path (in icc2_pnr_setup.tcl) should include paths 
					;# to these .db and physical source files.

#set LINK_LIBRARY		""	;# Specify .db files;
set LINK_LIBRARY                [ list \
	$REFLIB_PATH/library/ln28lpp_sc_9t_base_rvt_c130_V1.00c_pkg/FE-Common_sec190802_0203/LIBERTY/sc9_cmos28lpp_base_rvt_tt_nominal_max_1p000v_25c.db	\
	$REFLIB_PATH/library/ln28lpp_sc_9t_base_rvt_c130_V1.00c_pkg/FE-Common_sec190802_0203/LIBERTY/sc9_cmos28lpp_base_rvt_ff_nominal_min_1p100v_m40c_sadhm.db	\
	$REFLIB_PATH/library/ln28lpp_gpio_1p8v_V1.00a_pkg/FE-Common_sec190321_0300/LIBERTY/synopsys/io_gppr_cmos28lpp_t18_tt_1p000v_1p800v_25c.db	\
	$REFLIB_PATH/library/ln28lpp_gpio_1p8v_V1.00a_pkg/FE-Common_sec190321_0300/LIBERTY/synopsys/io_gppr_cmos28lpp_t18_ff_1p155v_1p950v_m40c.db	\
	$REFLIB_PATH/library/ln28lpp_power_1p8v_7001_7002_2k_V1.00d_pkg/FE-Common_sec190621_0140/LIBERTY/synopsys/esd_gppr_cmos28lpp_t18_tt_1p000v_1p800v_25c.db \
	$REFLIB_PATH/library/ln28lpp_power_1p8v_7001_7002_2k_V1.00d_pkg/FE-Common_sec190621_0140/LIBERTY/synopsys/esd_gppr_cmos28lpp_t18_ff_1p100v_1p980v_m40c.db \
	$REFLIB_PATH/library/memory/batch_script/FE-Common_sec190812_0141/MemoryCompiler_FE/batch_script/bin/cmos28lpp_rf1_hd_512x32m2/cmos28lpp_rf1_hd_512x32m2_tt_1p000v_1p000v_25c.db \
	$REFLIB_PATH/library/memory/batch_script/FE-Common_sec190812_0141/MemoryCompiler_FE/batch_script/bin/cmos28lpp_rf1_hd_1024x32m4/cmos28lpp_rf1_hd_1024x32m4_tt_1p000v_1p000v_25c.db \
        ]       ;# Specify .db files;
#        scmetro_cmos10lp_rvt_ff_1p32v_125c_sadhm.db  \
#        scmetro_cmos10lp_rvt_tt_1p2v_25c.db \
#        scmetro_cmos10lp_rvt_ss_1p08v_m40c_sadhm.db \
#        ss65lp3p3v_typ_120_330_p025.db  \
					;# 	for running VC-LP (vc_lp.tcl) and Formality (fm.tcl): required
					;# 	for ICC-II without LIBRARY_ASSEMBLY_FLOW enabled: not required
					;#	for ICC-II with LIBRARY_ASSEMBLY_FLOW enabled: required; 
					;#      	- the .db files specified will be used for the library assembly under the hood during create_lib 

##########################################################################################
## Variables related to flow controls of flat PNR, hierarchical PNR and transition with DP
##########################################################################################
set DESIGN_STYLE		"flat"	;# Specify the design style; flat|hier; default is flat; 
					;# specify flat for a totally flat flow (flat PNR for short) and 
					;# specify hier for a hierarchical flow (hier PNR for short);
					;# 	for hier PNR: required and auto set if unpack_rm_dirs.pl is used; (see README.unpack_rm_dirs.txt for details)
					;# 	for flat PNR: this should set to flat (default)
					;#	for DP: not used 

set PHYSICAL_HIERARCHY_LEVEL	"" 	;# Specify the current level of hierarchy for the hierarchical PNR flow; top|intermediate|bottom;
					;# 	for hier PNR: required and auto set if unpack_rm_dirs.pl is used; (see README.unpack_rm_dirs.txt for details)
					;# 	for flat PNR and for DP: not used.

set RELEASE_DIR_DP		"../dp/write_data_dir" 	;# Specify the release directory of DP RM; 
					;# this is where init_design.tcl of PNR flow gets DP RM released libraries; 
					;# 	for hier PNR: required and auto set if unpack_rm_dirs.pl is used; (see README.unpack_rm_dirs.txt for details)
					;# 	for flat PNR: required if INIT_DESIGN_INPUT = DP_RM_NDM, as init_design.tcl needs to know where DP RM libraries are
					;#	for DP: not used 
set RELEASE_LABEL_NAME_DP 	"for_pnr"	
					;# Specify the label name of the block in the DP RM released library;
					;# this is the label name which init_design.tcl of PNR flow will open. 

set RELEASE_DIR_PNR		"../../release/pnr" 	;# Specify the release directory of PNR RM; 
					;# this is where the init_design.tcl of hierarchical PNR flow gets the sub-block libraries;	
					;# 	for hier PNR: required and auto set if unpack_rm_dirs.pl is used; (see README.unpack_rm_dirs.txt for details)
					;# 	for flat PNR and for DP: not used.

##########################################################################################
## Variables related to In-design PrimeRail
##########################################################################################
set LIB_DIR                     "/data/S28"

#set PRIMERAIL_SEARCH_PATH      ""      ;# Required.  Additional search path to be added to the default search path.
set PRIMERAIL_SEARCH_PATH       ". \
$LIB_DIR/library/ln28lpp_sc_9t_base_rvt_c130_V1.00c_pkg/FE-Common_sec190802_0203/LIBERTY \
$LIB_DIR/library/ln28lpp_gpio_1p8v_V1.00a_pkg/FE-Common_sec190321_0300/LIBERTY/synopsys \
../../../MEM \
"

#set PRIMERAIL_MAP_FILE         ""      ;# Required.  Mapping file for TLUplus.
#set PRIMERAIL_TLUPLUS_FILE     ""      ;# Required. TLUplus file for extraction.

set PRIMERAIL_MAP_FILE          "$LIB_DIR/tech/TECH/LN28LPP_ICC_S00-V2.0.8.0/7U1x_2T8x_LB/28lpp_7U1x_2T8x_LB.map"        ;# Required.  Mapping file for TLUplus.
set PRIMERAIL_TLUPLUS_FILE      "$LIB_DIR/tech/TECH/LN28LPP_ICC_S00-V2.0.8.0/7U1x_2T8x_LB/28lpp_7U1x_2T8x_LB_SigRCmax_detailed.tlup"          ;# Required. TLUplus file for extraction.


set PRIMERAIL_PARASITIC_CORNER	"current_corner"   ; # set corner for parasitic extraction. Default corner is "current_corner"

#smkcow DVDD, DVSS Disable
#set PRIMERAIL_POWER_NET1	""	;# Required.  Power net 1
set PRIMERAIL_POWER_NET1	"VDD"	;# Required.  Power net 1
set PRIMERAIL_POWER_NET2	"DVDD"	;# Power net 2
set PRIMERAIL_POWER_NET2	""	;# Power net 2
set PRIMERAIL_POWER_NET3	""	;# Power net 3
#set PRIMERAIL_GROUND_NET1	""	;# Required.  Ground net 1
set PRIMERAIL_GROUND_NET1	"VSS"	;# Required.  Ground net 1
set PRIMERAIL_GROUND_NET2	"DVSS"	;# Ground net 2
set PRIMERAIL_GROUND_NET2	""	;# Ground net 2
set PRIMERAIL_GROUND_NET3	""	;# Ground net 3

puts "RM-info : Completed script [info script]\n"

