module register #(
    parameter WIDTH = 32,
    parameter RESET_VALUE = 32'h00000000
)(
    input              clk,
    input              rst_n,       // Active-low reset
    input              en,          // Enable (stall if 0)
    input  [WIDTH-1:0] d_in,        // Data input
    output [WIDTH-1:0] d_out        // Current d_out
);

    reg [WIDTH-1:0] reg_val;

    always @(posedge clk) begin
        if (!rst_n)
            reg_val <= RESET_VALUE;
        else if (en)
            reg_val <= d_in;
    end

    assign d_out = reg_val;

endmodule
