`timescale 1ns / 1ps

module instr_decode_tb;

    // Inputs
    reg [31:0] instr;

    // Outputs
    wire [6:0] opcode;
    wire [4:0] rd, rs1, rs2;
    wire [6:0] funct7;
    wire [2:0] funct3;
    wire [24:0] imm;

    // Instantiate the Unit Under Test (UUT)
    instr_decode uut (
        .instr(instr),
        .opcode(opcode),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .funct7(funct7),
        .funct3(funct3),
        .imm(imm)
    );

    // Task for displaying outputs with expected values
    task check_outputs;
        input [6:0] exp_opcode;
        input [4:0] exp_rd;
        input [4:0] exp_rs1;
        input [4:0] exp_rs2;
        input [6:0] exp_funct7;
        input [2:0] exp_funct3;
        input [24:0] exp_imm;

        begin
            $display("Instruction: 0x%08h", instr);
            $display("opcode: 0x%02h (expected 0x%02h)", opcode, exp_opcode);
            $display("rd: 0x%02h (expected 0x%02h)", rd, exp_rd);
            $display("rs1: 0x%02h (expected 0x%02h)", rs1, exp_rs1);
            $display("rs2: 0x%02h (expected 0x%02h)", rs2, exp_rs2);
            $display("funct7: 0x%02h (expected 0x%02h)", funct7, exp_funct7);
            $display("funct3: 0x%01h (expected 0x%01h)", funct3, exp_funct3);
            $display("imm: 0x%07h (expected 0x%07h)", imm, exp_imm);
            $display("-------------------------------------------------");
        end
    endtask

    initial begin
        // Example 1: R-type instruction (e.g. add x1, x2, x3)
        // add: 0x00000033: funct7=0000000, rs2=00011, rs1=00010, funct3=000, rd=00001, opcode=0110011
        instr = 32'b0000000_00011_00010_000_00001_0110011;
        #5;
        check_outputs(
            7'b0110011,   // opcode
            5'd1,        // rd
            5'd2,        // rs1
            5'd3,        // rs2
            7'b0000000,  // funct7
            3'b000,      // funct3
            instr[31:7]  // imm (all bits [31:7])
        );

        // Example 2: I-type instruction (e.g. addi x5, x6, 0x12)
        // addi: 0x01230313: imm=00010010 (0x12), rs1=00110, funct3=000, rd=00101, opcode=0010011
        instr = 32'b000000000001001001100000010010011;
        // But let's write actual bits for a correct I-type instruction:
        // imm[11:0] = 0x012 (18 decimal) = 000000010010 binary (12-bit)
        // rs1 = x6 = 6 => 00110
        // funct3 = 000
        // rd = x5 = 00101
        // opcode = 0010011

        instr = {12'b000000010010, 5'd6, 3'b000, 5'd5, 7'b0010011};
        #5;
        check_outputs(
            7'b0010011,    // opcode (I-type)
            5'd5,         // rd
            5'd6,         // rs1
            5'd0,         // rs2 (should be zero for I-type)
            7'b0000000,   // funct7 (not valid for I-type, but decoder assigns bits [31:25])
            3'b000,       // funct3
            instr[31:7]   // imm (all bits [31:7])
        );

        // Example 3: S-type instruction (e.g. sw x9, 0(x8))
        // sw: opcode=0100011, imm split between bits [31:25] and [11:7]
        // imm: [31:25] = 0000000, rs2 = x9=01001, rs1 = x8=01000, funct3=010, imm[11:7] = 00000, opcode=0100011
        instr = {7'b0000000, 5'd9, 5'd8, 3'b010, 5'b00000, 7'b0100011};
        #5;
        check_outputs(
            7'b0100011,   // opcode
            5'd0,        // rd not used in S-type, but bits here
            5'd8,        // rs1
            5'd9,        // rs2
            7'b0000000,  // funct7 (bits [31:25])
            3'b010,      // funct3
            instr[31:7]  // imm
        );

        // Example 4: U-type instruction (e.g. LUI x10, 0x12345000)
        // opcode = 0110111, rd = x10=01010, imm [31:12] = 0x12345
        instr = {20'h12345, 5'd10, 7'b0110111};
        #5;
        check_outputs(
            7'b0110111,   // opcode
            5'd10,       // rd
            5'd0,        // rs1 unused
            5'd0,        // rs2 unused
            instr[31:25],// funct7 bits
            instr[14:12],// funct3 bits
            instr[31:7]  // imm
        );

        // Example 5: B-type instruction (e.g. beq x1, x2, offset)
        // opcode=1100011, funct3=000
        // imm split, rs1=x1=00001, rs2=x2=00010
        instr = {7'b0000000, 5'd2, 5'd1, 3'b000, 5'b00000, 7'b1100011};
        #5;
        check_outputs(
            7'b1100011,
            5'b00000,    // rd is not used for B-type and is bits[11:7] → here 0
            5'd1,        // rs1
            5'd2,        // rs2
            7'b0000000,  // funct7 bits (maybe part of imm here)
            3'b000,      // funct3
            instr[31:7]  // imm
        );

        $display("All decode tests finished");
        $finish;
    end

endmodule
