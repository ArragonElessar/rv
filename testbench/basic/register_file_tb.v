`timescale 1ns / 1ps

module register_file_tb;

    // Parameters
    localparam REG_COUNT = 32;
    localparam DATA_WIDTH = 32;
    localparam ADDR_WIDTH = 5;

    // Inputs
    reg clk;
    reg rst_n;
    reg write_enable;
    reg [ADDR_WIDTH-1:0] rs1;
    reg [ADDR_WIDTH-1:0] rs2;
    reg [ADDR_WIDTH-1:0] rd;
    reg [DATA_WIDTH-1:0] write_data;

    // Outputs
    wire [DATA_WIDTH-1:0] rs1_data;
    wire [DATA_WIDTH-1:0] rs2_data;

    // Instantiate the register_file
    register_file #(
        .REG_COUNT(REG_COUNT),
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .write_enable(write_enable),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(write_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    // Clock generation: 10ns period (100 MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test procedure
    initial begin
        // Initialize inputs
        rst_n = 0;
        write_enable = 0;
        rs1 = 0;
        rs2 = 0;
        rd = 0;
        write_data = 0;

        // Hold reset for 2 clock cycles
        @(negedge clk);
        rst_n = 0;
        @(negedge clk);
        rst_n = 1;  // Release reset

        // Wait a cycle after reset
        @(negedge clk);

        // Test 1: Write to register 1 and read it back
        rd = 5'd1;
        write_data = 32'hDEADBEEF;
        write_enable = 1;
        @(negedge clk);
        write_enable = 0;

        rs1 = 5'd1;
        rs2 = 5'd0;  // Zero register should always read zero

        @(negedge clk); // wait for combinational read

        $display("Read rs1_data (reg1): 0x%h (expected 0xDEADBEEF)", rs1_data);
        $display("Read rs2_data (reg0): 0x%h (expected 0x00000000)", rs2_data);

        if (rs1_data !== 32'hDEADBEEF)
            $display("ERROR: rs1_data mismatch");
        if (rs2_data !== 32'h0)
            $display("ERROR: rs2_data mismatch");

        // Test 2: Write to register 2 and read register 1 and 2
        // Write reg2
        rd = 5'd2;
        write_data = 32'hCAFEBABE;
        write_enable = 1;
        @(negedge clk);
        write_enable = 0;

        // Set read addresses
        rs1 = 5'd1;
        rs2 = 5'd2;

        @(negedge clk);

        $display("Read rs1_data (reg1): 0x%h (expected 0xDEADBEEF)", rs1_data);
        $display("Read rs2_data (reg2): 0x%h (expected 0xCAFEBABE)", rs2_data);

        if (rs1_data !== 32'hDEADBEEF)
            $display("ERROR: rs1_data mismatch");
        if (rs2_data !== 32'hCAFEBABE)
            $display("ERROR: rs2_data mismatch");

        // Test 3: Try to write to x0 (register 0) - value should not change
        rd = 5'd0;
        write_data = 32'hFFFFFFFF;
        write_enable = 1;
        @(negedge clk);
        write_enable = 0;

        // Read back reg0
        rs1 = 5'd0;
        rs2 = 5'd0;

        @(negedge clk);

        $display("Read rs1_data (reg0): 0x%h (expected 0x00000000)", rs1_data);
        $display("Read rs2_data (reg0): 0x%h (expected 0x00000000)", rs2_data);

        if (rs1_data !== 32'h0)
            $display("ERROR: reg0 changed, which should not happen");
        if (rs2_data !== 32'h0)
            $display("ERROR: reg0 changed, which should not happen");

        // Test 4: Reset the register file and verify registers are cleared
        rst_n = 0;
        @(negedge clk);
        rst_n = 1;
        @(negedge clk);

        rs1 = 5'd1;
        rs2 = 5'd2;
        @(negedge clk);

        $display("After reset:");
        $display("rs1_data (reg1): 0x%h (expected 0x00000000)", rs1_data);
        $display("rs2_data (reg2): 0x%h (expected 0x00000000)", rs2_data);

        if (rs1_data !== 0)
            $display("ERROR: reg1 not cleared after reset");
        if (rs2_data !== 0)
            $display("ERROR: reg2 not cleared after reset");

        $display("Test completed.");
        $finish;
    end

endmodule
