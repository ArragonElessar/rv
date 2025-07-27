module data_mem #(
    parameter MEM_DEPTH = 256,
    parameter DATA_WIDTH = 32
)(
    input wire clk,
    input wire cs_mem_write,
    input wire [DATA_WIDTH-1:0] write_data,
    input wire [DATA_WIDTH-1:0] addr,
    output reg [DATA_WIDTH-1:0] read_data
);

reg [DATA_WIDTH-1:0] memory [0:MEM_DEPTH-1];

integer i;
initial begin
    for (i = 0; i < MEM_DEPTH; i = i + 1)
        memory[i] = {DATA_WIDTH{1'b0}};
end

// Handling Address overflow
wire data_addr = addr < MEM_DEPTH ? addr : 0;

always @(posedge clk) begin

    // write first
    if (cs_mem_write) begin
        memory[data_addr] <= write_data;
    end

    // then read
    read_data <= memory[data_addr];

end

endmodule