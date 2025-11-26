`timescale 1ns/1ns

module pe(
    input logic clk,
    input logic rst,
    input logic op,
    input logic e,
    input logic [`OP_SIZE-1:0] op1,
    input logic [`OP_SIZE-1:0] op2,
    output logic [`OP_SIZE-1:0] res
);

`define FLOAT_PART 16

localparam DOUBLE_SIZE = (`OP_SIZE)*2;
localparam SINGLE_SIZE = `OP_SIZE;

logic e_ff;
logic [DOUBLE_SIZE-1:0] op1_ff, op2_ff, res_ff;
logic [`OP_SIZE-1:0] sigm, x;

assign x = SINGLE_SIZE'(op1_ff + op2_ff);

assign res_ff = e_ff ? 0
                     : op ? op1_ff * op2_ff
                          : e ? DOUBLE_SIZE'(sigm)
                              : op1_ff + op2_ff;

assign res = op ? res_ff[`FLOAT_PART+`OP_SIZE-1:`FLOAT_PART]
                : res_ff[`OP_SIZE-1:0];

always @(posedge clk, negedge rst) begin
    if (rst) begin
        op1_ff <= 0;
        op2_ff <= 0;
    end else if (e | e_ff) begin
        op1_ff <= 0;
        op2_ff <= 0;
    end else begin
        op1_ff <= {{SINGLE_SIZE{op1[`OP_SIZE-1]}},op1};
        op2_ff <= {{SINGLE_SIZE{op2[`OP_SIZE-1]}},op2};
    end
end

always @(posedge clk, negedge rst) begin
    if(rst)
        e_ff<=0;
    else
        e_ff<=e;
end



sigmoid sigmoid_i(
    .x(x),
    .y(sigm)
);

endmodule
