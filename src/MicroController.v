`include "ControlUnit.v"    // Control Unit
`include "ALU.v"            // Arithmetic Logic Unit
`include "Adder.v"          // PC Adder
`include "MUX.v"            // Multiplexer
`include "PMem.v"           // Program Memory (256 x 12 bits)
`include "DMem.v"           // Data Memory (16 x 8 bits)

module MicroController(clk, rst);
    input clk, rst;
    parameter LOAD = 2'b00,FETCH = 2'b01, DECODE = 2'b10, EXECUTE = 2'b11;
    reg [1:0] current_state, next_state;
    reg [11:0] instr_set [25:0];
    reg load_done;
    reg [7:0] load_addr;
    wire [11:0] load_instr;
    reg [7:0] PC, DR, Acc;  // Program Counter, Data Register, Accumulator
    reg [11:0] IR;          // Instruction Register
    reg [3:0] SR;           // Status Register
    wire PC_E, Acc_E, SR_E, DR_E, IR_E;             // Enable signals
    reg PC_clr, Acc_clr, SR_clr, DR_clr, IR_clr;    // Clear signals
    wire [7:0] PC_updated, DR_updated;
    wire [11:0] IR_updated;
    wire [3:0] SR_updated;
    wire PMem_E, DMem_E, DMem_WE, ALU_E, PMem_LE, MUX1_Sel, MUX2_Sel;
    wire [3:0] ALU_Mode;    // ALU Output Mode
    wire [7:0] Adder_Out;
    wire [7:0] ALU_Out, ALU_Oper2;
 
    // Load instructions into Program Memory
    initial begin
        $readmemb("instr_set.dat", instr_set, 0, 25);
    end

    // Control logic
    ControlUnit Control_Unit(.stage(current_state),
                               .IR(IR),             // Instruction Register
                               .SR(SR),             // Status Register
                               .PC_E(PC_E),         // PC Enable
                               .Acc_E(Acc_E),       // Accumulator Enable
                               .SR_E(SR_E),         // SR Enable
                               .IR_E(IR_E),         // IR Enable
                               .DR_E(DR_E),         // DR Enable
                               .PMem_E(PMem_E),     // PMem Enable
                               .DMem_E(DMem_E),     // DMem Enable
                               .DMem_WE(DMem_WE),   // DMem Write Enable
                               .ALU_E(ALU_E),       // ALU Enable
                               .MUX1_Sel(MUX1_Sel), // MUX1 Selection line
                               .MUX2_Sel(MUX2_Sel), // MUX2 Selection line
                               .PMem_LE(PMem_LE),   // PMem Load Enable
                               .ALU_Mode(ALU_Mode));// ALU Output Mode

    // ALU
    ALU ALU_unit(.Operand1(Acc),
                 .Operand2(ALU_Oper2),
                 .E(ALU_E),
                 .Mode(ALU_Mode),
                 .CFlags(SR),                   // Current Flags  
                 .Out(ALU_Out),
                 .Flags(SR_updated));           // Updated Flags
                 /* 4 Flag bits are Z (zero),
                    C (carry), S (sign), O (overflow) 
                    in order from MSB to LSB */

    // PC Adder
    Adder PC_Adder(.In(PC),
                   .Out(Adder_Out));

    // MUX1
    MUX MUX1_unit(.In1(Adder_Out),
                  .In2(IR[7:0]),
                  .Sel(MUX1_Sel),
                  .Out(PC_updated));

    // MUX2
    MUX MUX2_unit(.In1(DR),
                  .In2(IR[7:0]),
                  .Sel(MUX2_Sel),
                  .Out(ALU_Oper2));

    // Program Memory
    PMem PMem_unit(.clk(clk),
                   .E(PMem_E), 
                   .Addr(PC),           // Address port
                   .I(IR_updated),      // Next instruction
                   // 3 special ports, used to load program to the memory
                   .LE(PMem_LE),        // Load enable port 
                   .LA(load_addr),      // Load address port
                   .LI(load_instr));    // Load instruction port

    // Data Memory
    DMem DMem_unit(.clk(clk),
                   .E(DMem_E),
                   .WE(DMem_WE),        // Write enable port
                   .Addr(IR[3:0]),      // Address port 
                   .DI(ALU_Out),        // Data input port
                   .DO(DR_updated));    // Data output port

    // LOAD
    always @(posedge clk) begin
        if(rst == 1) begin
            load_addr <= 0;
            load_done <= 1'b0;
        end 
        else if(PMem_LE == 1) begin 
            load_addr <= load_addr + 8'd1;
            if(load_addr == 8'd25) begin     // All instructions loaded
                load_addr <= 8'd0;          // into Program Memory
                load_done <= 1'b1;
            end
            else begin
                load_done <= 1'b0;
            end
        end 
    end

    assign load_instr = instr_set[load_addr];
    
    // Changing the Current State
    always @(posedge clk) begin
        if(rst == 1)
            current_state <= LOAD;
        else
            current_state <= next_state;
    end

    // State Transitions
    always @(*) begin
        PC_clr = 0;
        Acc_clr = 0;
        SR_clr = 0;
        DR_clr = 0; 
        IR_clr = 0;
        case(current_state)
            LOAD: begin
                if(load_done == 1) begin
                    next_state = FETCH;   // LOAD -> FETCH
                    PC_clr = 1;           // Set Clear to 1 for all registers
                    Acc_clr = 1;
                    SR_clr = 1;
                    DR_clr = 1; 
                    IR_clr = 1;
                end
                else
                    next_state = LOAD;
            end
            FETCH: next_state = DECODE;     // FETCH -> DECODE
            
            DECODE: next_state = EXECUTE;   // DECODE -> EXECUTE
            
            EXECUTE: next_state = FETCH;    // EXECUTE -> FETCH
        endcase
    end

    // Assigning Program Counter, Accumulator, Status Register
    always @(posedge clk) begin
        if(rst == 1) begin
            PC <= 8'd0;             // Clear all registers
            Acc <= 8'd0;
            SR <= 4'd0;
        end
        else begin
            if(PC_E == 1'd1) 
                PC <= PC_updated;   // Update Program Counter
            else if (PC_clr == 1)     
                PC <= 8'd0;         // Clear Program Counter
            if(Acc_E == 1'd1) 
                Acc <= ALU_Out;     // Update Accumulator
            else if (Acc_clr == 1)    
                Acc <= 8'd0;        // Clear Accumulator
            if(SR_E == 1'd1) 
                SR <= SR_updated;   // Update Status Register
            else if (SR_clr == 1)     
                SR <= 4'd0;         // Clear Status Register
        end
    end

    // Assigning Data Register, Instruction Register
    always @(posedge clk) begin
        if(DR_E == 1'd1) 
            DR <= DR_updated;   // Update Data Register
        else if (DR_clr == 1)     
            DR  <= 8'd0;        // Clear Data Register
        if(IR_E == 1'd1) 
            IR <= IR_updated;   // Next Instruction
        else if(IR_clr == 1)      
            IR <= 12'd0;        // Clear Instruction Register
    end

endmodule
