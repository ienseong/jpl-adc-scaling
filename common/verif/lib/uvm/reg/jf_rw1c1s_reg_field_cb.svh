// Author:  Rob Donnelly <robert.donnelly@jpl.nasa.gov>
// Created: 2017-05-04

// Class: jf_rw1c1s_reg_field_cb
//
// Records prediction information and defers the prediction to
// jf_rwcsb_reg_field_cb.
class jf_rw1c1s_reg_field_cb extends uvm_reg_cbs;
    `uvm_object_utils(jf_rw1c1s_reg_field_cb)

    function new(string name = "jf_rw1c1s_reg_field_cb");
        super.new(name);
    endfunction

    // Function: post_predict
    //
    // Assumes the key field `do_predict` will be called last.  In other words,
    // assumes the key field has lsb greater than the lsbs of the keyed fields.
    //
    // We store the write value then keep the previous value.  The key field
    // post_predict is responsible for updating the values of the keyed fields.
    function void post_predict(
        input uvm_reg_field  fld,
        input uvm_reg_data_t previous,
        inout uvm_reg_data_t value,
        input uvm_predict_e  kind,
        input uvm_path_e     path,
        input uvm_reg_map    map
    );
        jf_key_reg r;
        if (!$cast(r, fld.get_parent())) begin
            `uvm_fatal(get_name(), "Failed to cast")
        end

        if (kind == UVM_PREDICT_WRITE) begin
            // Prevent updating the mirrored value.
            // jf_rw1c1s_reg_field::predict_write_keyed_fields will do it.
            value = fld.get_mirrored_value();
        end
    endfunction
endclass
