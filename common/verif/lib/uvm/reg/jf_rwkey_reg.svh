// Author:  Rob Donnelly <robert.donnelly@jpl.nasa.gov>
// Created: 2017-05-09

typedef class jf_rwkey_reg_field_cb;
typedef class jf_rwdata_reg_field_cb;

// Class: jf_rwkey_reg
//
// Models the RWKEY keyed register type where a key field determines the keyed
// fields access types as follows:
//
// key: valid        access: RW
// key: invalid      access: RO
class jf_rwkey_reg extends jf_key_reg;
    u32 key;

    static jf_rwkey_reg_field_cb rwkey_cb;
    static jf_rwdata_reg_field_cb rwdata_cb;

    function new(
        string name = "jf_rwkey_reg",
        int unsigned n_bits,
        int has_coverage
    );
        super.new(name, n_bits, has_coverage);

        if (rwkey_cb == null) rwkey_cb = new();
        if (rwdata_cb == null) rwdata_cb = new();
    endfunction

    task update(
        output uvm_status_e      status,
        input  uvm_path_e        path = UVM_DEFAULT_PATH,
        input  uvm_reg_map       map = null,
        input  uvm_sequence_base parent = null,
        input  int               prior = -1,
        input  uvm_object        extension = null,
        input  string            fname = "",
        input  int               lineno = 0
    );
        case (key_field.value)
            key: begin
                // Do nothing, keyed fields already RW
                // access type
            end
            default: begin
                update_keyed_field_access("RO");
            end
        endcase

        super.update(
            status,
            path,
            map,
            parent,
            prior,
            extension,
            fname,
            lineno
        );

        update_keyed_field_access("RW");
    endtask

    // Function: configure_callbacks
    function void configure_callbacks();
        uvm_reg_field_cb::add(key_field, rwkey_cb);

        foreach (m_fields[i]) begin
            if (!is_keyed_field(m_fields[i])) continue;

            uvm_reg_field_cb::add(m_fields[i], rwdata_cb);
        end
    endfunction
endclass
