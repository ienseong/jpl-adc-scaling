# Common build scripts - common/scripts/phys

## Purpose

These scripts represent a default common set of scripts for building RTAX/ProASIC based FPGAs.
The intent is to provide a quick start for each project to get up and running with the build system.
Customization of these scripts can occur in the project specific phys area.

## Script description

## Usage

Copy the Makefile template `Makefile.phys.template` from `common/makedir` into your project at `$SBOX/<unit>/phys/scripts/Makefile`.

This Makefile is where project specific devices and top level names are defined.
Once this Makefile is setup for the project all of the make commands below can be invoked.

### Single pass build

Usage: `make <rtax|proasic>`

Description: Run synthesis and P&R for the RTAX device.
Also translates and generates the AX files.
This run is a single pass run.

Example:

    make rtax

### Multi pass build - non-incremental

Usage: `make multi_par_<rtax|proasic> build=<build dir to iterate on> iter=<number of passes to run>`

Description: This script will take an existing build database and run multiple P&R runs with different seeds.
Timing metrics are produced for all runs but not the detailed STA or programming files.
Note that this command will iterate on the data base named `<your topmodule>.adb`.

Example:

    make multi_par_rtax build=nvm_20190823_161907_sha_77e03d0_rtax iter=50

### Multi pass build - incremental

Usage: `make incr_multi_par_<rtax|proasic> build=<build dir to iterate on> iter=<number of passes to run>`

Description: This script will take an existing build database and run multiple incremental P&R runs.
Timing metrics are produced for all runs but not the detailed STA or programming files.
Note that this command will iterate on the data base named `<your topmodule>.adb`.

Example:

    make incr_multi_par_rtax build=nvm_20190823_161907_sha_77e03d0_rtax iter=50


### Static Timing Analysis and Programming File Generation

Usage: `make sta_<rtax|proasic> build=<build dir to run STA on>`

Description: This script will take an exisiting build database and run STA and also generate the programming files.
Note that this command reports on the data base named `<your topmodule>.adb`.

Example:

    make sta_rtax build=nvm_20190823_161907_sha_77e03d0_rtax

## Customization

Customization of the scripts can be done on a project by project basis.
To customize copy the desired `.tcl` file from `$SBOX/common/phys/scripts` to `$SBOX/<unit>/phys/scripts`.
Prepend the name of the local versions of the scripts with `<unit>_`.
The base scripts will recognize a local version and use that instead of what is in common.

Example:

    cp $SBOX/common/scripts/phys/par_rtax.tcl $SBOX/nvm/phys/scripts/nvm_par_rtax.tcl

## Design Constraints

Design specific physical and timing constraints should be created in `$SBOX/<unit>/phys/constraints/`.
Files should be named `<unit>_<rtax|proasic>_<par|syn>.sdc` for timing constraints and `<unit>_<rtax|proasic>_par.pdc`
for physical constraints.

Example:

    nvm_rtax_par.sdc (for P&R), nvm_rtax_par.pdc (for P&R) ,nvm_rtax_syn.sdc (for synth)
