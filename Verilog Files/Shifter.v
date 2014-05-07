////////////////////////////////////////////////////////////////////////////////
// 16 bit Shifter                                                             //
// Andrew Gailey and Zach York                                                //
////////////////////////////////////////////////////////////////////////////////
module Shifter(output [15:0]out, input [15:0]src1, input [3:0]shamt, input [1:0]Sel);

// Intermediate values
wire [15:0] w1, w2, w3;

// Shift 1 bit or 0 bits
assign w1[15:0] = shamt[0] ? (Sel[0] ? (Sel[1] ? {src1[15], src1[15:1]} // SRA
                                               : {1'b0, src1[15:1]})    // SRL
                                     : {src1[14:0], 1'b0}  )            // SLL
                           : src1;                                      // No shift
// Shift another 2 bits or 0 bits
assign w2[15:0] = shamt[1] ? (Sel[0] ? (Sel[1] ? {{2{src1[15]}}, w1[15:2]} // SRA
                                               : {2'b00, w1[15:2]})        // SRL
                                     : {w1[13:0], 2'b00}  )                // SLL
                           : w1;                                           // No shift
// Shift another 4 bits or 0 bits
assign w3[15:0] = shamt[2] ? (Sel[0] ? (Sel[1] ? {{4{src1[15]}}, w2[15:4]} // SRA
                                               : {4'h0, w2[15:4]})         // SRL
                                     : {w2[11:0], 4'h0}  )                 // SLL
                           : w2;                                           // No shift
// Shift another 8 bits or 0 bits
assign out[15:0] = shamt[3] ? (Sel[0] ? (Sel[1] ? {{8{src1[15]}}, w3[15:8]} // SRA
                                                : {8'h00, w3[15:8]})        // SRL
                                      : {w3[7:0], 8'h00}  )                 // SLL
                            : w3;                                           // No shift

endmodule
