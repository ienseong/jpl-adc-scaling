// Author:  Rob Donnelly <robert.donnelly@jpl.nasa.gov>
// Created: 2017-05-04

// Class: jf_rwcsb_reg_field_cb
//
// Implements the post_predict callback for RWCSB fields.
//
// Predicts both the key and keyed fields.
class jf_rwcsb_reg_field_cb extends jf_key_reg_field_cb;
    `uvm_object_utils(jf_rwcsb_reg_field_cb)

    function new(string name = "jf_rwcsb_reg_field_cb");
        super.new(name);
    endfunction

    function void predict_write_keyed_field(uvm_reg_field keyed_field);
        jf_rwcsb_reg rwcsb_reg;
        if (!$cast(rwcsb_reg, keyed_field.get_parent())) begin
            `uvm_fatal(get_name(), "Failed to cast")
        end

        begin
            uvm_reg_data_t key_field_write_value = rwcsb_reg.get_field_write_value(rwcsb_reg.key_field);
            uvm_reg_data_t keyed_field_write_value = rwcsb_reg.get_field_write_value(keyed_field);

            case (key_field_write_value)
                rwcsb_reg.set_key: begin
                    uvm_reg_data_t current = keyed_field.get_mirrored_value();
                    uvm_reg_data_t next = current | keyed_field_write_value;
                    `jf_ensure(keyed_field.predict(next));
                end
                rwcsb_reg.clear_key: begin
                    uvm_reg_data_t current = keyed_field.get_mirrored_value();
                    uvm_reg_data_t next = current & ~keyed_field_write_value;
                    `jf_ensure(keyed_field.predict(next));
                end
            endcase
        end
    endfunction
endclass
