#!/usr/bin/tclsh

if { $argc != 1 } {
    puts "Need TOP_MODULE name as argument"
} else {
    set topmodule [lindex $argv 0]
    puts "TOP_MODULE = $topmodule"

}

open_design  "${topmodule}.adb"

#save design
save_design  "$topmodule"

#generate reports
report \
    -type "pin" \
    -listby "name" \
    {report_pin_proasic.rpt}

report \
    -type "status" \
    {report_status_proasic.rpt}

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
    {report_timer_max_proasic.rpt}

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
    {report_timer_min_proasic.rpt}

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

# Generate PROASIC version
#generate SDF file
backannotate \
     -format "sdf" \
     -language "verilog" \
     -netlist

#export netlist
export \
     -format "verilog" \
     "${topmodule}_proasic.vnh"

#export programming file
export \
     -format "pdb" \
     -feature "prog_fpga" \
     "${topmodule}_proasic.pdb"

export \
    -format "log" \
    "${topmodule}_par_proasic.log"
