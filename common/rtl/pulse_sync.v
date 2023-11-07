/*  
File Name:  pulse_sync.v

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

Description:
          
(**ATTENTION**: THIS MODULE WILL NOT WORK FOR ACTIVE LOW PULSES!!!!) 
 
 This takes a single ACTIVE-HIGH pulse on the input, 
 and produces a single pulse synchronized to the output clock.  Two
 outputs are provided, one which is a single clock pulse, and one
 which is a pulse proportional to the input pulse length.  It also
 generates an enable output used to load the data_en_sync module.
 The timing of the signals when used as a pair should be as shown below.
 Note (1) that in_data must be held untill inReady goes high 
 (2) an input pulse cannot be issued while inReady is low
 If the inpulse is one clock wide, inReady will remain low for approximately
 5 inclks + 4 outclocks rounded up to a whole number of inclk periods

 inclk        |     |     |     |     |     |     |     |     
               _________________
 inPulse _____/     \_____\_____\________________________
              ____________________________________
 inData XXXXXX____________________________________XXXXXXX


 out_clk |        |        |        |        |        |
                                     _________________
 outLevel __________________________/        \________\__
                                     ________
 outPulse __________________________/        \___________
                            ________
 outEnable ________________/        \____________________
                                    _____________________
 outData XXXXXXXXXXXXXXXXXXXXXXXXXXX_____________________
         __________                               ________
 inReady           \_____________________________/


Usage:
,
pulse_sync #(.DELAY(5000),.SCKDELAY(4000),.CHECK(1),.CCDLY(0),.RANDOM(0)	pulse_sync_0
	(
	// Inputs
	.inpulse	(inpulse),
	.inclk	        (inclk),
	.inreset	(inreset),
	.outclk	        (outclk),
	.outreset	(outreset),
	// Outputs
	.outlevel	(outlevel),
	.outpulse	(outpulse),
	.outenable	(outenable),
	.inready	(inready)
	);

	where:
		DELAY (default 100ps): random delay value for CDC path relative to destination domain (outclk)
		SCKDELAY (default 100ps): random delay value for CDC path relative to source domain (inclk)
		MODE (default ON): extra sync clock cycle delay ON/OFF
		CHECK (default ON): pulse_sync ready check ON/OFF

NOTE - when MODE OFF is selected, the DELAY should be set to a value
that is less than the period, but greater the half the period of slowest clock
source.




*/
//*****************************************************************************

`include "timescale.vh"

`ifdef ASSERT_ON
   `include "std_ovl_defines.h"
`endif

module pulse_sync #(
	parameter	DELAY = 100,
	parameter	SCKDELAY = 100,
	parameter	CHECK = 1,	
	parameter	CCDLY = 1,
	parameter	RANDOM = 1,
        parameter       TQ_DLY = 1  // clk->q delay, in PS
	)
	(
	input	wire	inpulse,
	input	wire	inclk,
	input	wire	inreset,
	input	wire	outclk,
	input	wire	outreset,

	output	reg	outlevel,
	output	reg	outpulse,
	output	wire	outenable,
	output	wire	inready
	);

// synopsys template


reg	inpulse_latched;
reg	inpulse_clear_en;
wire	outlevel_sync;
wire	clearpulse_sync;

//***************************************************************************
// Report Errors for missed pulses
//***************************************************************************

`ifdef ASSERT_ON

reg	waiting_for_inready;
reg	waiting_for_endpulse;
	always_ff @(posedge inclk or posedge inreset) begin
		if (inreset) begin
			waiting_for_inready <= '0;
			waiting_for_endpulse <= '0;
		end
		else if (inpulse & inready 
			& ~waiting_for_inready 
			& ~waiting_for_endpulse)
		begin
			waiting_for_inready <= '0;
			waiting_for_endpulse <= '1;
		end
		else if (inpulse & ~inready 
			& ~waiting_for_inready 
			& ~waiting_for_endpulse)
		begin
			waiting_for_inready <= '1;
			waiting_for_endpulse <= '1;
		end
		else if(waiting_for_inready & inpulse & inready)
		begin
			waiting_for_inready <= '0;
		end
		else if (waiting_for_inready & ~inpulse)
		begin
			waiting_for_inready <= '0;
			waiting_for_endpulse <= '0;
		end
		else if (~waiting_for_inready & ~inpulse)
		begin
			waiting_for_endpulse <= '0;
		end
	end

ovl_never #(
	// Parameters
	.severity_level	(`OVL_ERROR),
	.msg("Pulse missed because Pulse Synchronizer not ready (design issue)")
	)
	pulsesync_ready_chk_0
	(
	// Inputs/Outputs
	.clock	(inclk),
	.reset	(!inreset),
	.enable	(CHECK[0]),
	.test_expr(waiting_for_inready & ~inpulse),
        .fire   ( )
	);



`endif


//***************************************************************************
// Latch Pulse
//***************************************************************************
	always_ff @(posedge inclk or posedge inreset)
	begin
		if (inreset)
		begin
			inpulse_latched <=  '0;
		end
		else if (inpulse & ~inpulse_latched & ~clearpulse_sync)
		begin
			inpulse_latched <=  '1;
		end
		else if (clearpulse_sync & inpulse_clear_en)
		begin
			inpulse_latched <=  '0;
		end
		else begin
			inpulse_latched <=  inpulse_latched;
		end
	end

	always_ff @(posedge inclk or posedge inreset)
	begin
		if (inreset)
		begin
			inpulse_clear_en <=  '0;
		end
		else if (inpulse_latched & ~inpulse)
		begin
			inpulse_clear_en <=  '1;
		end
		else if (~inpulse_latched)
		begin
			inpulse_clear_en <=  '0;
		end
		else begin
			inpulse_clear_en <=  inpulse_clear_en;
		end
	end


	assign inready = ~inpulse_latched & ~clearpulse_sync;

//***************************************************************************
// Sync inPulse & generate outPulse
//***************************************************************************


nbit_sync #(
	// Parameters
	.WIDTH	(1),
	.CHECK	(0),
	.DELAY	(DELAY),
	.CCDLY	(CCDLY),
	.RANDOM	(RANDOM)
	)
	nbit_sync_0
	(
	// Inputs/Outputs
	.sync_out_clk	(outclk),
	.sync_out_rst	(outreset),
	.sync_in	(inpulse_latched),
	.sync_out	(outlevel_sync)
	);

	always_ff @(posedge outclk or posedge outreset)
	begin
		if (outreset)
			begin
			outlevel      <=  '0;
			outpulse      <=  '0;
		end
		else begin
			outlevel      <=  outlevel_sync;
			outpulse      <=  outenable;
		end
	end

	assign outenable = outlevel_sync & ~outlevel;

//***************************************************************************
// Sync Clear
//***************************************************************************

nbit_sync #(
	// Parameters
	.WIDTH	(1),
	.CHECK	(0),
	.DELAY	(SCKDELAY),
	.CCDLY	(CCDLY),
	.RANDOM	(RANDOM)
	)
	nbit_sync_1
	(
	// Inputs/Outputs
	.sync_out_clk	(inclk),
	.sync_out_rst	(inreset),
	.sync_in	(outlevel_sync),
	.sync_out	(clearpulse_sync)
	);



endmodule
