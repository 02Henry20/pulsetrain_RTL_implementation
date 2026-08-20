puts "RM-info: Running script [info script]\n"

##########################################################################################
# Tool: IC Compiler II
# Script: settings.common.routing.tcl
# Purpose: Common routing (and extraction) related settings
# Version: N-2017.09-SP2 (February 20, 2018)
# Copyright (C) 2014-2018 Synopsys, Inc. All rights reserved.
##########################################################################################

## Timing-driven global route
set_app_options -name route.global.timing_driven -value true

set METAL_1 [get_attribute [get_layers -filter {mask_name==metal1}] name]
set METAL_2 [get_attribute [get_layers -filter {mask_name==metal2}] name]
set METAL_3 [get_attribute [get_layers -filter {mask_name==metal3}] name]
if {$MAX_ROUTING_LAYER != ""} {set_ignored_layers -max_routing_layer $MAX_ROUTING_LAYER}
if {$MIN_ROUTING_LAYER != "" && $MIN_ROUTING_LAYER != $METAL_2} {
	puts "RM-warning: MIN_ROUTING_LAYER is set to $MIN_ROUTING_LAYER - overriding with $METAL_2 instead"
}
set_ignored_layers -min_routing_layer $METAL_2
## Connect to cell pins by using vias and wires contained within the pin shapes for metal1
set_app_options -name route.common.connect_within_pins_by_layer_name -value [list [list $METAL_1 via_wire_all_pins]]

## Routing is allowed below the minimum layer only for pin connections
set_app_options -name route.common.global_min_layer_mode -value allow_pin_connection 

## Routing below the minimum layer is discouraged, but not disallowed
set_app_options -name route.common.net_min_layer_mode -value soft ;# use this if you want max routability
#set_app_options -name route.common.net_min_layer_mode -value allow_pin_connection ;# use this if you want minimum layer usage under net_min_layer

## Specify the double-patterning utilization percentage for each layer
#  ICC II default : 80 for M1 and M2, 85 for M3, and 90 for any higher layers
#  Example : set_app_options -name route.global.double_pattern_utilization_by_layer_name \
#  -value [list [list M1 80] [list M2 80] [list M3 85]]

puts "RM-info: Completed script [info script]\n"

