#!/bin/sh

unit=$1
top_module=$2
target=$3
par_dir=$4
incremental_run=$5
iter=$6
analysis=$7

# script directories
scr_dir=$SBOX/${unit}/phys/scripts
com_dir=$SBOX/common/scripts/phys

# timestamp info
start_par_time="$(date +"%Y_%m%d_%H%M_%S")"

# use this with the newest versions
if [ "$target" = "rtax" -o "$target" = "proasic" ]; then
    cd ${par_dir}

    if [ -f ${scr_dir}/${unit}_multi_${incr_str}par_${target}.tcl ];then
        echo "# OVERRIDE common TCL file with local TCL file: ${scr_dir}/${unit}_multi_${incr_str}par_${target}.tcl"
        designer "SCRIPT:${scr_dir}/${unit}_multi_${incr_str}par_${target}.tcl $top_module $iter $incremental_run $analysis"
    else
        designer "SCRIPT:${com_dir}/multi_${incr_str}par_${target}.tcl $top_module $iter $incremental_run $analysis"
    fi
elif [ -z "$target" ]; then
    echo "# P&R Failed no target device specified (options= rtax, proasic)"
fi

end_par_time="$(date +"%Y_%m%d_%H%M_%S")"
echo "################################################################"
echo "# Start Place and Route Time @ ${start_par_time}"
echo "# End Place and Route Time   @ ${end_par_time}"
echo "################################################################"
