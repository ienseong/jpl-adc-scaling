// DEPRECATED: DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED
// DEPRECATED:
// DEPRECATED: This file (`jf_include.svh`) has been deprecated.  It has been
// DEPRECATED: superceded by `jf.f`.  This was done to be consistent with UVM in
// DEPRECATED: how UVM is compiled and imported.
// DEPRECATED:
// DEPRECATED: Upgrade instructions:
// DEPRECATED:
// DEPRECATED: 1. In your `tb.f` REMOVE this line:
// DEPRECATED:
// DEPRECATED:     #include "$SBOX/common/verif/lib/common.f"
// DEPRECATED:
// DEPRECATED: 2. In your `tb.f` ADD this line:
// DEPRECATED:
// DEPRECATED:     #include "$SBOX/common/verif/lib/jf.f"
// DEPRECATED:
// DEPRECATED: 3. REMOVE all instances of this line from your code:
// DEPRECATED:
// DEPRECATED:     `include "jf_include.svh"
// DEPRECATED:
// DEPRECATED: 4. ADD this line after all instances of `import jf_pkg::*;`:
// DEPRECATED:
// DEPRECATED:     `include "jf_macros.svh"
// DEPRECATED:
// DEPRECATED: DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED DEPRECATED

`ifndef __JF_INCLUDE_SVH__
`define __JF_INCLUDE_SVH__

`include "knobs.sv"
`include "jf_macros.svh"

`include "jf_pkg.sv"

`endif
