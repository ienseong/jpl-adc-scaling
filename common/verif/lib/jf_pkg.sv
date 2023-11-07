`ifndef __JF_PKG_SV__
`define __JF_PKG_SV__

`include "jf_macros.svh"

package jf_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "jf_types.svh"
    `include "jf_interface.svh"
    `include "jf_functions.svh"
    `include "jf_math.svh"
    `include "jf_format.svh"
    `include "jf_enum_info.svh"
    `include "../dpi/bindings/jfdpi.svh"

    `include "uvm/jf_option_parser.svh"
    `include "uvm/jf_report_catcher.svh"
    `include "uvm/jf_report_server.svh"
    `include "uvm/jf_test.svh"

    `include "uvm/reg/jf_key_reg.svh"
    `include "uvm/reg/jf_key_reg_field_cb.svh"
    `include "uvm/reg/jf_rwcsb_reg.svh"
    `include "uvm/reg/jf_rwcsb_reg_field_cb.svh"
    `include "uvm/reg/jf_rw1c1s_reg_field_cb.svh"
    `include "uvm/reg/jf_rwkey_reg.svh"
    `include "uvm/reg/jf_rwkey_reg_field_cb.svh"
    `include "uvm/reg/jf_rwdata_reg_field_cb.svh"
endpackage

`endif
