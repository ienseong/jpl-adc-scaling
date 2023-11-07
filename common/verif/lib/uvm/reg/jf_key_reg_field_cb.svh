// Author:  Rob Donnelly <robert.donnelly@jpl.nasa.gov>
// Created: 2017-05-20

// Class: jf_key_reg_field_cb
//
// Base class for key fields.
virtual class jf_key_reg_field_cb extends uvm_reg_cbs;
    `uvm_object_utils(jf_key_reg_field_cb)

    function new(string name = "jf_key_reg_field_cb");
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
        bit busy;
        jf_key_reg r;
        if (!$cast(r, fld.get_parent())) begin
            `uvm_fatal(get_name(), "Failed to cast")
        end

        if (kind == UVM_PREDICT_WRITE) begin
            // Save last write value for use by the keyed fields
            r.set_field_write_value(fld, value);

            // Clear all but MSb
            //
            // Only MSb is backed by a flipflop
            value &= get_key_mask(r);

            // Clear busy status to prevent keyed_field.predict from throwing an
            // error due to predict while busy
            busy = r.is_busy();
            r.Xset_busyX(0);

            predict_write_keyed_fields(r);

            // Restore busy status
            r.Xset_busyX(busy);
        end
    endfunction

    function uvm_reg_data_t get_key_mask(jf_key_reg r);
        if (r.key_has_flop) begin
            return 1 << (r.key_field.get_n_bits() - 1);
        end else begin
            return 0;
        end
    endfunction

    // Function: predict_write_keyed_fields
    //
    // Go back and update the keyed fields.
    function void predict_write_keyed_fields(jf_key_reg r);
        uvm_reg_field fields[$];
        r.get_fields(fields);

        foreach (fields[i]) begin
            if (!r.is_keyed_field(fields[i])) continue;

            predict_write_keyed_field(fields[i]);
        end
    endfunction

    pure virtual function void predict_write_keyed_field(uvm_reg_field keyed_field);
endclass
