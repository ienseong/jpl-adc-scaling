# UVM Modeling of J5 Registers

J5 defines two special registers:

* RWCSB - Field access type is one of "W1S", "W1C", or "RO" depending on key
  value
* RWKEY - Field access type is one of "RW" or "RO" depending on key value

Custom UVM register types are required to model these special registers.

## Usage

### Register Model

If using [Register
Translator](https://github.jpl.nasa.gov/349-fpga-support/register-translator),
the generated register model will extend from `jf_rwkey_reg` and `jf_rwcsb_reg`
register types for "RWKEY" and "RWCSB" registers respectively.

If not using Register Translator, the following changes will need to be made to
the register model:

* Import the J5 package

  ```SystemVerilog
  import jf_pkg::*;
  `include "jf_macros.svh"
  ```

* Extend from `jf_rwkey_reg` and `jf_rwcsb_reg` instead of `uvm_reg` for
  "RWKEY" and "RWCSB" registers respectively

  ```SystemVerilog
  class my_rwkey_reg extends jf_rwkey_reg;

  class my_rwcsb_reg extends jf_rwcsb_reg;

  class my_normal_reg extends uvm_reg;
  ```

### Key Configuration

Add a class similar to the following that defines the keys for each key
register type.

```SystemVerilog
// Class: key_register_info_t
//
// Stores configuration for key registers that does not automatically make
// it from the design specification to the generated UVM register model.
virtual class key_register_info_t;
    typedef struct {
        u32 key;
        u32 set_key;
        u32 clear_key;
        bit key_has_flop;
    } keys_t;

    // Variable: KEYS
    //
    // Lookup for keys.  Given a register type name, returns the keys.
    static const keys_t KEYS[string] = '{
        "HK_PWR_CTL_CSR":       '{ key_has_flop:1, set_key:'hc7, clear_key:'h38, default:0 },
        "HK_NOR_SEMAPHORE_CSR": '{ key_has_flop:1, set_key:'hc,  clear_key:'he,  default:0 },
        "HK_RT2_RT6_STG_CSR":   '{ key_has_flop:1, key:'hc,  default:0 },
        "HK_FDU_CTL_CSR":       '{ key_has_flop:1, key:'hc7, default:0 },
        "HK_FDU_TIMER_RST_CSR": '{ key_has_flop:1, key:'hc7, default:0 },
        "HK_ITCICC_CTL_CSR":    '{ key_has_flop:1, key:'hc7, default:0 },
        "HK_RSTCTL_CSR":        '{ key_has_flop:1, key:'hc, default:0 },
        "HK_NOR_CFG_CSR":       '{ key_has_flop:1, key:'hc7, default:0 },
        "HK_NOR_WP_CSR":        '{ key_has_flop:1, key:'hc7, default:0 },
        "STSU_REF_WINDOW_CSR":  '{ key_has_flop:0, key:'hc7, default:0 }
    };

    static function keys_t keys(string type_name);
        if (!KEYS.exists(type_name)) begin
            `uvm_error("key_register_info_t", $sformatf("Type name '%s' does not exist", type_name))
        end

        return KEYS[type_name];
    endfunction

    static function u32 key_has_flop(uvm_reg r);
        return keys(r.get_type_name()).key_has_flop;
    endfunction

    static function u32 set_key(uvm_reg r);
        return keys(r.get_type_name()).set_key;
    endfunction

    static function u32 clear_key(uvm_reg r);
        return keys(r.get_type_name()).clear_key;
    endfunction

    static function u32 key(uvm_reg r);
        return keys(r.get_type_name()).key;
    endfunction
endclass
```

#### Configuration Parameters

* `key`

  Defines the key for RWKEY/RWDATA registers.

* `set_key`/`clear_key`

  Defines the set and clear keys respectively for RWCSB/RW1C1S registers.

* `key_has_flop`

  Defines how the key field is implemented.  A value of `1` indicates the least
  significant bit of the key field is read-write while the upper bits are
  read-only zero.  A value of `0` indicates the entire key field is read-only
  zero.

  Rules of thumb:

  * If a key register is implemented using Register Translator generated RTL,
    then `key_has_flop` should be `1`.
  * If a key register is implemented by hand, then `key_has_flop` should be
    `0`.

### Register Configuration

Execute the following code after calling `reg_block.build()`.

```SystemVerilog
begin
    uvm_reg registers[$];

    jf_key_reg key_reg;
    jf_rwcsb_reg rwcsb_reg;
    jf_rwkey_reg rwkey_reg;

    reg_block.get_registers(registers);

    foreach (registers[i]) begin
        if ($cast(key_reg, registers[i])) begin
            if ($cast(rwcsb_reg, key_reg)) begin
                rwcsb_reg.set_key = key_register_info_t::set_key(rwcsb_reg);
                rwcsb_reg.clear_key = key_register_info_t::clear_key(rwcsb_reg);
            end else if ($cast(rwkey_reg, key_reg)) begin
                rwkey_reg.key = key_register_info_t::key(rwkey_reg);
            end

            key_reg.key_has_flop = key_register_info_t::key_has_flop(key_reg);
            key_reg.configure_special_register();
        end
    end
end
```

### Set and update for RWCSB/RW1C1S registers

The `uvm_reg_field::set()` method for RW1C1S fields may not behave as one might
expect.  For the clear case, one may expect `uvm_reg_field::set()` to work the
same as a field with W1C access.  This is not the case.

When `uvm_reg_field::set()` is called on a RW1C1S field, the access type is
actually RW.  Therefore, to clear a field, a `set(0)` must be done instead of a
`set(1)`.

#### Example: Clearing a standard W1C field

```SystemVerilog
myreg.myfield.set(1);
myreg.update(status);
```

#### Example: Clearing a RW1C1S field

```SystemVerilog
myreg.mykey.set(clear_key);
myreg.myfield.set(0);
myreg.update(status);
```
