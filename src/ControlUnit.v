module ControlUnit
    (
        input[1:0] stage,		    // Load or Fetch or Decode or Execute
        input [11:0] IR,		    // Instruction Register
        input [3:0] SR,			    // Status Register
        output reg PC_E, Acc_E, SR_E, IR_E, DR_E, PMem_E,   // Enable signals
        output reg PMem_LE, DMem_E, DMem_WE, ALU_E, MUX1_Sel, MUX2_Sel,
        output reg [3:0] ALU_Mode	// ALU Output Mode
    );
	 	 
parameter LOAD = 2'b00, FETCH = 2'b01, DECODE = 2'b10, EXECUTE = 2'b11;

always @(*)
begin
    // Set all enable signals initially to "zero"
    PMem_LE = 0;
    PC_E = 0;
    Acc_E = 0;
    SR_E = 0;
    IR_E = 0;
    DR_E = 0;
    PMem_E = 0;
    DMem_E = 0;
    DMem_WE = 0;
    ALU_E =0;
    ALU_Mode = 4'd0;
    MUX1_Sel = 0;
    MUX2_Sel = 0;

    // Load instructions
    if(stage== LOAD )
        begin
            PMem_LE = 1;
            PMem_E = 1;
        end

    // Fetch instructions
    else if(stage== FETCH )
        begin
            IR_E = 1;
            PMem_E = 1;
        end

    // Decode instructions
    else if(stage== DECODE )
    begin
        // If IR MSB bits are '001' then enable data registers and data memory
        if( IR[11:9] == 3'b001)    
            begin
                DR_E = 1;
                DMem_E = 1;
            end

        else
            begin
                DR_E = 0;
                DMem_E = 0;
            end
    end

    // Execute instructions
    else if(stage== EXECUTE )
    begin
        if(IR[11]==1)       // for ALU type-I instructions
            begin 
                PC_E = 1;
                Acc_E = 1;
                SR_E = 1;
                ALU_E = 1;
                ALU_Mode = IR[10:8];
                MUX1_Sel = 1;
                MUX2_Sel = 0;
            end

        else if(IR[10]==1)  // for JZ, JC, JS, JO 
            begin
                PC_E = 1;
                MUX1_Sel = SR[IR[9:8]];
            end

        else if(IR[9]==1)   // for type-M instructions
            begin
                PC_E = 1;
                Acc_E = IR[8];
                SR_E = 1;
                DMem_E = !IR[8];
                DMem_WE = !IR[8];
                ALU_E = 1;
                ALU_Mode = IR[7:4];
                MUX1_Sel = 1;
                MUX2_Sel = 1;
            end

        else if(IR[8]==0)   // for No Operation (NOP)
            begin
                PC_E = 1;
                MUX1_Sel = 1;
            end

        else                // for GOTO
            begin
                PC_E = 1;
                MUX1_Sel = 0;
            end
    end
end

endmodule
