open_block /home/smkcow/QnA/digital/example_smkcow_DC_ICC2/memory_wrapper/PNR/SS/pnr/memory_wrapper:memory_wrapper.design
source -e ./rm_setup/icc2_pnr_setup.tcl

set_scenario_status * -active true -all
create_abstract -estimate_timing -timing_level compact -target_use implementation
create_frame -block_all true
save_block memory_wrapper:memory_wrapper.abstract
save_lib

# open abstract view and check
open_block /home/smkcow/QnA/digital/example_smkcow_DC_ICC2/memory_wrapper/PNR/SS/pnr/memory_wrapper:memory_wrapper.abstract
report_abstracts
save_block memory_wrapper:memory_wrapper.abstract

close_block memory_wrapper:memory_wrapper.abstract
close_block memory_wrapper:memory_wrapper.abstract

