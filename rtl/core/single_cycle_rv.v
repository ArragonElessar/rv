module single_cycle_rv #(
    parameter NAME = "single_cycle"
)(
    input wire clk, rst_n // Clock and Reset Signals
);

// Global Wires / Control Signals
wire cs_pc_src, cs_mem_write, cs_alu_src, cs_reg_write, cs_branch, cs_jump;
wire [1:0] cs_imm_src, cs_result_src;
wire [2:0] cs_alu_ctrl; 
wire [31:0] writeback_result;

// ----------------- INSTRUCTION FETCH STAGE -----------------------------------
wire [31:0] pc_next, pc, pc_plus4, pc_target;

mux2_to_1 pc_mux (
    .d_in_0(pc_plus4),
    .d_in_1(pc_target),
    .sel(cs_pc_src),
    .d_out(pc_next)
);

// program counter
register #(
    .WIDTH(32),
    .RESET_VALUE(32'h00000020)
) program_counter (
    .clk(clk),
    .rst_n(rst_n),
    .en(1'b1),
    .d_in(pc_next),
    .d_out(pc)
);

wire [31:0] instr;
instr_mem #(
    .MEM_DEPTH(256),
    .START_ADDR(32'h00000020)
) instr_mem_instance (
    .addr(pc),
    .instr(instr)
);

adder32 pc_adder(
    .a(pc),
    .b(32'h00000004),
    .sum(pc_plus4)
);

// --------------- INSTRUCTION DECODE STAGE -----------------------------------

// Breaking down the instruction
wire [6:0] opcode;
wire [4:0] rd, rs1, rs2;
wire [6:0] funct7;
wire [2:0] funct3;    
wire [24:0] imm;

instr_decode id(
    .instr(instr),
    .opcode(opcode),
    .rd(rd), 
    .rs1(rs1),
    .rs2(rs2),
    .funct7(funct7),
    .funct3(funct3),
    .imm(imm)
);

// Single Cycle Control Unit
cu_single_cycle cu_sc (
    .opcode(opcode),
    .funct3(funct3),
    .funct7_5(funct7[5]),
    .cs_mem_write(cs_mem_write),
    .cs_alu_src(cs_alu_src),
    .cs_reg_write(cs_reg_write),
    .cs_imm_src(cs_imm_src),
    .cs_result_src(cs_result_src),
    .cs_alu_ctrl(cs_alu_ctrl),
    .cs_jump(cs_jump),
    .cs_branch(cs_branch)
);

// Register File
wire [31:0] rs1_data, rs2_data;
register_file rf (
    .clk(clk),
    .rst_n(rst_n),
    .write_enable(cs_reg_write),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .write_data(writeback_result),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data)
);

// Imm Extender
wire [31:0] imm_ext;
imm_extender imm_ext_instance (
    .cs_imm_src(cs_imm_src),
    .imm(imm),
    .imm_ext(imm_ext)
);

// -------------------- Execute Stage -----------------------------

wire [31:0] srcB, alu_result;

// Control Logic for branches
wire branch_taken;
assign branch_taken = (funct3 == 3'b000) ? (cs_branch && cs_zero) :
                      (funct3 == 3'b001) ? (cs_branch && ~cs_zero) :
                                            1'b0;
assign cs_pc_src = branch_taken || cs_jump;

mux2_to_1 alu_srcB_mux (
    .d_in_0(rs2_data),
    .d_in_1(imm_ext),
    .sel(cs_alu_src),
    .d_out(srcB)
);

alu alu_inst (
    .srcA(rs1_data),
    .srcB(srcB),
    .alu_ctrl(cs_alu_ctrl),
    .res(alu_result),
    .zero(cs_zero)
);

adder32 pc_target_adder(
    .a(pc),
    .b(imm_ext),
    .sum(pc_target)
);

// ----------------- Data Memory Stage -----------------------------

wire [31:0] mem_read_data;
data_mem #(
    .MEM_DEPTH(256),
    .DATA_WIDTH(32)
) data_mem_instance (
    .clk(clk),
    .cs_mem_write(cs_mem_write),
    .write_data(rs2_data),
    .addr(alu_result),
    .read_data(mem_read_data)
);

// ----------------- WriteBack Stage -------------------------------

mux4_to_1 wb_mux (
    .d_in_0(alu_result),
    .d_in_1(mem_read_data),
    .d_in_2(pc_plus4),
    .d_in_3(32'd0),
    .sel(cs_result_src),
    .d_out(writeback_result)
);

endmodule