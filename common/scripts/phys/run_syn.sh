#!/bin/sh

unit=$1
top_module=$2
technology=$3
target=$4
part=$5
package=$6
speed_grade=$7
date=$8
syn_dir=$9

local_dir=$PWD/../..
synth_tcl_fname=synth_${target}
constraint_fname=${unit}_${target}_syn
scr_dir=${local_dir}/phys/scripts
com_dir=$SBOX/common/scripts/phys

# timestamp info
start_par_time="$(date +"%Y_%m%d_%H%M_%S")"

# Generate a synthesis tcl file
mkdir -p $syn_dir
syn_scr=$syn_dir/${target}_synth.tcl
rtl_f=${local_dir}/rtl/rtl.f

### (START) Function Definitions ###

# Function Variables #
myFilenameArray=()
myIncFilenameArray=()
myIncPathArray=()

process_dot_f_file() {
    dot_f_name=$1
    while IFS= read -r line; do
        #echo "Text read from file: $line"
        # Delete any comment from "//" to end of string
        line=${line%%//*}
        #echo "Text read from file after removing comments: $line"
        if [[ $line == *"-f"* ]]; then
            echo "Found -f: $line"
            read -a strarr <<< "$line"
            tmp=$(eval "echo ${strarr[1]}")
            process_dot_f_file $tmp
        elif [[ $line == *"-y"* ]]; then
            echo "Found -y: $line"
        elif [[ $line == *"-v"* ]]; then
            #echo "Found -v: $line"
            read -a strarr <<< "$line"
            tmp=$(eval "echo ${strarr[1]}")
            base=`eval basename $tmp`
            if [[ ! " ${myIncFilenameArray[@]} " =~ " ${base} " ]]; then
                echo "add_file ${tmp}" >> $syn_scr
            fi
            myIncFilenameArray+=(${base})
        elif [[ $line == *"+incdir+"* ]]; then
            #echo "Found +incdir: $line"
            tmp=$(eval "echo ${line}" | sed 's/+incdir+//')
            base=`eval basename $tmp`
            #echo "Found Include filename: $tmp ; $base"
            if [[ ! " ${myIncPathArray[@]} " =~ " ${base} " ]]; then
                echo "set_option -include_path ${tmp}" >> $syn_scr
            fi
            myIncPathArray+=(${base})
        elif [[ $line == *"+libext+"* ]]; then
            #echo "Found +libext: $line"
            tmp=$(eval "echo ${line}" | sed 's/+libext+//')
            for libext in `echo $tmp | tr '+' ' '`; do
                echo "set_option -libext ${libext}" >> $syn_scr
            done
        elif [[ -z "$line" ]]; then
            echo "Removing blank line: $line"
        elif [[ $line == "#"* ]]; then
            echo "Removing comment: $line"
            #        elif [[ $line == *"//"* ]]; then
            #            echo "Found comment: $line"
        elif [[ $line == *".v"* || $line == *".sv"* ]]; then
            tmp=`eval echo $line`
            base=`eval basename $tmp`
            # Remove trailing white spaces
            base="${base%%*( )}"
            #echo "Found RTL filename: $tmp ; $base"
            if [[ ! " ${myFilenameArray[@]} " =~ " ${base} " ]]; then
                echo "add_file -verilog -vlog_std sysv ${tmp}" >> $syn_scr
            fi
            myFilenameArray+=(${base})
        elif [[ $line == *".vhd"* ]]; then
            tmp=`eval echo $line`
            base=`eval basename $tmp`
            #echo "Found RTL filename: $tmp ; $base"
            if [[ ! " ${myFilenameArray[@]} " =~ " ${base} " ]]; then
                echo "add_file -vhdl ${tmp}" >> $syn_scr
            fi
            myFilenameArray+=(${base})
        else
            echo "Warning: run_syn.sh unable to process line from $dot_f_name: $line"
        fi
    done < $dot_f_name
}
### (END) Function Definitions ###

echo "*** Creating synthesis script: $syn_scr ***"
echo "#-- This file is auto-generated by run_syn.sh" > $syn_scr
# Convert paths to relative paths.  Synthesis tool does not support absolute paths???
#DIN(try without); export SBOX=$(perl -e "use File::Spec; print File::Spec->abs2rel('$SBOX',  '$syn_dir');")

echo "#-- Create new project file" >> $syn_scr
echo "project -new" >> $syn_scr

echo "#-- Implementation" >> $syn_scr
echo "impl -add rev_${target} -type fpga" >> $syn_scr

echo "#-- Implementation Attributes" >> $syn_scr
echo "set_option -vlog_std sysv" >> $syn_scr

echo "#-- Device options" >> $syn_scr
if [ "$target" = "proasic" -o "$target" = "rtax" -o "$target" = "rtg4" -o "$target" = "xilinx" ]; then
    echo "set_option -technology ${technology}" >> $syn_scr
    echo "set_option -part ${part}" >> $syn_scr
    echo "set_option -package ${package}" >> $syn_scr
    echo "set_option -speed_grade ${speed_grade}" >> $syn_scr
    echo "set_option -top_module ${top_module}" >> $syn_scr
elif [ -z "$target" ]; then
    echo "# Synthesis Failed no target device specified (options= rtax, proasic, rtg4, xilinx)"
fi

echo "#-- From source" >> $syn_scr
# Override default TCL synth script if unit specific file is located in target directory
if [ -f ${scr_dir}/${synth_tcl_fname}.tcl ]; then
    echo " source ${scr_dir}/${synth_tcl_fname}.tcl" >> $syn_scr
else
    echo " source ${com_dir}/synth_${target}.tcl" >> $syn_scr
fi

process_dot_f_file $rtl_f

echo "#-- Add Constraint" >> $syn_scr
# Load the FDC file (if there is one), otherwise try to load the SDC.
if [ -f ${local_dir}/phys/constraints/${constraint_fname}.fdc ]; then
    echo "add_file -constraint \"${local_dir}/phys/constraints/${constraint_fname}.fdc\"" >> $syn_scr
elif [ -f ${local_dir}/phys/constraints/${constraint_fname}.sdc ]; then
    echo "add_file -constraint \"${local_dir}/phys/constraints/${constraint_fname}.sdc\"" >> $syn_scr
else
    echo "ERROR: Could not find ${local_dir}/phys/constraints/${constraint_fname}.fdc (or .sdc)"
    exit
fi

echo "#-- Implementation attributes" >> $syn_scr
echo "impl -active \"rev_${target}\"" >> $syn_scr
echo "project -result_file \"rev_${target}/${unit}.edf\"" >> $syn_scr

echo "project -run" >> $syn_scr
echo "project -save" >> $syn_scr
echo "exit" >> $syn_scr

echo "# Moving to synth dir: $syn_dir"
cd $syn_dir
echo "# Synthesis Starting target=$target"
synplify_pro -batch $syn_scr -license_wait

# Print out any errors
num_errors=$(($(grep -c '@E:' ${syn_dir}/rev_${target}/${unit}.srr) + $(grep -c '@N: MF668' ${syn_dir}/rev_${target}/${unit}.srr)))
echo "################################################################"
echo "Synthesis Errors: ${num_errors}"
grep '@E:'       ${syn_dir}/rev_${target}/${unit}.srr
grep '@N: MF668' ${syn_dir}/rev_${target}/${unit}.srr
echo "################################################################"

# summarize removed logic
grep 'removed register'    ${syn_dir}/rev_${target}/${unit}.srr > ${syn_dir}/rev_${target}/${unit}_regs_removed.rpt

# summarize port mismatches
grep 'Port-width mismatch' ${syn_dir}/rev_${target}/${unit}.srr > ${syn_dir}/rev_${target}/${unit}_port_mismatch.rpt

# timestamp info
end_par_time="$(date +"%Y_%m%d_%H%M_%S")"
echo "################################################################"
echo "# Start Synthesis Time @ ${start_par_time}"
echo "# End Synthesis Time   @ ${end_par_time}"
echo "################################################################"