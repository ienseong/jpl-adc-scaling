# Common

## Purpose

This repository provides common FPGA design and verification pieces.

It is designed to be included as a git submodule in FPGA projects.

## Directory Structure

Common is a design/verification unit.  As such, it follows the common
design/verification unit directory structure.

    common
    |-- config
    |-- rtl
    |-- scripts
    `-- verif
        `-- lib

## Config

The `config/` directory contains default environment setup for common FPGA
tools (e.g. simulation, lint, synthesis, etc).  The
`$SBOX/config/proj.setup.{sh|csh}` should source the corresponding
`$SBOX/common/config/setup.{sh|csh}`.  The `proj.setup.{sh|csh}` can override
tool versions before sourcing the common `setup.{sh|csh}`.

## RTL

Common RTL modules are located in the `rtl/` directory.  These RTL modules should be
design and device agnostic. RTL modules like FIFOs,
Clock Domain Crossing modules, generic memories.

## Verification

Common verification components and utility classes and functions are located in
the `verif/` directory.

The `verif/lib/common.f` file is the common verification file list meant to be
included in the design specific `<unit>/verif/tb/tb.f` file.

The `verif/lib/uvm` directory contains UVM extensions and other components
dependent on UVM.  These extensions should be used instead of the vanilla UVM
components.

The `verif/lib` directory contains generic verification utility classes and
functions.

## Scripts

Common FPGA development scripts/applications are located in the `scripts/`
directory.

The major applications include the `jfsim` simulation launch script, `jobrnr`
simulation batch application, and the `jflint` application.

This directory is to be added to `$PATH` by the project `config/proj.setup.*`
files.

### Organization

Simple applications are located directly in the `scripts/` directory.  Larger
applications that span multiple files are located in
`scripts/stow/<script-name>`.  Symlinks link from `scripts/` to
`scripts/stow/<script-name>`.

    scripts
    |-- stow
    |   |-- jfsim
    |   |-- jflint
    |   `-- jobrnr
    |-- jfsim -> stow/jfsim/bin/jfsim
    |-- cppp
    |-- jflint -> stow/jflint/bin/jflint
    |-- jobrnr -> stow/jobrnr/bin/jobrnr
    |-- verilog-autos
    `-- ...

### `jfsim`

The `jfsim` application is used to compile and run Verilog/SystemVerilog
simulations.  It provides a vendor-agnostic frontend to the
Verilog/SystemVerilog simulator.  `jfsim` calls Rake with the
`scripts/Rakefile` Rakefile.  The Rakefile then invokes the
Verilog/SystemVerilog simulator.

See `jfsim --help` for more information.

### `jobrnr`

The `jobrnr` application is used to run regressions or test suites.  It is
commonly used to implement the compile-once run-many methodology.  It can also
be used to run anything that results in a pass/fail condition via exit code
(e.g. jflint, verilog-autos-diff, etc).

See `jobrnr --help` for more information.

### `jflint`

The `jflint` application provides Verilog/SystemVerilog linting.

See [scripts/stow/jflint/README.md](scripts/stow/jflint/README.md) for more information.

### Miscellaneous

* `cppp` - C pre-preprocessor.  Used by `flpp`.

* `flpp` - Filelist preprocessor.  Used to expand filelists (*.f).  Used by
  `scripts/Rakefile` to expand `#include` directives in Verilog/SystemVerilog
  file lists.  See `scripts/flpp` and `scripts/Rakefile` for more information.

* `mentor_questa_vsim_status` - Generates a non-zero exit code when error
  messages are detected on standard input since Questa does not.  See
  `scripts/mentor_questa_vsim_status` for more information.

* `verilog-autos` - Runs Emacs Verilog-Mode autos on Verilog/SystemVerilog files.

* `Verilog-autos-diff` - Checks if Emacs Verilog-Mode autos are up to date.
  For use in `jobrnr` regressions.
