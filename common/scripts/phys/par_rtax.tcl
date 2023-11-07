#!/usr/bin/tclsh

if { $argc != 11 } {
    puts "ERROR par_rtax.tcl:: 11 arguements need to be passed in"
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

set phys_dir $::env(PWD)/../../..

#set new design and family
new_design\
    -name "$topmodule"\
    -family "$technology"

#import netlists
import\
    -format "edif"\
    -netlist_naming "Generic"\
    -edif_flavor "GENERIC" "../syn/rev_rtax/${unit}.edf"\
    -format "sdc" "$phys_dir/constraints/${unit}_rtax_par.sdc"\
    -format "pdc" -abort_on_error "NO" "$phys_dir/constraints/${unit}_rtax_par.pdc"

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
    -show_placer_seed   \
    -effort_level "$effort_level"\
    -placer_seed 0 \
    -mindel_repair "ON"

#save design
save_design  "$topmodule"

#generate reports
report \
    -type "pin" \
    -listby "name" \
    {report_pin_rtax.rpt}

report \
    -type "status" \
    {report_status_rtax.rpt}

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
    {report_timer_max_rtax.rpt}

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
    {report_timer_min_rtax.rpt}


report \
    -type timing_violations \
    -analysis max \
    {report_timing_violations_max_rtax.rpt}

report \
    -type timing_violations \
    -analysis min \
    {report_timing_violations_min_rtax.rpt}

report \
    -type datasheet \
    {report_datasheet_rtax.rpt}

#generate SDF files
backannotate \
     -format "sdf" \
     -language "verilog" \
     -netlist

#export netlist
export \
     -format "verilog" \
     "${topmodule}.vnh"

#export programming file
export \
     -format "AFM-APS2" \
     -trstb_pullup "yes" \
     -axprg_set_algo "OPA" \
     "${topmodule}_rtax.afm"

export \
    -format "log" \
     "${topmodule}_rtax.log"

#save design
save_design     "${topmodule}_ax.adb"

# Generate AX version
set_defvar "PDC_NMAT_DIE_MIGRATION" {1}
set_defvar "DRC_BLOCK_SKIP_DEVICE_CHECK" {1}
set_defvar "DSWIZARD_SKIP_INCOMPATIBLE_DIE_PKG_MESSAGE" {1}
set_defvar "SMAT_DISCARD_OLD_ROUTING" {1}
set_defvar "BLOCK_ROUTING_CONFLICTS" {DISCARD}
set_device -die "AX2000" -package "896 FBGA"
set_defvar "KBI_FIX" {1}

# Compile for AX
compile -pdc_abort_on_error "off" -pdc_eco_display_unmatched_objects "off" -pdc_eco_max_warnings 10000 -combine_register "off" -report_high_fanout_nets_limit 10
save_design  "${topmodule}_ax.adb"

# Run layout for AX
layout -timing_driven -place_incremental "fix" -effort_level "$effort_level" -mindel_repair "on"
save_design  "${topmodule}_ax.adb"

#generate reports
report \
    -type "pin" \
    -listby "name" \
    {report_pin_ax.rpt}

report \
    -type "status" \
    {report_status_ax.rpt}

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
    {report_timer_max_ax.rpt}

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
    {report_timer_min_ax.rpt}

report \
    -type timing_violations \
    -analysis max \
    {report_timing_violations_max_ax.rpt}

report \
    -type timing_violations \
    -analysis min \
    {report_timing_violations_min_ax.rpt}

report \
    -type datasheet \
    {report_datasheet_ax.rpt}

#export programming file
export \
     -format "AFM-APS2" \
     -trstb_pullup "yes" \
    "${topmodule}_ax.afm"

export \
    -format "log" \
     "${topmodule}_ax.log"

save_design "${topmodule}_ax.adb"
