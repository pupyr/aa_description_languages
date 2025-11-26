`timescale 1ns/1ns

module exec_top(
    input logic clk,
    input logic rst,
    input logic r,
    input logic e,
    input logic o1,
    input logic o2,
    input logic w1,
    input logic w2,
    input logic reset,
    input logic next,
    input logic [`OP_SIZE-1:0] op,
    output logic computation_end
);

logic push_o1, push_o2, push_w1, push_w2;
logic pop_o1, pop_o2, pop_w1, pop_w2;
logic emp_1, emp_2;
logic reset_o1, reset_o2, next_o1, next_o2;

logic [`OP_SIZE-1:0] data_out_o1, data_out_o2,
                     data_out_w1, data_out_w2;

logic [`OP_SIZE-1:0] data_out_m1, data_out_m2;
logic [`OP_SIZE-1:0] data_out_s1, data_out_s2;

logic [`OP_SIZE-1:0] data_out_s2_e;

logic [`OP_SIZE-1:0] operand;

assign data_out_s2_e = e ? 0 : data_out_s2;

assign push_o1 = !r & !next & !reset & o1;
assign push_o2 = !r & !next & !reset & o2;
assign push_w1 = !r & !next & !reset & w1;
assign push_w2 = !r & !next & !reset & w2;

assign pop_o1 = r & o1;
assign pop_o2 = r & o2;
assign pop_w1 = r & w1;
assign pop_w2 = r & w2;

assign reset_o1 = reset & o1;
assign reset_o2 = reset & o2;

assign next_o1 = next & o1;
assign next_o2 = next & o2;

assign operand = (e & (o1 | o2 | w1 | w2)) ? data_out_s2 : op;

storage_queue storage_queue_i1(
    .clk (clk),
    .rst (rst),
    .push (push_o1),
    .pop (pop_o1),
    .reset (reset_o1),
    .next (next_o1),
    .data_in (operand),
    .data_out(data_out_o1),
    .empty (emp_1)
);

`ifdef TWO_LAY

storage_queue storage_queue_i2(
    .clk (clk),
    .rst (rst),
    .push (push_o2),
    .pop (pop_o2),
    .reset (reset_o2),
    .next (next_o2),
    .data_in (operand),
    .data_out(data_out_o2),
    .empty (emp_2)
);

assign computation_end = emp_1 & emp_2;

`ifdef DISPLAY_ANSWER

real answer;
always @(posedge clk) begin
    answer = data_out_o1[`OP_SIZE-1:0] + {{16{1'b0}},1'b1, {14{1'b0}},1'b1};
    if (computation_end & data_out_o1!=0) begin
        $display("%f",answer/(2**16));
    end
end

`endif

`endif
`ifndef TWO_LAY

assign data_out_o2 = 0;
assign computation_end = emp_1;

`endif

storage_stack storage_stack_i1(
    .clk (clk),
    .push (push_w1),
    .pop (pop_w1),
    .data_in (operand),
    .data_out(data_out_w1)
);

storage_stack storage_stack_i2(
    .clk (clk),
    .push (push_w2),
    .pop (pop_w2),
    .data_in (operand),
    .data_out(data_out_w2)
);

pe module_pe_mul1(
    .clk (clk),
    .rst (rst),
    .op  (1),
    .e   (e),
    .op1 (data_out_o1),
    .op2 (data_out_w1),
    .res (data_out_m1)
);

pe module_pe_mul2(
    .clk (clk),
    .rst (rst),
    .op  (1),
    .e   (e),
    .op1 (data_out_o2),
    .op2 (data_out_w2),
    .res (data_out_m2)
);

pe module_pe_sum1(
    .clk (clk),
    .rst (rst),
    .op  (0),
    .e   (e),
    .op1 (data_out_m1),
    .op2 (data_out_m2),
    .res (data_out_s1)
);

pe module_pe_sum2(
    .clk (clk),
    .rst (rst),
    .op  (0),
    .e   (e),
    .op1 (data_out_s1),
    .op2 (data_out_s2_e),
    .res (data_out_s2)
);

endmodule