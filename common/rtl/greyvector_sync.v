//*****************************************************************************
//    File Name:  greyvector_sync.v
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
// Synchronizer for grey coded input vector. Synchronizes from source clk domain
// to destination domain
//
//  *****NOTE******* 'vect_src' must be driven directly from flip-flops.        
//
//
//*****************************************************************************

`include "timescale.vh"





module	greyvector_sync
      (
	// Inputs
	rst_dest_n,
	clk_dest,
	vect_src,

	// Outputs
	vect_dest
        
      );
      


parameter VECTORWIDTH = 'd2;



// Inputs
input                            rst_dest_n;
input                            clk_dest;
input  [VECTORWIDTH-1:0]	 vect_src;

// Outputs
output [VECTORWIDTH-1:0]	 vect_dest;




reg [VECTORWIDTH-1:0]            vect_src_s1;
reg [VECTORWIDTH-1:0]            vect_dest;



always_ff @(posedge clk_dest or negedge rst_dest_n) begin
        if (~rst_dest_n) begin
		vect_src_s1	<=	'0;
   	        vect_dest	<=	'0;
	end
	else begin
		vect_src_s1	<=	vect_src;
		vect_dest	<=	vect_src_s1;
	end
end



endmodule
