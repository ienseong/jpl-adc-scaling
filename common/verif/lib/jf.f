#ifndef __JF_F__
#define __JF_F__

+libext+.vlib
+incdir+$OVL_HOME
-y      $OVL_HOME

// Prevent use of deprecated parts of UVM
+define+UVM_NO_DEPRECATED

+define+KNOBS_UVM
$KNOBS_HOME/share/knobs/bindings/systemverilog/lib/knobs.sv

+incdir+$J5_COMMON/verif/lib
$J5_COMMON/verif/lib/jf_pkg.sv

#endif
