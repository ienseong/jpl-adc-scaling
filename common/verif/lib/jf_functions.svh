// Function: div_ceil
//
// A integer version of ceil(dividend / divisor).
//
// DEPRECATED: Use idivc#(u32)::f() instead.
function u32 div_ceil(u32 dividend, u32 divisor);
    return (dividend + (divisor - 1)) / divisor;
endfunction

// Function: min_u32
//
// A short hand for u32[$]::min().
//
// Without this function:
//
// u32 values[$] = '{ a, b };
// u32 value = values.min[0]
//
// With this function:
//
// u32 value = min_u32('{ a, b });
//
// DEPRECATED: Use min#(u32)::f() instead.
function u32 min_u32(u32 values[$]);
    return values.min[0];
endfunction

// Function: max_u32
//
// A short hand for u32[$]::max().
//
// Example:
//
// u32 value = max_u32('{ a, b });
//
// DEPRECATED: Use max#(u32)::f() instead.
function u32 max_u32(u32 values[$]);
    return values.max[0];
endfunction
