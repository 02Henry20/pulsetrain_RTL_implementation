
## 3. Floorplan
initialize_floorplan -control_type die -side_length {95 150} -core_offset {10}

move_objects [get_cell Ucmos28lpp_ra1w_hd_1024x17m8] -rotate_by CW90
move_objects [get_cell Ucmos28lpp_ra1w_hd_1024x17m8] -to {35.614 28.930}
create_keepout_margin -type hard -outer { 3 3 3 3  } {Ucmos28lpp_ra1w_hd_1024x17m8}
set_fixed_objects [get_flat_cells -filter "is_hard_macro"]
source ../../netlist/memory_wrapper.tdf
place_pins -self

# placement blockage
create_placement_blockage -type hard -boundary {{35.2200 27.1000} {35.2200 141.4000} {90.0800 141.4000} {90.0800 27.1000}}

# route guide
create_routing_guide -boundary {{35.425 28.930} {84.880 139.600}} -layers {M1 V1 M2 V2 M3 V3 M4 V4 M5 V5 M6 V6 M7} -preferred_direction_only

 #ENDCAP & TAP Cell insertion
set_boundary_cell_rules -left_boundary_cell base_rvt_c130_frame/ENDCAPTIE4_A9TR -right_boundary_cell base_rvt_c130_frame/ENDCAPTIE4_A9TR
create_tap_cells -lib_cell base_rvt_c130_frame/FILLTIE4_A9TR -distance 118.3000 -pattern stagger -skip_fixed_cells
compile_boundary_cells

## Powerplan

### Example script.  For details please refer to the IC Compiler II Design Planning User Guide and command man pages
connect_pg_net
create_net -power VDD
create_net -power VSS
connect_pg_net -net {VDD} [get_pins -design [current_block] -quiet -physical_context {*VDD*}]
connect_pg_net -net {VSS} [get_pins -design [current_block] -quiet -physical_context {*VSS*}]


## Memory
connect_pg_net -net VDD [get_pins Ucmos28lpp_ra1w_hd_1024x17m8/VDDCE]
connect_pg_net -net VSS [get_pins Ucmos28lpp_ra1w_hd_1024x17m8/VSSE]
connect_pg_net -net VDD [get_pins Ucmos28lpp_ra1w_hd_1024x17m8/VDDPE]

## For std rail
connect_pg_net -automatic

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

################################################################

## Core Ring
create_pg_ring_pattern ring_pattern_core  -horizontal_layer M6  -horizontal_width {1} \
-vertical_layer M7  -vertical_width {1}  -corner_bridge false

set_pg_strategy ring_pattern_core -core -pattern {{name : ring_pattern_core}{nets : {VDD VSS}}{offset : {2 2}}} -extension {{{side : 1 2 3 4 }{stop : design_boundary_and_generate_pin}}}

## Mem Ring
create_pg_ring_pattern ring_pattern_mem  -horizontal_layer M4  -horizontal_width {0.5} \
-vertical_layer M5  -vertical_width {0.5}  -via_rule {{intersection: all }{via_master: default}} \
-corner_bridge false

set_pg_strategy ring_pattern_mem -macros Ucmos28lpp_ra1w_hd_1024x17m8 \
-pattern {{name : ring_pattern_mem}{nets : {VDD VSS}}{offset : {0.5 0.5}}} \
-extension {{{side : 1 3}{stop : outermost_ring}}}

## Mem mesh
create_pg_mesh_pattern pg_mesh1 -layers {{{vertical_layer: M5} {width: 0.2} {spacing: interleaving} {pitch: 10} {trim: false} }} -via_rule {}
set_pg_strategy pg_mesh1 -macros Ucmos28lpp_ra1w_hd_1024x17m8 -pattern {{name : pg_mesh1}{nets : {VDD VSS}}} \
-extension {{{direction : T}{stop : outermost_ring}}{{direction : B}{stop : innermost_ring}}}


## Std rail
create_pg_std_cell_conn_pattern \
    std_cell_rail  \
    -layers {M2} \
    -rail_width {0.134 0.134} \
    -rail_mask {follow_pin}

set_pg_strategy rail_strat -core \
    -pattern { {name : std_cell_rail} \
    {nets: VDD VSS} } \
-blockage {{{placement_blockages : all}}} \
    -extension {stop: outermost_ring}

###  Compile PG

compile_pg -strategies ring_pattern_core
compile_pg -strategies ring_pattern_mem
compile_pg -strategies pg_mesh1
compile_pg -strategies rail_strat



## Verify PG
check_pg_drc

check_pg_missing_vias

check_pg_connectivity


