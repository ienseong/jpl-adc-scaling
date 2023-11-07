module tb();
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import jf_pkg::*;
    `include "jf_macros.svh"

    `define ensure_string_equal(LEFT, RIGHT) \
        if (LEFT != RIGHT) begin \
            `uvm_error("ensure_string_equal", \
                $sformatf("left != right\n left: %s\nright: %s", \
                    LEFT, RIGHT)) \
        end

    `define begin_test(NAME) \
        class ``NAME``_test; \
            string name = `"NAME`"; \
 \
            function void run();

    `define end_test \
            endfunction \
        endclass

    `define run_test(NAME) \
        begin \
            ``NAME``_test test = new(); \
            `uvm_info("test", $sformatf("Running test %s...", test.name), UVM_MEDIUM) \
            test.run(); \
        end

    initial run_tests();

    `begin_test(jf_format_queue)
        u8 q[$] = '{0, 1, 2, 3, 4, 5, 6, 7};
        `ensure_string_equal(
            jf_format#(u8)::queue(q),
            "0x00 0x01 0x02 0x03 0x04 0x05 0x06 0x07"
        )
    `end_test

    `begin_test(jf_format_queue_limit)
        u8 q[$] = '{0, 1, 2, 3, 4, 5, 6, 7};
        `ensure_string_equal(
            jf_format#(u8)::queue(q, 4),
            "0x00 0x01 ... 0x06 0x07"
        )
    `end_test

    `begin_test(jf_format_queue_limit_odd)
        u8 q[$] = '{0, 1, 2, 3, 4, 5, 6, 7};
        `ensure_string_equal(
            jf_format#(u8)::queue(q, 5),
            "0x00 0x01 ... 0x06 0x07"
        )
    `end_test

    `begin_test(jf_format_queue_limit_zero)
        u8 q[$] = '{0, 1, 2, 3, 4, 5, 6, 7};
        `ensure_string_equal(
            jf_format#(u8)::queue(q, 2),
            "0x00 ... 0x07"
        )
    `end_test

    `begin_test(jf_format_array)
        u8 a[] = '{0, 1, 2, 3, 4, 5, 6, 7};
        `ensure_string_equal(
            jf_format#(u8)::array(a),
            "0x00 0x01 0x02 0x03 0x04 0x05 0x06 0x07"
        )
    `end_test

    `begin_test(jf_format_array_limit)
        u8 a[] = '{0, 1, 2, 3, 4, 5, 6, 7};
        `ensure_string_equal(
            jf_format#(u8)::array(a, 4),
            "0x00 0x01 ... 0x06 0x07"
        )
    `end_test

    `begin_test(jf_format_array_limit_odd)
        u8 a[] = '{0, 1, 2, 3, 4, 5, 6, 7};
        `ensure_string_equal(
            jf_format#(u8)::array(a, 5),
            "0x00 0x01 ... 0x06 0x07"
        )
    `end_test

    `begin_test(jf_format_array_limit_zero)
        u8 a[] = '{0, 1, 2, 3, 4, 5, 6, 7};
        `ensure_string_equal(
            jf_format#(u8)::array(a, 2),
            "0x00 ... 0x07"
        )
    `end_test

    function automatic void run_tests();
        `run_test(jf_format_queue)
        `run_test(jf_format_queue)
        `run_test(jf_format_queue_limit)
        `run_test(jf_format_queue_limit_odd)
        `run_test(jf_format_queue_limit_zero)
        `run_test(jf_format_array)
        `run_test(jf_format_array_limit)
        `run_test(jf_format_array_limit_odd)
        `run_test(jf_format_array_limit_zero)
    endfunction
endmodule
