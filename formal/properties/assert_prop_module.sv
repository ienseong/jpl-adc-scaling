bind prop_module assert_prop_module bind_prop_module (.*);

module prop_module (
//input       rstn,
//input       clk,
//input [2:0] ratio,
//input       rd_avail,
//input       wr_avail,
//input       rd,
//input       wr,
//input      rd_en,
//input      wr_en
);
//
//// requirement: enables are 1hot0
//a_en_1hot0: assert property (@(posedge clk) $onehot0({rd_en,wr_en}) );
//
//// requirement: only read one word at a time from fifo's
//a_rd_en_pulse: assert property (@(posedge clk) disable iff (!rstn) $rose(rd_en) |=> !rd_en );
//a_wr_en_pulse: assert property (@(posedge clk) disable iff (!rstn) $rose(wr_en) |=> !wr_en );

endmodule
