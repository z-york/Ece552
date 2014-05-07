////////////////////////////////////////////////////////////////////////////////
// Source 1 Mux                                                               //
// Andrew Gailey and Zach York                                                //
////////////////////////////////////////////////////////////////////////////////
module SRC1_MUX(src1, shift_src1, imm, p1, EX_ALU, MEM_dst, src1sel, pc);
input [2:0] src1sel;                     // Input select
input [15:0] p1, pc, EX_ALU, MEM_dst;    // Src1 read from forwards, reg, or pc+1
input [7:0] imm;                         // Immediate to be sign extended
output [15:0] src1, shift_src1;          // Mux output

// Select ALU SRC1
assign src1 = src1sel[2] ? (src1sel[1] ? EX_ALU                                 // Forward from next
                                       : MEM_dst)                               // Forward from 2nd next
                         : (src1sel[1] ? (src1sel[0] ? pc                       // PC+1
                                                     : {{12{imm[3]}}, imm[3:0]})// 4 bit immediate
                                       : (src1sel[0] ? {{8{imm[7]}}, imm[7:0]}  // 8 bit immediate
                                                     : p1));                    // Register value

// Select Shifter SRC (parallel select shortens the critical path)
assign shift_src1 = src1sel[2] ? (src1sel[0] ? EX_ALU                   // Forward from next
                                             : MEM_dst)                 // Forward from 
                               : (src1sel[0] ? {{8{imm[7]}}, imm[7:0]}  // 8 bit immediate
                                             : p1);                     // Register value

endmodule
