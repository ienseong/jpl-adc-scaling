// Formatting functions for various types
class jf_format#(type TYPE = u32);
    // Format a queue to a string.
    //
    // SystemVerilog provides the %p format specifier however it is not
    // ideal in most cases since it formats integers as decimal.  This
    // function formats integers as hexidecimal instead.
    //
    // An optional limit can be given to limit the number of entries.  If the
    // limit is less than the size of the collection, the middle entries will
    // be excluded.  For example, if the limit is 4 the first two entries and
    // the last two entries will be formatted while the middle entries will be
    // excluded.
    //
    // The limit will be rounded down to the nearest even number.
    //
    // Example: No limit
    //
    //     u8 q[$] = '{0, 1, 2, 3, 4, 5, 6, 7};
    //     `ensure_string_equal(
    //         jf_format#(u8)::queue(q),
    //         "0x00 0x01 0x02 0x03 0x04 0x05 0x06 0x07"
    //     )
    //
    // Example: With limit
    //
    //     u8 q[$] = '{0, 1, 2, 3, 4, 5, 6, 7};
    //     `ensure_string_equal(
    //         jf_format#(u8)::queue(q, 4),
    //         "0x00 0x01 ... 0x06 0x07"
    //     )
    static function string queue(ref TYPE in[$], input u64 limit = -1);
        string out;

        u64 edge_limit = limit / 2;

        if (in.size() == 0) begin
            return "[]";
        end

        for (int i = 0; i < in.size() - 1; i++) begin
            if (i == edge_limit && in.size() > edge_limit * 2) begin
                out = {out, "... "};

                if (edge_limit == 1) begin
                    break;
                end else begin
                    i = in.size() - edge_limit;
                end
            end

            out = {out, $sformatf("0x%x ", in[i])};
        end

        return {out, $sformatf("0x%x", in[$])};
    endfunction

    // Format an array to a string.
    //
    // SystemVerilog provides the %p format specifier however it is not
    // ideal in most cases since it formats integers as decimal.  This
    // function formats integers as hexidecimal instead.
    //
    // An optional limit can be given to limit the number of entries.  If the
    // limit is less than the size of the collection, the middle entries will
    // be excluded.  For example, if the limit is 4 the first two entries and
    // the last two entries will be formatted while the middle entries will be
    // excluded.
    //
    // The limit will be rounded down to the nearest even number.
    //
    // Example: No limit
    //
    //     u8 a[] = '{0, 1, 2, 3, 4, 5, 6, 7};
    //     `ensure_string_equal(
    //         jf_format#(u8)::array(a),
    //         "0x00 0x01 0x02 0x03 0x04 0x05 0x06 0x07"
    //     )
    //
    // Example: With limit
    //
    //     u8 a[] = '{0, 1, 2, 3, 4, 5, 6, 7};
    //     `ensure_string_equal(
    //         jf_format#(u8)::array(a, 4),
    //         "0x00 0x01 ... 0x06 0x07"
    //     )
    static function string array(ref TYPE in[], input u64 limit = -1);
        string out;

        u64 edge_limit = limit / 2;

        if (in.size() == 0) begin
            return "[]";
        end

        for (int i = 0; i < in.size() - 1; i++) begin
            if (i == edge_limit && in.size() > edge_limit * 2) begin
                out = {out, "... "};

                if (edge_limit == 1) begin
                    break;
                end else begin
                    i = in.size() - edge_limit;
                end
            end

            out = {out, $sformatf("0x%x ", in[i])};
        end

        return {out, $sformatf("0x%x", in[in.size() - 1])};
    endfunction
endclass
