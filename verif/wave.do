onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Params
add wave -noupdate /jpl_adc_scaling_tb/jpl_adc_scaling/B
add wave -noupdate /jpl_adc_scaling_tb/jpl_adc_scaling/S
add wave -noupdate /jpl_adc_scaling_tb/jpl_adc_scaling/D
add wave -noupdate /jpl_adc_scaling_tb/jpl_adc_scaling/LOG2AVG
add wave -noupdate -divider Inputs
add wave -noupdate /jpl_adc_scaling_tb/jpl_adc_scaling/i_clk
add wave -noupdate /jpl_adc_scaling_tb/jpl_adc_scaling/i_rst_n
add wave -noupdate /jpl_adc_scaling_tb/jpl_adc_scaling/i_start_cal
add wave -noupdate /jpl_adc_scaling_tb/jpl_adc_scaling/cur_adc_state
add wave -noupdate -color Orange -radix unsigned /jpl_adc_scaling_tb/s_adc_raw_valid_cont
add wave -noupdate /jpl_adc_scaling_tb/jpl_adc_scaling/i_adc_raw
add wave -noupdate /jpl_adc_scaling_tb/jpl_adc_scaling/i_adc_raw_valid
add wave -noupdate /jpl_adc_scaling_tb/jpl_adc_scaling/i_scale_val
add wave -noupdate /jpl_adc_scaling_tb/jpl_adc_scaling/i_ext_offset
add wave -noupdate -color Magenta /jpl_adc_scaling_tb/jpl_adc_scaling/i_offset_mode
add wave -noupdate /jpl_adc_scaling_tb/jpl_adc_scaling/i_threshold
add wave -noupdate -divider Outputs
add wave -noupdate /jpl_adc_scaling_tb/jpl_adc_scaling/o_result_valid
add wave -noupdate -color {Violet Red} /jpl_adc_scaling_tb/jpl_adc_scaling/o_cal_offset
add wave -noupdate /jpl_adc_scaling_tb/jpl_adc_scaling/s_cal_mode
add wave -noupdate -color Cyan /jpl_adc_scaling_tb/jpl_adc_scaling/o_cal_done
add wave -noupdate /jpl_adc_scaling_tb/jpl_adc_scaling/o_result
add wave -noupdate -color {Orange Red} /jpl_adc_scaling_tb/jpl_adc_scaling/o_fault_adc_raw
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {93604700 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 153
configure wave -valuecolwidth 84
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {2100 us}
