`timescale 1ns / 1ps

// Module to asynchronously decode an instruction into the several possible fields

module instr_decode(

    input  wire [31:0] instr,
    
    output wire [6:0] opcode,
    output wire [4:0] rd, rs1, rs2,
    output wire [6:0] funct7,
    output wire [2:0] funct3,
    
    output wire [24:0] imm // Maximum possible immediate value that might be fetched

);
    
    // Refer to RISCV instruction formats RISCV-Reference Sheet.
    
    // Assignment according to R-type instruction 
    assign opcode   = instr[6:0]; // Opcode
    assign rd       = instr[11:7]; // Destination Register
    assign funct3   = instr[14:12]; // Funct3 Field, used along with opcode to identify instr
    assign rs1      = instr[19:15]; // Source Register 1
    assign rs2      = instr[24:20]; // Source Register 2
    assign funct7   = instr[31:25]; // Funct7 - Used with R type instructions
    
    // Control unit will decide which signals to use based on op type
    assign imm      = instr[31:7]; // All possible combinations of immediate will be possible within this
    
endmodule
