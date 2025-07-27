module instr_mem #(
    parameter MEM_DEPTH  = 256,                    // Number of instructions
    parameter START_ADDR = 32'h00000000            // Base address of instruction memory
)(
    input  [31:0] addr,      // Address input (PC)
    output [31:0] instr      // Instruction output
);

    localparam MEM_FILE = "sw/mem/loads_and_stores.mem";

    // Declare memory
    reg [31:0] memory [0:MEM_DEPTH-1];

    // Translate byte address to word index (and align)
    wire [31:0] offset = addr - START_ADDR;
    wire [31:2] word_index = offset[31:2];

    // Provide default value if out of bounds
    assign instr = (word_index < MEM_DEPTH) ? memory[word_index] : 32'h00000013;  // Default to NOP

    // Initialize memory
    integer i;
    initial begin
        // Clear all memory to 0
        for (i = 0; i < MEM_DEPTH; i = i + 1) begin
            memory[i] = 32'h00000000;
        end

        // Load from hex file (word-per-line hex values)
        $display("Loading memory from: %s", MEM_FILE);
        $readmemh(MEM_FILE, memory);
    end

endmodule
