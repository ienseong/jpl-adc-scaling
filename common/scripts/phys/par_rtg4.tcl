#!/usr/bin/tclsh

if { $argc != 11 } {
    puts "ERROR par_rtg4.tcl:: 11 arguements need to be passed in"
    exit
} else {
    set unit         [lindex $argv 0]
    set topmodule    [lindex $argv 1]
    set technology   [lindex $argv 2]
    set part         [lindex $argv 3]
    set chip_package [lindex $argv 4]
    set speed        [lindex $argv 5]
    set voltage      [lindex $argv 6]
    set iostd        [lindex $argv 7]
    set temprange    [lindex $argv 8]
    set voltrange    [lindex $argv 9]
    set effort_level [lindex $argv 10]
    puts "UNIT       = $unit"
    puts "TOP_MODULE = $topmodule"
    puts "TECHNOLOGY = $technology"
    puts "PART       = $part"
    puts "PACKAGE    = $chip_package"
    puts "SPEED      = $speed"
    puts "VOLTAGE    = $voltage"
    puts "IOSTD      = $iostd"
    puts "TEMP_RANGE = $temprange"
    puts "VOLT_RANGE = $voltrange"
    puts "EFFORT_LEVEL = $effort_level"
}

set phys_dir $::env(SBOX)/${unit}/phys

#set new design and family
new_design\
    -name "$topmodule"\
    -family "$technology"

#import netlists
import\
    -format "edif"\
    -netlist_naming "Generic"\
    -edif_flavor "GENERIC" "../syn/rev_rtg4/${unit}.edf"\
    -format "sdc" "$phys_dir/constraints/${unit}_rtg4_par.sdc"\
    -format "pdc" -abort_on_error "NO" "$phys_dir/constraints/${unit}_rtg4_par.pdc"

#set device, package, speed grade, IO, and operating conditions
set_device\
    -die "$part"\
    -package "$chip_package"\
    -speed "$speed"\
    -voltage "$voltage"\
    -iostd "$iostd"\
    -temprange "$temprange"\
    -voltrange "$voltrange"

#compile
compile -combine_register "1"

#save design
save_design  "$topmodule"

#layout
layout\
    -timing_driven\
    -place_incremental "ON" \
    -route_incremental "ON" \
    -placer_high_effort "ON" \
    -show_placer_seed   \
    -placer_seed 0 \
    -mindel_repair "ON"

#save design
save_design  "$topmodule"

#generate reports
report \
    -type "pin" \
    -listby "name" \
    {report_pin.rpt}

report \
    -type "status" \
    {report_status.rpt}

report \
    -type "timer" \
    -analysis "max" \
    -print_summary "yes" \
    -use_slack_threshold "no" \
    -print_paths "yes" \
    -max_paths 100 \
    -include_user_sets "yes" \
    -include_pin_to_pin "yes" \
    -select_clock_domains "no" \
    {report_timer_max.rpt}

report \
    -type "timer" \
    -analysis "min" \
    -print_summary "yes" \
    -use_slack_threshold "no" \
    -print_paths "yes" \
    -max_paths 100 \
    -include_user_sets "yes" \
    -include_pin_to_pin "yes" \
    -select_clock_domains "no" \
    {report_timer_min.rpt}

report \
    -type timing_violations \
    -analysis max \
    {report_timing_violations_max.rpt}

report \
    -type timing_violations \
    -analysis min \
    {report_timing_violations_min.rpt}

report \
    -type datasheet \
    {report_datasheet.rpt}

#generate SDF files
backannotate \
     -format "sdf" \
     -language "verilog" \
     -netlist

#export netlist
export \
     -format "verilog" \
     "${topmodule}.vnh"

#export files
export \
    -format "pdb" \
     -feature "prog_fpga" \
     "${topmodule}.pdb"

export \
    -format "log" \
     "${topmodule}.log"

#save design
save_design  "$topmodule"
