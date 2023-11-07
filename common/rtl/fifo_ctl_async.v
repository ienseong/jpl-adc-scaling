//*****************************************************************************
//    File Name:  fifo_ctl_async.v
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
// Asynchronous FIFO controller
//
//
//*****************************************************************************

`include "timescale.vh"
`include "project_defines.vh"




module fifo_ctl_async
      (
	// Write Inputs
	rst_wr_n,
	clk_wr,
	wstb,
        
	// Read Inputs
	rst_rd_n,
	clk_rd,
	rstb,

	// RAM Address Outputs
	waddr,
	raddr,
        
	// Write Outputs
	numempty,
	overflow,
        
	// Read Outputs
	numfilled,
	underflow
        
      );
      
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
                                                                
                                                                


input                      rst_wr_n;
input                      clk_wr;
input                      wstb;
input                      rst_rd_n;
input                      clk_rd;
input                      rstb;

output [FIFOPTRWIDTH-1:0]  waddr;
output [FIFOPTRWIDTH-1:0]  raddr;
output [FIFOPTRWIDTH:0]	   numempty;
output                     overflow;
output [FIFOPTRWIDTH:0]    numfilled;
output                     underflow;



reg [FIFOPTRWIDTH:0]	numfilled_d;
reg [FIFOPTRWIDTH:0]	numfilled;
reg [FIFOPTRWIDTH:0]	numempty_d;
reg [FIFOPTRWIDTH:0]	numempty;
reg [FIFOPTRWIDTH:0]	wrptr_d;
reg [FIFOPTRWIDTH:0]	wrptr;
reg [FIFOPTRWIDTH:0]	wrptr_grey;
reg [FIFOPTRWIDTH:0]	rdptr_wr_s1;
reg [FIFOPTRWIDTH:0]	rdptr_d;
reg [FIFOPTRWIDTH:0]	rdptr;
reg [FIFOPTRWIDTH:0]	rdptr_grey;
reg [FIFOPTRWIDTH:0]	wrptr_rd_s1;
reg			overflow;
reg			underflow;

integer	i, j;





wire[FIFOPTRWIDTH-1:0]	waddr		=	wrptr;
wire[FIFOPTRWIDTH-1:0]	raddr		=	rdptr;

wire[FIFOPTRWIDTH:0]	rdptr_d_grey	=	f_binary2grey(rdptr_d);
wire[FIFOPTRWIDTH:0]	rdptr_grey_wr;
wire[FIFOPTRWIDTH:0]	rdptr_wr	=	f_grey2binary(rdptr_grey_wr);
wire			rdstrobe_wr	=	(rdptr_wr != rdptr_wr_s1);								
wire			rdptr_wr_msb	=	^{rdptr_wr[FIFOPTRWIDTH], rdptr_wr_s1[FIFOPTRWIDTH]};
wire[FIFOPTRWIDTH:0]	rdptrdelta_wr	=	{rdptr_wr_msb, rdptr_wr[FIFOPTRWIDTH-1:0]}				// Track how many entries were emptied
										-	{1'b0, rdptr_wr_s1[FIFOPTRWIDTH-1:0]};

wire[FIFOPTRWIDTH:0]	wrptr_d_grey	=	f_binary2grey(wrptr_d);
wire[FIFOPTRWIDTH:0]	wrptr_grey_rd;
wire[FIFOPTRWIDTH:0]	wrptr_rd	=	f_grey2binary(wrptr_grey_rd);
wire			wrstrobe_rd	=	(wrptr_rd != wrptr_rd_s1);								
wire			wrptr_rd_msb	=	^{wrptr_rd[FIFOPTRWIDTH], wrptr_rd_s1[FIFOPTRWIDTH]};
wire[FIFOPTRWIDTH:0]	wrptrdelta_rd	=	{wrptr_rd_msb, wrptr_rd[FIFOPTRWIDTH-1:0]}				// Track how many entries were filled
										-	{1'b0, wrptr_rd_s1[FIFOPTRWIDTH-1:0]};




always_comb begin 
	// Write Logic
	wrptr_d		=	wrptr + {{FIFOPTRWIDTH{1'b0}}, wstb};
        numempty_d	=	numempty - {{FIFOPTRWIDTH{1'b0}}, wstb} + (rdptrdelta_wr & {(FIFOPTRWIDTH+1){rdstrobe_wr}});

	// Read Logic
	rdptr_d		=	rdptr + {{FIFOPTRWIDTH{1'b0}}, rstb};
	numfilled_d	=	numfilled - {{FIFOPTRWIDTH{1'b0}}, rstb} + (wrptrdelta_rd & {(FIFOPTRWIDTH+1){wrstrobe_rd}});
end






always_ff @(posedge clk_wr or negedge rst_wr_n) begin
	if (!rst_wr_n) begin
		wrptr      <=	'0;
		wrptr_grey <=	'0;
		rdptr_wr_s1 <=	'0;
		numempty   <=	FIFODEPTH;
		overflow   <=	'0;

	end
	else begin
		wrptr      <=	wrptr_d;
		wrptr_grey <=	wrptr_d_grey;
		rdptr_wr_s1 <=	rdptr_wr;
		numempty   <=	numempty_d;
		overflow   <=	(~|numempty && wstb && !rdstrobe_wr);	// optimistic implementation, pessimistic:  remove && !rdstrobe_wr

	end
end



always_ff @(posedge clk_rd or negedge rst_rd_n) begin
	if (!rst_rd_n) begin
		rdptr      <=	'0;
		rdptr_grey <=	'0;
		wrptr_rd_s1 <=	'0;
		numfilled  <=	'0;
		underflow  <=	'0;

	end
	else begin
		rdptr      <=	rdptr_d;
		rdptr_grey <=	rdptr_d_grey;
		wrptr_rd_s1 <=	wrptr_rd;
		numfilled  <=	numfilled_d;
		underflow  <=	(~|numfilled && rstb && !wrstrobe_rd);	// optimistic implementation, pessimistic:  remove && !wrstrobe_rd
	end
        
end


greyvector_sync	#(FIFOPTRWIDTH+1)	wptr_grey_sync
(
	// Inputs
	.rst_dest_n	(rst_rd_n),
	.clk_dest	(clk_rd),
	.vect_src	(wrptr_grey),

	// Outputs
	.vect_dest	(wrptr_grey_rd)
);

greyvector_sync	#(FIFOPTRWIDTH+1)	rptr_grey_sync
(
	// Inputs
	.rst_dest_n	(rst_wr_n),
	.clk_dest	(clk_wr),
	.vect_src	(rdptr_grey),

	// Outputs
	.vect_dest	(rdptr_grey_wr)
);        
        


 //=====================================================================================
 // Binary to Grey Conversion Task
 //=====================================================================================        
function [FIFOPTRWIDTH:0]	f_binary2grey;
      input[FIFOPTRWIDTH:0]	binary;

      reg[FIFOPTRWIDTH:0]	grey;
      reg[FIFOPTRWIDTH:0]	i;
      
   begin
	for(i=0; i<FIFOPTRWIDTH; i=i+1)
		grey[i]	= ^{binary[i+1], binary[i]};
	        grey[FIFOPTRWIDTH] = binary[FIFOPTRWIDTH];
	        f_binary2grey =	grey;
   end
endfunction



 //=====================================================================================
 // Grey to Binary Conversion Task
 //=====================================================================================       
function [FIFOPTRWIDTH:0]	f_grey2binary;
      input[FIFOPTRWIDTH:0]	grey;

      reg[FIFOPTRWIDTH:0]	binary;
      reg[FIFOPTRWIDTH:0]       i, j;
      
   begin
	binary	=	grey;
	for(i=0; i<(FIFOPTRWIDTH+1); i=i+1)
		for(j=i+1; j<(FIFOPTRWIDTH+1); j=j+1)
			binary[i] = ^{binary[i], grey[j]};
	                f_grey2binary =	binary;
   end
endfunction
        
        



 //=====================================================================================
 // Assertions
 //===================================================================================== 

`ifdef ASSERT_ON

assert_never #(
	.severity_level(`OVL_ERROR),
	.msg("Async FIFO overflow")
	)
	ovl_assert_overflow (
	.clk(clk_wr),
	.reset_n(!rst_wr_n),
	.test_expr(overflow)
	);
        
        
assert_never #(
	.severity_level(`OVL_ERROR),
	.msg("Async FIFO underflow")
	)
	ovl_assert_underflow (
	.clk(clk_wr),
	.reset_n(!rst_wr_n),
	.test_expr(underflow)
	);
        
assert_never #(
	.severity_level(`OVL_ERROR),
	.msg("FIFO numempty bounds check violation")
	)
	ovl_assert_numempty_bounds (
	.clk(clk_wr),
	.reset_n(!rst_wr_n),
	.test_expr(FIFODEPTH < numempty)
	);
        
assert_never #(
	.severity_level(`OVL_ERROR),
	.msg("FIFO numfilled bounds check violation")
	)
	ovl_assert_numfilled_bounds (
	.clk(clk_rd),
	.reset_n(!rst_rd_n),
	.test_expr(FIFODEPTH < numfilled)
	);
        
        
assert_never #(
	.severity_level(`OVL_ERROR),
	.msg("rdptrdelta_wr bounds check violation")
	)
	ovl_assert_rdptrdelta_wr_bounds (
	.clk(clk_wr),
	.reset_n(!rst_wr_n),
	.test_expr(FIFODEPTH < rdptrdelta_wr)
	);
        
assert_never #(
	.severity_level(`OVL_ERROR),
	.msg("wrptrdelta_rd bounds check violation")
	)
	ovl_assert_wrptrdelta_rd_bounds (
	.clk(clk_rd),
	.reset_n(!rst_rd_n),
	.test_expr(FIFODEPTH < wrptrdelta_rd)
	);
        
        
ovl_code_distance #(
	.severity_level(`OVL_ERROR),
	.msg("Read Pointer grey-code had more than 1 bit change")
	)
	ovl_code_distance_rptr (
	.clk(clk_rd),
	.reset_n(!rst_rd_n),
	.test_expr1(rdptr_grey),
	.test_expr2(rdptr_d_grey)
	);
        
ovl_code_distance #(
	.severity_level(`OVL_ERROR),
	.msg("Write Pointer grey-code had more than 1 bit change")
	)
	ovl_code_distance_wptr (
	.clk(clk_wr),
	.reset_n(!rst_wr_n),
	.test_expr1(wrptr_grey),
	.test_expr2(wrptr_d_grey)
	);
        
        
`endif        
        


endmodule
