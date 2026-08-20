## Antenna TCL file for IC Compiler

#set lib [current_mw_lib]
#remove_antenna_rules $lib
#
#define_antenna_rule $lib -mode 1 -diode_mode 6 -metal_ratio 270 -cut_ratio 9
#define_antenna_layer_rule $lib -mode 1 -layer "M1" -ratio 270.0 -diode_ratio {0.0 0.0 2.0 0.0}
#define_antenna_layer_rule $lib -mode 1 -layer "V1" -ratio 9.0 -diode_ratio {0.0 0.0 5.0 0.0}
#define_antenna_layer_rule $lib -mode 1 -layer "M2" -ratio 270.0 -diode_ratio {0.0 0.0 2.0 0.0}
#define_antenna_layer_rule $lib -mode 1 -layer "V2" -ratio 9.0 -diode_ratio {0.0 0.0 5.0 0.0}
#define_antenna_layer_rule $lib -mode 1 -layer "M3" -ratio 270.0 -diode_ratio {0.0 0.0 2.0 0.0}
#define_antenna_layer_rule $lib -mode 1 -layer "V3" -ratio 9.0 -diode_ratio {0.0 0.0 5.0 0.0}
#define_antenna_layer_rule $lib -mode 1 -layer "M4" -ratio 270.0 -diode_ratio {0.0 0.0 2.0 0.0}
#define_antenna_layer_rule $lib -mode 1 -layer "W0" -ratio 9.0 -diode_ratio {0.0 0.0 5.0 0.0}
#define_antenna_layer_rule $lib -mode 1 -layer "B1" -ratio 270.0 -diode_ratio {0.0 0.0 2.0 0.0}
#define_antenna_layer_rule $lib -mode 1 -layer "W1" -ratio 9.0 -diode_ratio {0.0 0.0 5.0 0.0}
#define_antenna_layer_rule $lib -mode 1 -layer "B2" -ratio 270.0 -diode_ratio {0.0 0.0 2.0 0.0}
#define_antenna_layer_rule $lib -mode 1 -layer "YT" -ratio 9.0 -diode_ratio {0.0 0.0 5.0 0.0}
#define_antenna_layer_rule $lib -mode 1 -layer "EA" -ratio 270.0 -diode_ratio {0.0 0.0 2.0 0.0}
#define_antenna_layer_rule $lib -mode 1 -layer "JT" -ratio 9.0 -diode_ratio {0.0 0.0 5.0 0.0}
#define_antenna_layer_rule $lib -mode 1 -layer "OA" -ratio 270.0 -diode_ratio {0.0 0.0 2.0 0.0}
#define_antenna_layer_rule $lib -mode 1 -layer "VV" -ratio 9.0 -diode_ratio {0.0 0.0 5.0 0.0}
#define_antenna_layer_rule $lib -mode 1 -layer "LB" -ratio 270.0 -diode_ratio {0.0 0.0 2.0 0.0}


define_antenna_rule -mode 1 -diode_mode 6 -metal_ratio 270 -cut_ratio 9
define_antenna_layer_rule -mode 1 -layer "M1" -ratio 270.0 -diode_ratio {0.0 0.0 2.0 0.0}
define_antenna_layer_rule -mode 1 -layer "V1" -ratio 9.0 -diode_ratio {0.0 0.0 5.0 0.0}
define_antenna_layer_rule -mode 1 -layer "M2" -ratio 270.0 -diode_ratio {0.0 0.0 2.0 0.0}
define_antenna_layer_rule -mode 1 -layer "V2" -ratio 9.0 -diode_ratio {0.0 0.0 5.0 0.0}
define_antenna_layer_rule -mode 1 -layer "M3" -ratio 270.0 -diode_ratio {0.0 0.0 2.0 0.0}
define_antenna_layer_rule -mode 1 -layer "V3" -ratio 9.0 -diode_ratio {0.0 0.0 5.0 0.0}
define_antenna_layer_rule -mode 1 -layer "M4" -ratio 270.0 -diode_ratio {0.0 0.0 2.0 0.0}
define_antenna_layer_rule -mode 1 -layer "W0" -ratio 9.0 -diode_ratio {0.0 0.0 5.0 0.0}
define_antenna_layer_rule -mode 1 -layer "B1" -ratio 270.0 -diode_ratio {0.0 0.0 2.0 0.0}
define_antenna_layer_rule -mode 1 -layer "W1" -ratio 9.0 -diode_ratio {0.0 0.0 5.0 0.0}
define_antenna_layer_rule -mode 1 -layer "B2" -ratio 270.0 -diode_ratio {0.0 0.0 2.0 0.0}
define_antenna_layer_rule -mode 1 -layer "YT" -ratio 9.0 -diode_ratio {0.0 0.0 5.0 0.0}
define_antenna_layer_rule -mode 1 -layer "EA" -ratio 270.0 -diode_ratio {0.0 0.0 2.0 0.0}
define_antenna_layer_rule -mode 1 -layer "JT" -ratio 9.0 -diode_ratio {0.0 0.0 5.0 0.0}
define_antenna_layer_rule -mode 1 -layer "OA" -ratio 270.0 -diode_ratio {0.0 0.0 2.0 0.0}
define_antenna_layer_rule -mode 1 -layer "VV" -ratio 9.0 -diode_ratio {0.0 0.0 5.0 0.0}
define_antenna_layer_rule -mode 1 -layer "LB" -ratio 270.0 -diode_ratio {0.0 0.0 2.0 0.0}

