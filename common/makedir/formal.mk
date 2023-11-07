####### Project Uniqe Variables ####################################################
## DUT: Name of module in the top-level RTL file
#DUT = tu
## DUT_PATH: Absolute path to the directory containing ./rtl and ./formal
#DUT_PATH = $(SBOX)
## SPEC_PATH_F: Absolute path to directory containing the rtl.f used for the SLEC golden reference or original
#SPEC_PATH_F = $(SBOX)/rtl_orig
## FPGA: FPGA type so the cell library can be included in compile.
## valid values =[RTAX, PROASIC, RTG4, POLARFIRE, SMARTFUSION, VIRTEX5]
#FPGA = RTAX
####################################################################################

VLIB = ${QHOME}/share/modeltech/bin/vlib
VMAP = ${QHOME}/share/modeltech/bin/vmap
VLOG = ${QHOME}/share/modeltech/bin/vlog
VLIB = ${QHOME}/share/modeltech/bin/vlib

CDC_OD		   = $(DUT_PATH)/formal/reports/Output_cdc
CDC_SIMFILE        = $(CDC_OD)/cdc_protocol/simulation/cdc_protocol_vlog.arg
CDC_VSIMFILE       = $(CDC_OD)/cdc_protocol/simulation/cdc_protocol_vsim_3step.arg
CDC_VOPTFILE       = $(CDC_OD)/cdc_protocol/simulation/cdc_protocol_vopt.arg
CDC_SIMWAVE        = $(CDC_OD)/cdc_protocol/simulation/cdc_protocol_waveform.do
CDC_FORMALFILE     = $(CDC_OD)/cdc_protocol/formal/Makefile
CDC_DB             = $(CDC_OD)/cdc.db
CDCSIMDB           = cdc_sim_merge.db
CDCFORMALDB        = CDC_FORMAL_VERIFY/formal_verify.db

ifeq ($(FPGA),RTAX)
    FPGA_TECH_LIB = /opt/actel/9.2-SP3/lib/vlog/axcelerator.v
else ifeq ($(FPGA),PROASIC)
    FPGA_TECH_LIB = /opt/actel/9.2-SP3/lib/vlog/proasic3e.v
else ifeq ($(FPGA),RTG4)
    FPGA_TECH_LIB = /opt/actel/2021.3_soc/Libero/lib/vlog/rtg4.v
else ifeq ($(FPGA),POLARFIRE)
    FPGA_TECH_LIB = /opt/actel/2021.3_soc/Libero/lib/vlog/polarfire.v
else ifeq ($(FPGA),SMARTFUSION)
    FPGA_TECH_LIB = /opt/actel/2021.3_soc/Libero/lib/vlog/smartfusion2.v
else ifeq ($(FPGA),VIRTEX5)
    FPGA_TECH_LIB = /opt/xilinx/v2018.3.1/Vivado/2018.3/ids_lite/ISE/verilog/src/glbl.v
else
    FPGA_TECH_LIB = UNDEFINED
endif

###################################################################################
# Targets
###################################################################################
run_all: clean compile ac rc cdc lint

# Mentor AutoCheck (Mentor's super LINT tool)
run_ac:  clean_ac  compile ac
# Mentor ResetCheck
run_rc:  clean_rc  compile rc
# Mentor Clock Domain Crossing
run_cdc: clean_cdc compile cdc 
run_cdc_all: clean_cdc compile cdc cdc_promote cdc_formal
# Mentor Property Check (Formally prove design assertions)
run_pc:  clean_pc  compile compile_sva pc
# Mentor CoverCheck (Create code coverage waiver file for unreachable code)
run_cc:  clean_cc  compile cc 
# Mentor Questa LINT
run_lint: clean_lint compile lint 
# Mentor Sequential Logical Equivalence Checking
run_slec: clean_slec compile compile_spec slec

###### Compile Design #############################################################
compile:
	$(VLOG) -f $(DUT_PATH)/rtl/rtl.f +incdir+$(DUT_PATH)/rtl/verilog/include -skipsynthoffregion +define+SYNTHESIS -v $(FPGA_TECH_LIB)
###### Compile Specificaton = Golden Reference Design (For SLEC) ###################################
compile_spec:
	$(VLIB) work_spec
	$(VLOG) -f $(SPEC_PATH_F)/rtl.f +incdir+$(DUT_PATH)/rtl/verilog/include -work work_spec -skipsynthoffregion +define+SYNTHESIS -v $(FPGA_TECH_LIB)

###### Clean compile #######################################################
clean_compile:
	\rm -rf $(DUT_PATH)/formal/scripts/work

##############################################################################
##############################################################################
# Run AutoCheck 
##############################################################################
ac autocheck:
	rm -rf $(DUT_PATH)/formal/reports/Output_ac
	qverify -c -od $(DUT_PATH)/formal/reports/Output_ac -do " \
		do $(DUT_PATH)/formal/scripts/setup.do; \
	 	do $(DUT_PATH)/formal/scripts/ac.do; \
		autocheck compile -d $(DUT) ; \
		autocheck verify -timeout 5m; \
		exit"

##############################################################################
# Debug AutoCheck
##############################################################################
debug_ac:
	qverify $(DUT_PATH)/formal/reports/Output_ac/autocheck_verify.db &

###### Clean AutoCheck #######################################################
clean_ac:
	qverify_clean
	\rm -rf $(DUT_PATH)/formal/reports/Output_ac 



##############################################################################
##############################################################################
# Run ResetCheck 
##############################################################################
rc resetcheck:
	rm -rf $(DUT_PATH)/formal/reports/Output_rc
	qverify -od $(DUT_PATH)/formal/reports/Output_rc -c -do " \
		do $(DUT_PATH)/formal/scripts/setup.do; \
		do $(DUT_PATH)/formal/scripts/rc.do; \
		resetcheck run -d $(DUT) -report_reset; \
		resetcheck generate tree -reset reset_tree.rpt; \
		resetcheck generate tree -clock clock_tree.rpt; \
		resetcheck generate report resetcheck_report.rpt; \
		exit"

##############################################################################
# Debug ResetCheck
##############################################################################
debug_rc:
	qverify $(DUT_PATH)/formal/reports/Output_rc/resetcheck.db &

###### Clean ResetCheck ######################################################
clean_rc:
	qverify_clean
	\rm -rf $(DUT_PATH)/formal/reports/Output_rc 



##############################################################################
##############################################################################
# Run CDC Analysis
##############################################################################
cdc:
	qverify -od $(CDC_OD) -c -do " \
		do $(DUT_PATH)/formal/scripts/setup.do; \
		do $(DUT_PATH)/formal/scripts/cdc.do; \
		cdc run -formal -formal_effort medium -d $(DUT); \
		cdc generate report cdc_detail.rpt; \
		exit"

		## Temp: stop waiving violations from cdc target
		#do $(DUT_PATH)/formal/scripts/cdc_waiver.do; \

###### Run CDC Protocol Promotion #################################################
cdc_promote:
	qverify -od $(CDC_OD) -c -do " \
		cdc load db $(DUT_PATH)/formal/reports/Output_cdc/cdc.db; \
		do cdc_protocol.tcl; \
		cdc generate protocol ; \
		exit"

cdc_fx_promote:
	qverify -od $(CDC_OD) -c -do " \
		cdc load db $(DUT_PATH)/formal/reports/Output_cdc/cdc.db; \
		do cdc_fx.tcl; \
		cdc generate fx ; \
		exit"

cdc_formal:
	make -f $(CDC_FORMALFILE) all

cdc_sim_merge:
	find $(SBOX)/tif/verif_legacy/verif/results/*/cdc_sim.db > checksimdb.list
	qverify -c -od . -do "cdc sim merge -f checksimdb.list"

##############################################################################
# Debug CDC Analysis
##############################################################################
debug_cdc: 
	qverify $(CDC_DB) &

debug_cdc_formal: 
	qverify $(CDCFORMALDB) &

debug_cdc_sim: 
	qverify -classic $(CDCSIMDB) &

###### Clean CDC #############################################################
clean_cdc:
	qverify_clean
	\rm -rf $(DUT_PATH)/formal/work modelsim.ini *.wlf *.log replay* transcript *.db
	\rm -rf $(DUT_PATH)/formal/reports/Output_cdc 
	\rm -rf ./CDC_FORMAL_VERIFY



##############################################################################
##############################################################################
# Compile Properties 
##############################################################################
c_sva compile_sva:
	$(VLOG) -sv -mfcu -cuname sva_bind \
	$(DUT_PATH)/formal/properties/assert_prop_module.sv

##############################################################################
# Run PropCheck 
##############################################################################
pc propcheck:
	rm -rf $(DUT_PATH)/formal/reports/Output_pc
	qverify -c -od $(DUT_PATH)/formal/reports/Output_pc -do "\
		do $(DUT_PATH)/formal/scripts/setup.do; \
		do $(DUT_PATH)/formal/scripts/pc.do; \
		formal compile -d $(DUT) -cuname sva_bind ; \
		formal verify -timeout 20m sanity_waveforms ; \
		formal cover ;\
		formal generate coverage -detail formal_coverage.rpt ;\
		exit"

		#-init qs_files/wb_arbiter.init \

##############################################################################
# Debug PropCheck
##############################################################################
debug_pc:
	qverify $(DUT_PATH)/formal/reports/Output_pc/formal_verify.db &

###### Clean PropCheck ######################################################
clean_pc:
	qverify_clean
	\rm -rf $(DUT_PATH)/formal/reports/Output_pc 



##############################################################################
##############################################################################
# Run CoverCheck 
##############################################################################
cc covercheck:
	rm -rf $(DUT_PATH)/formal/reports/Output_cc
	qverify -c -od $(DUT_PATH)/formal/reports/Output_cc -do "\
		do $(DUT_PATH)/formal/scripts/setup.do; \
		do $(DUT_PATH)/formal/scripts/cc.do; \
		covercheck compile -d $(DUT) ; \
		covercheck verify -timeout 5h; \
		covercheck generate exclude $(DUT_PATH)/formal/reports/Output_cc/cc_exclude.do; \
		exit"

		# Note: load ucdb if available
		#covercheck load ucdb sim.ucdb; \

# JW: Breaking flow into compile & verify steps.  still need to sort out the UCDB import
# business, which isn't working at all well.
cc_comp:
	rm -rf $(DUT_PATH)/formal/reports/Output_cc
	qverify -c -od $(DUT_PATH)/formal/reports/Output_cc -do "\
                do $(DUT_PATH)/formal/scripts/setup.do; \
                do $(DUT_PATH)/formal/scripts/cc.do; \
                covercheck compile -d $(DUT) ; \
                exit"

# JW: Cut parallelism from the default 4 to 2, to avoid malloc death.
cc_verify: 
	mkdir -p $(DUT_PATH)/verif/coverage/excludes
	qverify -c -od $(DUT_PATH)/formal/reports/Output_cc -do "\
                covercheck load db $(DUT_PATH)/formal/reports/Output_cc/covercheck_compile.db; \
                covercheck verify -timeout 2h -jobs 2 -init $(DUT_PATH)/formal/scripts/ptif_init; \
                covercheck generate ucdb $(DUT_PATH)/verif/coverage/excludes/excludes.ucdb -exclude; \
                covercheck generate exclude $(DUT_PATH)/verif/coverage/excludes/cc_exclude.do; \
                exit"

# JW: This still needs work.  The reverify pprocess doesn't behave with UCDB.  I'm missing something here.
cc_reverify:
	qverify -c -od $(DUT_PATH)/formal/reports/Output_cc -do "\
                covercheck load db $(DUT_PATH)/formal/reports/Output_cc/covercheck_compile.db; \
                covercheck load ucdb $(DUT_PATH)/verif/coverage/excludes/excludes.ucdb; \
                covercheck verify -timeout 30m -jobs 2 -init $(DUT_PATH)/formal/scripts/ptif_init; \
                covercheck generate ucdb $(DUT_PATH)/verif/coverage/excludes/excludes2.ucdb -exclude; \
                covercheck generate exclude $(DUT_PATH)/verif/coverage/logs/cc2_exclude.do; \
                exit"

##############################################################################
# Debug CoverCheck
##############################################################################
debug_cc:
	qverify $(DUT_PATH)/formal/reports/Output_cc/covercheck_verify.db &

###### Clean CoverCheck ######################################################
clean_cc:
	qverify_clean
	\rm -rf $(DUT_PATH)/formal/reports/Output_cc 

##############################################################################
# Run Questa LINT 
##############################################################################
lint:
	rm -rf $(DUT_PATH)/formal/reports/Output_lint
	qverify -c -od $(DUT_PATH)/formal/reports/Output_lint -do " \
	    	do $(DUT_PATH)/formal/scripts/lint_waivers.tcl;\
	    	lint methodology fpga -goal release;\
		lint run -d $(DUT);\
		lint generate report -html -group_by_module;\
		lint generate report -json -group_by_module;\
		exit"

# Debug LINT
debug_lint:
	qverify $(DUT_PATH)/formal/reports/Output_lint/lint.db &

# Clean LINT
clean_lint:
	qverify_clean
	\rm -rf $(DUT_PATH)/formal/reports/Output_lint 

##############################################################################
# Run SLEC
##############################################################################
slec:
	rm -rf $(DUT_PATH)/formal/reports/Output_slec
	qverify -c -od $(DUT_PATH)/formal/reports/Output_slec -do " \
	    	slec configure -spec -d $(DUT) -work work_spec; \
	    	slec configure -impl -d $(DUT) -work work; \
		slec compile; \
		slec verify; \
		exit"

# Debug SLEC
debug_slec:
	qverify $(DUT_PATH)/formal/reports/Output_slec/slec.db &

# Clean SLEC
clean_slec:
	qverify_clean
	\rm -rf $(DUT_PATH)/formal/reports/Output_slec 
	\rm -rf $(DUT_PATH)/formal/scripts/work_spec

###### Clean Data #################################################################
clean:	clean_compile clean_ac clean_rc clean_cdc clean_pc clean_lint clean_slec

