module MUX(In1, In2, Sel, Out);
	
	input [7:0] In1, In2;
	input Sel;
	output [7:0] Out;
	
	assign Out = (Sel == 1) ? In1 : In2;
	// if Sel = 1, then Out = In1, else Out = In2

endmodule
