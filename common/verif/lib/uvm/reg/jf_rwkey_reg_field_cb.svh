// Author:  Rob Donnelly <robert.donnelly@jpl.nasa.gov>
// Created: 2017-05-09

// Class: jf_rwkey_reg_field_cb
//
// Implements the post_predict callback for RWKEY fields.
//
// Predicts both the key and keyed fields.
class jf_rwkey_reg_field_cb extends jf_key_reg_field_cb;
    `uvm_object_utils(jf_rwkey_reg_field_cb)

    function new(string name = "jf_rwkey_reg_field_cb");
        super.new(name);
    endfunction

    function void predict_write_keyed_field(uvm_reg_field keyed_field);
        jf_rwkey_reg rwkey_reg;
        if (!$cast(rwkey_reg, keyed_field.get_parent())) begin
            `uvm_fatal(get_name(), "Failed to cast")
        end

        if (rwkey_reg.get_field_write_value(rwkey_reg.key_field) == rwkey_reg.key) begin
            `jf_ensure(keyed_field.predict(rwkey_reg.get_field_write_value(keyed_field)))
        end
    endfunction
endclass
