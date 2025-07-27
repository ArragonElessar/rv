`timescale 1ns / 1ps

module register_file #(
    parameter REG_COUNT = 32,
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 5
)(
    input clk,
    input rst_n,
    input write_enable,
    input [ADDR_WIDTH-1:0] rs1,
    input [ADDR_WIDTH-1:0] rs2,
    input [ADDR_WIDTH-1:0] rd,
    input [DATA_WIDTH-1:0] write_data,
    output [DATA_WIDTH-1:0] rs1_data,
    output [DATA_WIDTH-1:0] rs2_data
);

integer i;
reg [DATA_WIDTH-1:0] regfile [0:REG_COUNT-1];

// Synchronous reset and write
always @(posedge clk) begin
    if (!rst_n) begin
        for (i = 0; i < REG_COUNT; i = i + 1)
            regfile[i] <= {DATA_WIDTH{1'b0}};
    end
    else begin
        if (write_enable && rd != 0)
            regfile[rd] <= write_data;
    end
end

// Combinational read
assign rs1_data = (rs1 == 0) ? {DATA_WIDTH{1'b0}} : regfile[rs1];
assign rs2_data = (rs2 == 0) ? {DATA_WIDTH{1'b0}} : regfile[rs2];

endmodule
