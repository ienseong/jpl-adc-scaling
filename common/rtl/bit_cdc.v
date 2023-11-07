/* 
File Name:  bit_cdc.v

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

Description:	This module is used to simulate a single-bit clock domain 
		crossing by causing the output to go to x or a random value
		for DELAY ps when the input changes.  It is also used after 
		synthesis in order to find clock domain crossings

		Example Usage:


		bit_cdc #(.DELAY(8000),.MODE(0) bit_cdc_0
				(.in(cdcpath), .out(cdcpath_cdc));
				              
		 where	
			DELAY (default 10000): 	delay for bit-change in pS
			MODE (defaults to 0) : 	
				0 for DELAY worth of X on input change
		      		1 for random delay of input change with pulse-width preservation of high pulses
				2 for random delay of input change without pulse-width preservation of high pulses


	
*/

`include "timescale.vh"


module bit_cdc #(
	parameter DELAY = 10000,
	parameter MODE = 0
	)
	(
	input   	in,


`ifdef SYNTHESIS
	output	logic	out

`else  // CODE FOR SIMULATION:
	output  logic	out

`endif
);

`ifdef SYNTHESIS
	//BUF cdc_buffer_0 (.O(out), .I(in));
	assign out = in;

`else // CODE FOR SIMULATION:
//   On any input change, make the output
//   go to either an x for MODE 0
//   or be randomly delayed in MODE 1
//   for DELAY ps before the
//   output changes to the input value.

  reg 		      old_in;
  reg 		      delay_bit = 0;
  reg 		      delayed_high_bit = 0;
  reg 		      now_out, dly_out;
  reg [31:0] 	      seed;

  initial begin

  seed = $random;
  
  end
  
initial begin
	forever @(in) 
	begin


		if ((in !== old_in))
		begin
			if (MODE == 1)
			begin
				if (old_in === 1'bx)
				begin
					out = old_in;
					out <= #(DELAY*1ps) in;
				end
				else begin
					delay_bit = {$random(seed)};
					if (delay_bit | delayed_high_bit)
					begin
					// if high bit previously delayed always delay next transition 
					// to ensure that the  pulse width of active high pulses 
					// are never shortened 
						out = old_in;
						out <= #(DELAY*1ps) in;
						delayed_high_bit = delay_bit & in;
					end
					else begin
						out = in;
					end					
				end
			end
			else if (MODE == 2)
			begin
				delay_bit = {$random(seed)};
				if (!delay_bit)
				begin
					now_out = in; // Get new immediate value
        				disable out_timer; // Cancel any pending delayed change
					assign out = now_out; // Assign output to new value now
				end
				dly_out <= #(DELAY*1ps) in; // Launch delayed value
			end
			else begin
				out = 1'bx;
				out <= #(DELAY*1ps) in;
			end
			old_in = in;
		end
		else begin
			out = in;
			old_in = in;
		end
	end
end

// Wait for delay and switch over to delayed output value if in MODE 2
always begin : out_timer
  wait(MODE == 2);
  #(DELAY*1ps+1); // +1 needed to work around a VCS issue
  assign out = dly_out;
  wait(0);
end


`endif
endmodule
