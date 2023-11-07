/*
File Name:  nbit_sync.v

File Type:  HDL

FPGA Name:  M2020

Project Name:  M2020

Author:  Jim Butler


THIS DOCUMENT MAY CONTAIN CALTECH/JPL PROPRIETARY INFORMATION.
THE TECHNICAL DATA CONTAINED IN THIS DOCUMENT(S) OR FILE(S) MAY BE
RESTRICTED FOR EXPORT UNDER THE INTERNATIONAL TRAFFIC IN ARMS REGULATIONS
(ITAR) OR THE EXPORT ADMINISTRATION REGULATIONS (EAR).
VIOLATIONS OF THESE EXPORT LAWS MAY BE SUBJECT TO FINES AND
PENALTIES UNDER THE ARMS EXPORT CONTROL ACT (22 U.S.C. 2778).

Description:	Parameterizable n-bit two-stage synchronizer with reset

		Example Usage:

		reg  [3:0] sync_in;
		wire [3:0] sync_out;

		nbit_sync	#(.WIDTH(4),.DELAY(5000),.CHECK(OFF),
				.CCDLY(ON),.RANDOM(OFF),.CDC_MODE(ONE)) nbit_sync_0
			(
			// Inputs
			.sync_out_clk	(sync_out_clk),
			.sync_out_rst	(sync_out_rst),
			.sync_in	(sync_in[3:0]),
			// Outputs
			.sync_out	(sync_out[3:0])
			);


	where	WIDTH (default 1): bit width 
		DELAY (default 1000ps): random delay value for CDC path 
		CHECK (default ON): pulse width check ON/OFF 
		CCDLY (default ON): extra clock cycle delay ON/OFF 
		RANDOM (default ON): randomize extra clock cycle delay ON/OFF (default ON)
		CDC_MODE (default 1): value passed to MODE parameter of bit_cdc cell

NOTE - when CCDLY OFF is selected, the DELAY should be set to a value
that is less than the period, but greater the half the period of the source 
clock of the signal being synchronized.


*/

`include "timescale.vh"


module	nbit_sync #(
	parameter	WIDTH = 1,
	parameter	CHECK = 1,
	parameter	DELAY = 100,
	parameter	CCDLY = 1,
	parameter	RANDOM = 1,
	parameter	CDC_MODE = 1
	)
	(
	input			sync_out_clk,
	input			sync_out_rst,
	input	[WIDTH-1:0]	sync_in,
	output	[WIDTH-1:0]	sync_out
	);


// synopsys template

wire	[WIDTH-1:0]	sync_in_cdc;

genvar i;

generate

	for(i=0; i<WIDTH; i=i+1)
	begin:sync_bit
		bit_cdc 
`ifndef SYNTHESIS
		#(.DELAY(DELAY),.MODE(CDC_MODE))	
`endif
		bit_cdc_0
			(
			// Inputs
			.in	(sync_in[i]),
			// Outputs
			.out	(sync_in_cdc[i])
			);

		bit_sync 
`ifndef SYNTHESIS
		#(.CHECK(CHECK),.CCDLY(CCDLY),.RANDOM(RANDOM))
`endif
		bit_sync_0
			(
			// Inputs
			.clk	(sync_out_clk),
			.rst_n	(~sync_out_rst),
			.d	(sync_in_cdc[i]),
			// Outputs
			.q	(sync_out[i])
			);
	end
endgenerate

endmodule
