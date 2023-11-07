// Class: jf_test
//
// Provides common framework and integration with J5.
//
// * Sets the time format
// * Overrides the default UVM report server for simplified log formatting
// * Overrides the default max quit count to stop on first error
// * Sets the Knobs seed via the +seed plusarg
//
// All J5 tests shall extend jf_test instead of uvm_test.
//
// Examples:
//
//| class my_base_test extends jf_test;
//|     `uvm_component_utils(my_base_test)
//|
//|     function new(string name, uvm_component parent);
//|         super.new(name, parent);
//|     endfunction
//|
//|     function void build_phase(uvm_phase phase);
//|         super.build_phase(phase);
//|         ...
//|         clock_period = 25ns;    // 40 MHz system clock
//|     endfunction
//|     ...
//| endclass
class jf_test extends uvm_test;
    `uvm_component_utils(jf_test)

    virtual class time_unit_t;
        typedef enum int {
            SECONDS = 0,
            MILLISECONDS = -3,
            MICROSECONDS = -6,
            NANOSECONDS = -9,
            PICOSECONDS = -12
        } e;
    endclass

    // For reporting cycles per second
    realtime clock_period;
    jf_time system_time;

    function new(string name, uvm_component parent);
        jf_report_server report_server = new();

        super.new(name, parent);

        // Make times "%t" more readable
        $timeformat(time_unit_t::NANOSECONDS, 0, "ns", 0);

        // Replace report_server for better message formatting
        uvm_report_server::set_server(report_server);

        // Default to quit on single error
        // Allow +UVM_MAX_QUIT_COUNT to override
        uvm_report_server::get_server().set_max_quit_count(1);

        // Report all miscompares
        uvm_default_comparer.show_max = -1;

        // Parse +seed plusarg for Knobs
        knobs::seed_from_plusargs();

        system_time = jf_time_new();
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        jf_option_parser::get_inst().parse();
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
        uvm_table_printer table_printer;

        super.end_of_elaboration_phase(phase);

        // Display test environment hierarchy
        table_printer = new();
        table_printer.knobs.depth = 4;
        `uvm_info(get_name(), {"\n", sprint(table_printer)}, UVM_MEDIUM)

        // Set and display max_quit_count
        table_printer.print_int("max_quit_count", uvm_report_server::get_server().get_max_quit_count(), 32);
        `uvm_info(get_name(), {"\n", table_printer.emit()}, UVM_MEDIUM)

        // Print factory configuration for debug
        uvm_coreservice_t::get().get_factory().print();
    endfunction

    function void final_phase(uvm_phase phase);
        super.final_phase(phase);

        if (clock_period == 0) begin
            `uvm_warning(get_name(), {
                "The jf_test::clock_period variable has not initialized.\n",
                "Cycles per second cannot be reported.  To resolve, set the jf_test::clock_period variable\n",
                "in the base test build_phase().\n",
                "For example: clock_period = 25ns; // 40MHz system clock"})
        end else begin
            u64 cycles = $realtime() / clock_period;
            u64 elapsed_time = jf_time_elapsed(system_time);
            u64 cycles_per_second = cycles / elapsed_time;
            `uvm_info(get_name(), $sformatf(
                "clock_period:%t cycles:%0d elapsed_time:%0ds cycles_per_second:%0d",
                clock_period, cycles, elapsed_time, cycles_per_second
            ), UVM_MEDIUM)
        end
    endfunction
endclass
