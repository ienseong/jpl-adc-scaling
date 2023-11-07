// Class: jf_option_parser
//
// * Parse and document command line options.
// * Display documentation on +help.
// * Display configuration on parse()
//
// Usage:
//
// 1. Define options in the new function of desired class (e.g. uvm_test derived class).
//
// *Example*:
//
// >   function new(...);
// >       jf_option_parser op = jf_option_parser::get_inst();
// >       super.new(...);
// >
// >       op.banner("MY OPTIONS:");
// >       op.register_bool_option("burst_write", "enable burst write stimulus");
// >       op.banner();
// >   endfunction
//
// 2. Call parse() in the build phase of the base test.
//
// *Example*:
//
// >   virtual function void build_phase(...);
// >       super.build_phase(...);
// >
// >       jf_option_parser::get_inst().parse();
// >
// >       ...
// >   endfunction
//
// 3. Get options by calling the ::get_<type>_option functions.
//
// *Example*:
//
// >   if (jf_option_parser::get_bool_option("burst_write")) ...
class jf_option_parser extends uvm_object;
    typedef enum {
        BOOL,
        INT,
        STRING
    } option_type_t;

    local static jf_option_parser inst;

    local string help;
    local string options[$];
    local option_type_t option_types[string];
    local u32 uint_options[string];
    local string string_options[string];

    local function new();
        banner();
        banner("GLOBAL OPTIONS");
        banner();
        register_bool_option("help", "display this message");
    endfunction

    static function jf_option_parser get_inst();
        if (!inst) inst = new();
        return inst;
    endfunction

    local function bit parse_bool_option(string option, bit default_value);
        string value_s;
        u32 value_d;

        if ($value$plusargs({option, "=%s"}, value_s)) begin
            if (value_s == "true") begin
                return 1;
            end else if (value_s == "false") begin
                return 0;
            end else begin
                `uvm_error("jf_option_parser", $sformatf("Could not parse +%s option", option))
            end
        end else if ($value$plusargs({option, "=%0d"}, value_d)) begin
            return value_d;
        end else if ($test$plusargs(option)) begin
            return 1;
        end else begin
            return default_value;
        end
    endfunction

    local function string parse_string_option(string option, string default_value);
        string value;
        if ($value$plusargs({option, "=%s"}, value)) begin
            return value;
        end else begin
            return default_value;
        end
    endfunction

    local function u32 parse_uint_option(string option, u32 default_value);
        u32 value;
        if ($value$plusargs({option, "=%d"}, value)) begin
            return value;
        end else if ($value$plusargs({option, "=0x%h"}, value)) begin
            return value;
        end else begin
            return default_value;
        end
    endfunction

    function void register_bool_option(string option, string doc, bit default_value = 0);
        options.push_back(option);
        option_types[option] = BOOL;
        uint_options[option] = parse_bool_option(option, default_value);
        append_doc(option, doc);
    endfunction

    function void register_string_option(string option, string doc, string default_value = "");
        options.push_back(option);
        option_types[option] = STRING;
        string_options[option] = parse_string_option(option, default_value);
        append_doc(option, doc);
    endfunction

    function void register_uint_option(string option, string doc, u32 default_value = 0);
        options.push_back(option);
        option_types[option] = INT;
        uint_options[option] = parse_uint_option(option, default_value);
        append_doc(option, doc);
    endfunction

    local function void append_doc(string option, string doc);
        help = {help, "  +", option, " - ", doc, "\n"};
    endfunction

    local function bit option_exists(string option);
        foreach (options[i]) begin
            if (options[i] == option) return 1;
        end

        return 0;
    endfunction

    local function void verify_option_exists(string option);
        if (!option_exists(option)) begin
            `uvm_error("jf_option_parser", $sformatf("Option '%s' does not exist", option))
        end
    endfunction

    static function bool_t get_bool_option(string option);
        jf_option_parser op = get_inst();
        op.verify_option_exists(option);
        return bool_t'(op.uint_options[option]);
    endfunction

    static function u32 get_uint_option(string option);
        jf_option_parser op = get_inst();
        op.verify_option_exists(option);
        return op.uint_options[option];
    endfunction

    static function string get_string_option(string option);
        jf_option_parser op = get_inst();
        op.verify_option_exists(option);
        return op.string_options[option];
    endfunction

    function void banner(string text = "");
        help = {help, text, "\n"};
    endfunction

    function void parse();
        if (parse_bool_option("help", false)) begin
            $display(help);
            $finish();
        end else begin
            uvm_table_printer table_printer = new();

            foreach (options[i]) begin
                string option = options[i];
                string plusarg = {"+", option};

                if (option == "help") continue;

                case (option_types[option])
                    INT:    table_printer.print_int(plusarg, uint_options[option], 32);
                    BOOL:   table_printer.print_generic(plusarg, "bool", 1, uint_options[option] ? "true" : "false");
                    STRING: table_printer.print_string(plusarg, string_options[option]);
                endcase
            end

            `uvm_info("jf_option_parser", {"Options\n", table_printer.emit()}, UVM_MEDIUM)
        end
    endfunction
endclass
