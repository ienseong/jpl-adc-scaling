#!/bin/sh

unit=$1
topmodule=$2
adb=$3
target=$4
par_dir=$5
effort=$6

# script directories
scr_dir=$SBOX/${unit}/phys/scripts
com_dir=$SBOX/common/scripts/phys

# timestamp info
start_par_time="$(date +"%Y_%m%d_%H%M_%S")"

# use this with the newest versions
if [ "$target" = "proasic" -o "$target" = "rtax" ]; then
    cd ${par_dir}
    echo "# STA Starting target=$target"
    echo "# Using Designer: $ALSDIR"
    echo "# Top Module: $topmodule"
    echo "# Build Directory: $par_dir"
    if [ -f ${scr_dir}/${unit}_par_${target}.tcl ]; then
        designer "SCRIPT:${scr_dir}/${unit}_sta_${target}.tcl $topmodule $adb "
    else
        designer "SCRIPT:${com_dir}/sta_${target}.tcl  $topmodule $adb "
    fi
elif [ "$target" = "xiliinx" ]; then
    echo "# Failed: run_timing.sh; xilinx not implemented yet"
elif [ -z "$target" ]; then
    echo "# Failed: run_timing.sh; no target device specified (options= rtax, proasic, xilinx)"
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
