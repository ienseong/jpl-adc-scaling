# Determine the path to fpga-common
#
# This allows fpga-common to be used without a sandbox (e.g. during development
# or CI).  This method assumes this file is in $J5_COMMON/config.  This method
# only works for bash.  Use hardcoded path for csh.
BASH_SOURCE=${BASH_SOURCE:-$0}; export J5_COMMON=$(cd $(dirname $BASH_SOURCE); cd ..; pwd) ##CSH:setenv J5_COMMON $SBOX/common

# Questa Verification IP
export QVIP_VERSION=2020.4
export QUESTA_MVC_HOME=/opt/mentor/apps/questa-vip/${QVIP_VERSION}
export PATH="${QUESTA_MVC_HOME}/bin:$PATH"
echo "Using Mentor Questa VIP $QVIP_VERSION at $QUESTA_MVC_HOME"

# Actel Designer
export ACTEL_VERSION=9.2-SP3
export ALSDIR=/opt/actel/$ACTEL_VERSION
export ACTLMGRD_LICENSE_FILE=${ALSDIR}/license.dat
export PATH="${ALSDIR}/bin:$PATH"
echo "Using Actel Designer $ACTEL_VERSION at $ALSDIR"

# Mentor ReqTracer
export REQT_VERSION=2020.3
export REQT_HOME=/opt/mentor/apps/reqtracer/lnx86_reqtracer_${REQT_VERSION}
export PATH="${REQT_HOME}/bin.pclinux:$PATH"
echo "Using Mentor ReqTracer $REQT_VERSION at $REQT_HOME"

# Mentor Questa CDC
export QUESTA_CDC_VERSION=2020.4_2
export QHOME=/opt/mentor/apps/questa/cdc${QUESTA_CDC_VERSION}/linux_x86_64
export MODEL_TECH=$QHOME/share/modeltech
export LD_LIBRARY_PATH=
export PATH="${QHOME}/bin:$PATH"
export PATH="${MODEL_TECH}/bin:$PATH"
echo "Using Mentor Questa CDC $QUESTA_CDC_VERSION at $QHOME"

# Xilinx ISE
export XILINX_VERSION=14.4
export XILINX_RELEASE=/opt/xilinx/a${XILINX_VERSION}
export XILINX=${XILINX_RELEASE}/ISE
export XILINXD_LICENSE_FILE=${XILINX}/license.dat
export XILINX_EDK=${XILINX_RELEASE}/EDK
export XILINX_PLANAHEAD=${XILINX_RELEASE}/PlanAhead
export PATH="${XILINX}/bin/lin:${XILINX_EDK}/bin/lin:${XILINX_PLANAHEAD}/bin:$PATH"
echo "Using Xilinx ISE $XILINX_VERSION at $XILINX"

# Mentor Questa
export QUESTA_VERSION=2020.4_2
export QUESTA_ROOT=/opt/mentor/apps/questa/v${QUESTA_VERSION}/questasim
export MODEL_TECH=$QUESTA_ROOT
export MODELSIM=${QUESTA_ROOT}/modelsim.ini
export MTI_VCO_MODE=64
export PATH="${QUESTA_ROOT}/linux_x86_64:$PATH"
echo "Using Mentor Questa $QUESTA_VERSION $MTI_VCO_MODE-bit at $QUESTA_ROOT"

# Mentor Visualizer
export VISUALIZER_VERSION=2020.4_2
export QVISUAL=/opt/mentor/apps/visualizer/${VISUALIZER_VERSION}/visualizer
export PATH="$QVISUAL/bin:$PATH"
echo "Using Mentor Visualizer $VISUALIZER_VERSION at $QVISUAL"

# UVM
export UVM_VERSION=1.2
export UVM_HOME=$QUESTA_ROOT/uvm-${UVM_VERSION}
export UVM_SRC_HOME=$QUESTA_ROOT/verilog_src/uvm-${UVM_VERSION}
echo "Using UVM $UVM_VERSION at $UVM_HOME"

# Synopsys Synplify
export SYNPLIFY_VERSION=2021.09-SP1
export SYNHOME=/opt/synplicity/synplify-${SYNPLIFY_VERSION}/fpga/S-${SYNPLIFY_VERSION}
export SNPSLMD_LICENSE_FILE=${SYNHOME}/license.dat
export PATH="${SYNHOME}/bin:$PATH"
echo "Using Synopsys Synplify $SYNPLIFY_VERSION at $SYNHOME"

# HDL Designer Series (for lint and register assistant)
export HDS_VERSION=2022.2
export HDS_ROOT=/opt/mentor/apps/hds/lnx86_hds_${HDS_VERSION}
export REGASSIST=$HDS_ROOT/registerassistant
export PATH="${REGASSIST}:$PATH"
echo "Using Mentor HDL Designer Series $HDS_VERSION at $HDS_ROOT"

# Accellera Open Verification Library
export OVL_VERSION=2.8.1
export OVL_HOME=/proj/fpga/fpga-packages/std_ovl/std_ovl-${OVL_VERSION}
echo "Using Accellera OVL $OVL_VERSION at $OVL_HOME"

# Knobs
export KNOBS_VERSION=1.1.1
export KNOBS_HOME=/proj/fpga/fpga-packages/knobs/knobs-${KNOBS_VERSION}
export PATH="${KNOBS_HOME}/bin:$PATH"
echo "Using Knobs $KNOBS_VERSION at $KNOBS_HOME"

# Java
export JDK_VERSION=1.8.0_74
export JDK_HOME=/proj/fpga/usr/stow/jdk${JDK_VERSION}
export PATH="${JDK_HOME}/bin:$PATH"
echo "Using Java JDK $JDK_VERSION at $JDK_HOME"

# Register Translator
export RTR_VERSION=1.6.0
export RTR_HOME=/proj/fpga/fpga-packages/register-translator/register-translator-${RTR_VERSION}
export PATH="${RTR_HOME}/bin:$PATH"
echo "Using Register Translator $RTR_VERSION at $RTR_HOME"

# Jobrnr Configuration
export JOBRNR_PLUGIN_PATH="$J5_COMMON/scripts/jobrnr_plugins"
export JOBRNR_MAX_FAILURES=2
export JOBRNR_MAX_JOBS=3

# Project Scripts
export PATH="${SBOX}/scripts:$J5_COMMON/scripts:$PATH"

echo
echo "Entered sandbox: $SBOX"
