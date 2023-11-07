#!/usr/bin/tclsh

if { $argc != 4 } {
    puts "Need TOP_MODULE name as argument"
    puts "Need ITER count argument - syntax: iter=<value>"
    puts "Need INCREMENTAL_RUN name as argument"
} else {
    set adbname [lindex $argv 0]
    puts "ADB Design Database = $adbname.adb"
    set iter [lindex $argv 1]
    puts "ITER = $iter"
    set incremental_run [lindex $argv 2]
    puts "INCREMENTAL_RUN = $incremental_run"
    set analysis [lindex $argv 3]
    puts "ANALYSIS = $analysis"
}

if { $incremental_run == "inc" } {
    set inc on
    set slack_criteria worst

} else {
    set inc off
    set slack_criteria worst
}

set alsdir $::env(ALSDIR)

################################################################################
# Multi Pass
################################################################################

puts "<<<<< Starting extended_run_shell.tcl >>>>>"
puts "<<<<< Iterations=$iter >>>>>"
exec $alsdir/bin/acttclsh $alsdir/scripts/extended_run_shell.tcl -adb $adbname.adb -n $iter -starting_seed_index 1 -save_all -timing_driven -run_placer on -place_incremental $inc -route_incremental $inc  -mindel_repair on -compare_criteria violations -analysis $analysis -slack_criteria $slack_criteria -stop_on_success
puts "<<<<< Finished extended_run_shell.tcl >>>>>"
