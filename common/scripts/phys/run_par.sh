#!/bin/sh

unit=$1
topmodule=$2
technology=$3
target=$4
part=$5
package=$6
speed_grade=$7
voltage=$8
iostd=$9
temprange=${10}
voltrange=${11}
effortlevel=${12}
par_dir=${13}

# script directories
local_dir=$PWD/../..
par_tcl_fname=par_${target}
constraint_fname=${unit}_${target}_par
scr_dir=${local_dir}/phys/scripts
com_dir=$SBOX/common/scripts/phys

# timestamp info
start_par_time="$(date +"%Y_%m%d_%H%M_%S")"

# use this with the newest versions
if [ "$target" = "proasic" -o "$target" = "rtax" -o "$target" = "rtg4" ]; then
    cd ${par_dir}
    echo "# P&R Starting target=$target"
    echo "# Using Designer: $ALSDIR"
    if [ -f ${scr_dir}/${par_tcl_fname}.tcl ]; then
        designer "SCRIPT:${scr_dir}/${par_tcl_fname}.tcl $unit $topmodule $technology $part \"$package\" $speed_grade $voltage $iostd $temprange $voltrange $effortlevel"
    else
        designer "SCRIPT:${com_dir}/par_${target}.tcl $unit $topmodule $technology $part \"$package\" $speed_grade $voltage $iostd $temprange $voltrange $effortlevel"
    fi
elif [ -z "$target" ]; then
    echo "# P&R Failed no target device specified (options= rtax, proasic)"
fi

# Print out any errors
echo "################################################################"
echo "Unplaced IO:"
grep 'UnPlaced:' ${par_dir}/report_status.rpt
echo "################################################################"

# timestamp info
end_par_time="$(date +"%Y_%m%d_%H%M_%S")"
echo "################################################################"
echo "# Start Place and Route Time @ ${start_par_time}"
echo "# End Place and Route Time   @ ${end_par_time}"
echo "################################################################"
