//*****************************************************************************
//    File Name:  memwr1r1.v
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
// Memory Model for simulation
// 
// NOTE NEED TO ADD VENDOR MODELS IN HERE AS WELL
//
//*****************************************************************************


`include "timescale.vh"
`include "project_defines.vh"


module memw1r1
         (
	rst_a_n,
	clk_a,
	addr_a,
	wen_a,
	di_a,
	addr_b,
	do_b
        
         );



parameter	NUMWORDS	=	'd3;
parameter	NUMBITS		=	'd72;
parameter	ADDRWIDTH	=	(('d1 > NUMWORDS) || ('d256 < NUMWORDS)) ? 'd0:
					('d3 > NUMWORDS)?	'd1:
					('d5 > NUMWORDS)?	'd2:
					('d9 > NUMWORDS)?	'd3:
					('d17 > NUMWORDS)?	'd4:
					('d33 > NUMWORDS)?	'd5:
					('d65 > NUMWORDS)?	'd6:
					('d129 > NUMWORDS)? 'd7:
					'd8;


input			rst_a_n; 
input			clk_a;
input [ADDRWIDTH-1:0]	addr_a;	
input [NUMBITS-1:0]	wen_a;	
input [NUMBITS-1:0]	di_a;	
input [ADDRWIDTH-1:0]	addr_b;	
output [NUMBITS-1:0]	do_b;	



reg [NUMBITS-1:0]	ram[NUMWORDS-1:0];
reg [NUMBITS-1:0]	ramword_a;
int unsigned		i, j;
wire [NUMBITS-1:0]	do_b = ram[addr_b];

always_comb
begin
	ramword_a	=	ram[addr_a];
	for(j=0; j<NUMBITS; j=j+1)
		if (wen_a[j]) ramword_a[j] = di_a[j] ;
end




always_ff @(posedge clk_a or negedge rst_a_n) begin
	if (!rst_a_n) begin
		for(i=0; i<NUMWORDS; i=i+1)
			ram[i]			<=	{NUMBITS{1'b0}};
	end
	else begin
		if (|wen_a)
			ram[addr_a]	<=	ramword_a;

 
	end
end



 //=====================================================================================
 // Assertions
 //===================================================================================== 

`ifdef ASSERT_ON

assert_never #(
	.severity_level(`OVL_ERROR),
	.msg("Invalid Port A Address")
	)
	ovl_assert_invalid_aaddr (
	.clk(clk_a),
	.reset_n(!rst_a_n),
	.test_expr((((NUMWORDS - 1) < addr_a) || (1'bx === ^addr_a)))
	);
 
 
 
 assert_never #(
	.severity_level(`OVL_ERROR),
	.msg("Invalid Port A Write Enable")
	)
	ovl_assert_invalid_awe (
	.clk(clk_a),
	.reset_n(!rst_a_n),
	.test_expr(^wen_a_i===1'bx)
	);
        
 
 assert_never #(
	.severity_level(`OVL_ERROR),
	.msg("Invalid Port A Write Data")
	)
	ovl_assert_invalid_awdata (
	.clk(clk_a),
	.reset_n(!rst_a_n),
	.test_expr((|wen_a) && ( ^(di_a & wen_a)=== 1'bx))
	);
        
        
 assert_never #(
	.severity_level(`OVL_ERROR),
	.msg("Invalid Port B Address")
	)
	ovl_assert_invalid_baddr (
	.clk(clk_a),
	.reset_n(!rst_a_n),
	.test_expr(((NUMWORDS - 1) < addr_b) || (^addr_b === 1'bx))
	);       
        
        
`endif






endmodule
