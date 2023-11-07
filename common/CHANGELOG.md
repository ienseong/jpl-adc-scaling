# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this
project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

### Added

* phys: Added Questa Formal

### Fixed

* jfsim: Fixed "(vlib-34) Library already exists" warning [[#108]]
* jfsim: ArgumentError on Ruby 3 [[#109]]
* jfsim: Fixed "(vlog-13288) Multiple macros defined in +define+ command line switch." warning [[#115]]
* phys: Fixed typos in place-and-route TCL scripts [[#112]]
* phys: Syntax errors in `run_syn.sh` and `run_par.sh` shell scripts [[#113]]

### Changed

* env: Upgraded Register Translator from 1.5.0 to 1.6.0 [[#111]]
* env: Upgraded Register Assistant from 2018.1 to 2022.2 [[#111]]
* env: Upgrade Synplify from 2017.03-SP1-1 to 2021.09-SP1

[#108]: https://github.jpl.nasa.gov/jfve/fpga-common/issues/108
[#109]: https://github.jpl.nasa.gov/jfve/fpga-common/issues/109
[#111]: https://github.jpl.nasa.gov/jfve/fpga-common/pull/111
[#112]: https://github.jpl.nasa.gov/jfve/fpga-common/issues/112
[#113]: https://github.jpl.nasa.gov/jfve/fpga-common/pull/113
[#114]: https://github.jpl.nasa.gov/jfve/fpga-common/pull/114
[#115]: https://github.jpl.nasa.gov/jfve/fpga-common/issues/115

## [0.11.0]

### Overview

#### Tool Upgrades

* Register Translator: 1.4.2 => 1.5.0

#### Deprecations

* The previously deprecated `lint` script has been removed and the `jflint` has
  been deprecated.  Use Questa Lint instead. See
  https://github.jpl.nasa.gov/pages/jfve/handbook/design/lint/ for more
  information.

#### Highlights

* Added the ability to load balance regressions across multiple hosts. [[#97]]
* Added support for interactive simulation with Visualizer [[#101]]

### Changed

* env: Upgraded Register Translator from 1.4.2 to 1.5.0 [[#104]]

### Removed

* Removed the previously deprecated `lint` script. Use Questa Lint instead. See
  https://github.jpl.nasa.gov/pages/jfve/handbook/design/lint/ for more
  information.

### Added

* jfsim: Added the ability to run jfsim on other hosts over SSH via the `--host` option. [[#97]]
* jfsim: Documented dumping memories for both the `--dump` and `--visualizer` options. [[#98]] [[#100]]
* jfsim: Documented the command to view legacy waveforms. [[#99]]
* jfsim: Added support for running interactively with Visualizer [[#101], [#105]]
* jobrnr: Added load balancing across multiple hosts via auto-management of the jfsim `--host` option. [[#97]]

### Fixed

* jfsim: Fixed backtraces on Ctrl-C.

[#97]: https://github.jpl.nasa.gov/jfve/fpga-common/pull/97
[#98]: https://github.jpl.nasa.gov/jfve/fpga-common/pull/98
[#99]: https://github.jpl.nasa.gov/jfve/fpga-common/pull/99
[#100]: https://github.jpl.nasa.gov/jfve/fpga-common/pull/100
[#101]: https://github.jpl.nasa.gov/jfve/fpga-common/pull/101
[#104]: https://github.jpl.nasa.gov/jfve/fpga-common/pull/104
[#105]: https://github.jpl.nasa.gov/jfve/fpga-common/pull/105

## [0.10.0]

### Overview

#### Tool Upgrades

* Mentor Questa CDC/Formal: 2019.1_1 => 2020.4_2
* Mentor Questa Core/Prime: 2019.1 => 2020.4_2
* Mentor Visualizer: 2019.1 => 2020.4_2

### Changed

* env: Upgraded Mentor Questa CDC/Formal from 2019.1_1 to 2020.4_2
* env: Upgraded Mentor Questa Core/Prime from 2019.1 to 2020.4_2
* env: Upgraded Mentor Visualizer from 2019.1 to 2020.4_2

### Added

* sbox-state: Added handling of unrecognized options
* sbox-state: Added documentation for the `--register` option
* sbox-state: Added short help (`-h`) and long help (`--help`) options
* jflib: Added `jf_path_exists()` for quietly testing path existence

### Fixed

* jflib: Fixed potential unhandled case in `jf_report_catcher`
* jobrnr: Fixed Jenkins JUnit parse error when multi-line error messages contain ampersands (or other XML special characters)
* jobrnr: Fixed leading whitespace in multi-line error messages in Jenkins JUnit XML output
* jfsim: Fixed silent VHDL assertion failures with 'failure' severity

## [0.9.0]

### Overview

#### Breaking Changes

* The `reqtracer` alias has been removed.  Use the vendor provided executable
  `reqTracer` instead.

#### Tool Upgrades

* Register Translator v1.4.1 => v1.4.2
* Mentor Questa Formal: 10.7 => 2019.1_1
* Mentor Questa VIP:  2019.4_2 => 2020.4
* Actel Designer: 9.1 => 9.2-SP3
* Mentor ReqTracer: 2017.1a => 2020.3

### Added

* jfsim: Added detection of incomplete sims to detect system kill of memory
  intensive sims
* jfsim: Added coverage results path to stdout at end-of-sim ([#94])
* jfsim: Added passed/failed indication to end-of-sim ([#95])
* jflint: Added `--no-synthesis` option to run without `SYNTHESIS` defined.
* jflint: Added `--blackbox` option to blackbox libraries.
* jflib: Added support for modeling Register Translator multi-bit RW1C1S
  fields. ([#90])
* jflib: Added handling of `uvm_reg*::predict()`-while-busy warnings ([#93])

### Changes

* jfsim: Changed warning/error coloring to color entire line
* env: Upgraded Register Translator from v1.4.1 to v1.4.2
* env: Upgraded Mentor Questa VIP from 10.7a to 2020.4 ([#96])
* env: Upgraded Mentor Questa Formal from 10.7 to 2019.1_1
* env: Upgraded Mentor ReqTracer from 2017.1a to 2020.3

### Fixed

* env: Fixed ReqTracer's ability to read UCDB files

### Removed

* env: Removed the `reqtracer` alias.

[#90]: https://github.jpl.nasa.gov/jfve/fpga-common/issues/90
[#93]: https://github.jpl.nasa.gov/jfve/fpga-common/pull/93
[#94]: https://github.jpl.nasa.gov/jfve/fpga-common/pull/94
[#95]: https://github.jpl.nasa.gov/jfve/fpga-common/pull/95
[#96]: https://github.jpl.nasa.gov/jfve/fpga-common/pull/96

## [0.8.0]

### Overview

#### Tool Upgrades

* Mentor Questa: 10.7a => 2019.1
* Mentor Visualizer: 10.7a => 2019.1
* Mentor Questa VIP: 10.5c => 10.7a
* Mentor HDL Designer Series: 2018.1 => 2018.2
* Register Translator v1.2.3 => v1.4.1

#### jfsim Improvements

##### Command Highlighting

`jfsim` orchestrates the running of several external commands (e.g. `vlog`,
`vsim`, etc).  These external command calls are now highlighted to
differentiate between commands and command output.

##### Stale Coverage Results

`jfsim` now removes the `<resdir>/coverstore` directory before running
simulation if the directory exists and the `--coverage` option is present.
This prevents implicit coverage merging which could cause coverage results to
become stale.

#### jobrnr Improvements

##### JUnit XML

`jobrnr` now produces JUnit XML (`results.xml`) which can be parsed by Jenkins
CI to give more insight into what jobs passed/failed and what the failure
messages were.

##### Multi-unit Coverage Merging

`jobrnr` now supports coverage merging for multiple units in a single
regression.  This produces multiple coverstores, one for each unit.

BREAKING CHANGE: The merged coverstore has been renamed from
`<jobrnr-output-directory>/coverstore` to
`<jobrnr-output-directory>/coverstore_\<unit>`.

##### Test Associated Coverage Merging

`jobrnr` now does `-testassociated` coverage merge instead of `-totals`
coverage merge.  This means the coverage results now include which tests
covered which items.  Use the `vcover merge -testassociated` option to keep the
test information when transforming the coverstore.

#### J5 UVM Library

The formatting of multi-line UVM messages has been modified to allow stepping
through multi-line messages without having to step through each line of each
multi-line message.

Previously, multi-line messages were formatted as follows:

```text
INFO 1: This
INFO 1: is a
INFO 1: multi-line
INFO 1: message
INFO 2: This is a single line message
```

There was no way to step through each message without stepping through each
line of each message because there was nothing consistent and unique in the
first line to grep for.

Now, multi-line messages are formatted as follows:

```text
INFO:1: This
INFO+1: is a
INFO+1: multi-line
INFO|1: message
INFO:2: This is a single line message
```

This allows stepping through each message by greping for 'INFO:'.

#### Register Translator Improvements

##### RTL Output Customization

Several command line options have been added to enable customization of the RTL
output.

##### C Header Output Overhaul

The C header output has been overhauled for production use in Europa flight
software.

### Added

* [[8ab0516]] jfsim/jflint: Added highlighting of jfsim/jflint output to better
  differentiate between commands are subprocess output.
* [[3e5c2f4]] jobrnr: Added JUnit XML output.
* [[f420c98]] jflib: Added jf_format::array() function for formatting arrays
* [[3252063]] jflib: Added limit feature to `jf_format::array()` and `jf_format::queue()`
* [[31c3b18]] jfsim: Added ability to modify error/warning detection
* [[f91e186]] jfsim: Added the `--vhdlopts` option for passing options to `vcom`

### Changed

* [[02fe331]] jobrnr: Changed coverage merging to support multi-unit coverage merge
* [[12e99b4]] jobrnr: Changed coverage merging from `-totals` merge to `-testassociated` merge
* [[74e4b92]] env: Upgraded Questa from 10.7a to 2019.1
* [[74e4b92]] env: Upgraded Visualizer from 10.7a to 2019.1
* [[c50dede]] env: Upgraded Questa VIP from 10.5c to 10.7a
* [[cdb0683]] jflib: Changed formatting of multi-line messages to allow greping
  for first line of each message.
* [[63f9691]] jflib: Renamed sformatqx::f() to jf_format::queue()
* [[f863006]] env: Upgraded HDL Designer Series from 2018.1 to 2018.2
* [[f863006]] env: Upgraded Register Translator from v1.2.3 to v1.4.1
* [[edf4f55]] autos: Change `verilog-autos` and `verilog-autos-diff` to use
  spaces instead of tabs

### Fixed

* [[5205838]] jflib: Fixed minutes calculation for wall clock time
* [[eac58af]] jfsim: Fixed handling of non-UTF-8 characters in `mentor_questa_vsim_status`
* [[#83]] jflib: Fixed UVM warnings due to deprecated code
* [[6adebed]] jobrnr: Fixed parsing of multi-line Questa runtime errors
* [[#85]] jfsim: Fixed implicit coverage merging
* [[#30]] flpp/verilog-autos*: Fixed Emacs Verilog-mode ignoring filelist entries
  with leading whitespace
* [[fa6f030]] jobrnr: Fixed coverage merging for jfsim commands with implicit --run option
* [[a7ebee3]] jfsim: Fixed mixed-language support

[3252063]: https://github.jpl.nasa.gov/jfve/fpga-common/commit/3252063a64fcb20baa189b0cf86fdf4f9b082e79
[02fe331]: https://github.jpl.nasa.gov/jfve/fpga-common/commit/02fe3319f262ff3eb0fe08e029887c47d86efd28
[12e99b4]: https://github.jpl.nasa.gov/jfve/fpga-common/commit/12e99b4c8f1909762f1528a7653d5796caf7265a
[8ab0516]: https://github.jpl.nasa.gov/jfve/fpga-common/commit/8ab0516586118a07638909704f6cf2fdeedc5f32
[3e5c2f4]: https://github.jpl.nasa.gov/jfve/fpga-common/commit/3e5c2f4e67562012d7b933090a94f92b340255c3
[74e4b92]: https://github.jpl.nasa.gov/jfve/fpga-common/commit/74e4b922dbe23e4e1b7703a9a147312589541463
[cdb0683]: https://github.jpl.nasa.gov/jfve/fpga-common/commit/cdb068396ae9bd35bb032ff65a5d54576e789360
[5205838]: https://github.jpl.nasa.gov/jfve/fpga-common/commit/5205838da7206aac4f75f08a8b180e07fc30ab93
[eac58af]: https://github.jpl.nasa.gov/jfve/fpga-common/commit/eac58af67b1f08aad31f504b571e9b1cf4b14eb5
[63f9691]: https://github.jpl.nasa.gov/jfve/fpga-common/commit/63f96919c2106c7984b9df9136441fdf76c0054f
[f420c98]: https://github.jpl.nasa.gov/jfve/fpga-common/commit/f420c98add52e8cdcdab26105ef6e06e313607fa
[f863006]: https://github.jpl.nasa.gov/jfve/fpga-common/commit/f863006aa3d95ce469ae0c073a97541dcfb05e05
[6adebed]: https://github.jpl.nasa.gov/jfve/fpga-common/commit/6adebed760bff71f669f639f740a5031f19b8706
[edf4f55]: https://github.jpl.nasa.gov/jfve/fpga-common/commit/edf4f55c0d5242c617a0cc26e8f7efa8af1f7823
[31c3b18]: https://github.jpl.nasa.gov/jfve/fpga-common/commit/31c3b18a488b6c1237f6176ad0db9576792a18b2
[fa6f030]: https://github.jpl.nasa.gov/jfve/fpga-common/commit/fa6f030d8bf1eac7f634d8262eda247c5de309ca
[a7ebee3]: https://github.jpl.nasa.gov/jfve/fpga-common/commit/a7ebee35be33f11994a107bb33df199f6846a0b8
[f91e186]: https://github.jpl.nasa.gov/jfve/fpga-common/commit/f91e18632e591aae011306aeac0096830404caa9
[#83]: https://github.jpl.nasa.gov/jfve/fpga-common/issues/83
[#85]: https://github.jpl.nasa.gov/jfve/fpga-common/issues/85
[#30]: https://github.jpl.nasa.gov/jfve/fpga-common/issues/30

## [0.7.0]

This release upgrades tools, adds several `jfsim` improvements, adds filelist
preprocessing to jflint, adds results preservation option to `jobrnr`, adds
simulation performance metrics, and overhauls basic simulation library types
and functions.

### Overview

#### Tool Upgrades

* Mentor HDL Designer Series: 2017.1 => 2018.1
* Mentor Questa: 10.5c_4 => 10.7a
* Mentor Visualizer: 10.6d => 10.7a

#### jfsim Improvements

##### Interactive Modes

Simulation can now be run in CLI interactive or GUI interactive mode via the
`jfsim --interactive` and `jfsim --gui` options respectively.  These options
load the simulator but do not start the simulation so that breakpoints may be
added.

##### Simulation Customization API

The simulation customization API (unit.rake) ergonomics have been improved and
better documented with several examples in `jfsim --help`.  Examples include
modifying the simulation build process and use of pre-compiled libraries among
others.

##### Better Support for Multiple Top Modules

Multiple top modules can now be specified using the `jfsim --top-module`
option by passing a space delimited string.  E.g. `jfsim --top-module 'module_a
module_b'`.  This can also be specified via a `unit.rake` file.  E.g.
`options.top_module = 'module_a module_b'`.

#### Lint Filelist Preprocessing

`jflint` now supports filelist preprocessing of `rtl.f`.  This adds support for
C-style comments and `#ifdef` et al.

#### Regression Results Preservation

By default, `jobrnr` regressions recycle results directories of passing jobs.
Previously, there was no way to change this behavior.  The `--no-recycle`
option has been added to `jobrnr` to prevent the recycling of results
directories for passing jobs.  This is useful for run-for-record regressions.

#### Performance Metrics

Two performance metrics have been added to all simulations.  The first adds the
system time elapsed to all UVM messages to help benchmark simulation events.
The second adds cycles-per-second reporting to the end-of-test to help
benchmark overall simulation performance.

System time elapsed example:

Both the simulation time elapsed (973370ns) and system time elapsed (4s) are
reported for every UVM message.

```text
# INFO 4544: 973370ns 4s [pci::trgt::rd::req:854] bar:HK 973340ns cmd:MEM_READ (0x6) addr:0xffff719c
```

Cycles-per-second example:

The cycles-per-second are reported at the end of every test.

```text
# INFO 4550: 975201ns 4s [uvm_test_top:16] clock_period:25ns cycles:39008 elapsed_time:4s cycles_per_second:9752
```

#### Simulation Library Overhaul

The basic integer types provided by J5 have been overhauled.  They have been
simplified to remove the `_t` suffix.  For example, the unsigned 32-bit integer
type has been changed from `u32_t` to `u32`.  Unsigned types for all sizes up
to 32 bits have been added (e.g. `u5`).

The basic functions have been modified to work for any type, not just `u32`.
For example, `div_ceil()` is now `idivc#(u32)::f()`.

### Deprecated

* jflib: Deprecated the `uN_t` and `sN_t` types.  Use the `uN` and `sN` type
  instead. (6d63272)

* jflib: Deprecated the `div_ceil`, `min_u32`, and `max_u32` functions.  Use
  `idivc#(u32)::f()`, `min#(u32)::f()`, and `max#(u32)::f()` functions instead.
  (3831911)

### Added

* jfsim: Improved the syntax, strictness, and documentation of the simulation
  customization API (5e0af63)

* jfsim: Added the `--top-module` option to specify a top module other than
  'tb'
  ([#67](https://github.jpl.nasa.gov/jfve/fpga-common/issues/67))

* jfsim: Added ability to disable SystemVerilog keywords and features
  ([#76](https://github.jpl.nasa.gov/jfve/fpga-common/issues/76))

* jfsim: Added documentation for the `--visualizer` option with documentation
  for specifying dump start and stop times.
  ([#10](https://github.jpl.nasa.gov/jfve/fpga-common/issues/10))

* jflib: Added reporting of report object for ERROR and FATAL (0292939)

* jflib: Added system timestamps to all report message (b6f091d, 4704b47)

* jflib: Added reporting of cycles per second at end of test (a5aeafa)

* jflib: Added unsigned integer types for all sizes up to 32 bits. (6d63272)

* jflib: Added generic `idivc`, `min`, and `max` math functions. (3831911)

* jflib: Added the `sformatqx` function for formatting a queue as a string.
  (5f30849)

* jflib: Added factory debug reporting to jf_test for factory override debug
  (8c7602d)

* jflint: Added filelist preprocessing support.
  ([#65](https://github.jpl.nasa.gov/jfve/fpga-common/issues/65))

* jobrnr: Added the `--no-recycle` option to preserve all results directories.
  (941ff766)

* jfsim: Added the `--interactive` and `--gui` options.
  ([#15](https://github.jpl.nasa.gov/jfve/fpga-common/issues/15),
  [#69](https://github.jpl.nasa.gov/jfve/fpga-common/issues/69))

### Changed

* env: Upgraded Mentor HDL Designer Series from 2017.1 to 2018.1 to fix parsing
  issues when running lint (24691bd)

* env: Upgraded Mentor Questa from 10.5c_4 to 10.7a
  ([#70](https://github.jpl.nasa.gov/jfve/fpga-common/issues/70))

* env: Upgraded Mentor Visualizer from 10.6d to 10.7a
  ([#70](https://github.jpl.nasa.gov/jfve/fpga-common/issues/70))

* jflib: Add the `id` field to `jf_interface::compare()` (92f6aeb)

* jflib: Removed context reporting for WARNINGs (4c33d3f)

* jflib: Removed '@' prefix from simulation timestamps to make copy and paste of
  timestamps easier (6fe80a9)

* jfsim: Changed Questa compile default from `-svinputport=relaxed` to
  `-svinputport=net` for strict LRM compliance and reduce potential for
  simulation-synthesis mismatches (ae0e330)

### Fixed

* jobrnr: Fixed missing hostname in summary when run via Bamboo (74a9c8b)
* jfsim: Fixed silent Questa fatal error
  ([#77](https://github.jpl.nasa.gov/jfve/fpga-common/issues/77))

## [0.6.0]

This release has a potential breaking change.  It removes the `+acc` option
from the Mentor Questa `vopt` command.  This may cause `vopt` to fail but can
yield a significant simulation performance improvement.  Performance
improvements from 1x-2x have been seen.  Another implication of this change is
that a re-compile is now required to dump (*.wlf) waves.

The `+acc` option can be added back on a per-unit basis by adding the following
to `<unit>/unit.rake`:

```Ruby
OPTIONS[:optopt] += " +acc"
```

Other notable changes include fixes to the lint violation sort ordering and
improved error messages in Register Translator.

### Added

* jflib: Added support for string options to `jf_option_parser` (e86e19e)
* jobrnr: Added cummulative job time statistic to summary (9821d70)
* jobrnr: Print statistics to stdout on completion (4e00fc2)

### Fixed

* jflint: Fixed lint violations not sorted by filename
  ([#63](https://github.jpl.nasa.gov/jfve/fpga-common/issues/63))

### Changed

* jflint: Changed lint violation sort order from severity/filename to
  filename/severity
  ([#63](https://github.jpl.nasa.gov/jfve/fpga-common/issues/63))
* env: Upgraded Register Translator from v1.2.2 to v1.2.3 for improved error
  messages (736dc7a)

### Removed

* jfsim: Removed the `+acc` option from the `vopt` command (ab827da)

## [0.5.4] - 2018-04-12

### Added

* jfsim: Added reporting of first few compile errors to address relevant
  compile errors scrolling off the screen (633b89a)

* jfsim: Added experimental support for Mentor Visualizer: `jfsim --visualizer
  ...` (1186cd2)

### Fixed

* env: Upgraded Mentor HDL Designer Series from 2015.2 to 2017.1 to fix
  out-of-memory issue when running lint (ef19eb2)

* env: Upgraded Mentor CDC from 10.6a to 10.7 to fix GUI crashing on database
  load ([#62](https://github.jpl.nasa.gov/jfve/fpga-common/issues/62))

* sequence-lib: Fixed `Sequence::Weighted` never returning last entry due to
  off by one error (f60fafc)

## [0.5.3] - 2018-03-17

### Fixed

* lint: Fixed support for SystemVerilog constructs in lint.
  ([#61](https://github.jpl.nasa.gov/jfve/fpga-common/issues/61))

* env: Upgraded ReqTracer from 2017.1 to 2017.1a to fix bug with covering VIs
  with assertions and instances.
  ([#60](https://github.jpl.nasa.gov/jfve/fpga-common/issues/60))

## [0.5.2] - 2018-03-12

### Fixed

* env: Upgrade Knobs from v1.1.0 to v1.1.1 to fix `knob_optional` default
  always `0` (a715595)

## [0.5.1] - 2018-02-27

### Removed

* env: Removed license servers from project environment.  These now live in the
  global environment. (f15ef63)

## [0.5.0] - 2018-02-07

### Changed

* jfsim: Make missing 'return' statements a compile error (6e701f5)

* knobs: Upgraded from Knobs v1.0.3 to v1.1.0 which adds a SystemVerilog class
  based API (d47b89a)

* jflib: Renamed jf_interface::uvm_config_db_set to jf_interface::config_db_set
  ([#58](https://github.jpl.nasa.gov/jfve/fpga-common/issues/58))

  **Upgrade Instructions**

  In clean sandbox, perform simple search and replace:

  1. `cd $SBOX`
  2. `rg '\buvm_config_db_set' -l | xargs perl -pi -e 's/\buvm_config_db_set/config_db_set/g'`


### Fixed

* jflint: Fix stacktrace on invalid unit
  ([#59](https://github.jpl.nasa.gov/jfve/fpga-common/issues/59))

* jfsim: Fix quoting of `jfsim` arguments in `jfsim.cmd` (e8d7c84)

* rtr: Upgrade Register Translator from v1.2.1 to v1.2.2 to fix persistent
  errors in log (7ee4a41)

## [0.4.1] - 2018-01-03

### Added

* jflib: Added `uvm_config_db_set` function to `jf_interface` to wrap virtual
  interfaces in an interface object and put into `uvm_config_db` (ccdba21)

* doc: Improved documentation on `jf_interface`, `jf_macros.svh`, and `flpp`
  (e888780, 3de18df)

### Removed

* jflib: Removed `get_vif()` accessor function from `jf_interface` due to
  possible bug in simulator preventing it from working properly. (46d3c49)

### Fixed

* jobrnr: Fixed automatic coverage merging for jfsim jobs when command contains
  multiple shell commands.
  ([#57](https://github.jpl.nasa.gov/jfve/fpga-common/issues/57))

## [0.4.0] - 2017-09-27

### Changed

* jfsim: Use new `UVM_HOME` environment variable instead of deriving from
  `QUESTA_ROOT` (7d2adef)

* env-reqtracer: Upgraded from ReqTracer 2016.1 to 2017.1 (3c4a1cc)

### Fixed

* jfsim: Fixed passing of quoted arguments to LSF
  ([#47](https://github.jpl.nasa.gov/jfve/fpga-common/issues/47))

* jfsim: Fixed coverage report generation documentation
  ([#48](https://github.jpl.nasa.gov/jfve/fpga-common/issues/48))

* template: Fixed Verilog AUTOs in `tb.sv` template
  ([#46](https://github.jpl.nasa.gov/jfve/fpga-common/issues/46))

* jflint: Fixed undefined variable error on RTL filelist missing not found
  error
  ([#51](https://github.jpl.nasa.gov/jfve/fpga-common/issues/51))

* jflint: Fixed handling of `--unit` option
  ([#52](https://github.jpl.nasa.gov/jfve/fpga-common/issues/52))

### Added

* jfsim: Added example of using pre-compiled libraries
  ([#45](https://github.jpl.nasa.gov/jfve/fpga-common/issues/45))

* jfsim: Added contents of `+knobs` argument to vsim `-testname` option
  (1954f0e)

* template: Added more detail to README.md template based on feedback from
  Eddie Miller (38080f5)

* env: Added `UVM_VERSION`, `UVM_HOME`, and `UVM_SRC_HOME` environment
  variables (7d2adef)

* jflib: Added `max_u32` function (70b0e88)

## [0.3.1] - 2017-06-28

### Added

* ovl: Added support for use of `assert_*` modules. (cdc665c)

## [0.3.0] - 2017-06-28

### Added

* jflib: Added file and line number to UVM_WARNING messages (8062c2d)

* qvip: Added support for Questa lib by adding `-mvchome` option to `vsim`
  command (29afba3)

* jflib-uvm-reg: Added documentation for `key_has_flop` variable
  ([#40](https://github.jpl.nasa.gov/jfve/fpga-common/issues/40))
* jflib-uvm-reg: Added key register configuration check
  ([#41](https://github.jpl.nasa.gov/jfve/fpga-common/issues/41))

### Changed

* jflib: Renamed `` `jf_assert*`` macros to `` `jf_ensure*`
  ([#42](https://github.jpl.nasa.gov/jfve/fpga-common/issues/42))

  **Upgrade Instructions**

  In clean sandbox, perform simple search and replace:

  1. `cd $SBOX`
  2. `rg '\bjf_assert' -l | xargs perl -pi -e 's/\bjf_assert/jf_ensure/g'`

* env-cdc: Upgrade Questa Verify from 10.4 to 10.6a (287d2d5)
* env-synth: Upgraded Synplify from 2012.09 to 2017.03-SP1-1 (305f5fb)

### Fixed

* jobrnr: Fixed regression overriding `verif/results/default/jfsim.cmd`
  (8414566)
* jobrnr: Fixed coverage merging for sub-units
  ([#43](https://github.jpl.nasa.gov/jfve/fpga-common/issues/43))

## [0.2.0] - 2017-06-05

### Removed

* jflib: Removed macros: `` `assert_predict``, `` `assert_randomize``,
  `` `assert_config_get``, `` `uvm_config_db_get_interface``, `` `uvm_debug``,
  `` `uvm_report``, `` `coverage_wildcard_bins_*``

  See upgrade instructions at
  ([#37](https://github.jpl.nasa.gov/jfve/fpga-common/issues/37))

### Deprecated

* jflib: Compilation of J5 via `` `include`` has been deprecated in favor of
  compiling J5 in its own compilation unit.

  This deprecates the common file list (`verif/lib/common.f`) and the J5
  include file (`verif/lib/jf_include.svh`).

  See upgrade instructions at
  ([#36](https://github.jpl.nasa.gov/jfve/fpga-common/issues/36))

### Changed

* env-knobs: Upgraded from Knobs v1.0.1 to v1.0.3 (7cd4d6e)
* env-reg: Upgraded from Register Translator v1.1.6 to v1.2.1 (88b09d5, 47ac49d)
* env-sim: Upgraded from Questa 10.4c_6 to 10.5c_4 (91c61a4)
* env-vip: Upgraded from Questa VIP 10.5b to 10.5c (91c61a4)
* env: Renamed environment variable for Questa VIP path from $QUESTA_VIP to
  $QUESTA_MVC_HOME (91c61a4)

### Added

* jflib-uvm-reg: Register modeling of J5 key register types: RWKEY/RWDATA, RWCSB/RW1C1S
  (d01f7f5)

  See [verif/lib/uvm/reg](https://github.jpl.nasa.gov/jfve/fpga-common/tree/master/verif/lib/uvm/reg)

* sim: Improve response to failed `randomize()` calls (77328f4)
  * Increase severity of failed calls from none to error
  * Enable reporting of debug information

### Fixed

* lint: Fixed `.gitignore` for lint byproducts (d9a534b)
* lint: `jflint-filter`: Stack trace when lint waivers.yml not found
  ([#33](https://github.jpl.nasa.gov/jfve/fpga-common/issues/33))
* lint: `jflint-filter`: 'NOTE' severity not allowed
  ([#34](https://github.jpl.nasa.gov/jfve/fpga-common/issues/34))
* env: Fixed an environment reproducibility issue (3c442a4)

## [0.1.0] - 2017-05-03

### Removed

* jflib: Removed `cmn_*` classes.  Replaced with J5 branded (`jf_*`) types. (896aa37)

  **Upgrade Instructions**

  In clean sandbox, perform simple search and replace:

  1. `cd $SBOX`
  2. `rg '\bcmn_' -l | xargs perl -pi -e 's/\bcmn_/jf_/g'`

### Deprecated

* lint: Moved rules from `$SBOX/lint/rule/lint_rules_prefs` to `$SBOX/lint/rules` (5342299)

  **Upgrade Instructions**

  1. Remove `$SBOX/lint`
  2. Run `jflint --init`
  3. Commit the change to `$SBOX/lint`

* sim: Deprecated `avsim` command.  Rebranded under J5 as `jfsim`. (9dbef0c)
* lint: Deprecated `lint` command.  Rebranded under J5 as `jflint`. (9dbef0c)

### Changed

* lint: Changed lint usage from `lint <module> <unit>` to `jflint [-u <unit>]
  <module>`.  If the `--unit|-u` option is not given, the unit will be inferred
  based on the present working directory. (d3c0655)

* env-rtr: Upgraded from Register Translator v1.1.3 to v1.1.6 (6650a9c, ec5c2df, 5e4dc37)

* sim: Changed handling of `jfsim -u $PROJECT`.  Previously, this meant unit
  located at `$SBOX`.  Now it means unit located at `$SBOX/$PROJECT` if it
  exists.  If it doesn't exist, it means unit located at `$SBOX`. (0ccee79)

* jflib: Replaced immediate `assert` statements with `if` statements (ced1ec7)

### Added

* env: Moved majority of environment configuration from the project into fpga-common.

  **Upgrade Instructions**

  Replace `$SBOX/config/proj.setup.sh` and `$SBOX/config/proj.setup.csh` with
  simplified project setup.  See [J5 Project
  Environment](https://github.jpl.nasa.gov/pages/jfve/handbook/project-structure/environment)
  for an example of a simplified project setup. (293973d)

* lint: Added ability to pass defines to lint: `jflint [-u <unit>] <module>
  [+defines]` (64f3105)

* sim: Pass UVM testname to Questa `-testname` option (bb0c0cd)

## 0.0.5 - 2017-02-25

First tracked release.

[Unreleased]: https://github.jpl.nasa.gov/jfve/fpga-common/compare/v0.11.0...HEAD
[0.11.0]: https://github.jpl.nasa.gov/jfve/fpga-common/compare/v0.10.0...v0.11.0
[0.10.0]: https://github.jpl.nasa.gov/jfve/fpga-common/compare/v0.9.0...v0.10.0
[0.9.0]: https://github.jpl.nasa.gov/jfve/fpga-common/compare/v0.8.0...v0.9.0
[0.8.0]: https://github.jpl.nasa.gov/jfve/fpga-common/compare/v0.7.0...v0.8.0
[0.7.0]: https://github.jpl.nasa.gov/jfve/fpga-common/compare/v0.6.0...v0.7.0
[0.6.0]: https://github.jpl.nasa.gov/jfve/fpga-common/compare/v0.5.4...v0.6.0
[0.5.4]: https://github.jpl.nasa.gov/jfve/fpga-common/compare/v0.5.3...v0.5.4
[0.5.3]: https://github.jpl.nasa.gov/jfve/fpga-common/compare/v0.5.2...v0.5.3
[0.5.2]: https://github.jpl.nasa.gov/jfve/fpga-common/compare/v0.5.1...v0.5.2
[0.5.1]: https://github.jpl.nasa.gov/jfve/fpga-common/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.jpl.nasa.gov/jfve/fpga-common/compare/v0.4.1...v0.5.0
[0.4.1]: https://github.jpl.nasa.gov/jfve/fpga-common/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.jpl.nasa.gov/jfve/fpga-common/compare/v0.3.1...v0.4.0
[0.3.1]: https://github.jpl.nasa.gov/jfve/fpga-common/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.jpl.nasa.gov/jfve/fpga-common/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.jpl.nasa.gov/jfve/fpga-common/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.jpl.nasa.gov/jfve/fpga-common/compare/v0.0.5...v0.1.0
