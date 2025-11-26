`timescale 1ns/1ns

module mem(
    input  logic clk,
    input  logic rd,
    input  logic wr,
    input  logic [`ADDR_LEN-1:0] addr,
    input  logic [`DATA_LEN-1:0] data_in,
    output logic [`DATA_LEN-1:0] data_out
);

logic [`DATA_LEN-1:0] data [0:`ADDRS-1];

always @(posedge clk) begin
    if (wr)
        data[addr] <= data_in;
    if (rd)
        data_out <= data[addr];
end


endmodule