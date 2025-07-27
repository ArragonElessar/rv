`timescale 1ns/1ps

module tb_cu_single_cycle;

  // Inputs
  reg [6:0] opcode;
  reg [2:0] funct3;
  reg funct7_5, zero;

  // Outputs
  wire cs_pc_src, cs_mem_write, cs_alu_src, cs_reg_write;
  wire [1:0] cs_imm_src, cs_result_src;
  wire [2:0] cs_alu_ctrl;

  // Instantiate DUT
  cu_single_cycle dut(
    .opcode(opcode),
    .funct3(funct3),
    .funct7_5(funct7_5),
    .zero(zero),
    .cs_pc_src(cs_pc_src),
    .cs_mem_write(cs_mem_write),
    .cs_alu_src(cs_alu_src),
    .cs_reg_write(cs_reg_write),
    .cs_imm_src(cs_imm_src),
    .cs_result_src(cs_result_src),
    .cs_alu_ctrl(cs_alu_ctrl)
  );

  // Expected value variables
  reg exp_cs_pc_src, exp_cs_mem_write, exp_cs_alu_src, exp_cs_reg_write;
  reg [1:0] exp_cs_imm_src, exp_cs_result_src;
  reg [2:0] exp_cs_alu_ctrl;

  // Output checking task (uses globals)
  task check_output;
    begin
      if ({cs_pc_src, cs_mem_write, cs_alu_src, cs_reg_write, cs_imm_src, cs_result_src, cs_alu_ctrl} !==
          {exp_cs_pc_src, exp_cs_mem_write, exp_cs_alu_src, exp_cs_reg_write, exp_cs_imm_src, exp_cs_result_src, exp_cs_alu_ctrl}) begin
        $display("FAIL: opcode=%b funct3=%b funct7_5=%b zero=%b", opcode, funct3, funct7_5, zero);
        $display("  Expected: %b%b%b%b %b %b %b", exp_cs_pc_src, exp_cs_mem_write, exp_cs_alu_src, exp_cs_reg_write, exp_cs_imm_src, exp_cs_result_src, exp_cs_alu_ctrl);
        $display("  Got:      %b%b%b%b %b %b %b", cs_pc_src, cs_mem_write, cs_alu_src, cs_reg_write, cs_imm_src, cs_result_src, cs_alu_ctrl);
      end else
        $display("PASS: opcode=%b funct3=%b funct7_5=%b zero=%b", opcode, funct3, funct7_5, zero);
    end
  endtask

  initial begin
    // Test LW
    opcode = 7'b0000011; funct3 = 3'b010; funct7_5 = 0; zero = 0;
    #1;
    exp_cs_pc_src = 0; exp_cs_mem_write = 0; exp_cs_alu_src = 1; exp_cs_reg_write = 1;
    exp_cs_imm_src = 2'b00; exp_cs_result_src = 2'b01; exp_cs_alu_ctrl = 3'b000;
    check_output;

    // Test SW
    opcode = 7'b0100011; funct3 = 3'b010; funct7_5 = 0; zero = 0;
    #1;
    exp_cs_pc_src = 0; exp_cs_mem_write = 1; exp_cs_alu_src = 1; exp_cs_reg_write = 0;
    exp_cs_imm_src = 2'b01; exp_cs_result_src = 2'b00; exp_cs_alu_ctrl = 3'b000;
    check_output;

    // BEQ taken
    opcode = 7'b1100011; funct3 = 3'b000; funct7_5 = 0; zero = 1;
    #1;
    exp_cs_pc_src = 1; exp_cs_mem_write = 0; exp_cs_alu_src = 0; exp_cs_reg_write = 0;
    exp_cs_imm_src = 2'b10; exp_cs_result_src = 2'b00; exp_cs_alu_ctrl = 3'b001;
    check_output;

    // BEQ not taken
    opcode = 7'b1100011; funct3 = 3'b000; funct7_5 = 0; zero = 0;
    #1;
    exp_cs_pc_src = 0; exp_cs_mem_write = 0; exp_cs_alu_src = 0; exp_cs_reg_write = 0;
    exp_cs_imm_src = 2'b10; exp_cs_result_src = 2'b00; exp_cs_alu_ctrl = 3'b001;
    check_output;

    // BNE taken
    opcode = 7'b1100011; funct3 = 3'b001; funct7_5 = 0; zero = 0;
    #1;
    exp_cs_pc_src = 1; exp_cs_mem_write = 0; exp_cs_alu_src = 0; exp_cs_reg_write = 0;
    exp_cs_imm_src = 2'b10; exp_cs_result_src = 2'b00; exp_cs_alu_ctrl = 3'b001;
    check_output;

    // R-Type ADD
    opcode = 7'b0110011; funct3 = 3'b000; funct7_5 = 0; zero = 0;
    #1;
    exp_cs_pc_src = 0; exp_cs_mem_write = 0; exp_cs_alu_src = 0; exp_cs_reg_write = 1;
    exp_cs_imm_src = 2'b00; exp_cs_result_src = 2'b00; exp_cs_alu_ctrl = 3'b000;
    check_output;

    // R-Type SUB
    opcode = 7'b0110011; funct3 = 3'b000; funct7_5 = 1; zero = 0;
    #1;
    exp_cs_pc_src = 0; exp_cs_mem_write = 0; exp_cs_alu_src = 0; exp_cs_reg_write = 1;
    exp_cs_imm_src = 2'b00; exp_cs_result_src = 2'b00; exp_cs_alu_ctrl = 3'b001;
    check_output;

    // R-Type SLT
    opcode = 7'b0110011; funct3 = 3'b010; funct7_5 = 0; zero = 0;
    #1;
    exp_cs_pc_src = 0; exp_cs_mem_write = 0; exp_cs_alu_src = 0; exp_cs_reg_write = 1;
    exp_cs_imm_src = 2'b00; exp_cs_result_src = 2'b00; exp_cs_alu_ctrl = 3'b101;
    check_output;

    // R-Type OR
    opcode = 7'b0110011; funct3 = 3'b110; funct7_5 = 0; zero = 0;
    #1;
    exp_cs_pc_src = 0; exp_cs_mem_write = 0; exp_cs_alu_src = 0; exp_cs_reg_write = 1;
    exp_cs_imm_src = 2'b00; exp_cs_result_src = 2'b00; exp_cs_alu_ctrl = 3'b011;
    check_output;

    // R-Type AND
    opcode = 7'b0110011; funct3 = 3'b111; funct7_5 = 0; zero = 0;
    #1;
    exp_cs_pc_src = 0; exp_cs_mem_write = 0; exp_cs_alu_src = 0; exp_cs_reg_write = 1;
    exp_cs_imm_src = 2'b00; exp_cs_result_src = 2'b00; exp_cs_alu_ctrl = 3'b010;
    check_output;

    // ADDI
    opcode = 7'b0010011; funct3 = 3'b000; funct7_5 = 0; zero = 0;
    #1;
    exp_cs_pc_src = 0; exp_cs_mem_write = 0; exp_cs_alu_src = 1; exp_cs_reg_write = 1;
    exp_cs_imm_src = 2'b00; exp_cs_result_src = 2'b00; exp_cs_alu_ctrl = 3'b000;
    check_output;

    // JAL
    opcode = 7'b1101111; funct3 = 3'b000; funct7_5 = 0; zero = 0;
    #1;
    exp_cs_pc_src = 1; exp_cs_mem_write = 0; exp_cs_alu_src = 0; exp_cs_reg_write = 1;
    exp_cs_imm_src = 2'b11; exp_cs_result_src = 2'b10; exp_cs_alu_ctrl = 3'b000;
    check_output;

    $stop;
  end

endmodule
