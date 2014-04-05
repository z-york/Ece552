//Andrew Gailey and Zach York
module Shifter(out, src1, shamt, Sel);

output [15:0] out;
input [15:0] src1;
input [1:0] Sel;
input [3:0] shamt;

wire [15:0] w1, w2, w3;

assign w1[15:0] = shamt[0]? (Sel[0]? (Sel[1]? {src1[15], src1[15:1]} : {1'b0, src1[15:1]}) : {src1[14:0], 1'b0}  ) : src1;
assign w2[15:0] = shamt[1]? (Sel[0]? (Sel[1]? {{2{src1[15]}}, w1[15:2]} : {2'b00, w1[15:2]}) : {w1[13:0], 2'b00}  ) : w1;
assign w3[15:0] = shamt[2]? (Sel[0]? (Sel[1]? {{4{src1[15]}}, w2[15:4]} : {4'h0, w2[15:4]}) : {w2[11:0], 4'h0}  ) : w2;
assign out[15:0] = shamt[3]? (Sel[0]? (Sel[1]? {{8{src1[15]}}, w3[15:8]} : {8'h00, w3[15:8]}) : {w3[7:0], 8'h00}  ) : w3;

endmodule
