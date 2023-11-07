# AUTOGENERATED WITH: sh2csh setup.sh
# ANY MANUAL EDITS TO THIS FILE WILL BE LOST

# Determine the path to fpga-common
#
# This allows fpga-common to be used without a sandbox (e.g. during development
# or CI).  This method assumes this file is in $J5_COMMON/config.  This method
# only works for bash.  Use hardcoded path for csh.
setenv J5_COMMON $SBOX/common

# Questa Verification IP
setenv QVIP_VERSION 2020.4
setenv QUESTA_MVC_HOME /opt/mentor/apps/questa-vip/${QVIP_VERSION}
setenv PATH "${QUESTA_MVC_HOME}/bin:$PATH"
echo "Using Mentor Questa VIP $QVIP_VERSION at $QUESTA_MVC_HOME"

# Actel Designer
setenv ACTEL_VERSION 9.2-SP3
setenv ALSDIR /opt/actel/$ACTEL_VERSION
setenv ACTLMGRD_LICENSE_FILE ${ALSDIR}/license.dat
setenv PATH "${ALSDIR}/bin:$PATH"
echo "Using Actel Designer $ACTEL_VERSION at $ALSDIR"

# Mentor ReqTracer
setenv REQT_VERSION 2020.3
setenv REQT_HOME /opt/mentor/apps/reqtracer/lnx86_reqtracer_${REQT_VERSION}
setenv PATH "${REQT_HOME}/bin.pclinux:$PATH"
echo "Using Mentor ReqTracer $REQT_VERSION at $REQT_HOME"

# Mentor Questa CDC
setenv QUESTA_CDC_VERSION 2020.4_2
setenv QHOME /opt/mentor/apps/questa/cdc${QUESTA_CDC_VERSION}/linux_x86_64
setenv MODEL_TECH $QHOME/share/modeltech
setenv LD_LIBRARY_PATH 
setenv PATH "${QHOME}/bin:$PATH"
setenv PATH "${MODEL_TECH}/bin:$PATH"
echo "Using Mentor Questa CDC $QUESTA_CDC_VERSION at $QHOME"

# Xilinx ISE
setenv XILINX_VERSION 14.4
setenv XILINX_RELEASE /opt/xilinx/a${XILINX_VERSION}
setenv XILINX ${XILINX_RELEASE}/ISE
setenv XILINXD_LICENSE_FILE ${XILINX}/license.dat
setenv XILINX_EDK ${XILINX_RELEASE}/EDK
setenv XILINX_PLANAHEAD ${XILINX_RELEASE}/PlanAhead
setenv PATH "${XILINX}/bin/lin:${XILINX_EDK}/bin/lin:${XILINX_PLANAHEAD}/bin:$PATH"
echo "Using Xilinx ISE $XILINX_VERSION at $XILINX"

# Mentor Questa
setenv QUESTA_VERSION 2020.4_2
setenv QUESTA_ROOT /opt/mentor/apps/questa/v${QUESTA_VERSION}/questasim
setenv MODEL_TECH $QUESTA_ROOT
setenv MODELSIM ${QUESTA_ROOT}/modelsim.ini
setenv MTI_VCO_MODE 64
setenv PATH "${QUESTA_ROOT}/linux_x86_64:$PATH"
echo "Using Mentor Questa $QUESTA_VERSION $MTI_VCO_MODE-bit at $QUESTA_ROOT"

# Mentor Visualizer
setenv VISUALIZER_VERSION 2020.4_2
setenv QVISUAL /opt/mentor/apps/visualizer/${VISUALIZER_VERSION}/visualizer
setenv PATH "$QVISUAL/bin:$PATH"
echo "Using Mentor Visualizer $VISUALIZER_VERSION at $QVISUAL"

# UVM
setenv UVM_VERSION 1.2
setenv UVM_HOME $QUESTA_ROOT/uvm-${UVM_VERSION}
setenv UVM_SRC_HOME $QUESTA_ROOT/verilog_src/uvm-${UVM_VERSION}
echo "Using UVM $UVM_VERSION at $UVM_HOME"

# Synopsys Synplify
setenv SYNPLIFY_VERSION 2021.09-SP1
setenv SYNHOME /opt/synplicity/synplify-${SYNPLIFY_VERSION}/fpga/S-${SYNPLIFY_VERSION}
setenv SNPSLMD_LICENSE_FILE ${SYNHOME}/license.dat
setenv PATH "${SYNHOME}/bin:$PATH"
echo "Using Synopsys Synplify $SYNPLIFY_VERSION at $SYNHOME"

# HDL Designer Series (for lint and register assistant)
setenv HDS_VERSION 2022.2
setenv HDS_ROOT /opt/mentor/apps/hds/lnx86_hds_${HDS_VERSION}
setenv REGASSIST $HDS_ROOT/registerassistant
setenv PATH "${REGASSIST}:$PATH"
echo "Using Mentor HDL Designer Series $HDS_VERSION at $HDS_ROOT"

# Accellera Open Verification Library
setenv OVL_VERSION 2.8.1
setenv OVL_HOME /proj/fpga/fpga-packages/std_ovl/std_ovl-${OVL_VERSION}
echo "Using Accellera OVL $OVL_VERSION at $OVL_HOME"

# Knobs
setenv KNOBS_VERSION 1.1.1
setenv KNOBS_HOME /proj/fpga/fpga-packages/knobs/knobs-${KNOBS_VERSION}
setenv PATH "${KNOBS_HOME}/bin:$PATH"
echo "Using Knobs $KNOBS_VERSION at $KNOBS_HOME"

# Java
setenv JDK_VERSION 1.8.0_74
setenv JDK_HOME /proj/fpga/usr/stow/jdk${JDK_VERSION}
setenv PATH "${JDK_HOME}/bin:$PATH"
echo "Using Java JDK $JDK_VERSION at $JDK_HOME"

# Register Translator
setenv RTR_VERSION 1.6.0
setenv RTR_HOME /proj/fpga/fpga-packages/register-translator/register-translator-${RTR_VERSION}
setenv PATH "${RTR_HOME}/bin:$PATH"
echo "Using Register Translator $RTR_VERSION at $RTR_HOME"

# Jobrnr Configuration
setenv JOBRNR_PLUGIN_PATH "$J5_COMMON/scripts/jobrnr_plugins"
setenv JOBRNR_MAX_FAILURES 2
setenv JOBRNR_MAX_JOBS 3

# Project Scripts
setenv PATH "${SBOX}/scripts:$J5_COMMON/scripts:$PATH"

echo
echo "Entered sandbox: $SBOX"