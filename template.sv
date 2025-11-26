`timescale 1ns/1ns

module testbench;

{module template}

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
			
			{generated_if}
				
		end
	end
end

endmodule
