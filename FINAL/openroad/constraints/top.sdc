# -----------------------------------------------------------------------------
#  Timing constraints for the top level.
#
#  There is no clock yet: both macros are analog and the digital part of the
#  chip (DECODER) has not been written in Verilog. This file exists so the flow
#  has something to read, and so the place to put the real constraints is
#  obvious once there is a clock.
#
#  When a clock appears, it goes here, e.g.
#      create_clock -name clk -period 100.0 [get_ports clk]
#      set_input_delay  -clock clk 10.0 [all_inputs]
#      set_output_delay -clock clk 10.0 [all_outputs]
# -----------------------------------------------------------------------------

set_units -time ns -capacitance pF -current mA -voltage V -resistance kOhm

# 5 V supply, room temperature: matches the tt_025C_5v00 corner used in
# load_design.tcl.
set_max_fanout    10 [current_design]
set_max_transition 5.0 [current_design]
