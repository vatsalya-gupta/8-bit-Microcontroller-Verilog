module ALU( 
            input [7:0] Operand1, Operand2,
            input E,
            input [3:0] Mode,
            input [3:0] CFlags,
            output [7:0] Out,
            output [3:0] Flags
            /* 4 Flag bits are Z (zero),
               C (carry), S (sign), O (overflow) 
               in order from MSB to LSB */
           );

wire Z, S, O;
reg CarryOut;
reg [7:0] Out_ALU;

always @(*)
begin
    case(Mode)
        // Addition Mode
        4'b0000: {CarryOut, Out_ALU} = Operand1 + Operand2;
        
        // Subtraction Mode
        4'b0001: begin
                    Out_ALU = Operand1 - Operand2;  
                    CarryOut = !Out_ALU[7];
                 end

        // Move value of accumulator to a memory
        4'b0010: Out_ALU = Operand1;

        /* Move value of memory entry to accumulator
           and moving immediate number to accumulator */
        4'b0011: Out_ALU = Operand2;

        /* Logic Gate Operations between memory entries and accumulator
           (bitwise operations) */
        4'b0100: Out_ALU = Operand1 & Operand2;     // AND Gate
        4'b0101: Out_ALU = Operand1 | Operand2;     // OR Gate
        4'b0110: Out_ALU = Operand1 ^ Operand2;     // XOR Gate
        
        // Subtract Memory entry by accumulator
        4'b0111: begin
                    Out_ALU = Operand2 - Operand1;
                    CarryOut = !Out_ALU[7];
                 end

        // Increment Memory entry by 1
        4'b1000: {CarryOut, Out_ALU} = Operand2 + 8'h1;

        // Decrement Memory entry by 1
        4'b1001: begin
                    Out_ALU = Operand2 - 8'h1;
                    CarryOut = !Out_ALU[7];
                 end
        
        // Left Shift (Circular)
        4'b1010: Out_ALU = (Operand2 << Operand1[2:0]) | (Operand2 >> Operand1[2:0]);

        // Right Shift (Circular)
        4'b1011: Out_ALU = (Operand2 >> Operand1[2:0]) | (Operand2 << Operand1[2:0]);

        // Logical Left Shift
        4'b1100: Out_ALU = Operand2 << Operand1[2:0];

        // Logical Right Shift
        4'b1101: Out_ALU = Operand2 >> Operand1[2:0];

        // Arithmetic Shift 
        4'b1110: Out_ALU = Operand2 >>> Operand1[2:0];

        // 2's complement generation
        4'b1111: begin
                    Out_ALU = 8'h0 - Operand2;
                    CarryOut = !Out_ALU[7];
                 end

        default: Out_ALU = Operand2;
    endcase
end

// Assigning Flags
assign O = Out_ALU[7] ^ Out_ALU[6];
assign Z = (Out_ALU == 0) ? 1'b1 : 1'b0;
assign S = Out_ALU[7];

assign Flags = {Z, CarryOut, S, O};

assign Out = Out_ALU;

endmodule
