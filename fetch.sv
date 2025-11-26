`timescale 1ns/1ns

module fetch(
    input logic clk,
    input logic rst,
    // mem
    input logic rd,
    input  logic [`DATA_LEN-1:0] data_in,
    output logic computation_end
);

`ifndef OP_SIZE
`define OP_SIZE `DATA_LEN-8
`endif

logic r,e,o1,o2,w1,w2,reset,next;
logic [`OP_SIZE-1:0] op;

assign r  = data_in[`DATA_LEN-1];
assign e  = data_in[`DATA_LEN-2];
assign o1 = data_in[`DATA_LEN-3];
assign o2 = data_in[`DATA_LEN-4];
assign w1 = data_in[`DATA_LEN-5];
assign w2 = data_in[`DATA_LEN-6];
assign reset = data_in[`DATA_LEN-7];
assign next  = data_in[`DATA_LEN-8];
assign op = data_in[`OP_SIZE-1:0];

logic [31:0] counter;

always @(posedge clk)
	counter <= counter+1;

exec_top exec_top_i(
    .clk (clk),
    .rst (rst),
    .r (r),
    .e (e),
    .o1 (o1),
    .o2 (o2),
    .w1 (w1),
    .w2 (w2),
    .reset (reset),
    .next (next),
    .op (op),
    .computation_end (computation_end)
);

endmodule
