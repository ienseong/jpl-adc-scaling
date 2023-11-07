// DEPRECATED: Use the types without the _t suffix instead.
typedef bit unsigned [3:0]  u4_t;
typedef byte unsigned       u8_t;
typedef shortint unsigned   u16_t;
typedef int unsigned        u32_t;
typedef longint unsigned    u64_t;

// DEPRECATED: Use the types without the _t suffix instead.
typedef bit signed [3:0]    s4_t;
typedef byte signed         s8_t;
typedef shortint signed     s16_t;
typedef int signed          s32_t;
typedef longint signed      s64_t;

// Unsigned types
typedef bit u1;
typedef bit [1:0] u2;
typedef bit [2:0] u3;
typedef bit [3:0] u4;
typedef bit [4:0] u5;
typedef bit [5:0] u6;
typedef bit [6:0] u7;
typedef byte unsigned u8;
typedef bit [8:0] u9;
typedef bit [9:0] u10;
typedef bit [10:0] u11;
typedef bit [11:0] u12;
typedef bit [12:0] u13;
typedef bit [13:0] u14;
typedef bit [14:0] u15;
typedef shortint unsigned u16;
typedef bit [16:0] u17;
typedef bit [17:0] u18;
typedef bit [18:0] u19;
typedef bit [19:0] u20;
typedef bit [20:0] u21;
typedef bit [21:0] u22;
typedef bit [22:0] u23;
typedef bit [23:0] u24;
typedef bit [24:0] u25;
typedef bit [25:0] u26;
typedef bit [26:0] u27;
typedef bit [27:0] u28;
typedef bit [28:0] u29;
typedef bit [29:0] u30;
typedef bit [30:0] u31;
typedef int unsigned u32;
typedef longint unsigned u64;
typedef bit [127:0] u128;

// Signed types
typedef bit signed [3:0] s4;
typedef byte signed s8;
typedef shortint signed s16;
typedef int signed s32;
typedef longint signed s64;
typedef longint signed s128;

// Knobs
import knobs::kh_t;
import knobs::knob_base;
import knobs::knob;
import knobs::knob_optional;
export knobs::kh_t;
export knobs::knob_base;
export knobs::knob;
export knobs::knob_optional;

// Deprecated
//
// Use bit instead
typedef enum bit {
    false = 0,
    true = 1
} bool_t;
