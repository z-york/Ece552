
module SRC0_MUX(src0, imm, p0, EX_ALU, MEM_dst, src0sel);
input [2:0]src0sel;                      // Input select
input [15:0] p0, EX_ALU, MEM_dst;        // Src1 read from reg file, pc + 1, or forwards
input [11:0] imm;                        // Immediate to be sign extended
output [15:0] src0;                      // Mux output

// src1sel selects between reg src, sign extended immediate, and forwards
assign src0 = src0sel[2] ? (src0sel[1] ? EX_ALU : MEM_dst) : (src0sel[1] ? (src0sel[0] ? {{7{imm[8]}}, imm[8:0]} : {{4{imm[11]}}, imm[11:0]}): src0sel[0]? {{7{imm[8]}}, imm[8:0]} : p0);

endmodule
