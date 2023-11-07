##############################################################################
#             Copyright 2006-2017 Mentor Graphics Corporation
#                        All Rights Reserved.
#             THIS WORK CONTAINS TRADE SECRET AND PROPRIETARY
#           INFORMATION WHICH IS THE PROPERTY OF MENTOR GRAPHICS
#        CORPORATION OR ITS LICENSORS AND IS SUBJECT TO LICENSE TERMS.
##############################################################################


onerror {exit}
###### add directives
netlist constraint PORn          -value 1'b1 -after_init
netlist constraint BOARD_POR_0n  -value 1'b1 -after_init
netlist constraint BOARD_POR_1n  -value 1'b1 -after_init

