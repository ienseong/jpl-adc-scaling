// Class: jf_enum_info
//
// Provides SystemVerilog enum introspection.
//
// *Example*:
//
// Set access_type_invalid to a value not in the access_type_e enum.
//
// >    typedef bit [1:0] access_type_t;
// >    typedef enum access_type_t {
// >        READ = 1,
// >        WRITE = 2
// >    } access_type_e;
// >    typedef jf_enum_info #(access_type_e, access_type_t) access_type_info;
// >
// >    access_type_e access_type_valid;
// >    access_type_t access_type_invalid;
// >
// >    `jf_ensure_randomize(std::randomize(access_type_valid, access_type_invalid) with {
// >        !(access_type_invalid inside { access_type_info::values() });
// >    })
// >
// >    assert(access_type_invalid == 0 || access_type_invalid == 3);
// >    assert(access_type_valid == READ || access_type_valid == WRITE);
//
// *Example*:
//
// Same example using scoped enum.
//
// >    typedef bit [1:0] access_type_t;
// >    class access_type_e;
// >        typedef enum access_type_t {
// >            READ = 1,
// >            WRITE = 2
// >        } t;
// >
// >        typedef jf_enum_info #(t, access_type_t) info;
// >    endclass
// >
// >    access_type_e::t access_type_valid;
// >    access_type_t access_type_invalid;
// >
// >    `jf_ensure_randomize(std::randomize(access_type_valid, access_type_invalid) with {
// >        !(access_type_invalid inside { access_type_e::info::values() });
// >    })
// >
// >    assert(access_type_invalid == 0 || access_type_invalid == 3);
// >    assert(access_type_valid == access_type_e::READ || access_type_valid == access_type_e::WRITE);
//
class jf_enum_info #(parameter type E, parameter type T = u32);
    typedef T string_to_T[string];
    typedef string T_to_string[T];

    static local string_to_T _values;
    static local T_to_string _ids;

    static function void initialize();
        E e = e.first;

        forever begin
            T value = T'(e);
            _values[e.name] = value;
            _ids[value] = e.name;
            if (e == e.last) break;
            e = e.next;
        end
    endfunction

    static function string_to_T values();
        if (_values.size() == 0) initialize();

        return _values;
    endfunction

    static function T_to_string ids();
        if (_ids.size() == 0) initialize();

        return _ids;
    endfunction
endclass
