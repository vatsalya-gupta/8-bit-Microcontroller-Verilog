`timescale 1ns/10ps
`include "MicroController.v"

module MicroController_tb;

	reg clk;		// Positive edge triggered clock
	reg rst;		// Active high reset

	MicroController UUT(.clk(clk), .rst(rst));

	always #5 clk = ~clk;
	initial begin
		$dumpfile("MicroController_tb.vcd");
		$dumpvars(0, MicroController_tb);
		clk = 0;		
		rst = 1;
		#20 rst = 0;
		#980 $finish;
	end

endmodule
