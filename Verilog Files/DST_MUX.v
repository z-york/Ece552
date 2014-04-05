// Andrew Gailey and Zach York
module DST_MUX(dst, ALU_out, rd_data, addr, dst_sel);
input [1:0]dst_sel;                     // Input select
input [15:0] ALU_out, rd_data, addr;    // dst reads from ALU, Memory, or PC + 1
output [15:0] dst;                      // Mux output

// dst_sel selects between ALU, Mem, PC + 1
assign dst = dst_sel[1]? (dst_sel[0] ? rd_data : addr): dst_sel[0]? rd_data : ALU_out;

endmodule
