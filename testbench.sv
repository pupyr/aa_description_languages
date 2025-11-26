`timescale 1ns/1ns

module testbench;

logic [1-1:0] clk;
logic [1-1:0] rst;
logic [1-1:0] r;
logic [1-1:0] e;
logic [1-1:0] o1;
logic [1-1:0] o2;
logic [1-1:0] w1;
logic [1-1:0] w2;
logic [1-1:0] reset;
logic [1-1:0] next;
logic [32-1:0] op;
logic [1-1:0] computation_end;

exec_top exec_top_i(
	.clk(clk),
	.rst(rst),
	.r(r),
	.e(e),
	.o1(o1),
	.o2(o2),
	.w1(w1),
	.w2(w2),
	.reset(reset),
	.next(next),
	.op(op),
	.computation_end(computation_end)
);

int fd;
int data;
string str;
string sstr[2];

initial begin
	$dumpfile("packed.vcd");
	$dumpvars();

	fd = $fopen("trace", "r");
	
	while (!$feof(fd)) begin

		$fgets(str, fd);
		if (str[0]=="#")
			#5;
		else begin
			$sscanf(str, "b%s %s\n", sstr[0], sstr[1]);
			
			if (sstr[1] == "clk")
				$sscanf(sstr[0],"%b", clk);
			else if (sstr[1] == "rst")
				$sscanf(sstr[0],"%b", rst);
			else if (sstr[1] == "r")
				$sscanf(sstr[0],"%b", r);
			else if (sstr[1] == "e")
				$sscanf(sstr[0],"%b", e);
			else if (sstr[1] == "o1")
				$sscanf(sstr[0],"%b", o1);
			else if (sstr[1] == "o2")
				$sscanf(sstr[0],"%b", o2);
			else if (sstr[1] == "w1")
				$sscanf(sstr[0],"%b", w1);
			else if (sstr[1] == "w2")
				$sscanf(sstr[0],"%b", w2);
			else if (sstr[1] == "reset")
				$sscanf(sstr[0],"%b", reset);
			else if (sstr[1] == "next")
				$sscanf(sstr[0],"%b", next);
			else if (sstr[1] == "op")
				$sscanf(sstr[0],"%b", op);
			else if (sstr[1] == "computation_end")
				$sscanf(sstr[0],"%b", computation_end);
				
		end
	end
end

endmodule
