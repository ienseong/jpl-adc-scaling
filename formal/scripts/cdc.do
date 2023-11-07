## Add CDC constraints
cdc reconvergence on
cdc preference reconvergence -depth 1
cdc preference fifo -check_multi_clock_memory
cdc scheme on -fifo
cdc preference -formal_add_bus_stability
cdc preference -formal_add_recon_stability
cdc preference fifo -effort high -sync_effort high
#cdc promote scheme async_reset -promotion on
#
## Add Primary Input clock association

# Async Inputs
#netlist port domain -async por_n
#netlist port domain -async rst_n
