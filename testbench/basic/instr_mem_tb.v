`timescale 1ns / 1ps

module instr_mem_tb;

    // Parameters
    parameter MEM_DEPTH  = 256;
    parameter START_ADDR = 32'h00000000;
    // Testbench signals
    reg  [31:0] addr;
    wire [31:0] instr;

    // Clock signal (not needed by instr_mem, but useful for timing)
    reg clk;
    initial clk = 0;
    always #5 clk = ~clk; // 100 MHz clock

    // Instantiate the instruction memory
    instr_mem #(
        .MEM_DEPTH(MEM_DEPTH),
        .START_ADDR(START_ADDR)
    ) dut (
        .addr(addr),
        .instr(instr)
    );

    // Drive address and monitor output
    integer i;
    initial begin
        $display("\n==== Instruction Memory Test ====");
        $display("Reading first 50 memory words...\n");

        addr = START_ADDR;
        #10; // Wait for memory to initialize

        for (i = 0; i < 50; i = i + 1) begin
            @(posedge clk);
            $display("addr: 0x%08h -> instr: 0x%08h", addr, instr);
            addr = addr + 4;
        end

        $display("\n==== Done ====");
        $finish;
    end

endmodule
