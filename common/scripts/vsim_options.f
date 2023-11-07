# Demote missing timescale error to warning
#
# Some verification IP doesn't have it
#
# Example:
#
# ** Error:**  (vsim-3009) [TSCALE] - Module 'assert_never' does not have a timeunit/timeprecision specification in effect, but
# other modules do.
-warning 3009

# Promote "unable to read file" warning to error
#
# Warning could result in silent simulation failure.  If an input file is optional, file accessibility should be checked before
# attempting to read.
#
# Example:
#
# ** Warning: (vsim-3534) [FOFIR] - Failed to open file "/home/rdonnell/sbox/cvac/2/vp/homog_warp/rtl/recip_rom.mif" for reading.
-error 3534

# Promote "failed to open readmem file" warning to error
#
# Example:
#
# ** Warning: (vsim-7) Failed to open readmem file "./pat/eio_ir/IREG_por_pttn_f1" in read mode.
# No such file or directory. (errno = ENOENT)    : /proj/ecm_avs/users/rdonnell/sbox/eio/2/eio/legacy/verif/code/eio_ireg.sv(124)
-error 7

# Report randomize failures as error
-solvefailseverity=2

# Report debug info on randomize failures
# Setting of 2 is highest but has a performance penalty.  Setting of 1 gives enough information without a performance penalty.
-solvefaildebug=1
