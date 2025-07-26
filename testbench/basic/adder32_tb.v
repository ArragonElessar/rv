// riscv_cpu_project/testbench/basic/adder32_tb.v
`timescale 1ns/1ps

module adder32_tb;
    reg  [31:0] a, b;
    wire [31:0] sum;

    adder32 uut (
        .a(a),
        .b(b),
        .sum(sum)
    );

    initial begin
        $dumpfile("sim/waves/adder32.vcd"); // Adjust path as needed
        $dumpvars(0, adder32_tb);

        a = 32'h00000001; b = 32'h00000001; #10;
        a = 32'hFFFFFFFF; b = 32'h00000001; #10;
        a = 32'h12345678; b = 32'h87654321; #10;
        $finish;
    end
endmodule
