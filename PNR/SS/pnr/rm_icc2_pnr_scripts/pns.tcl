### Example script.  For details please refer to the IC Compiler II Design Planning User Guide and command man pages

create_net -power VDD
create_net -power VSS

#connect_pg_net -net {VDD} [get_pins -design [current_block] -quiet -physical_context {*VDD*}]
#connect_pg_net -net {VSS} [get_pins -design [current_block] -quiet -physical_context {*VSS*}]

set io_PDVDD_cells [get_cells * -hier -filter "ref_name == PDVDDSEC_18_18_NT_DR"]
set io_PDVSS_cells [get_cells * -hier -filter "ref_name == PDVSSSEC_18_18_NT_DR"]

set io_PVDD_cells [get_cells * -hier -filter "ref_name == PVDDSEC_18_18_NT_DR"]
set io_PVSS_cells [get_cells * -hier -filter "ref_name == PVSSSEC_18_18_NT_DR"]

connect_pg_net -net VDD [remove_from_collection [get_pins */VDD] [get_pins $io_PDVDD_cells/VDD]]
connect_pg_net -net VSS [remove_from_collection [get_pins */VSS] [get_pins $io_PDVSS_cells/VSS]]



## Memory 
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_0/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_1/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_2/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_3/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_4/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_5/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_6/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_7/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_8/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_9/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_10/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_11/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_12/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_13/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_14/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_15/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_16/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_17/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_18/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_19/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_20/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_21/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_22/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_23/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_24/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_25/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_26/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_27/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_28/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_29/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_30/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_31/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_32/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_33/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_34/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_35/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_36/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_37/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_38/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_39/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_40/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_41/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_42/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_43/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_44/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_45/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_46/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_47/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_48/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_49/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_50/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_51/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_52/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_53/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_54/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_55/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_56/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_57/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_58/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_59/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_60/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_61/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_62/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_63/mem_inst_0/VDDCE]

connect_pg_net -net VDD [get_pins top_core_0/imem_0/mem_inst_0/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/imem_0/mem_inst_1/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/imem_0/mem_inst_2/VDDCE]
connect_pg_net -net VDD [get_pins top_core_0/imem_0/mem_inst_3/VDDCE]

connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_0/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_1/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_2/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_3/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_4/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_5/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_6/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_7/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_8/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_9/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_10/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_11/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_12/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_13/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_14/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_15/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_16/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_17/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_18/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_19/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_20/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_21/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_22/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_23/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_24/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_25/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_26/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_27/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_28/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_29/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_30/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_31/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_32/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_33/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_34/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_35/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_36/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_37/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_38/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_39/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_40/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_41/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_42/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_43/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_44/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_45/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_46/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_47/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_48/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_49/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_50/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_51/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_52/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_53/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_54/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_55/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_56/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_57/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_58/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_59/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_60/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_61/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_62/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/memset_0/MEM_63/mem_inst_0/VSSE]

connect_pg_net -net VSS [get_pins top_core_0/imem_0/mem_inst_0/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/imem_0/mem_inst_1/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/imem_0/mem_inst_2/VSSE]
connect_pg_net -net VSS [get_pins top_core_0/imem_0/mem_inst_3/VSSE]

connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_0/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_1/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_2/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_3/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_4/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_5/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_6/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_7/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_8/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_9/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_10/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_11/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_12/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_13/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_14/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_15/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_16/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_17/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_18/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_19/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_20/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_21/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_22/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_23/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_24/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_25/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_26/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_27/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_28/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_29/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_30/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_31/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_32/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_33/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_34/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_35/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_36/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_37/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_38/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_39/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_40/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_41/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_42/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_43/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_44/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_45/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_46/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_47/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_48/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_49/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_50/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_51/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_52/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_53/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_54/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_55/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_56/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_57/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_58/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_59/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_60/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_61/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_62/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/memset_0/MEM_63/mem_inst_0/VDDPE]

connect_pg_net -net VDD [get_pins top_core_0/imem_0/mem_inst_0/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/imem_0/mem_inst_1/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/imem_0/mem_inst_2/VDDPE]
connect_pg_net -net VDD [get_pins top_core_0/imem_0/mem_inst_3/VDDPE]


################################################################################
#-------------------------------------------------------------------------------
# VIA RULE 
#-------------------------------------------------------------------------------
################################################################################
set_pg_via_master_rule M4_M5_via_rule \
-via_array_dimension {10 10} \
-allow_multiple {0.2 0.2} 

set_pg_via_master_rule M5_M6_via_rule \
-via_array_dimension {10 10} \
-allow_multiple {0.2 0.2} 

set_pg_via_master_rule M6_M7_via_rule \
-via_array_dimension {10 10} \
-allow_multiple {0.2 0.2} 

set_pg_via_master_rule M7_IA_via_rule \
-via_array_dimension {10 10} \
-allow_multiple {0.2 0.2} 

set_pg_via_master_rule IA_IB_via_rule \
-via_array_dimension {10 10} \
-allow_multiple {0.2 0.2} 
################################################################################
#-------------------------------------------------------------------------------
# P G   R I N G   C R E A T I O N
#-------------------------------------------------------------------------------
################################################################################


create_pg_ring_pattern ring_pattern_IA_IB -horizontal_layer IA -horizontal_width {5} -horizontal_spacing {5} -vertical_layer IB -vertical_width {5} -vertical_spacing {5} -corner_bridge false

create_pg_ring_pattern ring_pattern_M7_IA -horizontal_layer IA -horizontal_width {4.5} -horizontal_spacing {5} -vertical_layer M7 -vertical_width {4.5} -vertical_spacing {5} -corner_bridge false




set_pg_strategy inner_ring_VDD_VSS -polygon {{300 300} {3659 3659}} -pattern {{name: ring_pattern_IA_IB} {nets: {VDD VSS}} {offset: {5 5}}}

compile_pg -strategies {inner_ring_VDD_VSS}



create_pg_ring_pattern ring_pattern_mem  -horizontal_layer M4  -horizontal_width {0.5} \
-vertical_layer M5  -vertical_width {0.5}  -via_rule {{intersection: all }{via_master: default}} \
-corner_bridge false

set_pg_strategy ring_pattern_mem -macros {top_core_0/memset_0/MEM_0/mem_inst_0 \
						top_core_0/memset_0/MEM_1/mem_inst_0 \
						top_core_0/memset_0/MEM_2/mem_inst_0 \
						top_core_0/memset_0/MEM_3/mem_inst_0 \
						top_core_0/memset_0/MEM_4/mem_inst_0 \
						top_core_0/memset_0/MEM_5/mem_inst_0 \
						top_core_0/memset_0/MEM_6/mem_inst_0 \
						top_core_0/memset_0/MEM_7/mem_inst_0 \
						top_core_0/memset_0/MEM_8/mem_inst_0 \
						top_core_0/memset_0/MEM_9/mem_inst_0 \
						top_core_0/memset_0/MEM_10/mem_inst_0 \
						top_core_0/memset_0/MEM_11/mem_inst_0 \
						top_core_0/memset_0/MEM_12/mem_inst_0 \
						top_core_0/memset_0/MEM_13/mem_inst_0 \
						top_core_0/memset_0/MEM_14/mem_inst_0 \
						top_core_0/memset_0/MEM_15/mem_inst_0 \
						top_core_0/memset_0/MEM_16/mem_inst_0 \
						top_core_0/memset_0/MEM_17/mem_inst_0 \
						top_core_0/memset_0/MEM_18/mem_inst_0 \
						top_core_0/memset_0/MEM_19/mem_inst_0 \
						top_core_0/memset_0/MEM_20/mem_inst_0 \
						top_core_0/memset_0/MEM_21/mem_inst_0 \
						top_core_0/memset_0/MEM_22/mem_inst_0 \
						top_core_0/memset_0/MEM_23/mem_inst_0 \
						top_core_0/memset_0/MEM_24/mem_inst_0 \
						top_core_0/memset_0/MEM_25/mem_inst_0 \
						top_core_0/memset_0/MEM_26/mem_inst_0 \
						top_core_0/memset_0/MEM_27/mem_inst_0 \
						top_core_0/memset_0/MEM_28/mem_inst_0 \
						top_core_0/memset_0/MEM_29/mem_inst_0 \
						top_core_0/memset_0/MEM_30/mem_inst_0 \
						top_core_0/memset_0/MEM_31/mem_inst_0 \
						top_core_0/memset_0/MEM_32/mem_inst_0 \
						top_core_0/memset_0/MEM_33/mem_inst_0 \
						top_core_0/memset_0/MEM_34/mem_inst_0 \
						top_core_0/memset_0/MEM_35/mem_inst_0 \
						top_core_0/memset_0/MEM_36/mem_inst_0 \
						top_core_0/memset_0/MEM_37/mem_inst_0 \
						top_core_0/memset_0/MEM_38/mem_inst_0 \
						top_core_0/memset_0/MEM_39/mem_inst_0 \
						top_core_0/memset_0/MEM_40/mem_inst_0 \
						top_core_0/memset_0/MEM_41/mem_inst_0 \
						top_core_0/memset_0/MEM_42/mem_inst_0 \
						top_core_0/memset_0/MEM_43/mem_inst_0 \
						top_core_0/memset_0/MEM_44/mem_inst_0 \
						top_core_0/memset_0/MEM_45/mem_inst_0 \
						top_core_0/memset_0/MEM_46/mem_inst_0 \
						top_core_0/memset_0/MEM_47/mem_inst_0 \
						top_core_0/memset_0/MEM_48/mem_inst_0 \
						top_core_0/memset_0/MEM_49/mem_inst_0 \
						top_core_0/memset_0/MEM_50/mem_inst_0 \
						top_core_0/memset_0/MEM_51/mem_inst_0 \
						top_core_0/memset_0/MEM_52/mem_inst_0 \
						top_core_0/memset_0/MEM_53/mem_inst_0 \
						top_core_0/memset_0/MEM_54/mem_inst_0 \
						top_core_0/memset_0/MEM_55/mem_inst_0 \
						top_core_0/memset_0/MEM_56/mem_inst_0 \
						top_core_0/memset_0/MEM_57/mem_inst_0 \
						top_core_0/memset_0/MEM_58/mem_inst_0 \
						top_core_0/memset_0/MEM_59/mem_inst_0 \
						top_core_0/memset_0/MEM_60/mem_inst_0 \
						top_core_0/memset_0/MEM_61/mem_inst_0 \
						top_core_0/memset_0/MEM_62/mem_inst_0 \
						top_core_0/memset_0/MEM_63/mem_inst_0 \
						top_core_0/imem_0/mem_inst_0 \
						top_core_0/imem_0/mem_inst_1 \
						top_core_0/imem_0/mem_inst_2 \
						top_core_0/imem_0/mem_inst_3} \
-pattern {{name : ring_pattern_mem}{nets : {VDD VSS}}{offset : {0.5 0.5}}}

 
#-extension {{{side : 1 3}{stop : outermost_ring}}}

compile_pg -strategies ring_pattern_mem




#set_pg_strategy macro_ring -macros Ucmos10lpsvrv_ra1_hd_256x17m8 \
#-pattern {{name : ring_pattern}{nets : {VDD VSS}}{offset : {1 1}}{skip_sides : 1 2}} \
#-extension {stop:innermost_ring}


################################################################################
#-------------------------------------------------------------------------------
# P G   M E S H   C R E A T I O N
#-------------------------------------------------------------------------------
################################################################################


#create_pg_mesh_pattern pg_mesh1 \
#   -parameters {w1 p1 w2 p2 f t} \
#   -layers {{{vertical_layer: M8} {width: @w1} {spacing: interleaving} \
#        {pitch: @p1} {offset: @f} {trim: @t}} \
# 	     {{horizontal_layer: M9} {width: @w2} {spacing: interleaving} \
#        {pitch: @p2} {offset: @f} {trim: @t}}}
#
#
#set_pg_strategy s_mesh1 \
#   -pattern {{pattern: pg_mesh1} {nets: {VDD VSS VSS VDD}} \
#{offset_start: 400 400} {parameters: 4 80 6 120 3.344 false}} \
#   -blockage {{{nets: VDD} {block: u0_2 u0_3}}} \
#   -core -extension {{stop: outermost_ring}}

#create_pg_mesh_pattern pg_mesh_IA_IB \
#   -parameters {w1 p1 w2 p2 f t} \
#   -layers {{{vertical_layer: IB} {width: @w1} {spacing: interleaving} \
#        {pitch: @p1} {offset: @f} {trim: @t}} \
# 	     {{horizontal_layer: IA} {width: @w2} {spacing: interleaving} \
#        {pitch: @p2} {offset: @f} {trim: @t}}}

create_pg_mesh_pattern pg_mesh_IA_IB \
   -parameters {w1 p1 w2 p2 f t} \
   -layers {{{vertical_layer: IB} {width: @w1} {spacing: interleaving} \
        {pitch: @p1} {offset: @f} {trim: @t}}} 


#option 1 : make region & extension
create_pg_region {pg_0} -polygon {{300 300} {3659 3659}}

#set_pg_strategy mesh1 -pg_regions pg_0 -pattern {{pattern: pg_mesh_IA_IB} {nets: {VDD VSS}} {parameters: 5 130 5 130 10 false}} -blockage {{{nets: VDD VSS} {block:UTOP/Ufifo  \
UTOP/Umemory_wrapper}}} -extension {stop: outermost_ring}

#smkcow : check which is better between up  line and down line
set_pg_strategy mesh1 -pg_regions pg_0 -pattern {{pattern: pg_mesh_IA_IB} {nets: {VDD VSS}} {parameters: 5 100 5 100 10 false}} -extension {stop: outermost_ring}

#option 2
#set_pg_strategy mesh1 -polygon {{332.880 367.430} {3632.615 3590.200}} -pattern {{pattern: pg_mesh_IA_IB} {nets: {VDD VSS}} {parameters: 5 120 5 120 10 false}} -blockage {{{nets: VDD VSS} {block:UTOP/Ufifo  \
UTOP/Umemory_wrapper}}} -extension {stop: outermost_ring}

#Execute 3-2
compile_pg -strategies mesh1 


################################################################################
#-------------------------------------------------------------------------------
# 2 N D    P G   C O N N E C T I O N S
#-------------------------------------------------------------------------------
################################################################################

#set_pg_strategy outer_ring_VDD_VSS -polygon {{200 200} {3750 3750}} -pattern {{name: ring_pattern_IA_IB} {nets: {VDD VSS}} {offset: {5 5}}}
set_pg_strategy outer_ring_VDD_VSS -polygon {{200 200} {3759 3759}} -pattern {{name: ring_pattern_M7_IA} {nets: {VDD VSS}} {offset: {5 5}}}

#set_pg_strategy outer_ring_DVSS -polygon {{170 170} {3786 3790}} -pattern {{name: ring_pattern_IA_IB} {nets: {DVSS}} {offset: {5 5}}}
#set_pg_strategy outer_ring_DVDD -polygon {{206 206} {3740 3755}} -pattern {{name: ring_pattern_IA_IB} {nets: {DVDD}} {offset: {5 5}}}
#set_pg_strategy outer_ring_DVSS -polygon {{170 170} {3786 3790}} -pattern {{name: ring_pattern_M3_M4} {nets: {DVSS}} {offset: {5 5}}}
#set_pg_strategy outer_ring_DVDD -polygon {{206 206} {3740 3755}} -pattern {{name: ring_pattern_M3_M4} {nets: {DVDD}} {offset: {5 5}}}

#Execute 4
compile_pg -strategies {outer_ring_VDD_VSS}
#compile_pg -strategies {outer_ring_DVDD}
#compile_pg -strategies {outer_ring_DVSS}


################################################################################
#-------------------------------------------------------------------------------
# P A D   T O   R I N G   P G   C O N N E C T I O N S
#-------------------------------------------------------------------------------
################################################################################
# This design has pad so turn on pad_pattern
set_app_options -name plan.pgroute.treat_pad_as_macro -value true
set_app_options -name plan.pgroute.hmpin_connection_target_layers -value {M3 M4 M5 M6 M7 IA IB}

####################
##### smkcow ######
####################
# All Power cell like PVDD, PVSS has metal pin from M3 to IB

#create_pg_macro_conn_pattern io_to_ring -pin_conn_type scattered_pin -pin_layers {IA IB} -layers {IA IB}
#create_pg_macro_conn_pattern io_to_ring -pin_conn_type scattered_pin -pin_layers {M7 IA} -layers {IA IB}

# smkcow : layers option should have h, v direction layers
#create_pg_macro_conn_pattern io_to_ring_connect_h -pin_conn_type scattered_pin -pin_layers {IA} -layers {M7 IA}
#create_pg_macro_conn_pattern io_to_ring_connect_v -pin_conn_type scattered_pin -pin_layers {M7} -layers {M7 IA}
create_pg_macro_conn_pattern io_to_ring_connect_h -pin_conn_type scattered_pin -pin_layers {IA}
create_pg_macro_conn_pattern io_to_ring_connect_v -pin_conn_type scattered_pin -pin_layers {M7}
#create_pg_macro_conn_pattern io_to_ring -pin_conn_type scattered_pin -pin_layers {M7 IA} -layers {M7 IA}

#set_pg_strategy s_io_to_ring -macros {pad*}  \
    -pattern {{name: io_to_ring}{nets: DVDD DVSS}}

set_pg_strategy s_io_to_ring_h -macros "$io_PVDD_cells $io_PVSS_cells" -pattern {{name: io_to_ring_connect_h}{nets: VDD VSS}}
set_pg_strategy s_io_to_ring_v -macros "$io_PVDD_cells $io_PVSS_cells" -pattern {{name: io_to_ring_connect_v}{nets: VDD VSS}}
#set_pg_strategy VDD_io_to_ring -macros "$io_PVSS_cells $io_PVDD_cells" -pattern {{name: io_to_ring_connect_h}{nets: VDD VSS}}
#set_pg_strategy VSS_io_to_ring -macros "$io_PVSS_cells" -pattern {{name: io_to_ring}{nets: VSS}}

#compile_pg -strategies s_io_to_ring -ignore_drc
compile_pg -strategies s_io_to_ring_h
compile_pg -strategies s_io_to_ring_v
#compile_pg -strategies VDD_io_to_ring
#compile_pg -strategies VSS_io_to_ring

#perhaps....
#connect_pg_net -net VDD [remove_from_collection [get_pins */VDD] [get_pins pad*/VDD]]
#connect_pg_net -net VSS [remove_from_collection [get_pins */VSS] [get_pins pad*/VSS]]




################################################################################
#-------------------------------------------------------------------------------
# M A C R O   P G   C O N N E C T I O N S
#-------------------------------------------------------------------------------
################################################################################
#set toplevel_hms [filter_collection [get_cells * -physical_context] "is_hard_macro == true"]
#set_pg_strategy macro_con -macros $toplevel_hms -pattern {{name: hm_pattern} {nets: {VDD VDD_LOW VSS}}}
#set_pg_strategy macro_con -macros $toplevel_hms -pattern {{name: hm_pattern} {nets: {VDD VSS}}}



################################################################################
#-------------------------------------------------------------------------------
# P O W E R  P L A N  S T R U C T U R E
#-------------------------------------------------------------------------------
################################################################################
#create_pg_region r0 -core \
#	-exclude_macros [get_cells -filter "design_type==macro"] \
#	-macro_offset "2 2" -expand -0

################################################################################
#-------------------------------------------------------------------------------
# S T R A P 
#-------------------------------------------------------------------------------
################################################################################
#strap will be done at post_pns.tcl
#create_pg_strap -layer B2 -direction vertical -width 5.0000 -net VDD -start 35.0000 -stop 275 -pitch 60 -extend_low innermost_ring -extend_high innermost_ring
#create_pg_strap -layer B2 -direction vertical -width 5.0000 -net VSS -start 41 -stop 281 -pitch 60 -extend_low innermost_ring -extend_high innermost_ring

################################################################################
#-------------------------------------------------------------------------------
# S T A N D A R D    C E L L    R A I L    I N S E R T I O N
#-------------------------------------------------------------------------------
################################################################################
create_pg_std_cell_conn_pattern \
    std_cell_rail  \
    -layers {M2} \
    -rail_width {0.134 0.134} \
    -rail_mask {follow_pin}

#set_pg_strategy rail_strat -core \
#    -pattern { {name : std_cell_rail} \
#    {nets: VDD VSS} } \
#    -blockage {{{placement_blockages : all}}} \

set_pg_strategy rail_strat \
    -pg_regions pg_0 \
    -pattern { {name : std_cell_rail} \
    {nets: VDD VSS} } \
    -blockage {{{placement_blockages : all}}} \

compile_pg -strategies rail_strat




#set  gnd_pins  [get_pins -all -of_objects  [get_cell *] -filter "name==VSS"]


#set_pg_strategy rail_strat -core \
    -pattern {{name: std_cell_rail} {nets: VDD VSS} } \
    -blockage {{{nets : {VDD VSS}}{macros_with_keepout : {Ucmos10lpsvrv_ra1_hd_256x17m8}}}} \
    -extension {stop: innermost_ring}
#    -extension {{stop: pad_ring}}

# Reference :: remove_*
#remove_routes -lib_cell_pin_connect
#remove_pg_strategies rail_strat   
#remove_cells [get_cells *FILLTIE*] 
#remove_keepout_margins Ucmos10lpsvrv_ra1_hd_256x17m8/KEEPOUT_hard_OUTER_0
#create_keepout_margin -type hard -outer { 8.0000 2.0000 2.0000 2.0000 } {Ucmos10lpsvrv_ra1_hd_256x17m8}
#remove_routes -stripe
#remove_routes -ring
#remove_routes -lib_cell_pin_connect


# add End cap cell
#set_boundary_cell_rules -left_boundary_cell cmos10lprvt_m_frame/FILLTIEMTR -right_boundary_cell cmos10lprvt_m_frame/FILLTIEMTR

# Add tap cell array
#create_tap_cells -lib_cell cmos10lprvt_m_frame/FILLTIEMTR -distance 118.8000 -pattern stagger -skip_fixed_cells
#compile_boundary_cells

# macro ring pattern 
#create_pg_ring_pattern macro_pattern -horizontal_layer M3 -horizontal_width {5} -vertical_layer M4 -vertical_width {5} -corner_bridge false
#set_pg_strategy macro_con -macros Ucmos10lpsvrv_ra1_hd_256x17m8 -pattern {{name : macro_pattern}{nets : {VDD VSS}}{offset: {2 2}}}
create_pg_mesh_pattern pg_mesh1 -layers {{{vertical_layer: M5} {width: 0.2} {spacing: interleaving} {pitch: 10} {trim: false} }} -via_rule {}
set_pg_strategy pg_mesh1 -macros {top_core_0/memset_0/MEM_0/mem_inst_0 \
					top_core_0/memset_0/MEM_1/mem_inst_0 \
					top_core_0/memset_0/MEM_2/mem_inst_0 \
					top_core_0/memset_0/MEM_3/mem_inst_0 \
					top_core_0/memset_0/MEM_4/mem_inst_0 \
					top_core_0/memset_0/MEM_5/mem_inst_0 \
					top_core_0/memset_0/MEM_6/mem_inst_0 \
					top_core_0/memset_0/MEM_7/mem_inst_0 \
					top_core_0/memset_0/MEM_8/mem_inst_0 \
					top_core_0/memset_0/MEM_9/mem_inst_0 \
					top_core_0/memset_0/MEM_10/mem_inst_0 \
					top_core_0/memset_0/MEM_11/mem_inst_0 \
					top_core_0/memset_0/MEM_12/mem_inst_0 \
					top_core_0/memset_0/MEM_13/mem_inst_0 \
					top_core_0/memset_0/MEM_14/mem_inst_0 \
					top_core_0/memset_0/MEM_15/mem_inst_0 \
					top_core_0/memset_0/MEM_16/mem_inst_0 \
					top_core_0/memset_0/MEM_17/mem_inst_0 \
					top_core_0/memset_0/MEM_18/mem_inst_0 \
					top_core_0/memset_0/MEM_19/mem_inst_0 \
					top_core_0/memset_0/MEM_20/mem_inst_0 \
					top_core_0/memset_0/MEM_21/mem_inst_0 \
					top_core_0/memset_0/MEM_22/mem_inst_0 \
					top_core_0/memset_0/MEM_23/mem_inst_0 \
					top_core_0/memset_0/MEM_24/mem_inst_0 \
					top_core_0/memset_0/MEM_25/mem_inst_0 \
					top_core_0/memset_0/MEM_26/mem_inst_0 \
					top_core_0/memset_0/MEM_27/mem_inst_0 \
					top_core_0/memset_0/MEM_28/mem_inst_0 \
					top_core_0/memset_0/MEM_29/mem_inst_0 \
					top_core_0/memset_0/MEM_30/mem_inst_0 \
					top_core_0/memset_0/MEM_31/mem_inst_0 \
					top_core_0/memset_0/MEM_32/mem_inst_0 \
					top_core_0/memset_0/MEM_33/mem_inst_0 \
					top_core_0/memset_0/MEM_34/mem_inst_0 \
					top_core_0/memset_0/MEM_35/mem_inst_0 \
					top_core_0/memset_0/MEM_36/mem_inst_0 \
					top_core_0/memset_0/MEM_37/mem_inst_0 \
					top_core_0/memset_0/MEM_38/mem_inst_0 \
					top_core_0/memset_0/MEM_39/mem_inst_0 \
					top_core_0/memset_0/MEM_40/mem_inst_0 \
					top_core_0/memset_0/MEM_41/mem_inst_0 \
					top_core_0/memset_0/MEM_42/mem_inst_0 \
					top_core_0/memset_0/MEM_43/mem_inst_0 \
					top_core_0/memset_0/MEM_44/mem_inst_0 \
					top_core_0/memset_0/MEM_45/mem_inst_0 \
					top_core_0/memset_0/MEM_46/mem_inst_0 \
					top_core_0/memset_0/MEM_47/mem_inst_0 \
					top_core_0/memset_0/MEM_48/mem_inst_0 \
					top_core_0/memset_0/MEM_49/mem_inst_0 \
					top_core_0/memset_0/MEM_50/mem_inst_0 \
					top_core_0/memset_0/MEM_51/mem_inst_0 \
					top_core_0/memset_0/MEM_52/mem_inst_0 \
					top_core_0/memset_0/MEM_53/mem_inst_0 \
					top_core_0/memset_0/MEM_54/mem_inst_0 \
					top_core_0/memset_0/MEM_55/mem_inst_0 \
					top_core_0/memset_0/MEM_56/mem_inst_0 \
					top_core_0/memset_0/MEM_57/mem_inst_0 \
					top_core_0/memset_0/MEM_58/mem_inst_0 \
					top_core_0/memset_0/MEM_59/mem_inst_0 \
					top_core_0/memset_0/MEM_60/mem_inst_0 \
					top_core_0/memset_0/MEM_61/mem_inst_0 \
					top_core_0/memset_0/MEM_62/mem_inst_0 \
					top_core_0/memset_0/MEM_63/mem_inst_0 \
					top_core_0/imem_0/mem_inst_0 \
					top_core_0/imem_0/mem_inst_1 \
					top_core_0/imem_0/mem_inst_2 \
					top_core_0/imem_0/mem_inst_3} \
-pattern {{name : pg_mesh1}{nets : {VDD VSS}}} \
-extension {{{direction : T}{stop : innermost_ring}}{{direction : B}{stop : innermost_ring}}}

compile_pg -strategies pg_mesh1


################################################################################
#-------------------------------------------------------------------------------
# S T R A P 
#-------------------------------------------------------------------------------
################################################################################


create_pg_strap -layer IA -direction horizontal -width 3.8 -net VDD -start 700 -stop 3500 -pitch 700 -low_end 200 -high_end 250 -extend_low first_target -extend_high first_target
create_pg_strap -layer IA -direction horizontal -width 3.8 -net VSS -start 690 -stop 3490 -pitch 700 -low_end 200 -high_end 250 -extend_low first_target -extend_high first_target

create_pg_strap -layer IA -direction horizontal -width 3.8 -net VDD -start 700 -stop 3500 -pitch 700 -low_end 3700 -high_end 3750 -extend_low first_target -extend_high first_target
create_pg_strap -layer IA -direction horizontal -width 3.8 -net VSS -start 690 -stop 3490 -pitch 700 -low_end 3700 -high_end 3750 -extend_low first_target -extend_high first_target

create_pg_strap -layer M7 -direction vertical -width 2.58 -net VDD -start 800 -stop 3600 -pitch 700 -low_end 200 -high_end 250 -extend_low first_target -extend_high first_target
create_pg_strap -layer M7 -direction vertical -width 2.58 -net VSS -start 790 -stop 3590 -pitch 700 -low_end 200 -high_end 250 -extend_low first_target -extend_high first_target

create_pg_strap -layer M7 -direction vertical -width 2.58 -net VDD -start 800 -stop 3600 -pitch 700 -low_end 3700 -high_end 3750 -extend_low first_target -extend_high first_target
create_pg_strap -layer M7 -direction vertical -width 2.58 -net VSS -start 790 -stop 3590 -pitch 700 -low_end 3700 -high_end 3750 -extend_low first_target -extend_high first_target


#create_pg_strap -layer IB -direction vertical -width 5.0000 -net VDD -start 30 -stop 60 -pitch 30 -extend_low innermost_ring -extend_high innermost_ring \
-via_rule { \
{{existing: ring}{via_master: IA_IB_via_rule}} \
{{intersection: undefined} {via_master: default}} \
}
#create_pg_strap -layer IB -direction vertical -width 5.0000 -net VSS -start 38 -stop 68 -pitch 30 -extend_low innermost_ring -extend_high innermost_ring \
-via_rule { \
{{existing: ring}{via_master: IA_IB_via_rule}} \
{{intersection: undefined} {via_master: default}} \
}

#create_pg_strap -layer M7 -direction vertical -width 1 -net VDD -start 200 -stop 1400 -pitch 200 -extend_low innermost_ring -extend_high innermost_ring -via_rule {{{existing: ring}{via_master: M6_M7_via_rule}} {{intersection: undefined} {via_master: default}}}

#create_pg_strap -layer M7 -direction vertical -width 1 -net VSS -start 250 -stop 1450 -pitch 200 -extend_low innermost_ring -extend_high innermost_ring -via_rule {{{existing: ring}{via_master: M6_M7_via_rule}} {{intersection: undefined} {via_master: default}}}

