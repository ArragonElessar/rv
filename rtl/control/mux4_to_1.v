module mux4_to_1 #(
    parameter DATA_WIDTH = 32
)(
    input  [DATA_WIDTH-1:0] d_in_0, d_in_1, d_in_2, d_in_3,
    input  [1:0] sel,
    output [DATA_WIDTH-1:0] d_out
);

assign d_out = (sel == 2'b00) ? d_in_0 :
               (sel == 2'b01) ? d_in_1 :
               (sel == 2'b10) ? d_in_2 :
                                d_in_3;

endmodule
