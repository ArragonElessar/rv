`timescale 1ns/1ps

module single_cycle_rv_tb;

    // Signal declarations (example)
    reg clk;
    reg rst_n;

    // Instantiate your DUT here...
    single_cycle_rv dut(
        .clk(clk),
        .rst_n(rst_n)
    );

    // Clock generation
    always #10 clk = ~clk;

    initial begin
        $display("[TB] Starting single_cycle_rv_tb testbench");
        
        // VCD generation
        $dumpfile("sim/waves/single_cycle_rv.vcd"); //  desired file path
        $dumpvars(0, single_cycle_rv_tb);           //  specific top-level TB

        // Init
        clk = 1;
        rst_n = 0;
        #30;
        rst_n = 1;

        repeat (100) @(posedge clk);
        $display("[TB] Finished simulation");
        $finish;
    end

endmodule
