// rv/rtl/alu/adder32.v
module adder32 (
    input  [31:0] a,
    input  [31:0] b,
    output [31:0] sum
);
    assign sum = a + b;
endmodule
