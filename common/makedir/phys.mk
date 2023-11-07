SHELL := /bin/bash
####### Define Variables ###########################################################

UNIT_PATH := $(PWD)/../..
SBOX_STATE := $(shell sbox-state)
GIT_ID := $(shell sbox-state --register)
ITERATIONS := 50

# Grab datestamp/timestamp.
# The date and time string is grabbed in the native UTC
# format by the date -u command.  This is converted to the
# local time by passing it back through the date command
# without the -u argument.  It is also reformatted into the
# indivdual parameter values for date and time for utc and
# local.  The date/time is only grabbed once.

utc_string := $(shell (date -u))
utc_date := $(shell (date -d "${utc_string}" +"%Y%m%d" -u))
utc_time := $(shell (date -d "${utc_string}" +"%H%M%S" -u))
loc_string := $(shell (date -d "${utc_string}"))
loc_date := $(shell (date -d "${utc_string}" +"%Y%m%d"   ))
loc_time := $(shell (date -d "${utc_string}" +"%H%M%S"   ))

build_dir_name = $(UNIT)_${loc_date}_${loc_time}_sha_${SBOX_STATE}_$(target)
build_dir  = $(UNIT_PATH)/phys/results/$(build_dir_name)
latest_dir = $(UNIT_PATH)/phys/results/latest
script_dir = $(SBOX)/common/scripts/phys

###### Default Overrides #####################################################
ifndef $(build)
    build=latest
endif
ifndef $(iter)
    iter=$(ITERATIONS)
endif
ifndef $(adb)
    adb=$(TOP_MODULE)
endif

.PHONY: proasic rtax xilinx rtg4
proasic: syn_proasic par_proasic
rtax:    syn_rtax    par_rtax
xilinx:  syn_xilinx  par_xilinx
rtg4:    syn_rtg4    par_rtg4

###### Synthesis #############################################################
# Note: Each time synthesis is run, it updates 'latest' directory for par,
#       multi_par, and inc_multi_par to run on.
.PHONY: syn_%
syn_%: target = $*
syn_%: workdir = $(build_dir)/syn
syn_%: check_sbox_state
	if [ -d $(workdir) ]; then mv -f  $(workdir) $(workdir).prev; fi
	mkdir -p $(workdir)
	rm -f $(latest_dir)
	ln -s $(build_dir) $(latest_dir)
	# TODO: Put the ` back in front of the define statements
	if [ ! -f $(UNIT_PATH)/rtl/chip_defines.vh ]; then \
		echo "\\\`define GIT_ID 32'h$(GIT_ID)"      >> $(UNIT_PATH)/rtl/chip_defines.vh; \
		echo "\\\`define SYN_DATE 32'h$(loc_date)"  >> $(UNIT_PATH)/rtl/chip_defines.vh; \
		echo "\\\`define SYN_TIME 32'h$(loc_time)"  >> $(UNIT_PATH)/rtl/chip_defines.vh; \
	else \
		sed -i "/GIT_ID\s\{0,\}/    c\\\`define GIT_ID 32'h$(GIT_ID)"      $(UNIT_PATH)/rtl/chip_defines.vh; \
		sed -i "/SYN_DATE\s\{0,\}/  c\\\`define SYN_DATE 32'h$(loc_date)"  $(UNIT_PATH)/rtl/chip_defines.vh; \
		sed -i "/SYN_TIME\s\{0,\}/  c\\\`define SYN_TIME 32'h$(loc_time)"  $(UNIT_PATH)/rtl/chip_defines.vh; \
	fi
	#sed -i "/latest\s\{0,\}/    c\set latest {$(UNIT) ${loc_date} ${loc_time} sha ${SBOX_STATE} $(target)}"  $(UNIT_PATH)/phys/latest.tcl
	$(script_dir)/run_syn.sh $(UNIT) $(TOP_MODULE) $(TECHNOLOGY) $(target) $(PART) $(PACKAGE) $(SPEED_GRADE) $(loc_date) $(workdir)

###### Place & Route #############################################################
.PHONY: par_%
par_%: target = $*
par_%: workdir = $(UNIT_PATH)/phys/results/$(build)/par
par_%: check_sbox_state
	if [ -d $(workdir) ]; then mv -f  $(workdir) $(workdir).prev; fi
	mkdir -p $(workdir)
	$(script_dir)/run_par.sh $(UNIT) $(TOP_MODULE) $(TECHNOLOGY) $(target) $(PART) $(PACKAGE) $(SPEED_GRADE) $(VOLTAGE) $(IOSTD) $(TEMP_RANGE) $(VOLT_RANGE) $(EFFORT_LEVEL) $(workdir)

###### Place & Route (Multi) #####################################################
# Note: A multi run needs the *.adb file from the unsuccessful par run
.PHONY: multi_par_%
multi_par_%: target = $*
multi_par_%: workdir = $(UNIT_PATH)/phys/results/$(build)/par
multi_par_%: check_sbox_state
	@echo "P&R Command line default override:"
	@echo "    build=<build dir to iterate on>  # Specify build directory;      Default is <latest>"
	@echo "    adb=<adb database name>          # Specify design database name; Default is <$(TOP_MODULE)>"
	@echo "    iter=<iteration count>           # Specify number of iterations; Default is <$(ITERATIONS)>"
	$(script_dir)/run_multi_par.sh $(UNIT) $(adb) $(target) $(workdir) noinc $(iter) max

###### Place & Route (Multi w/ incremental) #####################################################
# Note: A multi inc run needs the *.adb file from the unsuccessful par run
.PHONY: incr_multi_par_%
incr_multi_par_%: target = $*
incr_multi_par_%: workdir = $(UNIT_PATH)/phys/results/$(build)/par
incr_multi_par_%: check_sbox_state
	@echo "P&R Command line default override:"
	@echo "    build=<build dir to iterate on>  # Specify build directory;      Default is <latest>"
	@echo "    adb=<adb database name>          # Specify design database name; Default is <$(TOP_MODULE)>"
	@echo "    iter=<iteration count>           # Specify number of iterations; Default is <$(ITERATIONS)>"
	$(script_dir)/run_multi_par.sh $(UNIT) $(adb) $(target) $(workdir) inc $(iter) min

###### Running Timing and generate programming files for already Place & Routed design #####################################################
.PHONY: sta_%
sta_%: target = $*
sta_%: workdir = $(UNIT_PATH)/phys/results/$(build)/par
sta_%: check_sbox_state
	@echo "P&R Command line default override:"
	@echo "    build=<build dir to iterate on>  # Specify build directory;      Default is <latest>"
	@echo "    adb=<adb database name>          # Specify design database name; Default is <$(TOP_MODULE)>"
	$(script_dir)/run_timing.sh $(UNIT) $(TOP_MODULE) $(adb) $(target) $(workdir) $(EFFORT_LEVEL)

# State check
check_sbox_state:
	@# Check sbox state suitable for physical FPGA
	@if echo $(SBOX_STATE) | grep 'dirty' > /dev/null; then \
	    echo "WARNING: Build not suitable for FPGA programming due to sbox state $(SBOX_STATE).";  \
	    echo "WARNING: Build suitable for informational purposes only."; \
	    echo; \
	    sleep 5; \
	fi
