// Author:  Rob Donnelly <robert.donnelly@jpl.nasa.gov>
// Created: 2017-05-04

typedef class jf_rwcsb_reg_field_cb;
typedef class jf_rw1c1s_reg_field_cb;

// Class: jf_rwcsb_reg
//
// Models the RWCSB keyed register type where a key field determines the keyed
// fields access types as follows:
//
// key: set_key     access: RW1S
// key: clear_key   access: RW1C
// key: others      access: RO
class jf_rwcsb_reg extends jf_key_reg;
    u32 set_key;
    u32 clear_key;

    static jf_rwcsb_reg_field_cb rwcsb_cb;
    static jf_rw1c1s_reg_field_cb rw1c1s_cb;

    function new(
        string name = "jf_rwcsb_reg",
        int unsigned n_bits,
        int has_coverage
    );
        super.new(name, n_bits, has_coverage);

        if (rwcsb_cb == null) rwcsb_cb = new();
        if (rw1c1s_cb == null) rw1c1s_cb = new();
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
            set_key: begin
                update_keyed_field_access("W1S");
            end
            clear_key: begin
                update_keyed_field_access("W1C");
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
        uvm_reg_field_cb::add(key_field, rwcsb_cb);

        foreach (m_fields[i]) begin
            if (!is_keyed_field(m_fields[i])) continue;

            uvm_reg_field_cb::add(m_fields[i], rw1c1s_cb);
        end
    endfunction
endclass
