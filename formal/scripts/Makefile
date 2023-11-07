###### Project Uniqe Variables ####################################################
# DUT: Name of module in the top-level RTL file
DUT = jpl_adc_scaling
# DUT_PATH: Absolute path to the directory containing ./rtl and ./formal
DUT_PATH = $(SBOX)
# SPEC_PATH_F: Absolute path to directory containing the rtl.f used for the SLEC golden reference or original
SPEC_PATH_F = $(SBOX)/rtl_orig
# FPGA: FPGA type so the cell library can be included in compile.
# valid values =[RTAX, PROASIC, RTG4, POLARFIRE, SMARTFUSION, VIRTEX5]
FPGA = RTAX
###################################################################################

include $(SBOX)/common/makedir/formal.mk

###################################################################################
# Targets
###################################################################################
##### Complete flows #######
#	run_all 
#	run_ac  
#	run_rc  
#	run_cdc 
#	run_cdc_all 
#	run_pc  
#	run_cc  
#	run_lint
#	run_slec
#
####### Individual targets ########
## Mentor AutoCheck (Mentor's super LINT tool):
#	clean_ac  
#	ac 
## Mentor ResetCheck:
#	clean_rc  
#	rc 
## Mentor Clock Domain Crossing:
#	clean_cdc 
#	cdc 
#	cdc_promote 
#	cdc_formal
## Mentor Property Check (Formally prove design assertions):
#	clean_pc  
#	pc
## Mentor CoverCheck (Create code coverage waiver file for unreachable code):
#	clean_cc  
#	cc 
## Mentor Questa LINT:
#	clean_lint 
#	lint
## Mentor SLEC:
#	clean_slec
#	compile_spec
#	slec
## Mentor General
#	clean 
#	compile 
#	compile_sva 
#
