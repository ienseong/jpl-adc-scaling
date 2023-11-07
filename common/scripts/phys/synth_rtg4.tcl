#implementation attributes

set_option -vlog_std sysv
set_option -project_relative_includes 1

#device options
# Note: these are set in run_syn.sh -------
#set_option -technology RTG4
#set_option -part RT4G150
#set_option -package CG1657
#set_option -speed_grade STD
# -----------------------------------------

set_option -part_companion ""

#compilation/mapping options
set_option -use_fsm_explorer 0

# hdl_compiler_options
set_option -distributed_compile 0

# mapper_without_write_options
set_option -frequency auto
set_option -srs_instrumentation 1

# mapper_options
set_option -write_verilog 1
set_option -write_vhdl 0

# actel_options
set_option -rw_check_on_ram 0

# Microsemi G4
set_option -run_prop_extract 1
set_option -maxfan 10000
set_option -clock_globalthreshold 2
set_option -async_globalthreshold 200000
set_option -globalthreshold 5000
set_option -low_power_ram_decomp 0
set_option -seqshift_to_uram 0
set_option -disable_io_insertion 0
set_option -opcond COMTC
set_option -retiming 0
set_option -report_path 4000
set_option -update_models_cp 0
set_option -preserve_registers 0

# NFilter
set_option -no_sequential_opt 0

# sequential_optimization_options
set_option -symbolic_fsm_compiler 1

# Compiler Options
set_option -compiler_compatible 0
set_option -resource_sharing 1
set_option -multi_file_compilation_unit 1

# Compiler Options

#automatic place and route (vendor) options
set_option -write_apr_constraint 1
