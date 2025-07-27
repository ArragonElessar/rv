`timescale 1ns / 1ps

module cu_single_cycle(

    input [6:0] opcode,
    input [2:0] funct3,
    input funct7_5, zero, 
    output cs_mem_write, cs_alu_src, cs_reg_write, cs_branch, cs_jump,
    output [1:0] cs_imm_src, cs_result_src, 
    output [2:0] cs_alu_ctrl
);
    
// Define the extra wires that we need
wire [1:0] alu_op;

// Main Decoder
cu_single_cycle_main_decoder main_decoder (
    .opcode(opcode),
    .branch(cs_branch),
    .jump(cs_jump),
    .cs_result_src(cs_result_src),
    .cs_mem_write(cs_mem_write),
    .cs_alu_src(cs_alu_src),
    .cs_imm_src(cs_imm_src),
    .cs_reg_write(cs_reg_write),
    .alu_op(alu_op)
);
 
// ALU Decoder 
cu_single_cycle_alu_decoder alu_decoder ( 
    .opcode_5(opcode[5]),
    .funct7_5(funct7_5),
    .funct3(funct3),
    .alu_op(alu_op),
    .cs_alu_ctrl(cs_alu_ctrl)
);


endmodule
