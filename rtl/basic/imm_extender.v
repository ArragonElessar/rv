`timescale 1ns / 1ps

module imm_extender (
    input  [1:0]      cs_imm_src,
    input  [31:7]     imm,
    output reg [31:0] imm_ext
);

    always @(*) begin
        case (cs_imm_src)
            2'b00: begin // I-type
                imm_ext = {{20{imm[31]}}, imm[31:20]};
            end
            2'b01: begin // S-type
                imm_ext = {{20{imm[31]}}, imm[31:25], imm[11:7]};
            end
            2'b10: begin // B-type
                imm_ext = {{19{imm[31]}}, imm[31], imm[7], imm[30:25], imm[11:8], 1'b0};
            end
            2'b11: begin // J-type
                imm_ext = {{11{imm[31]}}, imm[31], imm[19:12], imm[20], imm[30:21], 1'b0};
            end
            default: begin
                imm_ext = 32'b0;
            end
        endcase
    end

endmodule
