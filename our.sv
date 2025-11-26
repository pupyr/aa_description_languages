`timescale 1ns/1ns
  module our;
logic clk;
logic rst;

`define DISPLAY_ANSWER
`define TWO_LAY
`define ADDR_LEN 11
`define ADDRS 2048
`define DATA_LEN 40

localparam CHAR_PART = `DATA_LEN/8;

initial begin
	clk= 0;
	forever begin
    		#5 clk = ~clk; 
	end
end

initial begin
	rst = 1;
	#10;
	rst = 0; 
end

logic rd;
logic wr;
logic [`ADDR_LEN-1:0] addr;
logic [`DATA_LEN-1:0] data_in;
logic [`DATA_LEN-1:0] data_out;
logic computation_end;

fetch fetch_i(
	.clk (clk),
	.rst (rst),

	.rd (rd),
	.data_in (data_out),
	.computation_end (computation_end)
	);
mem mem_i(
	.clk (clk),
	.rd (rd),
	.wr (wr),
	.addr (addr),
	.data_in (data_in),
	.data_out (data_out)
);

integer file_handle;
logic [8-1:0] file_char;
logic [`DATA_LEN-1:0] file_data;
integer counter;

initial begin
	$dumpfile("test.vcd");
	$dumpvars();

// `ifndef TWO_LAY
	file_handle = $fopen("dump", "r");
// `endif
// `ifdef TWO_LAY
// 	file_handle = $fopen("dump2", "r");
// `endif

	@(posedge clk);

	addr = '0;
	wr = 0;
	rd = 0;
	counter = 0;
	while (!$feof(file_handle)) begin
		file_data = '0;
		for(int i=0; i<CHAR_PART; i++) begin
			file_char = $fgetc(file_handle);
			file_data = (file_data<<8) | `DATA_LEN'(file_char);
		end
		counter++;
		wr = 1;
		data_in = file_data;
		@(posedge clk);
		addr = addr + 1;
	end
	addr = '0;
	wr = 0;
	rd = 1;
	repeat(counter) begin
		@(posedge clk);
		addr = addr + 1;
	end

	for(int i=0; i<50; i++) begin
		@(posedge clk);
		if (computation_end) break;
	end
	$fclose(file_handle);
	$finish;
end
  endmodule
