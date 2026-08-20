##########################################################################################
# Tool: IC Compiler II
# Script: init_design.tcl
# Version: N-2017.09-SP2 (February 20, 2018)
# Copyright (C) 2014-2018 Synopsys, Inc. All rights reserved.
##########################################################################################

source -echo ./rm_setup/icc2_pnr_setup.tcl 

########################################################################
## Design creation (depends on value of INIT_DESIGN_INPUT)
#  For ASCII and DC_ASCII : create design library and create block from input files
#  For DP_RM_NDM : Copy, open design library and open block	
########################################################################
if {$INIT_DESIGN_INPUT == "DP_RM_NDM"} {
	## Copy designs from ICC2-DP-RM release area
	puts "RM-info: Sourcing [which import_from_dp.tcl]"
	source -e import_from_dp.tcl

        if {$DESIGN_STYLE == "flat"} {
                ## For totally flat designs, open the design copied from ICC2 DP RM release area
                open_lib ${DESIGN_NAME}${LIBRARY_SUFFIX}
                open_block ${DESIGN_NAME}/${RELEASE_LABEL_NAME_DP}
        
        } elseif {$DESIGN_STYLE == "hier"} {
                if {$PHYSICAL_HIERARCHY_LEVEL == "bottom"} {
                	## For bottom level of hier designs, open the design copied from ICC2 DP RM release area
                	open_lib ${DESIGN_NAME}${LIBRARY_SUFFIX}
                	open_block ${DESIGN_NAME}/${RELEASE_LABEL_NAME_DP}
                } elseif {$PHYSICAL_HIERARCHY_LEVEL == "top" || $PHYSICAL_HIERARCHY_LEVEL == "intermediate"} {
			## For top or intermediate level of hier designs, link to sub-blocks in PNR RM release area
			puts "RM-info: Sourcing [which create_softlinks_to_subblocks.tcl]"
			source -e create_softlinks_to_subblocks.tcl

                	## For top or intermediate level of hier designs, open the copied design and do change_abstract
                	open_lib ${DESIGN_NAME}${LIBRARY_SUFFIX}
                	open_block ${DESIGN_NAME}/${RELEASE_LABEL_NAME_DP}
                	## Swap abstracts created after DesignPlanning to abstracts specified for place_opt
                	if {$USE_ABSTRACTS_FOR_BLOCKS != ""} {
                	      puts "RM-info: Swap abstracts created after ICC2-DP-RM with $BLOCK_ABSTRACT_FOR_PLACE_OPT abstracts for all blocks."
                	      change_abstract -view abstract -references $USE_ABSTRACTS_FOR_BLOCKS -label $BLOCK_ABSTRACT_FOR_PLACE_OPT
			     ##smkcow example
                	     # change_abstract -view abstract -references {BLENDER_0 BLENDER_1 SDRAM_TOP}-label route_opt
                	      report_abstracts
                	}

			## Set the editability of the sub-blocks to false
                        set_editability -blocks [get_blocks -hierarchical] -value false
                        report_editability -blocks [get_blocks -hierarchical]

                        ## Ignore the sub-blocks internal timing paths
                        if {$USE_ABSTRACTS_FOR_BLOCKS != ""} {
                              set_timing_paths_disabled_blocks  -all_sub_blocks
                        }
                }
        }
}

# below lines are executed  :: smkcow
if {$INIT_DESIGN_INPUT == "ASCII" || $INIT_DESIGN_INPUT == "DC_ASCII"} {
	if {[file exists $DESIGN_LIBRARY]} {
		file delete -force $DESIGN_LIBRARY
	}
	
	set create_lib_cmd "create_lib $DESIGN_LIBRARY"

	if {[file exists [which $TECH_FILE]]} {
		lappend create_lib_cmd -tech $TECH_FILE ;# recommended
	} elseif {$TECH_LIB != ""} {
		lappend create_lib_cmd -use_technology_lib $TECH_LIB ;# optional
	}

	if {$DESIGN_LIBRARY_SCALE_FACTOR != ""} {
		lappend create_lib_cmd -scale_factor $DESIGN_LIBRARY_SCALE_FACTOR
	}

	set_app_options -name lib.setting.on_disk_operation -value true ;# default false and global-scoped

	## Library assembly flow: calls library manager under the hood to generate .nlibs, store, and link them
	#  - To enable it, in icc2_common_setup.tcl, set LIBRARY_ASSEMBLY_FLOW to true,
	#    specify LINK_LIBRARY with .db files, and specify REFERENCE_LIBRARY with physical source files. 
	#    In icc2_pnr_setup.tcl, make sure search_path includes all relevant locations. 
	if {$LIBRARY_ASSEMBLY_FLOW} {
		set link_library $LINK_LIBRARY
	}

	lappend create_lib_cmd -ref_libs $REFERENCE_LIBRARY

	puts "RM-info: $create_lib_cmd"
	eval ${create_lib_cmd}
}

redirect -file ${REPORTS_DIR}/${INIT_DESIGN_BLOCK_NAME}.report_ref_libs {report_ref_libs}


# INIT_DESIGN_INPUT : ASCII, DESIGN_STYLE : flat
# below lines are executed : smkcow
########################################################################
## INIT_DESIGN_INPUT = ASCII : reads ASCII verilog and link_block, etc
########################################################################
if {$INIT_DESIGN_INPUT == "ASCII"} {
        if {$DESIGN_STYLE == "flat"} {
                read_verilog -top $DESIGN_NAME $VERILOG_NETLIST_FILES
                current_block $DESIGN_NAME
                link_block
                save_lib
        } elseif {$DESIGN_STYLE == "hier"} {
                if {$PHYSICAL_HIERARCHY_LEVEL == "bottom"} {
                       	read_verilog -top $DESIGN_NAME $VERILOG_NETLIST_FILES
                       	current_block $DESIGN_NAME
                       	link_block
                       	save_lib
                } elseif {$PHYSICAL_HIERARCHY_LEVEL == "top" || $PHYSICAL_HIERARCHY_LEVEL == "intermediate"} {
			## For top or intermediate level of hier designs, add sub-block design libraries to the reference libraries list
                        foreach BLOCK $SUB_BLOCK_REFS {
                                if {[file exists ${RELEASE_DIR_PNR}/${BLOCK}${LIBRARY_SUFFIX}]} {
                                   	puts "RM-info: Adding ${RELEASE_DIR_PNR}/${BLOCK}${LIBRARY_SUFFIX} to the reference library list"
                                   	set_ref_libs -add ${RELEASE_DIR_PNR}/${BLOCK}${LIBRARY_SUFFIX}
					## smkcow
                                   	#set_ref_libs -add "MYBLOCKS/A.dlib MYBLOCKS/B.dlib ..."
                                } else {
                                   	puts "RM-error: Adding ${RELEASE_DIR_PNR}/${BLOCK}${LIBRARY_SUFFIX} to the reference library list but it doesn't exist. Exiting"
				   	exit 
                                }
                        }

                       ## Specify the label to be used for the created design
                       ## Specifying the following application option will enable the tool to link to the sub-blocks of the same label
                       set_app_options -name file.verilog.default_user_label -value $INIT_DESIGN_BLOCK_NAME

                       read_verilog -top ${DESIGN_NAME} $VERILOG_NETLIST_FILES
                       current_block ${DESIGN_NAME}/${INIT_DESIGN_BLOCK_NAME}
                       link_block
                       save_lib

                       ## In the link performed above, the tool tries to link to sub-blocks with ${INIT_DESIGN_BLOCK_NAME} label
		       ## In the following step, change_abstract is used to link to the sub-blocks specified for place_opt step
                        if {$USE_ABSTRACTS_FOR_BLOCKS != ""} {
                              puts "RM-info: Swap abstracts to $BLOCK_ABSTRACT_FOR_PLACE_OPT abstracts for all blocks."
                              change_abstract -view abstract -references $USE_ABSTRACTS_FOR_BLOCKS -label $BLOCK_ABSTRACT_FOR_PLACE_OPT
                              report_abstracts
                        }

		}
	}

########################################################################
## INIT_DESIGN_INPUT = ASCII : reads UPF  
########################################################################
	####################################
	## Load and commit UPF file
	####################################
	if {[file exists [which $UPF_FILE]]} {
		load_upf $UPF_FILE

		## Read the supply set file
		if {[file exists [which $UPF_UPDATE_SUPPLY_SET_FILE]]} {
			load_upf $UPF_UPDATE_SUPPLY_SET_FILE
		} elseif {$UPF_UPDATE_SUPPLY_SET_FILE != ""} {
			puts "RM-error: UPF_UPDATE_SUPPLY_SET_FILE($UPF_UPDATE_SUPPLY_SET_FILE) is invalid. Please correct it."
		}
		commit_upf
		associate_mv_cells -all
	} elseif {$UPF_FILE != ""} {
		puts "RM-error : UPF file($UPF_FILE) is invalid. Please correct it."
	}
########################################################################
## INIT_DESIGN_INPUT = ASCII : reads parasitics and MCMM constraints  
########################################################################
	####################################
	## Timing constraints
	####################################
	## Specify a Tcl script to read in your TLU+ files by using the read_parasitic_tech command;
	#  refer to the example in read_parasitic_tech_example.tcl

# below lines are executed : smkcow
	if {[file exists [which $TCL_PARASITIC_SETUP_FILE]]} {
		puts "RM-info: Sourcing [which $TCL_PARASITIC_SETUP_FILE]"
		source -echo $TCL_PARASITIC_SETUP_FILE
	} elseif {$TCL_PARASITIC_SETUP_FILE != ""} {
		puts "RM-error : TCL_PARASITIC_SETUP_FILE($TCL_PARASITIC_SETUP_FILE) is invalid. Please correct it."
	}

	## Specify a Tcl script to create your corners, modes, scenarios and load respective constraints;
	#  Two examples are provided in rm_icc2_pnr_scripts: 
	# 	- mcmm_example.explicit.tcl: provide mode, corner, and scenario constraints; create modes, corners, 
	# 	  and scenarios; source mode, corner, and scenario constraints, respectively 
	# 	- mcmm_example.auto_expanded.tcl: provide constraints for the scenarios; create modes, corners, 
	# 	  and scenarios; source scenario constraints which are then expanded to associated modes and corners


########################################################################
## TCL_MCMM_SETUP_FILE :: smkcow
########################################################################
# below lines are should be sourced :: smkcow
# First, there is no TCL_MCMM_SETUP_FILE so make TCL_MCMM_FILE_FILE in icc2 
        # make wscript folder !!!  and define top.tcl file as TCL_MCMM_SETUP_FILE
        # If Erors, do below first
#####################################################################################
        # Users do
#       create_mode mode_norm
#       create_corner OC_rvt_ss_1p08v_125c
#       create_corner OC_rvt_ff_1p32v_m40c
#       create_scenario -name mode_norm.OC_rvt_ss_1p08v_125c.RC_MAX -mode mode_norm -corner OC_rvt_ss_1p08v_125c
#       create_scenario -name mode_norm.OC_rvt_ff_1p32v_m40c.RC_MIN -mode mode_norm -corner OC_rvt_ff_1p32v_m40c
#       current_scenario mode_norm.OC_rvt_ff_1p32v_m40c.RC_MIN
#       source /home/smkcow/QnA/digital/example_smkcow_DC_ICC2/fifo/PNR/netlist/fifo.mode_norm.OC_rvt_ff_1p32v_m40c.RC_MIN.sdc
#       current_scenario mode_norm.OC_rvt_ss_1p08v_125c.RC_MAX
#       source /home/smkcow/QnA/digital/example_smkcow_DC_ICC2/fifo/PNR/netlist/fifo.mode_norm.OC_rvt_ss_1p08v_125c.RC_MAX.sdc
#       write_script

# After write_script
# 1. check wscript folder and open the top.tcl file
# 2. control set_scenario_status command :: setup true hold false and so on
# 3. Disable above lines and file common_setup.tcl : define TCL_MCMM_SETUP_FILE variable ==> ./wscript
# 4. current scenario is for setup timing, but after cts, switch current scenario to ff and RC_MIN scenario and -hold true
#####################################################################################

	if {[file exists [which $TCL_MCMM_SETUP_FILE]]} {
		puts "RM-info: Sourcing [which $TCL_MCMM_SETUP_FILE]"
		source -echo $TCL_MCMM_SETUP_FILE
	} elseif {$TCL_MCMM_SETUP_FILE != ""} {
		puts "RM-error : TCL_MCMM_SETUP_FILE($TCL_MCMM_SETUP_FILE) is invalid. Please correct it."
	}
     
        ## Following lines are applicable for designs with physical hierarchy
        # Ignore the sub-blocks internal timing paths
        if {$DESIGN_STYLE == "hier" && $PHYSICAL_HIERARCHY_LEVEL != "bottom"} {
            set_timing_paths_disabled_blocks  -all_sub_blocks
        }

########################################################################
## INIT_DESIGN_INPUT = ASCII : floorplanning
########################################################################
	####################################
	## Floorplanning : technology setup 
	####################################
	## Technology setup includes routing layer direction, offset, site default, and site symmetry
	#  - If TECH_FILE is used, technology setup is required 
	#  - If TECH_LIB is used and it does not contain the technology setup, then it is required
	#  Specify your technology setup script through TCL_TECH_SETUP_FILE. RM default is tech_setup.tcl.
	if {$TECH_FILE != "" || ($TECH_LIB != "" && !$TECH_LIB_INCLUDES_TECH_SETUP_INFO)} {
		if {[file exists [which $TCL_TECH_SETUP_FILE]]} {
			puts "RM-info: Sourcing [which $TCL_TECH_SETUP_FILE]"
			source -e $TCL_TECH_SETUP_FILE
		} elseif {$TCL_TECH_SETUP_FILE != ""} {
			puts "RM-error : TCL_TECH_SETUP_FILE($TCL_TECH_SETUP_FILE) is invalid. Please correct it."
		}
	}

	####################################
	## Floorplanning : from DEF 
	####################################
	## Floorplanning by reading $DEF_FLOORPLAN_FILES (supports multiple DEF files)
	#  Script first checks if all the specified DEF files are valid, if not, read_def is skipped
	if {$DEF_FLOORPLAN_FILES != ""} {
		set RM_DEF_FLOORPLAN_FILE_is_not_found FALSE
		foreach def_file $DEF_FLOORPLAN_FILES {
	      		if {![file exists [which $def_file]]} {
	      			puts "RM-error : DEF floorplan file ($def_file) is invalid."
	      			set RM_DEF_FLOORPLAN_FILE_is_not_found TRUE
	      		}
		}
	
	      	if {!$RM_DEF_FLOORPLAN_FILE_is_not_found} {
	      		set read_def_cmd "read_def -add_def_only_objects cells [list $DEF_FLOORPLAN_FILES]"
	      		if {$DEF_SITE_NAME_PAIRS != ""} {lappend read_def_cmd -convert $DEF_SITE_NAME_PAIRS}
	      		puts "RM-info: Creating floorplan from DEF file DEF_FLOORPLAN_FILES ($DEF_FLOORPLAN_FILES)"
			puts "RM-info: $read_def_cmd"
			eval ${read_def_cmd}
			redirect -var x {catch {resolve_pg_nets}} ;# workaround in case resolve_pg_nets returns warning that causes conditional to exit unexpectedly 
			puts $x
			if {[regexp ".*NDMUI-096.*" $x]} {
				puts "RM-error: UPF may have an issue. Please review and correct it."
			}
	      	} else {
	      		puts "RM-error : At least one of the DEF_FLOORPLAN_FILES specified is invalid. Pls correct it."
	      		puts "RM-info: Skipped reading of DEF_FLOORPLAN_FILES"
	      	}

	####################################
	## Floorplanning : from write_floorplan 
	####################################
	## Floorplanning by reading the write_floorplan generated TCL file, $TCL_FLOORPLAN_FILE
	} elseif {$TCL_FLOORPLAN_FILE != ""} {
		set RM_TCL_FLOORPLAN_FILE_is_not_found FALSE
		if {[file exists [which $TCL_FLOORPLAN_FILE]]} {
			puts "RM-info: creating floorplan from TCL_FLOORPLAN_FILE ($TCL_FLOORPLAN_FILE)"
			source $TCL_FLOORPLAN_FILE
		} else {
			puts "RM-error : TCL_FLOORPLAN_FILE($TCL_FLOORPLAN_FILE) is invalid. Please correct it."
			set RM_TCL_FLOORPLAN_FILE_is_not_found TRUE
		}

	####################################
	## Floorplanning : initialize_floorplan
	#################################### 
# modified by smkcow
	## Perform initialize_floorplan if neither DEF_FLOORPLAN_FILES nor TCL_FLOORPLAN_FILE is specified
	} else {
	      	puts "RM-info: creating floorplan using initialize_floorplan"
		save_block -as design_setup

		initialize_floorplan -control_type die -side_length {3959 3959} -core_offset {300 300 300 300}

#		source -echo $TCL_BOND_CONSTRAINTS_FILE

		puts "RM-info : Loading TCL_PAD_CONSTRAINTS_FILE file ($TCL_PAD_CONSTRAINTS_FILE)"
		source -echo $TCL_PAD_CONSTRAINTS_FILE

		puts "RM-info : running place_io"
		place_io
		create_io_filler_cells -reference_cells {PFILL10_18_18_NT_DR PFILL5_18_18_NT_DR PFILL2_18_18_NT_DR PFILL1NC_18_18_NT_DR}

		
		move_object [get_cell top_core_0/memset_0/MEM_0/mem_inst_0]  -rotate_by CW90 
		move_object [get_cell top_core_0/memset_0/MEM_1/mem_inst_0]  -rotate_by CW90 
		move_object [get_cell top_core_0/memset_0/MEM_2/mem_inst_0]  -rotate_by CW90 
		move_object [get_cell top_core_0/memset_0/MEM_3/mem_inst_0]  -rotate_by CW90 
		move_object [get_cell top_core_0/memset_0/MEM_4/mem_inst_0]  -rotate_by CW90 
		move_object [get_cell top_core_0/memset_0/MEM_5/mem_inst_0]  -rotate_by CW90 
		move_object [get_cell top_core_0/memset_0/MEM_6/mem_inst_0]  -rotate_by CW90 
		move_object [get_cell top_core_0/memset_0/MEM_7/mem_inst_0]  -rotate_by CW90 
		move_object [get_cell top_core_0/memset_0/MEM_8/mem_inst_0]  -rotate_by CW90 
		move_object [get_cell top_core_0/memset_0/MEM_9/mem_inst_0]  -rotate_by CW90 
		move_object [get_cell top_core_0/memset_0/MEM_10/mem_inst_0] -rotate_by CW90 
		move_object [get_cell top_core_0/memset_0/MEM_11/mem_inst_0] -rotate_by CW90 
		move_object [get_cell top_core_0/memset_0/MEM_12/mem_inst_0] -rotate_by CW90 
		move_object [get_cell top_core_0/memset_0/MEM_13/mem_inst_0] -rotate_by CW90 
		move_object [get_cell top_core_0/memset_0/MEM_14/mem_inst_0] -rotate_by CW90 
		move_object [get_cell top_core_0/memset_0/MEM_15/mem_inst_0] -rotate_by CW90 

		move_object [get_cell top_core_0/memset_0/MEM_16/mem_inst_0] -rotate_by CW90 
		move_object [get_cell top_core_0/memset_0/MEM_17/mem_inst_0] -rotate_by CW90 
		move_object [get_cell top_core_0/memset_0/MEM_18/mem_inst_0] -rotate_by CW90 
		move_object [get_cell top_core_0/memset_0/MEM_19/mem_inst_0] -rotate_by CW90 
		move_object [get_cell top_core_0/memset_0/MEM_20/mem_inst_0] -rotate_by CW90 
		move_object [get_cell top_core_0/memset_0/MEM_21/mem_inst_0] -rotate_by CW90 
		move_object [get_cell top_core_0/memset_0/MEM_22/mem_inst_0] -rotate_by CW90 
		move_object [get_cell top_core_0/memset_0/MEM_23/mem_inst_0] -rotate_by CW90 
		move_object [get_cell top_core_0/memset_0/MEM_24/mem_inst_0] -rotate_by CW90 
		move_object [get_cell top_core_0/memset_0/MEM_25/mem_inst_0] -rotate_by CW90 
		move_object [get_cell top_core_0/memset_0/MEM_26/mem_inst_0] -rotate_by CW90 
		move_object [get_cell top_core_0/memset_0/MEM_27/mem_inst_0] -rotate_by CW90 
		move_object [get_cell top_core_0/memset_0/MEM_28/mem_inst_0] -rotate_by CW90 
		move_object [get_cell top_core_0/memset_0/MEM_29/mem_inst_0] -rotate_by CW90 
		move_object [get_cell top_core_0/memset_0/MEM_30/mem_inst_0] -rotate_by CW90 
		move_object [get_cell top_core_0/memset_0/MEM_31/mem_inst_0] -rotate_by CW90 
                                            
		move_object [get_cell top_core_0/memset_0/MEM_32/mem_inst_0] -rotate_by CW90   
		move_object [get_cell top_core_0/memset_0/MEM_33/mem_inst_0] -rotate_by CW90   
		move_object [get_cell top_core_0/memset_0/MEM_34/mem_inst_0] -rotate_by CW90   
		move_object [get_cell top_core_0/memset_0/MEM_35/mem_inst_0] -rotate_by CW90   
		move_object [get_cell top_core_0/memset_0/MEM_36/mem_inst_0] -rotate_by CW90   
		move_object [get_cell top_core_0/memset_0/MEM_37/mem_inst_0] -rotate_by CW90   
		move_object [get_cell top_core_0/memset_0/MEM_38/mem_inst_0] -rotate_by CW90   
		move_object [get_cell top_core_0/memset_0/MEM_39/mem_inst_0] -rotate_by CW90   
		move_object [get_cell top_core_0/memset_0/MEM_40/mem_inst_0] -rotate_by CW90   
		move_object [get_cell top_core_0/memset_0/MEM_41/mem_inst_0] -rotate_by CW90   
		move_object [get_cell top_core_0/memset_0/MEM_42/mem_inst_0] -rotate_by CW90   
		move_object [get_cell top_core_0/memset_0/MEM_43/mem_inst_0] -rotate_by CW90   
		move_object [get_cell top_core_0/memset_0/MEM_44/mem_inst_0] -rotate_by CW90   
		move_object [get_cell top_core_0/memset_0/MEM_45/mem_inst_0] -rotate_by CW90   
		move_object [get_cell top_core_0/memset_0/MEM_46/mem_inst_0] -rotate_by CW90   
		move_object [get_cell top_core_0/memset_0/MEM_47/mem_inst_0] -rotate_by CW90   
                                            
		move_object [get_cell top_core_0/memset_0/MEM_48/mem_inst_0] -rotate_by CW90       
		move_object [get_cell top_core_0/memset_0/MEM_49/mem_inst_0] -rotate_by CW90       
		move_object [get_cell top_core_0/memset_0/MEM_50/mem_inst_0] -rotate_by CW90       
		move_object [get_cell top_core_0/memset_0/MEM_51/mem_inst_0] -rotate_by CW90       
		move_object [get_cell top_core_0/memset_0/MEM_52/mem_inst_0] -rotate_by CW90       
		move_object [get_cell top_core_0/memset_0/MEM_53/mem_inst_0] -rotate_by CW90       
		move_object [get_cell top_core_0/memset_0/MEM_54/mem_inst_0] -rotate_by CW90       
		move_object [get_cell top_core_0/memset_0/MEM_55/mem_inst_0] -rotate_by CW90       
		move_object [get_cell top_core_0/memset_0/MEM_56/mem_inst_0] -rotate_by CW90       
		move_object [get_cell top_core_0/memset_0/MEM_57/mem_inst_0] -rotate_by CW90       
		move_object [get_cell top_core_0/memset_0/MEM_58/mem_inst_0] -rotate_by CW90       
		move_object [get_cell top_core_0/memset_0/MEM_59/mem_inst_0] -rotate_by CW90       
		move_object [get_cell top_core_0/memset_0/MEM_60/mem_inst_0] -rotate_by CW90       
		move_object [get_cell top_core_0/memset_0/MEM_61/mem_inst_0] -rotate_by CW90       
		move_object [get_cell top_core_0/memset_0/MEM_62/mem_inst_0] -rotate_by CW90       
		move_object [get_cell top_core_0/memset_0/MEM_63/mem_inst_0] -rotate_by CW90     

		move_object [get_cell top_core_0/imem_0/mem_inst_0] 	  -rotate_by CW90	
		move_object [get_cell top_core_0/imem_0/mem_inst_1] 	  -rotate_by CW90	
		move_object [get_cell top_core_0/imem_0/mem_inst_2] 	  -rotate_by CW90	
		move_object [get_cell top_core_0/imem_0/mem_inst_3] 	  -rotate_by CW90	
  
		move_object [get_cell top_core_0/memset_0/MEM_0/mem_inst_0]  -to {400    	400}
		move_object [get_cell top_core_0/memset_0/MEM_1/mem_inst_0]  -to {600    	400}
		move_object [get_cell top_core_0/memset_0/MEM_2/mem_inst_0]  -to {800    	400}
		move_object [get_cell top_core_0/memset_0/MEM_3/mem_inst_0]  -to {1000    	400}
		move_object [get_cell top_core_0/memset_0/MEM_4/mem_inst_0]  -to {1200    	400}
		move_object [get_cell top_core_0/memset_0/MEM_5/mem_inst_0]  -to {1400    	400}
		move_object [get_cell top_core_0/memset_0/MEM_6/mem_inst_0]  -to {1600    	400}
		move_object [get_cell top_core_0/memset_0/MEM_7/mem_inst_0]  -to {1800    	400}
		move_object [get_cell top_core_0/memset_0/MEM_8/mem_inst_0]  -to {2000    	400}
		move_object [get_cell top_core_0/memset_0/MEM_9/mem_inst_0]  -to {2200    	400}
		move_object [get_cell top_core_0/memset_0/MEM_10/mem_inst_0] -to {2400	400}
		move_object [get_cell top_core_0/memset_0/MEM_11/mem_inst_0] -to {2600	400}
		move_object [get_cell top_core_0/memset_0/MEM_12/mem_inst_0] -to {2800	400}
		move_object [get_cell top_core_0/memset_0/MEM_13/mem_inst_0] -to {3000	400}
		move_object [get_cell top_core_0/memset_0/MEM_14/mem_inst_0] -to {3200	400}
		move_object [get_cell top_core_0/memset_0/MEM_15/mem_inst_0] -to {3400	400}

		move_object [get_cell top_core_0/memset_0/MEM_16/mem_inst_0] -to {400     	800}
		move_object [get_cell top_core_0/memset_0/MEM_17/mem_inst_0] -to {600     	800}
		move_object [get_cell top_core_0/memset_0/MEM_18/mem_inst_0] -to {800     	800}
		move_object [get_cell top_core_0/memset_0/MEM_19/mem_inst_0] -to {1000    	800}
		move_object [get_cell top_core_0/memset_0/MEM_20/mem_inst_0] -to {1200    	800}
		move_object [get_cell top_core_0/memset_0/MEM_21/mem_inst_0] -to {1400    	800}
		move_object [get_cell top_core_0/memset_0/MEM_22/mem_inst_0] -to {1600    	800}
		move_object [get_cell top_core_0/memset_0/MEM_23/mem_inst_0] -to {1800    	800}
		move_object [get_cell top_core_0/memset_0/MEM_24/mem_inst_0] -to {2000    	800}
		move_object [get_cell top_core_0/memset_0/MEM_25/mem_inst_0] -to {2200    	800}
		move_object [get_cell top_core_0/memset_0/MEM_26/mem_inst_0] -to {2400	800}
		move_object [get_cell top_core_0/memset_0/MEM_27/mem_inst_0] -to {2600	800}
		move_object [get_cell top_core_0/memset_0/MEM_28/mem_inst_0] -to {2800	800}
		move_object [get_cell top_core_0/memset_0/MEM_29/mem_inst_0] -to {3000	800}
		move_object [get_cell top_core_0/memset_0/MEM_30/mem_inst_0] -to {3200	800}
		move_object [get_cell top_core_0/memset_0/MEM_31/mem_inst_0] -to {3400	800}
                                            
		move_object [get_cell top_core_0/memset_0/MEM_32/mem_inst_0] -to {400     	3000}   
		move_object [get_cell top_core_0/memset_0/MEM_33/mem_inst_0] -to {600     	3000}   
		move_object [get_cell top_core_0/memset_0/MEM_34/mem_inst_0] -to {800     	3000}   
		move_object [get_cell top_core_0/memset_0/MEM_35/mem_inst_0] -to {1000    	3000}   
		move_object [get_cell top_core_0/memset_0/MEM_36/mem_inst_0] -to {1200    	3000}   
		move_object [get_cell top_core_0/memset_0/MEM_37/mem_inst_0] -to {1400    	3000}   
		move_object [get_cell top_core_0/memset_0/MEM_38/mem_inst_0] -to {1600    	3000}   
		move_object [get_cell top_core_0/memset_0/MEM_39/mem_inst_0] -to {1800    	3000}   
		move_object [get_cell top_core_0/memset_0/MEM_40/mem_inst_0] -to {2000    	3000}   
		move_object [get_cell top_core_0/memset_0/MEM_41/mem_inst_0] -to {2200    	3000}   
		move_object [get_cell top_core_0/memset_0/MEM_42/mem_inst_0] -to {2400	3000}   
		move_object [get_cell top_core_0/memset_0/MEM_43/mem_inst_0] -to {2600	3000}   
		move_object [get_cell top_core_0/memset_0/MEM_44/mem_inst_0] -to {2800	3000}   
		move_object [get_cell top_core_0/memset_0/MEM_45/mem_inst_0] -to {3000	3000}   
		move_object [get_cell top_core_0/memset_0/MEM_46/mem_inst_0] -to {3200	3000}   
		move_object [get_cell top_core_0/memset_0/MEM_47/mem_inst_0] -to {3400	3000}   
                                            
		move_object [get_cell top_core_0/memset_0/MEM_48/mem_inst_0] -to {400     	3400}      
		move_object [get_cell top_core_0/memset_0/MEM_49/mem_inst_0] -to {600     	3400}      
		move_object [get_cell top_core_0/memset_0/MEM_50/mem_inst_0] -to {800     	3400}      
		move_object [get_cell top_core_0/memset_0/MEM_51/mem_inst_0] -to {1000    	3400}      
		move_object [get_cell top_core_0/memset_0/MEM_52/mem_inst_0] -to {1200    	3400}      
		move_object [get_cell top_core_0/memset_0/MEM_53/mem_inst_0] -to {1400    	3400}      
		move_object [get_cell top_core_0/memset_0/MEM_54/mem_inst_0] -to {1600    	3400}      
		move_object [get_cell top_core_0/memset_0/MEM_55/mem_inst_0] -to {1800    	3400}      
		move_object [get_cell top_core_0/memset_0/MEM_56/mem_inst_0] -to {2000    	3400}      
		move_object [get_cell top_core_0/memset_0/MEM_57/mem_inst_0] -to {2200    	3400}      
		move_object [get_cell top_core_0/memset_0/MEM_58/mem_inst_0] -to {2400	3400}      
		move_object [get_cell top_core_0/memset_0/MEM_59/mem_inst_0] -to {2600	3400}      
		move_object [get_cell top_core_0/memset_0/MEM_60/mem_inst_0] -to {2800	3400}      
		move_object [get_cell top_core_0/memset_0/MEM_61/mem_inst_0] -to {3000	3400}      
		move_object [get_cell top_core_0/memset_0/MEM_62/mem_inst_0] -to {3200	3400}      
		move_object [get_cell top_core_0/memset_0/MEM_63/mem_inst_0] -to {3400	3400}    

		move_object [get_cell top_core_0/imem_0/mem_inst_0] -to {3200 1200}	
		move_object [get_cell top_core_0/imem_0/mem_inst_1] -to {3400 1200}	
		move_object [get_cell top_core_0/imem_0/mem_inst_2] -to {3200 2600}	
		move_object [get_cell top_core_0/imem_0/mem_inst_3] -to {3400 2600}	
  

		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_0/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_1/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_2/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_3/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_4/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_5/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_6/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_7/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_8/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_9/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_10/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_11/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_12/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_13/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_14/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_15/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_16/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_17/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_18/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_19/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_20/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_21/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_22/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_23/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_24/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_25/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_26/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_27/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_28/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_29/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_30/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_31/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_32/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_33/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_34/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_35/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_36/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_37/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_38/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_39/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_40/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_41/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_42/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_43/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_44/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_45/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_46/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_47/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_48/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_49/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_50/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_51/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_52/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_53/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_54/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_55/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_56/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_57/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_58/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_59/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_60/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_61/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_62/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/memset_0/MEM_63/mem_inst_0}

		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/imem_0/mem_inst_0}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/imem_0/mem_inst_1}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/imem_0/mem_inst_2}
		create_keepout_margin -type hard -outer {3 3 3 3} {top_core_0/imem_0/mem_inst_3}

		create_placement_blockage -type hard -boundary {{397	397}	{483	463}}
		create_placement_blockage -type hard -boundary {{597	397}	{683	463}}
		create_placement_blockage -type hard -boundary {{797	397}	{883	463}}
		create_placement_blockage -type hard -boundary {{997	397}	{1083	463}}
		create_placement_blockage -type hard -boundary {{1197	397}	{1283	463}}
		create_placement_blockage -type hard -boundary {{1397	397}	{1483	463}}
		create_placement_blockage -type hard -boundary {{1597	397}	{1683	463}}
		create_placement_blockage -type hard -boundary {{1797	397}	{1883	463}}
		create_placement_blockage -type hard -boundary {{1997	397}	{2083	463}}
		create_placement_blockage -type hard -boundary {{2197	397}	{2283	463}}
		create_placement_blockage -type hard -boundary {{2397	397}	{2483	463}}
		create_placement_blockage -type hard -boundary {{2597	397}	{2683	463}}
		create_placement_blockage -type hard -boundary {{2797	397}	{2883	463}}
		create_placement_blockage -type hard -boundary {{2997	397}	{3083	463}}
		create_placement_blockage -type hard -boundary {{3197	397}	{3283	463}}
		create_placement_blockage -type hard -boundary {{3397	397}	{3483	463}}

		create_placement_blockage -type hard -boundary {{397	797}	{483	863}}
		create_placement_blockage -type hard -boundary {{597	797}	{683	863}}
		create_placement_blockage -type hard -boundary {{797	797}	{883	863}}
		create_placement_blockage -type hard -boundary {{997	797}	{1083	863}}
		create_placement_blockage -type hard -boundary {{1197	797}	{1283	863}}
		create_placement_blockage -type hard -boundary {{1397	797}	{1483	863}}
		create_placement_blockage -type hard -boundary {{1597	797}	{1683	863}}
		create_placement_blockage -type hard -boundary {{1797	797}	{1883	863}}
		create_placement_blockage -type hard -boundary {{1997	797}	{2083	863}}
		create_placement_blockage -type hard -boundary {{2197	797}	{2283	863}}
		create_placement_blockage -type hard -boundary {{2397	797}	{2483	863}}
		create_placement_blockage -type hard -boundary {{2597	797}	{2683	863}}
		create_placement_blockage -type hard -boundary {{2797	797}	{2883	863}}
		create_placement_blockage -type hard -boundary {{2997	797}	{3083	863}}
		create_placement_blockage -type hard -boundary {{3197	797}	{3283	863}}
		create_placement_blockage -type hard -boundary {{3397	797}	{3483	863}}

		create_placement_blockage -type hard -boundary {{397	2997}	{483	3063}}
		create_placement_blockage -type hard -boundary {{597	2997}	{683	3063}}
		create_placement_blockage -type hard -boundary {{797	2997}	{883	3063}}
		create_placement_blockage -type hard -boundary {{997	2997}	{1083	3063}}
		create_placement_blockage -type hard -boundary {{1197	2997}	{1283	3063}}
		create_placement_blockage -type hard -boundary {{1397	2997}	{1483	3063}}
		create_placement_blockage -type hard -boundary {{1597	2997}	{1683	3063}}
		create_placement_blockage -type hard -boundary {{1797	2997}	{1883	3063}}
		create_placement_blockage -type hard -boundary {{1997	2997}	{2083	3063}}
		create_placement_blockage -type hard -boundary {{2197	2997}	{2283	3063}}
		create_placement_blockage -type hard -boundary {{2397	2997}	{2483	3063}}
		create_placement_blockage -type hard -boundary {{2597	2997}	{2683	3063}}
		create_placement_blockage -type hard -boundary {{2797	2997}	{2883	3063}}
		create_placement_blockage -type hard -boundary {{2997	2997}	{3083	3063}}
		create_placement_blockage -type hard -boundary {{3197	2997}	{3283	3063}}
		create_placement_blockage -type hard -boundary {{3397	2997}	{3483	3063}}
	
		create_placement_blockage -type hard -boundary {{397	3397}	{483	3463}}
		create_placement_blockage -type hard -boundary {{597	3397}	{683	3463}}
		create_placement_blockage -type hard -boundary {{797	3397}	{883	3463}}
		create_placement_blockage -type hard -boundary {{997	3397}	{1083	3463}}
		create_placement_blockage -type hard -boundary {{1197	3397}	{1283	3463}}
		create_placement_blockage -type hard -boundary {{1397	3397}	{1483	3463}}
		create_placement_blockage -type hard -boundary {{1597	3397}	{1683	3463}}
		create_placement_blockage -type hard -boundary {{1797	3397}	{1883	3463}}
		create_placement_blockage -type hard -boundary {{1997	3397}	{2083	3463}}
		create_placement_blockage -type hard -boundary {{2197	3397}	{2283	3463}}
		create_placement_blockage -type hard -boundary {{2397	3397}	{2483	3463}}
		create_placement_blockage -type hard -boundary {{2597	3397}	{2683	3463}}
		create_placement_blockage -type hard -boundary {{2797	3397}	{2883	3463}}
		create_placement_blockage -type hard -boundary {{2997	3397}	{3083	3463}}
		create_placement_blockage -type hard -boundary {{3197	3397}	{3283	3463}}
		create_placement_blockage -type hard -boundary {{3397	3397}	{3483	3463}}

		create_placement_blockage -type hard -boundary {{3197	1197}	{3283	1303}}
		create_placement_blockage -type hard -boundary {{3397	1197}	{3483	1303}}
		create_placement_blockage -type hard -boundary {{3197	2597}	{3283	2703}}
		create_placement_blockage -type hard -boundary {{3397	2597}	{3483	2703}}

#		move_objects [get_cell Ucmos28lpp_ra1w_hd_1024x17m8] -rotate_by CW90 
#		move_objects [get_cell Ucmos28lpp_ra1w_hd_1024x17m8] -to {35.614 28.930}
#		create_keepout_margin -type hard -outer { 3 3 3 3  } {Ucmos28lpp_ra1w_hd_1024x17m8}
		# If you want to remove, command :::::::  remove_keepout_margins [get_keepout_margins]

#		create_placement_blockage -type hard -boundary {{10 114} {213.5 114} {213.5 35} {10 35}}
#		create_keepout_margin -type hard -outer { 3 3 3 3  } {Ucmos28lpp_ra1w_hd_1024x17m8}
#		create_placement_blockage -type hard -boundary {{35.2200 27.1000} {35.2200 141.4000} {90.0800 141.4000} {90.0800 27.1000}}
		# If you want to remove, command :::::::  remove_placement_blockage

		## Route Guide
		create_routing_guide -boundary {{300 300} {3658 3658}} -layers {M1 V1 M2 V2 M3 V3 M4 V4 M5 V5 M6 V6 M7} -preferred_direction_only


#		source "../../netlist/memory_wrapper.tdf"
#      	     	place_pins -self ;# to place unplaced pins if needed
        }
	## Additional floorplan constraints 
	#  If DEF_FLOORPLAN_FILES is provided but can not cover certain floorplan constraint types, then they can be provided here.
	#  If initialize_floorplan is used, additional floorplan constraints can be provided here. 
	#  For example, bounds, pin guides, or route guides, etc
	if {[file exists [which $TCL_ADDITIONAL_FLOORPLAN_FILE]]} {
		puts "RM-info: Adding additional floorplan information from TCL_ADDITIONAL_FLOORPLAN_FILE ($TCL_ADDITIONAL_FLOORPLAN_FILE)"
		source $TCL_ADDITIONAL_FLOORPLAN_FILE
	} elseif {$TCL_ADDITIONAL_FLOORPLAN_FILE != ""} {
		puts "RM-error : TCL_ADDITIONAL_FLOORPLAN_FILE($TCL_ADDITIONAL_FLOORPLAN_FILE) is invalid. Please correct it."
	}
	
	## For IO, and macro cell placement, you can refer to the following example : 
	#  rm_icc2_flat_scripts/init_design_flat_design_planning_example.tcl
	
	####################################
	## SCANDEF 
	####################################
	if {[file exists [which $DEF_SCAN_FILE]]} {
		read_def $DEF_SCAN_FILE
	} elseif {$DEF_SCAN_FILE != ""} {
		puts "RM-error : DEF_SCAN_FILE($DEF_SCAN_FILE) is invalid. Please correct it."
	}
}

########################################################################
## INIT_DESIGN_INPUT = DC_ASCII : 
## sources specified write_icc2_files output from DC and commit UPF  
########################################################################
if {$INIT_DESIGN_INPUT == "DC_ASCII"} {

	if {[file exists ${DCRM_RESULTS_DIR}/${DCRM_FINAL_DESIGN_ICC2}/${DESIGN_NAME}.icc2_script.tcl]} {
		## Read in design output files from Design Compiler's write_icc2_files command
		puts "RM-info: Sourcing [which ${DCRM_RESULTS_DIR}/${DCRM_FINAL_DESIGN_ICC2}/${DESIGN_NAME}.icc2_script.tcl]"
		source ${DCRM_RESULTS_DIR}/${DCRM_FINAL_DESIGN_ICC2}/${DESIGN_NAME}.icc2_script.tcl
		puts "RM-info: Running commit_upf"
		commit_upf
		puts "RM-info: Running associate_mv_cells -all"
		associate_mv_cells -all
	} else {
		puts "RM-error : ${DCRM_RESULTS_DIR}/${DCRM_FINAL_DESIGN_ICC2}/${DESIGN_NAME}.icc2_script.tcl is not found." 
		puts "RM-warning : ${DCRM_RESULTS_DIR}/${DCRM_FINAL_DESIGN_ICC2}/${DESIGN_NAME}.icc2_script.tcl is required for DC_ASCII flow." 
	}
}

########################################################################
## Additional timer related setups : POCV	
########################################################################
## Read POCV coefficient data and distance-based derate tables to reduce pessimism and improve accuracy of the results.
#  Specify a list of corner and its associated POCV file in pairs, as POCV is corner dependant.
if {$POCV_CORNER_FILE_MAPPING_LIST != ""} {
	foreach pair $POCV_CORNER_FILE_MAPPING_LIST {
		set corner [lindex $pair 0]	
		set file [lindex $pair 1]	
		if {[file exists [which $file]]} {
			puts "RM-info: Corner $corner: reading POCV file $file"
	        	read_ocvm -corners $corner $file
		} else {
	        	puts "RM-error: Corner $corner: POCV file $file is not found"
	      	}
	}
}

## Enable POCV related settings if library contains LVF or if POCV files are specified
set_app_options -name time.pocvm_enable_analysis -value false ;# enable POCV in order to check for library LVF
#set_app_options -name time.pocvm_enable_analysis -value true ;# enable POCV in order to check for library LVF
redirect -variable x {report_ocvm -type pocvm -nosplit -lib_cell -list_annotated}
if {[regexp "LVF" $x] || $POCV_CORNER_FILE_MAPPING_LIST != ""} {
	## Enable POCV analysis
	reset_app_options time.aocvm_enable_analysis ;# reset it to prevent POCV being overriden by AOCV
	
	## Enable distance analysis
	#	set_app_options -name time.ocvm_enable_distance_analysis -value true
	
	## Enable constraint variation if there's pre-existing library LVF constraints
	if {[regexp "LVF" $x]} {
		set_app_options -name time.pocvm_enable_constraint_variation -value true
	}
	
	## Specify the number of standard deviations used in POCV analysis
	#  The larger the value, the more violations there will be 
	#	set_app_options -name time.pocvm_corner_sigma -value 3.5 -block [current_block] ;# default 3
	
	## Use OCV derates to fill gaps in POCV data
	#  To completely ignore OCV derate settings:  
	#	set_app_options -name time.ocvm_precedence_compatibility -value true
	#  To consider both OCV and POCV derate settings:
	#	set_app_options -name time.ocvm_precedence_compatibility -value false
	
	## Set and report POCV guard band (per corner)
	#  Use the set_timing_derate command to specify POCV guard band, which affects the mean and sensit
	#  values in the timing report. For ex, if value is the same across corners:
	#	set_timing_derate -cell_delay -pocvm_guardband -early 0.97 -corner [all-corners]
	#  Or if value is different per corner:
	#	set_timing_derate -cell_delay -pocvm_guardband -early 0.97 -corner corner1
	#	set_timing_derate -cell_delay -pocvm_guardband -early 0.98 -corner corner2, ... etc
	#  To report guard band:
	#	report_timing_derate -pocvm_guardband -corner [all_corners]
	
	## Set and report scaling factor (per corner)
	#  It affects sensit which equals to sensit * scaling factor. For ex, if value is the same across corners:
	#	set_timing_derate -cell_delay -pocvm_coefficient_scale_factor -early 0.95 -corner [all_corners]
	#  Or if value is different per corner:
	#	set_timing_derate -cell_delay -pocvm_coefficient_scale_factor -early 0.95 -corner corner1
	#	set_timing_derate -cell_delay -pocvm_coefficient_scale_factor -early 0.96 -corner corner2, ... etc
	#  To report scale factor:
	#	report_timing_derate -pocvm_coefficient_scale_factor -corner [all_corners]
} else {
	## Reset it to default false as library has no LVF and POCV_CORNER_FILE_MAPPING_LIST is not specified
	reset_app_options time.pocvm_enable_analysis ;# default false
} 

########################################################################
## Additional timer related setups : AOCV (mutually exclusive with POCV)
########################################################################
## Read AOCV derate factor table to reduce pessimism and improve accuracy of the results.
#  Specify a list of corner and its associated AOCV table in pairs, as AOCV is corner dependant.
if {![get_app_option_value -name time.pocvm_enable_analysis] && $AOCV_CORNER_TABLE_MAPPING_LIST != ""} {
	foreach pair $AOCV_CORNER_TABLE_MAPPING_LIST {
		set corner [lindex $pair 0]	
		set table [lindex $pair 1]	
		if {[file exists [which $table]]} {
			puts "RM-info: Corner $corner: reading AOCV table file $table"
	        	read_ocvm -corners $corner $table
		} else {
	        	puts "RM-error: Corner $corner: AOCV table file $table is not found"
	      	}
	}
	
	## Set user-specified instance based random coefficient for the AOCV analysis 
	#  Example : set_aocvm_coefficient <value> [get_lib_cells <lib_cell>]

	## AOCV is enabled in clock_opt_cts.tcl after CTS is done
}

########################################################################
## Additional timer related setups : create path groups 	
########################################################################
if {$CREATE_IO_PATH_GROUPS} {
	## Tool auto creates 3 IO path groups : in2reg_default, reg2out_default, and in2out_default
	set_app_options -name time.enable_io_path_groups -value true  
}

## Optionally create a register to register group
#  set cur_mode [current_mode]
#  foreach_in_collection mode [all_modes] {
#  	current_mode $mode;
#  	group_path -name reg2reg -from [all_clocks] -to [all_clocks] ;# creates register to register path group   
#  }
#  current_mode $cur_mode

## Optionally increase path group weight on critical path groups, for ex:
#  It is recommended to increase path group weight to at least 15 for critical ones 
#	group_path -name clk_gate_enable -weight 15
#	group_path -name xyz -weight 15

redirect -file ${REPORTS_DIR}/${INIT_DESIGN_BLOCK_NAME}.report_path_groups {report_path_groups -nosplit -modes [all_modes]}

########################################################################
## Additional timer related setups : remove propagated clocks	
########################################################################
## Remove all propagated clocks
set cur_mode [current_mode]
foreach_in_collection mode [all_modes] {
	current_mode $mode
	remove_propagated_clocks [all_clocks]
	remove_propagated_clocks [get_ports]
	remove_propagated_clocks [get_pins -hierarchical]
}
current_mode $cur_mode

#smkcow
                remove_ideal_network *


# To set clock gating check :
# set cur_mode [current_mode]
# foreach_in_collection mode [all_modes] {
#	current_mode $mode
#	set_clock_gating_check -setup 0 [current_design]
#	set_clock_gating_check -hold  0 [current_design]
# }
# current_mode $cur_mode


########################################################################
## Additional power related setups : power derate	
########################################################################
## Power derating factors can affect power analysis and power optimization
#  To set power derating factors on objects, use set_power_derate command
#  Examples
#	set_power_derate 0.98 -scenarios [current_scenario] -leakage -internal
#	set_power_derate 0.9 -switching [get_lib_cells my_lib/cell1] 
#	set_power_derate 0.5 -group {memory} 
#  To report and get power derating factors
#	report_power_derate ...
#  To remove all power derating factors when no arguments are specified
#	reset_power_derate


if {$TCL_USER_CONNECT_PG_NET_SCRIPT != ""} {
	if {[file exists [which $TCL_USER_CONNECT_PG_NET_SCRIPT]]} {
		puts "RM-info: Sourcing [which $TCL_USER_CONNECT_PG_NET_SCRIPT]"
  		source $TCL_USER_CONNECT_PG_NET_SCRIPT
	} elseif {$TCL_USER_CONNECT_PG_NET_SCRIPT != ""} {
		puts "RM-error: TCL_USER_CONNECT_PG_NET_SCRIPT($TCL_USER_CONNECT_PG_NET_SCRIPT) is invalid. Pls correct it."
	}
} else {
	connect_pg_net
	# For non-MV designs with more than one PG, you should use connect_pg_net in manual mode.
}

####################################
## MV setup :
## provide a customized MV script	
####################################
## A Tcl script placeholder for your MV setup commands,such as create_voltage_area, placement bound, 
#  power switch creation and level shifter insertion, etc
if {[file exists [which $TCL_MV_SETUP_FILE]]} {
	puts "RM-info: Sourcing [which $TCL_MV_SETUP_FILE]"
	source -echo $TCL_MV_SETUP_FILE
} elseif {$TCL_MV_SETUP_FILE != ""} {
	puts "RM-error: TCL_MV_SETUP_FILE($TCL_MV_SETUP_FILE) is invalid. Pls correct it."
}

## For a sample script to insert, assign, and connect power switches, 
#  refer to power_switch_example.tcl


# below lines are executed  :: smkcow
####################################
## Power and ground network creation	
####################################
## A Tcl script placeholder for your power ground network creation commands, such as create_pg*, 
#  set_pg_strategy, and compile_pg, etc.

#set TCL_PG_CREATION_FILE "/home/smkcow/QnA/digital/example_smkcow_DC_ICC2/memory_wrapper/PNR/SS/pnr/rm_icc2_pnr_scripts/pns.tcl"

## Create standard cell PG rail
#  Example : rm_icc2_pnr_scripts/init_design_std_cell_rail_example.tcl

# smkcow : pns.tcl includes STD Cell PG rail

if {[file exists [which $TCL_PG_CREATION_FILE]]} {
	puts "RM-info: Sourcing [which $TCL_PG_CREATION_FILE]"
	source -echo $TCL_PG_CREATION_FILE
} elseif {$TCL_PG_CREATION_FILE != ""} {
	puts "RM-error: TCL_PG_CREATION_FILE($TCL_PG_CREATION_FILE) is invalid. Pls correct it."
}


## Verify technology routing DRC and illegal overlaps of PG net objects.
#       check_pg_drc
# Create error report for PG ignoring std cells because they are not legalized
check_pg_drc -ignore_std_cells

# Check phyiscal connectivity
check_pg_connectivity -check_std_cell_pins none
#equal to verify_pg_nets

# check_mv_design -erc_mode and -power_connectivity
redirect -file ${REPORTS_DIR}/check_mv_design.erc_mode {check_mv_design -erc_mode}
redirect -file ${REPORTS_DIR}/check_mv_design.power_connectivity {check_mv_design -power_connectivity}


####################################
## Boundary cells
####################################

## Boundary cells: to be added around the boundaries of objects, such as voltage areas, macros, blockages, and the core area
#	set_boundary_cell_rules ... 
#	report_boundary_cell_rules
#	compile_boundary_cells
#	check_boundary_cells

####################################
# Fix all shaped blocks and macros
####################################
#set_fixed_objects [get_flat_cells -filter "is_hard_macro"]
#Below lines are equal to set_fixed_objects

if [sizeof_collection [get_cells -hier -filter is_hard_macro==true -quiet]] {
   set_attribute -quiet [get_cells -hierarchical -filter is_hard_macro==true] status fixed
}

# add End cap cell
#set_boundary_cell_rules -left_boundary_cell base_rvt_c130_frame/ENDCAPTIE4_A9TR -right_boundary_cell base_rvt_c130_frame/ENDCAPTIE4_A9TR
set_boundary_cell_rules -left_boundary_cell sc9_cmos28lpp_base_rvt_tt_nominal_max_1p000v_25c_ff_nominal_min_1p100v_m40c_sadhm_physical_only/ENDCAPTIE4_A9TR -right_boundary_cell sc9_cmos28lpp_base_rvt_tt_nominal_max_1p000v_25c_ff_nominal_min_1p100v_m40c_sadhm_physical_only/ENDCAPTIE4_A9TR


####################################
## Tap cells
####################################
#  Example : create_tap_cells -lib_cell myLib/Cell1 -distance 30 -pattern every_row
# Add tap cell array

#create_tap_cells -lib_cell base_rvt_c130_frame/FILLTIE4_A9TR -distance 118.3000 -pattern stagger -skip_fixed_cells
create_tap_cells -lib_cell sc9_cmos28lpp_base_rvt_tt_nominal_max_1p000v_25c_ff_nominal_min_1p100v_m40c_sadhm_physical_only/FILLTIE4_A9TR -distance 118.3000 -pattern stagger -skip_fixed_cells
compile_boundary_cells

# If you want, remove, the below command
# remove_cells [get_cells *FILLTIE*]

###################################
## Placement
####################################

create_placement -floorplan
#legalize_placement

report_placement \
   -physical_hierarchy_violations all \
   -wirelength all -hard_macro_overlap \
   -verbose high > ${REPORTS_DIR}/report_placement.rpt



####################################
# Check Design: Pre-Timing Estimation
####################################
   redirect -file ${REPORTS_DIR}/check_design.pre_timing_estimation \
    {check_design -ems_database check_design.pre_timing_estimation.ems -checks dp_pre_timing_estimation}

################################################################################
# Run timing estimation on the entire top design to ensure quality 
################################################################################
# smkcow 
# skip errors :: estimated corner occurs errors
#   estimate_timing

# smkcow 
# skip errors :: estimated corner occurs errors
report_timing -mode [all_modes] -corner [all_corner] > $REPORTS_DIR/${DESIGN_NAME}.post_estimated_timing.rpt
report_qor -corner [all_corner] > $REPORTS_DIR/${DESIGN_NAME}.post_estimated_timing.qor
report_qor -summary > $REPORTS_DIR/${DESIGN_NAME}.post_estimated_timing.qor.sum


####################################
## Post-init_design customizations
####################################
if {[file exists [which $TCL_USER_INIT_DESIGN_POST_SCRIPT]]} {
        puts "RM-info: Sourcing [which $TCL_USER_INIT_DESIGN_POST_SCRIPT]"
        source $TCL_USER_INIT_DESIGN_POST_SCRIPT
} elseif {$TCL_USER_INIT_DESIGN_POST_SCRIPT != ""} {
        puts "RM-error: TCL_USER_INIT_DESIGN_POST_SCRIPT($TCL_USER_INIT_DESIGN_POST_SCRIPT) is invalid. Please correct it."
}

save_upf ${REPORTS_DIR}/${INIT_DESIGN_BLOCK_NAME}.save_upf

if {$USE_RM_BLOCK_NAME_AS_LABEL} {
	save_block -as ${DESIGN_NAME}/$INIT_DESIGN_BLOCK_NAME
} else {
	save_block -as $INIT_DESIGN_BLOCK_NAME
}
save_lib

####################################
## Sanity checks and QoR Report	
####################################
if {$REPORT_QOR} {
	set REPORT_PREFIX $INIT_DESIGN_BLOCK_NAME
	puts "RM-info: Sourcing [which $REPORT_QOR_SCRIPT]"
	source $REPORT_QOR_SCRIPT ;# reports with zero interconnect delay

	## Check the technology file before starting place and route flow
	write_tech_file ${REPORTS_DIR}/${REPORT_PREFIX}.tech_file.dump
}


print_message_info -ids * -summary
echo [date] > init_design

exit 


