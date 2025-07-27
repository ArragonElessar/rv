`timescale 1ns / 1ps

module cu_single_cycle_main_decoder(
    
    input [6:0] opcode,
    output reg branch, cs_mem_write, cs_alu_src, cs_reg_write, jump,
    output reg [1:0] cs_imm_src, cs_result_src,
    output reg [1:0] alu_op
    );

// Defining some opcodes here
localparam OP_LW     = 7'b0000011; // Load Word
localparam OP_SW     = 7'b0100011; // Store Word
localparam OP_BRANCH = 7'b1100011; // Branch
localparam OP_R_TYPE = 7'b0110011; // R-Type instructions are decoded using other fields as well
localparam OP_ADDI   = 7'b0010011; // ADDI 
localparam OP_JAL    = 7'b1101111; // JAL - Jump and Link Instruction 

// R-Type data paths are similar on other components, differ only on ALU Operation
// So it makes sense to have the same main OPCode, but different Funct fields.
    
always @(*) begin
    
    // Single cycle control unit is an easy encoding
    // Refer to Table 7.2 from book. 
    if ( opcode == OP_LW ) begin
        cs_reg_write  = 1'b1;
        cs_imm_src    = 2'b00;
        cs_alu_src    = 1'b1;
        cs_mem_write  = 1'b0;
        cs_result_src = 2'b01;
        branch        = 1'b0;
        alu_op        = 2'b00;
        jump          = 1'b0;
    end
    else if ( opcode == OP_SW ) begin
        cs_reg_write  = 1'b0;
        cs_imm_src    = 2'b01;
        cs_alu_src    = 1'b1;
        cs_mem_write  = 1'b1;
        cs_result_src = 2'b00;
        branch        = 1'b0;
        alu_op        = 2'b00;
        jump          = 1'b0;
    end
    else if ( opcode == OP_R_TYPE ) begin
        cs_reg_write  = 1'b1;
        cs_imm_src    = 2'b00;
        cs_alu_src    = 1'b0;
        cs_mem_write  = 1'b0;
        cs_result_src = 2'b00;
        branch        = 1'b0;
        alu_op        = 2'b10;
        jump          = 1'b0;
    end
    else if ( opcode == OP_BRANCH ) begin
        cs_reg_write  = 1'b0;
        cs_imm_src    = 2'b10;
        cs_alu_src    = 1'b0;
        cs_mem_write  = 1'b0;
        cs_result_src = 2'b00;
        branch        = 1'b1; // Only branch instructions will pull the branch signal up.
        alu_op        = 2'b01;
        jump          = 1'b0;
    end
    else if ( opcode == OP_ADDI ) begin
        cs_reg_write  = 1'b1;
        cs_imm_src    = 2'b00;
        cs_alu_src    = 1'b1;
        cs_mem_write  = 1'b0;
        cs_result_src = 2'b00;
        branch        = 1'b0; // Only branch instructions will pull the branch signal up.
        alu_op        = 2'b10;
        jump          = 1'b0;
    end
    else if ( opcode == OP_JAL ) begin
        cs_reg_write  = 1'b1;
        cs_imm_src    = 2'b11;
        cs_alu_src    = 1'b0;
        cs_mem_write  = 1'b0;
        cs_result_src = 2'b10;
        branch        = 1'b0; // Only branch instructions will pull the branch signal up.
        alu_op        = 2'b10;
        jump          = 1'b1;
    end
    
end
endmodule
