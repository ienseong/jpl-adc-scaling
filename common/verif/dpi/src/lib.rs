use std::ffi::CStr;
use std::os::raw::c_char;
use std::path::Path;
use std::time::SystemTime;

/// Allocates and returns the system time corresponding to "now".
///
/// See also [jf_time_elapsed].
#[no_mangle]
pub extern "C" fn jf_time_new() -> *mut SystemTime {
    Box::into_raw(Box::new(SystemTime::now()))
}

/// Returns the system time elapsed between the provided system time and "now" in seconds.
///
/// # Examples
///
/// ```
/// let reference_time = jf_time_new();
/// // pass some time...
/// let seconds_since_reference_time = jf_time_elapsed(reference_time);
/// jf_time_free(time);
/// ```
#[no_mangle]
pub extern "C" fn jf_time_elapsed(time: *const SystemTime) -> u64 {
    let time = unsafe { *time };

    match time.elapsed() {
        Ok(elapsed) => elapsed.as_secs(),
        Err(_) => 0,
    }
}

/// Frees a system time previous allocated by [jf_time_new].
///
/// Used to provide wall time elapsed in simulation log messages.
///
/// See also [jf_time_elapsed].
#[no_mangle]
pub extern "C" fn jf_time_free(time: *mut SystemTime) {
    unsafe { Box::from_raw(time) };
}

/// Returns true if path exists on the filesystem.
///
/// This is a quiet alternative to using SystemVerilog's `$fopen` for testing path existence.
#[no_mangle]
pub extern "C" fn jf_path_exists(path: *const c_char) -> bool {
    let path = unsafe { CStr::from_ptr(path) };
    match path.to_str() {
        Ok(path) => Path::exists(Path::new(path)),
        Err(_) => false,
    }
}

#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        assert_eq!(2 + 2, 4);
    }
}
