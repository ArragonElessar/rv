module mux2_to_1 #(
    parameter DATA_WIDTH = 32
)(
    input [DATA_WIDTH-1:0] d_in_0, d_in_1,
    input sel,
    output [DATA_WIDTH-1:0] d_out
);

assign d_out = ( sel == 0 ) ? d_in_0 : d_in_1;

endmodule