`timescale 1ns / 1ps

module cu_single_cycle_alu_decoder(
    input opcode_5, funct7_5,
    input [2:0] funct3,
    input [1:0] alu_op,
    output reg [2:0] cs_alu_ctrl
    );

wire [1:0] op_func_internal_ctrl;
assign op_func_internal_ctrl = { opcode_5, funct7_5 }; // Concatenate
    
always @(*) begin

    // Instruction Wise Control Signals
    if ( alu_op == 2'b00 ) begin
        // LW, SW Instructions
        cs_alu_ctrl = 3'b000; // ALU -> Add 
    end
    else if ( alu_op == 2'b01 ) begin
        // BEQ instruction, BNE instruction
        cs_alu_ctrl = 3'b001; // ALU -> Subtract
    end
    else if ( alu_op == 2'b10 ) begin
        // Here come the R-Type instructions
        if ( funct3 == 3'b000 ) begin
            if ( op_func_internal_ctrl == 2'b11 ) begin
                // SUB instruction
                cs_alu_ctrl = 3'b001; // ALU -> Sub 
            end 
            else begin
                // ADD Instruction
                cs_alu_ctrl = 3'b000; // ALU -> Add
            end
        end
        else if ( funct3 == 3'b010 ) begin
            // SLT Instrution
            cs_alu_ctrl = 3'b101; // ALU -> Set Less Than
        end
        else if ( funct3 == 3'b110 ) begin
            // OR instruction
            cs_alu_ctrl = 3'b011; // ALU -> Logical OR
        end
        else if ( funct3 == 3'b111) begin
            // AND instruction
            cs_alu_ctrl = 3'b010; // ALU -> Logical AND
        end
        // TODO: Handle the Edge Cases Later Here 
    end

end    

endmodule
