typedef chandle jf_time;

import "DPI-C" function jf_time jf_time_new();
import "DPI-C" function u64 jf_time_elapsed(jf_time t);
import "DPI-C" function jf_time_free(jf_time t);

import "DPI-C" function bit jf_path_exists(string path);
