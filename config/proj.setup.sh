export PROJECT=jpl-adc-scaling

############################################################################
# Units and other local paths
############################################################################
export JPL_ADC_SCALING=$SBOX

# Local QVIP paths for testbench compilation
#export AHBLITE_MASTER_QVIP_DIR_NAME=$JPL_SPW/verif/vip/ahblite_master_qvip_dir/uvmf
#export AHBLITE_SLAVE_QVIP_DIR_NAME=$JPL_SPW/verif/vip/ahblite_slave_qvip_dir/uvmf
#export APB_MASTER_QVIP_DIR_NAME=$JPL_SPW/verif/vip/apb_master_qvip_dir/uvmf
#export SPW_QVIP_DIR_NAME=$JPL_SPW/verif/vip/spw_qvip_dir/uvmf

# Required sourced file
source $SBOX/common/config/setup.sh

# path to rm_path.sh
export RM_PATH_DIR=$SBOX/config

############################################################################
# Override Questa Tools as needed
############################################################################

# Questa Verification IPA -- clear previous path setup before setting again
export RM_PATH="${QUESTA_MVC_HOME}/bin" ; source $RM_PATH_DIR/rm_path.sh
export QVIP_VERSION=2021.4_20220207
export QUESTA_MVC_HOME=/opt/mentor/apps/questa-vip/${QVIP_VERSION}
export PATH="${QUESTA_MVC_HOME}/bin:$PATH"
echo "Override Mentor Questa VIP $QVIP_VERSION at $QUESTA_MVC_HOME"


# Mentor Questa CDC -- clear previous path setup before setting again
#export RM_PATH="${QHOME}/bin" ; source $RM_PATH_DIR/rm_path.sh
#export RM_PATH="${MODEL_TECH}/bin" ; source $RM_PATH_DIR/rm_path.sh
export QUESTA_CDC_VERSION=2021.3_2
export QHOME=/opt/mentor/apps/questa/cdc${QUESTA_CDC_VERSION}/linux_x86_64
export MODEL_TECH=$QHOME/share/modeltech
export LD_LIBRARY_PATH=
export PATH="${QHOME}/bin:$PATH"
export PATH="${MODEL_TECH}/bin:$PATH"
echo "Override Mentor Questa CDC $QUESTA_CDC_VERSION at $QHOME"


# Mentor Questa -- clear previous path setup before setting again
#export RM_PATH="${QUESTA_ROOT}/linux_x86_64" ; source $RM_PATH_DIR/rm_path.sh
export QUESTA_VERSION=2021.3_2
export QUESTA_ROOT=/opt/mentor/apps/questa/v${QUESTA_VERSION}/questasim
export MODEL_TECH=$QUESTA_ROOT
export MODELSIM=${QUESTA_ROOT}/modelsim.ini
export MTI_VCO_MODE=64
export PATH="${QUESTA_ROOT}/linux_x86_64:$PATH"
echo "Override Mentor Questa $QUESTA_VERSION $MTI_VCO_MODE-bit at $QUESTA_ROOT"


# Mentor Visualizer -- clear previous path setup before setting again
#export RM_PATH="${QVISUAL}/bin" ; source $RM_PATH_DIR/rm_path.sh
export VISUALIZER_VERSION=2021.3_2
export QVISUAL=/opt/mentor/apps/visualizer/${VISUALIZER_VERSION}/visualizer
export PATH="$QVISUAL/bin:$PATH"
echo "Override Mentor Visualizer $VISUALIZER_VERSION at $QVISUAL"


############################################################################
# Override Register Translator and RegAssist
############################################################################

# Register Translator -- clear previous path setup before setting again
#export RM_PATH="${RTR_HOME}/bin" ; source $RM_PATH_DIR/rm_path.sh
#export RTR_VERSION=1.4.2
#export RTR_HOME=/proj/fpga/fpga-packages/register-translator/register-translator-${RTR_VERSION}
#export PATH="${RTR_HOME}/bin:$PATH"
#echo "Override Register Translator $RTR_VERSION at $RTR_HOME"

# RegAssist -- keeping lint as-is, clear previous path setup before setting again
export RM_PATH_VAR="REGASSIST" ; source $RM_PATH_DIR/rm_path.sh
export REGASSIST=/home/rdonnell/usr/HDS_2022.2/registerassistant
export PATH="${REGASSIST}:$PATH"
echo "Override RegAssist to local temp installation: $REGASSIST"


############################################################################
# UVM and UVMF Versions
############################################################################

# UVM -- UVMF compilation targets 1.1d
export UVM_VERSION=1.1d
export UVM_HOME=$QUESTA_ROOT/uvm-${UVM_VERSION}
export UVM_SRC_HOME=$QUESTA_ROOT/verilog_src/uvm-${UVM_VERSION}
echo "Using UVM $UVM_VERSION at $UVM_HOME"

# UVMF 
export RM_PATH_VAR="UVMF_HOME_SCRIPTS" ; source $RM_PATH_DIR/rm_path.sh
export UVMF_HOME=$SBOX/vip/uvmf
export UVMF_HOME_SCRIPTS=$UVMF_HOME/scripts
export PATH="${UVMF_HOME_SCRIPTS}:$PATH"


############################################################################
# Setup additional project scripts
############################################################################

# UVMF -- clear previous path setup before setting again
export RM_PATH_VAR="SCR_TEST_UTILS_HOME" ; source $RM_PATH_DIR/rm_path.sh
export SCR_TEST_UTILS_HOME="$SBOX/scripts/scripts_test_utils"
export PATH="${SCR_TEST_UTILS_HOME}:$PATH"



