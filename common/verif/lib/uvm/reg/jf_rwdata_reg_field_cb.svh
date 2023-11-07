// Author:  Rob Donnelly <robert.donnelly@jpl.nasa.gov>
// Created: 2017-05-09

// Class: jf_rwdata_reg_field_cb
//
// Extends from jf_rw1c1s_reg_field_cb because it is same implementation.  See
// jf_rw1c1s_reg_field_cb.
class jf_rwdata_reg_field_cb extends jf_rw1c1s_reg_field_cb;
    `uvm_object_utils(jf_rwdata_reg_field_cb)

    function new(string name = "jf_rwdata_reg_field_cb");
        super.new(name);
    endfunction
endclass
