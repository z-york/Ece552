
module SRC0_MUX(src0, imm, p0, src0sel);
input [1:0]src0sel;     // Input select
input [15:0] p0;        // Src1 read from reg file or pc + 1
input [11:0] imm;       // Immediate to be sign extended
output [15:0] src0;     // Mux output

// src1sel selects between reg src and sign extended immediate
assign src0 = src0sel[1]? (src0sel[0] ? {{7{imm[8]}}, imm[8:0]} : {{4{imm[11]}}, imm[11:0]}): src0sel[0]? {{7{imm[8]}}, imm[8:0]} : p0;

endmodule
