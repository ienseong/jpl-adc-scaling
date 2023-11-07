// Author:  Rob Donnelly <robert.donnelly@jpl.nasa.gov>
// Created: 2017-05-09

// Class: jf_key_reg
//
// Base class for key register types.
virtual class jf_key_reg extends uvm_reg;
    virtual class field_kind_t;
        typedef enum {
            KEY,
            KEYED,
            RSVD
        } e;
    endclass

    typedef struct {
        field_kind_t::e kind;
        u32 write_value;
    } field_info_t;

    uvm_reg_field key_field;
    bit key_has_flop = 1;

    field_info_t field_info[*];

    local bit m_configured;

    function new(
        string name = "jf_key_reg",
        int unsigned n_bits,
        int has_coverage
    );
        super.new(name, n_bits, has_coverage);
    endfunction

    function void do_predict(
        uvm_reg_item      rw,
        uvm_predict_e     kind = UVM_PREDICT_DIRECT,
        uvm_reg_byte_en_t be = -1
    );
        check_config();

        // Set field write values here instead of in the callback post_predict.
        // post_predict is not given the raw write value.  Instead, it is given
        // the predicted write value.  The predicted write value is useless.
        // Set the field write values here since we have the raw write value.
        if (kind == UVM_PREDICT_WRITE) begin
            foreach (m_fields[i]) begin
                u32 field_value = (rw.value[0] >> m_fields[i].get_lsb_pos()) & ((1 << m_fields[i].get_n_bits()) - 1);
                set_field_write_value(m_fields[i], field_value);
            end
        end

        super.do_predict(rw, kind, be);
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
        check_config();

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
    endtask

    // Function: configure_special_register
    //
    // Must be called by the user after build().
    //
    // We can't hide this from the user because this must be done after
    // uvm_reg_field::configure() is called in reg::build() AND:
    //
    // * uvm_reg_field::configure() is not virtual so we can't override to
    //   add the callback
    //
    // * uvm_reg does not define build() so we can't override it to add the
    //   callbacks either
    virtual function void configure_special_register();
        identify_fields();
        configure_callbacks();
        m_configured = 1;
    endfunction

    // Function: identify_fields
    //
    // Populates the field_info variable with field identity information using
    // heuristics.
    //
    // Heuristics:
    //
    // * Last field is key field
    // * Read-only fields are RSVD
    // * Everything else is a keyed field
    virtual function void identify_fields();
        if (key_field != null) return;

        key_field = m_fields[$];

        foreach (m_fields[i]) begin
            uvm_reg_field field = m_fields[i];

            if (field == key_field) begin
                field_info[field.get_inst_id()].kind = field_kind_t::KEY;
            end else if (field.get_access() == "RO") begin
                field_info[field.get_inst_id()].kind = field_kind_t::RSVD;
            end else begin
                field_info[field.get_inst_id()].kind = field_kind_t::KEYED;
            end
        end
    endfunction

    pure virtual function void configure_callbacks();

    function void update_keyed_field_access(string access);
        foreach (m_fields[i]) begin
            if (!is_keyed_field(m_fields[i])) continue;

            void'(m_fields[i].set_access(access));
        end
    endfunction

    function bit is_keyed_field(uvm_reg_field field);
        return field_info[field.get_inst_id()].kind == field_kind_t::KEYED;
    endfunction

    function u32 get_field_write_value(uvm_reg_field field);
        return field_info[field.get_inst_id()].write_value;
    endfunction

    function void set_field_write_value(uvm_reg_field field, u32 write_value);
        field_info[field.get_inst_id()].write_value = write_value;
    endfunction

    local function void check_config();
        if (!m_configured) `uvm_fatal(get_name(), "Register not configured.  See $J5_COMMON/verif/lib/uvm/reg/README.md for configuration instructions.")
    endfunction
endclass
