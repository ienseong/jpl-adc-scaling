//*****************************************************************************
//    File Name:  fifo_async.v
//
//    File Type:  HDL
//
//    FPGA Name:  PCI
//
//    Project Name:  PCI
//
//    Author:  Jim Butler
//
//
// THIS DOCUMENT MAY CONTAIN CALTECH/JPL PROPRIETARY INFORMATION.
// THE TECHNICAL DATA CONTAINED IN THIS DOCUMENT(S) OR FILE(S) MAY BE
// RESTRICTED FOR EXPORT UNDER THE INTERNATIONAL TRAFFIC IN ARMS REGULATIONS
// (ITAR) OR THE EXPORT ADMINISTRATION REGULATIONS (EAR).
// VIOLATIONS OF THESE EXPORT LAWS MAY BE SUBJECT TO FINES AND
// PENALTIES UNDER THE ARMS EXPORT CONTROL ACT (22 U.S.C. 2778).
//
// Description:
// Asynchronous FIFO top level
//
//
//*****************************************************************************

`include "timescale.vh"
`include "project_defines.vh"



module fifo_async
         (
	// Write Inputs
	rst_wr_n,
	clk_wr,
	wstb,
	wdata,
        
	// Read Inputs
	rst_rd_n,
	clk_rd,
	rstb,

	// Write Outputs
	numempty,
	overflow,
        
	// Read Outputs
	rdata,
	numfilled,
	underflow
      );
      
      
      
      
// synopsys template
parameter	FIFODEPTH	=	'd16;
parameter	FIFOWIDTH	=	'd72;
parameter	FIFOPTRWIDTH	=	('d2 == FIFODEPTH)? 'd1:
					('d4 == FIFODEPTH) ? 'd2:
					('d8 == FIFODEPTH) ? 'd3:
					('d16 == FIFODEPTH) ? 'd4:
					('d32 == FIFODEPTH) ? 'd5:
					('d64 == FIFODEPTH) ? 'd6:
					('d128 == FIFODEPTH) ? 'd7:
					('d256 == FIFODEPTH) ? 'd8:
					'd0;
                                        
                                        
input		        rst_wr_n;
input			clk_wr;
input		        wstb;
input [FIFOWIDTH-1:0]	wdata;
input			rst_rd_n;
input			clk_rd;
input			rstb;

output [FIFOPTRWIDTH:0]	numempty;
output			overflow;
output [FIFOWIDTH-1:0]	rdata;
output [FIFOPTRWIDTH:0]	numfilled;
output			underflow;




wire[FIFOPTRWIDTH-1:0]	waddr;
wire[FIFOPTRWIDTH-1:0]	raddr;
wire[FIFOPTRWIDTH:0]	numempty;
wire			overflow;
wire[FIFOWIDTH-1:0]	rdata;
wire[FIFOPTRWIDTH:0]	numfilled;
wire			underflow;




fifo_ctl_async #(FIFODEPTH, FIFOWIDTH, FIFOPTRWIDTH)	fifo_ctl_async_0
	(
		// Write Inputs
		.rst_wr_n		(rst_wr_n),
		.clk_wr			(clk_wr),
		.wstb			(wstb),
		// Read Inputs
		.rst_rd_n		(rst_rd_n),
		.clk_rd			(clk_rd),
		.rstb			(rstb),
		// RAM Address Outputs
		.waddr		        (waddr),
		.raddr		        (raddr),
		// Write Outputs
		.numempty		(numempty),
		.overflow		(overflow),
		// Read Outputs
		.numfilled		(numfilled),
		.underflow		(underflow)
	);
        
        
        

memw1r1	#(FIFODEPTH, FIFOWIDTH, FIFOPTRWIDTH)	fifo_async_mem
	(
		.rst_a_n	       (rst_wr_n),
		.clk_a		       (clk_wr),
		.addr_a		       (waddr),
		.wen_a		       ({FIFOWIDTH{wstb}}),
		.di_a		       (wdata),
		.addr_b		       (raddr),

		.do_b		       (rdata)
	);


endmodule
