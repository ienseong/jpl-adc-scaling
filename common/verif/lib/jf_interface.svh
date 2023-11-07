typedef class jf_interface_uvm_config_db;

// Class: jf_interface
//
// A wrapper for virtual interfaces that allows annotation of the virtual
// interface with metadata.
//
// Specifically, it allows a name and numerical identifier to be associated
// with a virtual interface.  This is useful for monitors/drivers/scoreboards
// to use when reporting on which interface a uvm_sequence_item was seen.
//
// Available metadata:
//
// Name - String identifier for messages.  Obtain via get_name().
// ID - Optional numerical identifier for comparisons.  Obtain via get_id().
//
// Examples:
//
// Define a typedef.
//
//| // File: my_pkg.sv
//|
//| package my_pkg;
//|     // Define the interface class as a typedef
//|     typedef jf_interface#(virtual spi_if) spi_if_t;
//|     ...
//| endpackage
//
// Instantiate and place into UVM configuration database.
//
//| // File: verif/testbench/tb.sv
//|
//| module tb;
//|     import mk_pkg::spi_if_t;
//|     ...
//|     initial begin
//|         // Create an interface object for the virtual interface and put into
//|         // the uvm_config_db
//|         spi_if_t::config_db_set("spi_if", spi_if);
//|         ...
//|         run_test();
//|     end
//| endmodule
//
// Pull out of configuration database and put into a UVC configuration object.
//
//| // File: verif/tests/my_base_test.svh
//|
//| class my_base_test extends jf_test;
//|     ...
//|     function void build_phase(uvm_phase phase);
//|         super.build_phase(phase);
//|         ...
//|         spi_cfg = spi_uvc_config::type_id::create("spi_cfg");
//|         spi_cfg.initialize();
//|         `jf_config_db_get_interface(spi_if_t, "spi_if", spi_cfg.cfgs[0].ifo);
//|         uvm_config_db#(spi_uvc_config)::set(
//|             this, "*.spi_uvc", "spi_uvc_config", spi_cfg);
//|         ...
//|     endfunction
//| endclass
//
// Get interface name from interface object.
//
//| // File: my_scoreboard.svh
//|
//| class my_scoreboard extends uvm_scoreboard;
//|     ...
//|     function void write_spi(spi_sequence_item actual);
//|         `uvm_info(actual.ifo.get_name(), actual.convert2string(), UVM_MEDIUM)
//|         ...
//|     endfunction
//| endclass
//
// Get virtual interface from interface object.
//
//| // File: spi_monitor.svh
//|
//| class spi_monitor extends uvm_monitor;
//|     ...
//|     spi_if_t ifo;
//|     ...
//|     task run_phase(uvm_phase phase);
//|         spi_if_v vif = ifo.vif;
//|         ...
//|     endtask
//| endclass
class jf_interface #(type VIF_TYPE) extends uvm_object;
    // Group: Accessors

    // Variable: vif
    //
    // A handle to the virtual interface.
    VIF_TYPE vif;
    local u32 id;

    `uvm_object_param_utils_begin(jf_interface#(VIF_TYPE))
        `uvm_field_int(id, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "jf_interface", VIF_TYPE vif = null, u32 id = 0);
        super.new(name);
        this.vif = vif;
        this.id = id;
    endfunction

    function void do_copy(uvm_object rhs);
        jf_interface#(VIF_TYPE) rhs_;
        super.do_copy(rhs);
        $cast(rhs_, rhs);
        vif = rhs_.vif;
        id = rhs_.id;
    endfunction

    // Function: get_name
    //
    // Returns the name associated with the interface.
    //
    // Inherited from uvm_object.

    // Function: get_id
    //
    // Returns the ID associated with the interface.
    function u32 get_id();
        return id;
    endfunction

    // Group: Helper Methods

    // Function: config_db_set
    //
    // Wraps a virtual interface in an interface object (jf_interface instance)
    // and puts the interface object into the uvm_config_db.
    //
    // Example:
    //
    //| // Define the interface class as a typedef
    //| typedef jf_interface#(virtual spi_if) spi_if_t;
    //| ...
    //| initial begin
    //|     // Create an interface object for the virtual interface and put
    //|     // into the uvm_config_db
    //|     spi_if_t::config_db_set("spi_if", spi_if);
    //|     ...
    //|     run_test();
    //| end
    static function void config_db_set(string name, VIF_TYPE vif, u32 id = 0);
        jf_interface_uvm_config_db#(jf_interface#(VIF_TYPE), VIF_TYPE)::set(name, vif, id);
    endfunction
endclass

// Class: jf_interface_uvm_config_db
//
// Provides a parameterized method for putting a virtual interface into an
// interface object then putting the interface object into the uvm_config_db.
//
// This virtual class is not intended to be used directly except for special
// cases.
//
// Instead, it is recommended that jf_interface#(VIF_TYPE)::config_db_set
// be used.
//
// Example:
//
//| // Define the interface class as a typedef
//| typedef jf_interface#(virtual spi_if) spi_if_t;
//| ...
//| initial begin
//|     // Create an interface object for the virtual interface and put into
//|     // the uvm_config_db
//|     spi_if_t::config_db_set("spi_if", spi_if);
//|     ...
//|     run_test();
//| end
//
// Parameterized interface classes cannot use
// jf_interface#(VIF_TYPE)::config_db_set due to type mismatch.  Instead
// they must use jf_interface_uvm_config_db#(...)::set() directly.
//
// Example:
//
//| // Define the interface class as an extended class
//| class discrete_if_t#(...) extends jf_interface#(virtual discrete_if#(...));
//| ...
//| endclass
//| ...
//| initial begin
//|     // Create an interface object for the virtual interface and put into
//|     // the uvm_config_db
//|     jf_interface_uvm_config_db#(
//|         discrete_if_t#(logic), virtual discrete_if#(logic)
//|     )::set(id.name.tolower(), vifs[i], id);
//|     ...
//|     run_test();
//| end
virtual class jf_interface_uvm_config_db#(type IFO_TYPE, type VIF_TYPE);
    static function void set(string name, VIF_TYPE vif, u32 id = 0);
        IFO_TYPE ifo = new(name, vif, id);
        uvm_config_db#(IFO_TYPE)::set(null, "uvm_test_top", name, ifo);
    endfunction
endclass

