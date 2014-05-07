////////////////////////////////////////////////////////////////////////////////
// Source 0 Mux                                                               //
// Andrew Gailey and Zach York                                                //
////////////////////////////////////////////////////////////////////////////////
module SRC0_MUX(src0, imm, p0, EX_ALU, MEM_dst, src0sel);
input [2:0]src0sel;                      // Input select
input [15:0] p0, EX_ALU, MEM_dst;        // Src1 read from reg file, pc + 1, or forwards
input [11:0] imm;                        // Immediate to be sign extended
output [15:0] src0;                      // Mux output

// Select ALU SRC0
assign src0 = src0sel[2] ? (src0sel[1] ? EX_ALU                                     // Forward from next
                                       : MEM_dst)                                   // Forward from 2nd next
                         : (src0sel[1] ? ({{4{imm[11]}}, imm[11:0]})                // 12 bit immediate
                                       : (src0sel[0] ? {{7{imm[8]}}, imm[8:0]}      // 9 bit immediate
                                                     : p0));                        // Register value

endmodule
