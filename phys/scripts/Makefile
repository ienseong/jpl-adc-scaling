# INSTRUCTIONS:
#   Copy this template file to $SBOX/<UNIT>/phys/script/Makefile
#   Modify the variables based on your target
SHELL := /bin/bash

###### Define Variables ###########################################################
# UNIT is the directory you would use for J5: i.e. jfsim --unit <UNIT>
UNIT := jpl_adc_scaling
TOP_MODULE := jpl_adc_scaling
TECHNOLOGY := AXCELERATOR
PART := RTAX2000S
PACKAGE := "624 CCGA/LGA"
SPEED_GRADE := "-1"
VOLTAGE := 1.5
IOSTD := LVTTL
TEMP_RANGE := MIL
VOLT_RANGE := MIL
EFFORT_LEVEL := 5

include $(SBOX)/common/makedir/phys.mk

#### Targets in phys.mk ####
# proasic: syn_proasic par_proasic
# rtax:    syn_rtax    par_rtax
# xilinx:  syn_xilinx  par_xilinx
# rtg4:    syn_rtg4    par_rtg4
# ------------------
#  Example
#  > make syn_rtax
#  > make par_rtax
#
#  OR
#  > make rtax

# NOTES:
# (1) To create a Microsemi AXnnnn programming file, create an RTAXnnnn
# 	programming file first and use Microsemi Designer gui selecting
# 	Tools->GeneratePrototype... to create AXnnnn programming file.
# (2) PACKAGE for RTAX2000S can be one of:
#	(a) "256 CQFP"
#	(b) "352 CQFP"
#	(c) "624 CCGA/LGA"
#	(d) "1152 CCGA/LGA"
#
