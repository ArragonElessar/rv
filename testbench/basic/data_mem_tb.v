`timescale 1ns / 1ps

module data_mem_tb;

    // Parameters
    localparam MEM_DEPTH = 256;
    localparam DATA_WIDTH = 32;

    // Inputs
    reg clk;
    reg cs_mem_write;
    reg [DATA_WIDTH-1:0] write_data;
    reg [DATA_WIDTH-1:0] addr;

    // Output
    wire [DATA_WIDTH-1:0] read_data;

    // Instantiate the memory module
    data_mem #(
        .MEM_DEPTH(MEM_DEPTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) uut (
        .clk(clk),
        .cs_mem_write(cs_mem_write),
        .write_data(write_data),
        .addr(addr),
        .read_data(read_data)
    );

    // Clock generation (period 10ns)
    initial clk = 0;
    always #5 clk = ~clk;

    integer i;

    initial begin
        // ---- Reset conditions ----
        cs_mem_write = 0;
        write_data = 0;
        addr = 0;

        // Wait a few cycles
        #12;

        // ---- Write to location 42 ----
        addr = 32'd42;
        write_data = 32'hDEADBEEF;
        cs_mem_write = 1;
        @(negedge clk);
        cs_mem_write = 0;

        // ---- Read after write (should reflect new value) ----
        // Make sure cs_mem_write is low
        @(negedge clk);
        $display("Read after write at addr 42: 0x%h (expected 0xDEADBEEF)", read_data);
        if (read_data !== 32'hDEADBEEF)
            $display("ERROR: Read data mismatch!");

        // ---- Write to location 100 ----
        addr = 32'd100;
        write_data = 32'hCAFEBABE;
        cs_mem_write = 1;
        @(negedge clk);
        cs_mem_write = 0;

        // ---- Read from addr 100 (should be CAFEBABE) ----
        @(negedge clk);
        $display("Read after write at addr 100: 0x%h (expected 0xCAFEBABE)", read_data);
        if (read_data !== 32'hCAFEBABE)
            $display("ERROR: Read data mismatch!");

        // ---- Read from addr 55 (uninitialized, expect 0) ----
        addr = 32'd55;
        @(negedge clk);
        $display("Read from uninitialized addr 55: 0x%h (expected 0x00000000)", read_data);
        if (read_data !== 32'h0)
            $display("ERROR: Expected zero for uninitialized location!");

        // ---- Overwrite addr 42, verify update ----
        addr = 32'd42;
        write_data = 32'hA5A5A5A5;
        cs_mem_write = 1;
        @(negedge clk);
        cs_mem_write = 0;

        @(negedge clk);
        $display("Read overwritten addr 42: 0x%h (expected 0xA5A5A5A5)", read_data);
        if (read_data !== 32'hA5A5A5A5)
            $display("ERROR: Overwrite failed!");

        // ---- Test simultaneous write and read to different address (should show old value) ----
        // Let’s write to one, read from another in same cycle:
        addr = 32'd10;
        write_data = 32'h11223344;
        cs_mem_write = 1;
        @(negedge clk); // Writes at addr 10
        cs_mem_write = 0;

        addr = 32'd100; // Go back to previously written address
        @(negedge clk);
        $display("Read from addr 100: 0x%h (expected 0xCAFEBABE)", read_data);

        $display("Testbench done.");
        $finish;
    end

endmodule
