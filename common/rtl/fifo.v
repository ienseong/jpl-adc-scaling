//*****************************************************************************
//    File Name:  fifo.v
//
//    File Type:  HDL
//
//    FPGA Name:  HK
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
//
// Description:
// Generic FIFO module
//
//
//*****************************************************************************

`include "timescale.vh"

`ifdef ASSERT_ON
   `include "std_ovl_defines.h"
`endif


module fifo(/*AUTOARG*/
		clk,
		rst_n,
		fifo_push,
		fifo_pop,
		fifo_clear,
		fifo_data_in,
		
		fifo_dout,
		fifo_empty,
		fifo_full,
		fifo_count
);


parameter 	FIFO_WIDTH = 33;
parameter 	FIFO_DEPTH = 2;
localparam  FIFO_PTR_WIDTH = $clog2(FIFO_DEPTH+1); //HSB fixed to avoid user setting incorrect value here

input		clk;
input		rst_n;
input		fifo_push;                         // FIFO write 
input		fifo_pop;                          // FIFO read
input		fifo_clear;                        // FIFO reset
input		[FIFO_WIDTH-1:0] fifo_data_in;     // FIFO data in

output		[FIFO_WIDTH-1:0] fifo_dout;         // FIFO data out
output		fifo_empty;                         // FIFO empty status
output		fifo_full;                          // FIFO Full status
output		[FIFO_PTR_WIDTH-1:0]	fifo_count; // FIFO element count

wire		[FIFO_WIDTH-1:0] fifo_dout;




genvar g;

logic	[FIFO_WIDTH-1:0]	fifo_array	[0:FIFO_DEPTH-1];
logic	[FIFO_PTR_WIDTH-1:0]	fifo_rdptr;
logic	[FIFO_PTR_WIDTH-1:0]	fifo_wptr;
logic	[FIFO_PTR_WIDTH-1:0]	fifo_count;
logic				fifo_empty;
logic				fifo_full;

`ifdef ASSERT_ON
assert_never #(
	.severity_level(`OVL_ERROR),
	.msg("FIFO Overflow")
	)
	ovl_assert_never_overflow_chk_0 (
	.clk(clk),
	.reset_n(rst_n),
	.test_expr(fifo_push & fifo_full)
	);
	
assert_never #(
	.severity_level(`OVL_ERROR),
	.msg("FIFO Underflow")
	)
	ovl_assert_never_underflow_chk_0 (
	.clk(clk),
	.reset_n(rst_n),
	.test_expr(fifo_pop & fifo_empty)
	);
        

`endif

//	--------------------------------------------------
//	generate fifo entries
//	--------------------------------------------------

generate
	for (g = 0; g < FIFO_DEPTH; g=g+1) 
	begin: fifo_entry

//	--------------------------------------------------
//	write to fifo registers
//	--------------------------------------------------
		always_ff @(posedge clk or negedge rst_n) 
		begin
			if (~rst_n) 
			begin
				fifo_array[g] <=  '0; 
			end
                        else if(fifo_clear) begin
                        	fifo_array[g] <=  '0; 
                        end
			else if (fifo_push)
			begin
				if (fifo_wptr == g) 
				begin
					fifo_array[g] <=  fifo_data_in[FIFO_WIDTH-1:0];
                                                              
				end
			end
		end
	end
endgenerate

//	--------------------------------------------------
//	 fifo read pointer control
//	--------------------------------------------------

	always_ff @(posedge clk or negedge rst_n) 
	begin
		if (~rst_n) begin

			fifo_rdptr[FIFO_PTR_WIDTH-1:0] 
				<=  {FIFO_PTR_WIDTH{1'b0}};
		end
		else if(fifo_clear) begin
			fifo_rdptr[FIFO_PTR_WIDTH-1:0] 
				<=  {FIFO_PTR_WIDTH{1'b0}};
		end
		else if (fifo_pop) 
		begin
			if (fifo_rdptr[FIFO_PTR_WIDTH-1:0] == FIFO_DEPTH-1)
			begin
				fifo_rdptr[FIFO_PTR_WIDTH-1:0] 
					<= {FIFO_PTR_WIDTH{1'b0}}; 
			end
			else begin
				fifo_rdptr[FIFO_PTR_WIDTH-1:0] 
					<=  fifo_rdptr[FIFO_PTR_WIDTH-1:0] + 1;
			end
		end
		else begin
			fifo_rdptr[FIFO_PTR_WIDTH-1:0] 
				<=  fifo_rdptr[FIFO_PTR_WIDTH-1:0];
		end
	end

	assign fifo_dout[FIFO_WIDTH-1:0] = fifo_array[fifo_rdptr];

//	--------------------------------------------------
//	fifo write pointer control
//	--------------------------------------------------


	always_ff @(posedge clk or negedge rst_n) 
	begin
		if (~rst_n)
		begin
			fifo_wptr[FIFO_PTR_WIDTH-1:0] 
				<=  {FIFO_PTR_WIDTH{1'b0}};
		end
		else if(fifo_clear) begin
			fifo_wptr[FIFO_PTR_WIDTH-1:0] 
				<=  {FIFO_PTR_WIDTH{1'b0}}; 
		end
		else if (fifo_push & ~fifo_full) 
		begin
			if (fifo_wptr[FIFO_PTR_WIDTH-1:0] == FIFO_DEPTH-1)
			begin
				fifo_wptr[FIFO_PTR_WIDTH-1:0] 
					<=  {FIFO_PTR_WIDTH{1'b0}};
			end
			else begin
				fifo_wptr[FIFO_PTR_WIDTH-1:0] 
					<=  fifo_wptr[FIFO_PTR_WIDTH-1:0] + 1;
			end
		end
		else begin
			fifo_wptr[FIFO_PTR_WIDTH-1:0] 
				<=  fifo_wptr[FIFO_PTR_WIDTH-1:0];
		end
	end

//	--------------------------------------------------
//	fifo manager
//	--------------------------------------------------
	always_ff @(posedge clk or negedge rst_n) 
	begin
		if (~rst_n)
		begin
			fifo_count[FIFO_PTR_WIDTH-1:0]	<=  '0; //HSB fixed to avoid bug when first using FIFO after reset if no fifo_clear issued
			fifo_empty 	<=  1'b1;
			fifo_full 	<=  1'b0;
		end
		else if (fifo_clear)
		begin
			fifo_count[FIFO_PTR_WIDTH-1:0]	<=  {FIFO_PTR_WIDTH{1'b0}};
			fifo_empty 	<=  1'b1;
			fifo_full 	<=  1'b0;
		end
		else begin
			if (fifo_pop & fifo_push) // rd and wr same time
			begin
				fifo_count[FIFO_PTR_WIDTH-1:0] <=  fifo_count[FIFO_PTR_WIDTH-1:0];
				fifo_empty 	<=  fifo_empty;
				fifo_full 	<=  fifo_full;
			end
			else if (fifo_push & ~fifo_full)
			begin	// write increment
				fifo_count[FIFO_PTR_WIDTH-1:0] 
					<=  fifo_count[FIFO_PTR_WIDTH-1:0] + 1'b1;
				fifo_empty 	<=  1'b0;
				if (fifo_count[FIFO_PTR_WIDTH-1:0] == FIFO_DEPTH-1)
				begin
					fifo_full 	<=  1'b1;
				end
				else begin
					fifo_full 	<=  fifo_full;
				end
			end
			else if (fifo_pop & ~fifo_empty)
			begin	// read decrement
				fifo_count[FIFO_PTR_WIDTH-1:0] 
					<=  fifo_count[FIFO_PTR_WIDTH-1:0] - 1'b1;
				fifo_full 	<=  1'b0;
				if (fifo_count[FIFO_PTR_WIDTH-1:0]==1)
				begin
					fifo_empty 	<=  1'b1;
				end
				else begin
					fifo_empty 	<=  fifo_empty;
				end
			end
			else begin
				fifo_count[FIFO_PTR_WIDTH-1:0] 
					<=  fifo_count[FIFO_PTR_WIDTH-1:0];
				fifo_empty 	<=  fifo_empty;
				fifo_full 	<=  fifo_full;
			end
		end
	end
endmodule
// Local Variables:
// verilog-library-flags:("-f rtl.f")
// End:
