module DMem(clk, E, WE, Addr, DI, DO);
	
	input clk;  					// Clock
    input E;						// Enable Port
    input WE;						// Write Enable
    input [3:0] Addr;				// Address Port
    input [7:0] DI;					// Data In
    output [7:0] DO;				// Data Out
	reg [7:0] data_mem [15:0];

	always@(posedge clk) begin
		// Enable port = Write Enable = high => accept data as input
		if((E == 1) && (WE == 1))
			data_mem[Addr] <= DI;
	end

	// Enable port = high => make data available to output, else data out = zero
	assign DO = (E ==1)? data_mem[Addr]:0;

endmodule
