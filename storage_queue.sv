`timescale 1ns/1ns

module storage_queue(
    input logic clk,
    input logic rst,
    input logic push,
    input logic pop,
    input logic reset,
    input logic next,
    input logic [`OP_SIZE-1:0] data_in,
    output logic [`OP_SIZE-1:0] data_out,
    output logic empty
);

`define QUEUE_DEPTH 64
`define QUEUE_ADDR_SIZE 6

logic [`OP_SIZE-1:0] data [0:`QUEUE_DEPTH-1];
logic [`QUEUE_ADDR_SIZE-1:0] addr_start, addr_end, addr_end_tmp;
logic [`QUEUE_ADDR_SIZE-1:0] addr_start_next, addr_end_next, addr_end_tmp_next;

assign data_out = data[addr_end];
assign addr_start_next   = push ? addr_start + 1 : addr_start;
assign addr_end_next     = reset ? addr_end_tmp
                                 : pop  
                                    ? addr_end + 1 
                                    : addr_end;

assign addr_end_tmp_next = next ? addr_end
                                : addr_end_tmp;

assign empty = addr_start <= addr_end_tmp + 3;

always @(posedge clk, negedge rst) begin
    if (rst) begin
        addr_start <= '0;
        addr_end <= '0;
        addr_end_tmp <= '0;
    end else begin 
        addr_start <= addr_start_next;
        addr_end   <= addr_end_next;
        addr_end_tmp <= addr_end_tmp_next;
    end
end

always @(posedge clk) begin
    if(push)
        data[addr_start] <= data_in;
end

endmodule