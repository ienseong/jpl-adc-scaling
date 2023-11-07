##############################
# jpl_adc_scaling constraints file
##############################

create_clock -period 30 i_clk 

########  Input Delay Constraints  ########
#set_input_delay  -max 10.00 -clock { i_clk } [get_ports { i_adc_* }]
#set_input_delay  -min  0.00 -clock { i_clk } [get_ports { i_adc_* }]

########  Output Delay Constraints  ########
#set_output_delay  -max 18 -clock { i_clk } [get_ports { o_* }]
#set_output_delay  -min -2 -clock { i_clk } [get_ports { o_* }]

