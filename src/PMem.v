module PMem(
            input clk,			// Clock
            input E,			// Enable Port
            input [7:0] Addr,	// Address Port
            output [11:0] I,	// Instruction Port
            // 3 special ports are used to load program to the memory
            input LE,			// Load Enable Port
            input [7:0] LA,		// Load Address Port
            input [11:0] LI		// Load Instruction Port
            );

reg [11:0] Prog_Mem [255:0] ;

always @(posedge clk)
begin
    // Load Enable = high => copy instructions into Program Memory Register
    if(LE == 1)
        Prog_Mem[LA] <= LI;
end

// Enable = high => porgram memory address is stored in instruction port, else store "zero"
assign I = (E == 1) ? Prog_Mem[Addr] : 0 ;

endmodule
