// Andrew Gailey and Zach York
module SRC1_MUX(src1, imm, p1, src1sel, pc);
input [1:0] src1sel;    // Input select
input [15:0] p1, pc;    // Src1 read from reg file or pc + 1
input [7:0] imm;        // Immediate to be sign extended
output [15:0] src1;     // Mux output

// src1sel selects between reg src and sign extended immediate
assign src1 = src1sel[0]? (src1sel[1] ? pc : {{12{imm[3]}}, imm[3:0]}): src1sel[1]? {{8{imm[7]}}, imm[7:0]} : p1;

endmodule
