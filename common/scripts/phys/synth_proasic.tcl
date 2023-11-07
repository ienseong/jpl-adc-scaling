#-- compilation/mapping options
set_option -default_enum_encoding default
set_option -symbolic_fsm_compiler 1
set_option -resource_sharing 1
set_option -use_fsm_explorer 0

#-- map options
set_option -frequency 40
set_option -vendor_xcompatible_mode 0
set_option -vendor_xcompatible_mode 0
set_option -run_prop_extract 1
set_option -fanout_limit 30
set_option -globalthreshold 50
set_option -maxfan_hard 0
set_option -disable_io_insertion 0
set_option -retiming 1
set_option -report_path 4000
set_option -opcond COMWC
set_option -update_models_cp 0
set_option -preserve_registers 0
set_option -hdl_define -set "PROASIC"

#-- simulation options
set_option -write_verilog 1
set_option -write_vhdl 0

#-- automatic place and route (vendor) options
set_option -write_apr_constraint 1

#-- implementation attributes
set_option -vlog_std v2001
set_option -dup 0
set_option -auto_constrain_io 0
set_option -project_relative_includes 1
