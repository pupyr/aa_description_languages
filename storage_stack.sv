`timescale 1ns/1ns

module storage_stack(
    input logic clk,
    input logic push,
    input logic pop,
    input logic [`OP_SIZE-1:0] data_in,
    output logic [`OP_SIZE-1:0] data_out
);

`define STACK_DEPTH 1024
`define STACK_ADDR_SIZE 10

logic [`OP_SIZE-1:0] data      [0:`STACK_DEPTH-1];
logic [`OP_SIZE-1:0] data_next [0:`STACK_DEPTH-1];

assign data_out = data[0];

assign data_next[0] = push ? data_in
                           : pop ? data[1]
                                 : data[0];

always @(posedge clk)
    data[0] <= data_next[0];

assign data_next[`STACK_DEPTH-1] = push ? data[{`STACK_ADDR_SIZE{1'b1}}]
                                        : pop ? '0
                                              : data[`STACK_DEPTH-1];

always @(posedge clk)
    data[`STACK_DEPTH-1] <= data_next[`STACK_DEPTH-1];

generate 
    for (genvar idx = 1; idx < (`STACK_DEPTH-1); idx++) begin
        assign data_next[idx] = push ? data[idx-1]
                                     : pop ? data[idx+1]
                                           : data[idx];

        always @(posedge clk)
            data[idx] <= data_next[idx];
    end
endgenerate

endmodule