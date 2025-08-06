`timescale 1ns/1ps

module single_cycle_rv_tb;

    reg clk;
    reg rst_n;

    // Instantiate DUT (Device Under Test)
    single_cycle_rv dut(
        .clk(clk),
        .rst_n(rst_n)
    );

    // Clock generation: 50 MHz clock
    always #10 clk = ~clk;
    integer i;
    
    initial begin
        $display("[TB] Starting single_cycle_rv_tb testbench");

        // VCD waveform output for GTKWave
        $dumpfile("sim/waves/single_cycle_rv.vcd");
        $dumpvars(0, single_cycle_rv_tb);

        // Init reset
        clk = 1;
        rst_n = 0;
        #30;
        rst_n = 1;

        for( i = 0; i < 75; i = i + 1) begin
            $display("\n[TB] Cycle:%02d", i);
            
            // Instruction Fetch Stage
            $display("\t[IF] PC: 0x%08X, Instruction: 0x%08X", dut.pc, dut.instr);
            $display("\t[IF] PC+4: 0x%08X, PC_Target: 0x%08X, PC_Src: %b", 
                     dut.pc_plus4, dut.pc_target, dut.cs_pc_src);
            
            // Instruction Decode Stage
            $display("\t[ID] Opcode: 0x%02X, RD: x%02d, RS1: x%02d, RS2: x%02d", 
                     dut.opcode, dut.rd, dut.rs1, dut.rs2);
            $display("\t[ID] Funct3: 0x%01X, Funct7: 0x%02X, Imm_Raw: 0x%07X", 
                     dut.funct3, dut.funct7, dut.imm);
            $display("\t[ID] Imm_Extended: 0x%08X (%0d)", dut.imm_ext, $signed(dut.imm_ext));
            
            // Control Signals
            $display("\t[CTRL] RegWrite: %b, MemWrite: %b, ALUSrc: %b, Branch: %b, Jump: %b", 
                     dut.cs_reg_write, dut.cs_mem_write, dut.cs_alu_src, dut.cs_branch, dut.cs_jump);
            $display("\t[CTRL] ImmSrc: %b, ResultSrc: %b, ALUCtrl: %b", 
                     dut.cs_imm_src, dut.cs_result_src, dut.cs_alu_ctrl);
            
            // Register File Data
            $display("\t[RF] RS1_Data: 0x%08X (%0d), RS2_Data: 0x%08X (%0d)", 
                     dut.rs1_data, $signed(dut.rs1_data), dut.rs2_data, $signed(dut.rs2_data));
            
            // Execute Stage
            $display("\t[EX] ALU_SrcA: 0x%08X, ALU_SrcB: 0x%08X, ALU_Result: 0x%08X", 
                     dut.rs1_data, dut.srcB, dut.alu_result);
            $display("\t[EX] ALU_Zero: %b, Branch_Taken: %b", dut.cs_zero, dut.branch_taken);
            
            // Memory Stage
            $display("\t[MEM] Addr: 0x%08X, WriteData: 0x%08X, ReadData: 0x%08X, WriteEn: d", 
                     dut.alu_result, dut.rs2_data, dut.mem_read_data, dut.cs_mem_write);
            
            // Writeback Stage
            $display("\t[WB] WriteBack_Result: 0x%08X (%0d) -> x%02d", 
                     dut.writeback_result, $signed(dut.writeback_result), dut.rd);
            
            // Instruction Type Detection
            case(dut.opcode)
                7'b0110011: $display("\t[INSTR_TYPE] R-Type (Register-Register)");
                7'b0010011: $display("\t[INSTR_TYPE] I-Type (Immediate)");
                7'b0000011: $display("\t[INSTR_TYPE] I-Type (Load)");
                7'b0100011: $display("\t[INSTR_TYPE] S-Type (Store)");
                7'b1100011: $display("\t[INSTR_TYPE] B-Type (Branch)");
                7'b0110111: $display("\t[INSTR_TYPE] U-Type (LUI)");
                7'b0010111: $display("\t[INSTR_TYPE] U-Type (AUIPC)");
                7'b1101111: $display("\t[INSTR_TYPE] J-Type (JAL)");
                7'b1100111: $display("\t[INSTR_TYPE] I-Type (JALR)");
                default:    $display("\t[INSTR_TYPE] Unknown/Invalid");
            endcase
            
            // Pipeline Separator
            $display("\t------------------------------------------------------------");
            
            #20;
        end

        // Dump memory contents to files
        $writememh("sim/mem/dump_instr.hex", dut.instr_mem_instance.memory);
        $writememh("sim/mem/dump_data.hex", dut.data_mem_instance.memory);
        
        // Performance Statistics
        $display("\n[TB] Simulation Statistics:");
        $display("\tTotal Cycles Simulated: %0d", i);
        $display("\tFinal PC Value: 0x%08X", dut.pc);
        $display("\tMemory Dumps Created: dump_instr.hex, dump_data.hex");

        $display("[TB] Finished simulation");
        $finish;
    end
endmodule
