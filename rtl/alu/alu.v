`timescale 1ns / 1ps

module alu(
    input [31:0] srcA,
    input [31:0] srcB,
    input [2:0] alu_ctrl,
    output reg [31:0] res,
    output zero
);

    always @(*) begin
        case (alu_ctrl)
            3'b000: res = srcA + srcB;                                // Add
            3'b001: res = srcA - srcB;                                // Sub
            3'b010: res = srcA & srcB;                                // AND
            3'b011: res = srcA | srcB;                                // OR
            3'b101: res = (srcA < srcB) ? 32'b1 : 32'b0;              // SLT
            default: res = 32'b0;
        endcase
    end

    assign zero = (res == 32'b0);

endmodule
