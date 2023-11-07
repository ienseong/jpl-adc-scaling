#!/usr/bin/tclsh

if { $argc != 1 } {
    puts "Need TOP_MODULE name as arguement"
} else {
    set topmodule [lindex $argv 0]
    puts "TOP_MODULE = $topmodule"
}

set alsdir $::env(ALSDIR)

################################################################################
# Multi Pass
################################################################################

puts "<<<<< Starting extended_run_shell.tcl >>>>>"
exec $alsdir/bin/acttclsh $alsdir/scripts/extended_run_shell.tcl -adb $topmodule.adb -n 100 -starting_seed_index 1 -save_all -timing_driven -run_placer on -place_incremental on -route_incremental on  -mindel_repair on -compare_criteria violations
puts "<<<<< Finished extended_run_shell.tcl >>>>>"

################################################################################
# Open design (extended_run_shell closes it)
################################################################################

#open_design  {hk.adb}

################################################################################
# Reports
################################################################################

#puts "<<<<< Starting Reports >>>>>"

#report \
#    -type "pin" \
#    -listby "name" \
#    {report_pin.rpt}

#report \
#    -type "status" \
#    {report_status.rpt}

#report \
#    -type "timer" \
#    -analysis "max" \
#    -print_summary "yes" \
#    -use_slack_threshold "no" \
#    -print_paths "yes" \
#    -max_paths 100 \
#    -include_user_sets "yes" \
#    -include_pin_to_pin "yes" \
#    -select_clock_domains "no" \
#    {report_timer.rpt}

#save design
#save_design  "hk"

#puts "<<<<< Finishing Reports >>>>>"

################################################################################
# Generate Files
################################################################################

#puts "<<<<< Starting File Generate >>>>>"


#generate reports
#report \
#    -type "pin" \
#    -listby "name" \
#    {report_pin.rpt}

#report \
#    -type "status" \
#    "report_status_rtax.rpt"

#report \
#    -type "timer" \
#    -analysis "max" \
#    -print_summary "yes" \
#    -use_slack_threshold "no" \
#    -print_paths "yes" \
#    -max_paths 50 \
#    -max_expanded_paths 5 \
#    -include_user_sets "yes" \
#    -include_pin_to_pin "no" \
#    -select_clock_domains "no" \
#    "report_timer_max_rtax.rpt"

#report \
#    -type "timer" \
#    -analysis "min" \
#    -print_summary "yes" \
#    -use_slack_threshold "no" \
#    -print_paths "yes" \
#    -max_paths 50 \
#    -max_expanded_paths 5 \
#    -include_user_sets "yes" \
#    -include_pin_to_pin "no" \
#    -select_clock_domains "no" \
#    "report_timer_min_rtax.rpt"

#report \
#    -type timing_violations \
#    -analysis max \
#    "report_timing_violations_max_rtax.rpt"

#report \
#    -type timing_violations \
#    -analysis min \
#    "report_timing_violations_min_rtax.rpt"

#report \
#    -type datasheet \
#    report_datasheet_rtax.rpt


##generate SDF file
#backannotate \
#     -format "sdf" \
#     -language "verilog" \
#     -netlist

#export netlist
#export \
#     -format "verilog" \
#     "hk_rtax.vnh"


#export programming file
#export \
#     -format "pdb" \
#     -feature "prog_fpga" \
#     "hk_rtax.pdb"

#export programming file
#export \
#     -format "bts_stp" \
#     -feature "prog_fpga" \
#     "hk_rtax.stp"

#export \
#    -format "log" \
#    "hk_par_rtax.log"


#save design
#save_design  "hk"

#puts "<<<<< Finishing File Generate >>>>>"
