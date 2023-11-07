//*****************************************************************************
//    File Name:  bit_sync.v
//
//    File Type:  HDL
//
//    FPGA Name:  M2020
//
//    Project Name:  M2020
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
//          This module does bit synchronization between clock domains
//          
//
//
//*****************************************************************************


`include "timescale.vh"

`ifdef ASSERT_ON
   `include "std_ovl_defines.h"
`endif


module bit_sync 
	(
        
	input  wire	clk,
	input  wire	rst_n,
	input  wire	d,
	output reg	q



	);


	parameter 	CHECK = 1;	// check pulse width 
	parameter 	CCDLY = 1;	// delay output by 1 extra clock cycle
	parameter 	RANDOM = 0;	// randomly delay output
        parameter       TQ_DLY = 1;      // TQ delay, in PS

`ifdef SYNTHESIS
	reg	q_meta;
	
	always_ff @(posedge clk or negedge rst_n)
	begin
		if (~rst_n)
		begin
			q_meta <=  1'b0;
                        q  <=  1'b0;
		end
		else begin
			q_meta <=  d;
                        q  <=  q_meta;

		end
                
	end
        


`else

// --------------------------------------------------------
// Behavioral Model for Simulation
// --------------------------------------------------------
		
//   On any input change,  randomly hold
//   the old value for one cycle.

  reg 		q_meta;
  reg 		delay_bit;
  reg 		delayed_q_meta;
  reg 		delayed;
  reg 		previously_delayed;
  reg [31:0] 	seed;


 
initial    seed = $random;
    
  
	always_ff @(posedge clk or negedge rst_n)
	begin
		if (~rst_n)
		begin
			q <=  '0;
			q_meta <=  '0;
			delayed <=  '0;
			delayed_q_meta <=  '0;		
			previously_delayed <=  '0;
			delay_bit = '0;
		end
		else begin
			q_meta <=  d;
			delayed_q_meta <=  q_meta;
			if ((q_meta !== delayed_q_meta) // input changed
				&& CCDLY && RANDOM ) 
			begin	// randomly add 1 extra clock cycle delay
				delay_bit = {$random(seed)};
				if (delayed)
				begin	// to avoid shortening short pulses 
					// even further don't change the delay 
					// if delayed one cycle earlier
					q <=  delayed_q_meta;	
					delayed <=  '1;
					previously_delayed <=  '1;			
				end
				else if (delay_bit & !previously_delayed) 
				begin	// only delay if previous edge not delayed 
					// use delayed q_meta
					q <=  delayed_q_meta;	
					delayed <=  '1;
					previously_delayed <=  '1;
				end
				else begin
					// no delay - use q_meta
 					q <=  q_meta;
					delayed <=  '0;
					previously_delayed <=  '0;
				end
			end
			else if (CCDLY && !RANDOM) 
			begin	// always add 1 clock cycle delay
					q <=  delayed_q_meta;	
					delayed <=  '1;
					previously_delayed <=  '1;
			end
			else begin
 				q <=  q_meta;
				delayed <=  '0;
				previously_delayed <=  previously_delayed;
			end
		end 
	end


// --------------------------------------------------------
// Behavioral code to check pulse widths
// --------------------------------------------------------
   
integer 	period = 2000000000; // 0.2 seconds - 500Hz
integer 	previous_clk_event = 0;
integer 	last_clk_event = 0;
integer 	last_event = 0;
integer 	previous_last_event = 0;
integer		sig_pulse_width = 0;
reg		input_pulse_width_chk_enable = 0;
reg		pulse_width_error = 0;

        initial begin
          wait(CHECK);
          fork

  	    // figure out what the clock period is
            forever @(posedge clk)
	    begin
		previous_clk_event = last_clk_event;
		last_clk_event = $time; //time in ps
		period = last_clk_event - previous_clk_event;
  	    end

   	   // determine whether signal is held longer than clock period
	   forever @(d)
	   begin
		if (!rst_n & CHECK)
		begin
			previous_last_event = last_event;
			last_event = $time; // time in ps
			sig_pulse_width = last_event - previous_last_event;
			if ( (last_event > previous_last_event) 
				& (sig_pulse_width < (period * 1.5)) // adding 50% adds an increased margin of error
				& (period <= 1000000) // ignore bogus clks less than 1MHz
				& (period > 0)
				& (previous_last_event>0)) begin

			        $display("%m: Bit_sync input signal pulse-width = %0dps, clk period = %0dps\n",sig_pulse_width,period);                              
				pulse_width_error = '1;
			end
		end
	   end


	   // generate enable for OVL checker
	   forever @(posedge clk or negedge rst_n)
	   begin
		if (~rst_n)
		begin
			input_pulse_width_chk_enable = 0;
		end
		else if (CHECK)
		begin
			input_pulse_width_chk_enable = 1;
		end
	   end
       join
     end






 //=====================================================================================
 // Assertions
 //=====================================================================================


`ifdef ASSERT_ON
 assert_never #(
	.severity_level(`OVL_ERROR),
	.msg("ERROR: Bit_sync input pulse-width too short")
	)
	ovl_assert_bit_sync_pulse (
	.clk(clk),
	.reset_n(!rst_n),
	.test_expr(input_pulse_width_chk_enable && pulse_width_error)
	);       


`endif // ASSERT_ON








`endif // SYNTHESIS

endmodule
