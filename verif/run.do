# Close the current project (if one is open)
catch {project close}
# Create a new project
project new . jpl_adc_scaling_project

project compileall

vlog jpl_adc_scaling_tb.sv +acc
vlog ../rtl/jpl_adc_scaling.sv +acc

vsim work.jpl_adc_scaling_tb
do wave.do

radix -decimal  
run -all
wave zoom full