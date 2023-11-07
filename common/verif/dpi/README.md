# J5 DPI

A small library that enhances SystemVerilog capabilities via DPI.

For example, there is no easy way to obtain the system time in SystemVerilog
for benchmarking.  One way to do this is by redirecting the output of the
system `date` command to a temporary file via `$system()`, using `$fopen()`
to parse the temporary file, then finally removing the temporary file.

This library provides a more efficient method of obtaining the system time.

This library is written in Rust and exposes functions to SystemVerilog DPI via
the C ABI.
