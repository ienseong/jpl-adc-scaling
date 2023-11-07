// Fast ceiling integer division
//
// Implements ceil(dividend / divisor) for integers.
//
// Example:
//
// `jf_ensure(idivc#(u32)::f(5, 4) == 2)
class idivc#(type TYPE = u32);
    static function TYPE f(TYPE dividend, TYPE divisor);
        return (dividend + (divisor - 1)) / divisor;
    endfunction
endclass

// Returns the minimum value in a queue.
//
// Example:
//
// `jf_ensure(min#(u32)::f('{ 1, 2, 3 }) == 1)
class min#(type TYPE = u32);
    static function TYPE f(TYPE x[$]);
        TYPE result[$] = x.min();
        return result[0];
    endfunction
endclass

// Returns the maximum value in a queue.
//
// Example:
//
// `jf_ensure(max#(u32)::f('{ 1, 2, 3 }) == 3)
class max#(type TYPE = u32);
    static function TYPE f(TYPE x[$]);
        TYPE result[$] = x.max();
        return result[0];
    endfunction
endclass
