`ifndef __JF_MACROS_SVH__
`define __JF_MACROS_SVH__

// Group: C-like Assertions
//
// The following macros are used to guarantee a condition similar to
// C assertions.

// Macro: `jf_ensure
//
// A SystemVerilog implementation of C's assert().
//
// Calls `jf_ensure_desc using the statement as the description.
//
// Consider using this for a simple check on single-line statements w/o string
// literals.
//
// Limitations:
//
// * Multi-line statements will result in warning.  Consider jf_ensure_*
//   instead.
// * Cannot pass statements containing string literals.  Consider jf_ensure_*
//   instead.
//
// Examples:
//
//| u32 a;
//|
//| `jf_ensure(std::randomize(a) with { a > 10; })
`define jf_ensure(STATEMENT) `jf_ensure_desc(STATEMENT, \
    {"The following statement failed:\n", `jf_stringify(STATEMENT)})

// Macro: `jf_ensure_desc
//
// Generic assert macro that calls `uvm_fatal on failure with user defined
// message.
//
// Intended as a replacement to immediate assertions.  Immediate assertions are
// often undesirable because they:
//
// * They do not automatically terminate execution.  They require an
//   explicit terminate statement in an else clause to do so.
// * Can be disabled via the $assertoff system call
// * Show up in the coverage report making it difficult to find actual
//   coverage
`define jf_ensure_desc(STATEMENT, DESCRIPTION) if (!(STATEMENT)) begin \
    `uvm_fatal("ensure", DESCRIPTION) \
end

// Macro: `jf_ensure_randomize
//
// Reports randomization failure.  For use on multi-line std::randomize and
// obj.randomize calls.  If not used, these calls will fail without
// stopping the test.
//
// Examples:
//
//| u32 a;
//|
//| `jf_ensure_randomize(std::randomize(a) with {
//|     a > 10;
//| })
`define jf_ensure_randomize(STATEMENT) `jf_ensure_desc(STATEMENT, "Could not randomize.")

// Group: Coverage

// Macro: `jf_coverage_wildcard_bins_32
//
// Defines wildcard bins for a 32 coverpoint where we are more interested in
// the individual bits than the word values.
//
// Example:
//
// Cover all 32 bits of address.
//
//| covergroup my_covergroup;
//|     coverpoint address `jf_coverage_wildcard_bins_32
//| endgroup
//
// Example:
//
// Oddly sized values can be broken up into smaller coverpoints.
//
//| bit [27:0] value;
//|
//| covergroup my_covergroup;
//|     coverpoint value[27:24] `jf_coverage_wildcard_bins_4
//|     coverpoint value[23:16] `jf_coverage_wildcard_bins_8
//|     coverpoint value[15:00] `jf_coverage_wildcard_bins_16
//| endgroup
`define jf_coverage_wildcard_bins_32 { \
    wildcard bins bit_00_0 = {32'b???????????????????????????????0}; \
    wildcard bins bit_00_1 = {32'b???????????????????????????????1}; \
    wildcard bins bit_01_0 = {32'b??????????????????????????????0?}; \
    wildcard bins bit_01_1 = {32'b??????????????????????????????1?}; \
    wildcard bins bit_02_0 = {32'b?????????????????????????????0??}; \
    wildcard bins bit_02_1 = {32'b?????????????????????????????1??}; \
    wildcard bins bit_03_0 = {32'b????????????????????????????0???}; \
    wildcard bins bit_03_1 = {32'b????????????????????????????1???}; \
    wildcard bins bit_04_0 = {32'b???????????????????????????0????}; \
    wildcard bins bit_04_1 = {32'b???????????????????????????1????}; \
    wildcard bins bit_05_0 = {32'b??????????????????????????0?????}; \
    wildcard bins bit_05_1 = {32'b??????????????????????????1?????}; \
    wildcard bins bit_06_0 = {32'b?????????????????????????0??????}; \
    wildcard bins bit_06_1 = {32'b?????????????????????????1??????}; \
    wildcard bins bit_07_0 = {32'b????????????????????????0???????}; \
    wildcard bins bit_07_1 = {32'b????????????????????????1???????}; \
    wildcard bins bit_08_0 = {32'b???????????????????????0????????}; \
    wildcard bins bit_08_1 = {32'b???????????????????????1????????}; \
    wildcard bins bit_09_0 = {32'b??????????????????????0?????????}; \
    wildcard bins bit_09_1 = {32'b??????????????????????1?????????}; \
    wildcard bins bit_10_0 = {32'b?????????????????????0??????????}; \
    wildcard bins bit_10_1 = {32'b?????????????????????1??????????}; \
    wildcard bins bit_11_0 = {32'b????????????????????0???????????}; \
    wildcard bins bit_11_1 = {32'b????????????????????1???????????}; \
    wildcard bins bit_12_0 = {32'b???????????????????0????????????}; \
    wildcard bins bit_12_1 = {32'b???????????????????1????????????}; \
    wildcard bins bit_13_0 = {32'b??????????????????0?????????????}; \
    wildcard bins bit_13_1 = {32'b??????????????????1?????????????}; \
    wildcard bins bit_14_0 = {32'b?????????????????0??????????????}; \
    wildcard bins bit_14_1 = {32'b?????????????????1??????????????}; \
    wildcard bins bit_15_0 = {32'b????????????????0???????????????}; \
    wildcard bins bit_15_1 = {32'b????????????????1???????????????}; \
    wildcard bins bit_16_0 = {32'b???????????????0????????????????}; \
    wildcard bins bit_16_1 = {32'b???????????????1????????????????}; \
    wildcard bins bit_17_0 = {32'b??????????????0?????????????????}; \
    wildcard bins bit_17_1 = {32'b??????????????1?????????????????}; \
    wildcard bins bit_18_0 = {32'b?????????????0??????????????????}; \
    wildcard bins bit_18_1 = {32'b?????????????1??????????????????}; \
    wildcard bins bit_19_0 = {32'b????????????0???????????????????}; \
    wildcard bins bit_19_1 = {32'b????????????1???????????????????}; \
    wildcard bins bit_20_0 = {32'b???????????0????????????????????}; \
    wildcard bins bit_20_1 = {32'b???????????1????????????????????}; \
    wildcard bins bit_21_0 = {32'b??????????0?????????????????????}; \
    wildcard bins bit_21_1 = {32'b??????????1?????????????????????}; \
    wildcard bins bit_22_0 = {32'b?????????0??????????????????????}; \
    wildcard bins bit_22_1 = {32'b?????????1??????????????????????}; \
    wildcard bins bit_23_0 = {32'b????????0???????????????????????}; \
    wildcard bins bit_23_1 = {32'b????????1???????????????????????}; \
    wildcard bins bit_24_0 = {32'b???????0????????????????????????}; \
    wildcard bins bit_24_1 = {32'b???????1????????????????????????}; \
    wildcard bins bit_25_0 = {32'b??????0?????????????????????????}; \
    wildcard bins bit_25_1 = {32'b??????1?????????????????????????}; \
    wildcard bins bit_26_0 = {32'b?????0??????????????????????????}; \
    wildcard bins bit_26_1 = {32'b?????1??????????????????????????}; \
    wildcard bins bit_27_0 = {32'b????0???????????????????????????}; \
    wildcard bins bit_27_1 = {32'b????1???????????????????????????}; \
    wildcard bins bit_28_0 = {32'b???0????????????????????????????}; \
    wildcard bins bit_28_1 = {32'b???1????????????????????????????}; \
    wildcard bins bit_29_0 = {32'b??0?????????????????????????????}; \
    wildcard bins bit_29_1 = {32'b??1?????????????????????????????}; \
    wildcard bins bit_30_0 = {32'b?0??????????????????????????????}; \
    wildcard bins bit_30_1 = {32'b?1??????????????????????????????}; \
    wildcard bins bit_31_0 = {32'b0???????????????????????????????}; \
    wildcard bins bit_31_1 = {32'b1???????????????????????????????}; \
}

// Macro: `jf_coverage_wildcard_bins_16
//
// See jf_coverage_wildcard_bins_32
`define jf_coverage_wildcard_bins_16 { \
    wildcard bins bit_00_0 = {16'b???????????????0}; \
    wildcard bins bit_00_1 = {16'b???????????????1}; \
    wildcard bins bit_01_0 = {16'b??????????????0?}; \
    wildcard bins bit_01_1 = {16'b??????????????1?}; \
    wildcard bins bit_02_0 = {16'b?????????????0??}; \
    wildcard bins bit_02_1 = {16'b?????????????1??}; \
    wildcard bins bit_03_0 = {16'b????????????0???}; \
    wildcard bins bit_03_1 = {16'b????????????1???}; \
    wildcard bins bit_04_0 = {16'b???????????0????}; \
    wildcard bins bit_04_1 = {16'b???????????1????}; \
    wildcard bins bit_05_0 = {16'b??????????0?????}; \
    wildcard bins bit_05_1 = {16'b??????????1?????}; \
    wildcard bins bit_06_0 = {16'b?????????0??????}; \
    wildcard bins bit_06_1 = {16'b?????????1??????}; \
    wildcard bins bit_07_0 = {16'b????????0???????}; \
    wildcard bins bit_07_1 = {16'b????????1???????}; \
    wildcard bins bit_08_0 = {16'b???????0????????}; \
    wildcard bins bit_08_1 = {16'b???????1????????}; \
    wildcard bins bit_09_0 = {16'b??????0?????????}; \
    wildcard bins bit_09_1 = {16'b??????1?????????}; \
    wildcard bins bit_10_0 = {16'b?????0??????????}; \
    wildcard bins bit_10_1 = {16'b?????1??????????}; \
    wildcard bins bit_11_0 = {16'b????0???????????}; \
    wildcard bins bit_11_1 = {16'b????1???????????}; \
    wildcard bins bit_12_0 = {16'b???0????????????}; \
    wildcard bins bit_12_1 = {16'b???1????????????}; \
    wildcard bins bit_13_0 = {16'b??0?????????????}; \
    wildcard bins bit_13_1 = {16'b??1?????????????}; \
    wildcard bins bit_14_0 = {16'b?0??????????????}; \
    wildcard bins bit_14_1 = {16'b?1??????????????}; \
    wildcard bins bit_15_0 = {16'b0???????????????}; \
    wildcard bins bit_15_1 = {16'b1???????????????}; \
}

// Macro: `jf_coverage_wildcard_bins_8
//
// See jf_coverage_wildcard_bins_32
`define jf_coverage_wildcard_bins_8 { \
    wildcard bins bit_00_0 = {8'b???????0}; \
    wildcard bins bit_00_1 = {8'b???????1}; \
    wildcard bins bit_01_0 = {8'b??????0?}; \
    wildcard bins bit_01_1 = {8'b??????1?}; \
    wildcard bins bit_02_0 = {8'b?????0??}; \
    wildcard bins bit_02_1 = {8'b?????1??}; \
    wildcard bins bit_03_0 = {8'b????0???}; \
    wildcard bins bit_03_1 = {8'b????1???}; \
    wildcard bins bit_04_0 = {8'b???0????}; \
    wildcard bins bit_04_1 = {8'b???1????}; \
    wildcard bins bit_05_0 = {8'b??0?????}; \
    wildcard bins bit_05_1 = {8'b??1?????}; \
    wildcard bins bit_06_0 = {8'b?0??????}; \
    wildcard bins bit_06_1 = {8'b?1??????}; \
    wildcard bins bit_07_0 = {8'b0???????}; \
    wildcard bins bit_07_1 = {8'b1???????}; \
}

// Macro: `jf_coverage_wildcard_bins_4
//
// See jf_coverage_wildcard_bins_32
`define jf_coverage_wildcard_bins_4 { \
    wildcard bins bit_00_0 = {4'b???0}; \
    wildcard bins bit_00_1 = {4'b???1}; \
    wildcard bins bit_01_0 = {4'b??0?}; \
    wildcard bins bit_01_1 = {4'b??1?}; \
    wildcard bins bit_02_0 = {4'b?0??}; \
    wildcard bins bit_02_1 = {4'b?1??}; \
    wildcard bins bit_03_0 = {4'b0???}; \
    wildcard bins bit_03_1 = {4'b1???}; \
}

// Group: Misc

// Macro: `jf_stringify
//
// Convert a statement to a string. See whitepaper
// "The Verilog Preprocessor: Force for `Good and `Evil"
//
// Limitations:
//
// * Cannot pass statements containing string literals.
`define jf_stringify(STATEMENT) `"STATEMENT`"

// Macro: `jf_config_db_get_interface
//
// Simplifies uvm_config_db::get for interfaces.
`define jf_config_db_get_interface(TYPE, FIELD_NAME, VALUE) \
    if (!uvm_config_db#(TYPE)::get(this, "", FIELD_NAME, VALUE)) begin \
        `uvm_fatal("Configuration", {"Must 'uvm_config_db#(", \
            `jf_stringify(TYPE), ")::set(null, \"uvm_test_top\", \"", \
            FIELD_NAME, "\", ...)' before 'run_test()'"}); \
    end

`endif