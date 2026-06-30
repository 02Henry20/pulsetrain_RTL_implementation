
###################################
#                                 #
#   UNITS                         #
#                                 #
###################################

# The unit of time in this library is 1ns 
# The unit of capacitance in this library is 1pF 
#


###################################
#                                 #
#   CLEAN-UP                      #
#                                 #
###################################

# Remove any existing constraints and attributes
#
reset_design


###################################
#                                 #
#   CLOCK DEFINITION              #
#                                 #
###################################

# 50Mhz clock is a 20ns period:
# So, let's treat 16 ns period to make chip stable (80% margin) 
create_clock -period 3 -name MAIN_CLOCK [get_ports CLK]

# External clock source latency is 2ns 
# and the maximum internal clock network insertion delay or latency is 1 ns:
# latency is only needed for AP application
set_clock_latency -source  -max 0.1 [get_clocks MAIN_CLOCK] 
set_clock_latency -max 0.1 [get_clocks MAIN_CLOCK]


# 600ps skew (+300ps and -300ps) 
# 400ps jitter 
# 500ps setup margin;
# This equals 1.5 ns of total uncertainty.
set_clock_uncertainty -setup 0.2 [get_clocks MAIN_CLOCK]


# The maximum clock transition is 1ns
set_clock_transition 0.1 [get_clocks MAIN_CLOCK]

###################################
#                                 #
#   SPECIAL CLOCK DEFINITION      #
#                                 #
###################################

# there are some kinds of clock series
# clock source is 1 but 3 or 4 kinds of clocks will be made
# so we should define the proper constraints

# divide clock by 2 to make HALF_CLK in top SoC module
#create_generated_clock -divide_by 2 -name HALF_CLK -source [get_ports CLK] [get_pins UTOP/half_clk_reg/Q]
#set_clock_transition 0.3 [get_clocks HALF_CLK]
#set_clock_latency -max 0.3 [get_clocks HALF_CLK]
#set_clock_uncertainty -setup 0.3 [get_clocks HALF_CLK]


###################################
#                                 #
#   INPUT/OUTPUT TIMING           #
#                                 #
###################################

# in/out is consists of board(switch,led), memory, UART
# Delay is estimated like below

#half is recommended
set_input_delay -max 0.2 -clock MAIN_CLOCK [all_inputs]
set_input_delay -min 0.05 -clock MAIN_CLOCK [all_inputs]
remove_input_delay [get_ports "CLK"] 

set_output_delay -max 0.2 -clock MAIN_CLOCK [all_outputs]
set_output_delay -min -0.05 -clock MAIN_CLOCK [all_outputs]
###################################
#                                 #
#   DESIGN AREA                   #
#                                 #
###################################

# Area Constraint
#
set_max_area 0


###################################
#                                 #
#   ENVIRONMENTAL ATTRIBUTES      #
#                                 #
###################################
#set_driving_cell -lib_cell pvhbcudtart -library ss65lp3p3v_lek_132_360_p125 -no_design_rule [all_inputs]
set_driving_cell -lib_cell PBIDIR_18_18_NT_DR -library io_gppr_cmos28lpp_t18_ff_1p155v_1p950v_m40c -no_design_rule [all_inputs]

set_load [load_of io_gppr_cmos28lpp_t18_ff_1p155v_1p950v_m40c/PBIDIR_18_18_NT_DR/A] [all_outputs]

#set_wire_load_mode "top"
#set auto_wire_load_selection false

# operating condition use to scale cell and net delays.
#
# smkcow : operating condition command is done at pad_TOP.mcmm.scenarios.tcl
#set_operating_condition -max ss_1p08v_125c -max_library scmetro_cmos10lp_rvt_ss_1p08v_125c_sadhm -min ff_1p32v_m40c -min_library scmetro_cmos10lp_rvt_ff_1p32v_m40c_sadhm

set_operating_conditions ff_1p100v_m40c -library sc9_cmos28lpp_base_rvt_ff_nominal_min_1p100v_m40c_sadhm -analysis_type on_chip_variation


#set_wire_load_model -name zero-wire-load-model


###################################
#                                 #
#   ETC ATTRIBUTES      	  #
#                                 #
###################################
# pin name of sub module was changed so dont touch

# We usually don't know the external capaciatnce 
# so insert buffers to isolate and protect inner logics


#set_dont_touch core_0
#set_dont_touch vector_0
#set_dont_touch vector_1
#set_dont_touch vector_2
#set_dont_touch vector_3
#set_dont_touch vector_4
#set_dont_touch vector_5
#set_dont_touch vector_6
#set_dont_touch vector_7
#set_dont_touch memset_0

set_isolate_ports [all_outputs]

set_ideal_network [get_ports "CLK RSTn RST"]

# no through pass assign syntax => insert buffers
set_fix_multiple_port_nets -all -buffer_constants -feedthroughs -constants
