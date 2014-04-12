// Andrew Gailey and Zach York
module branch_control(branch, neg, o, zr, branch_code);
input [3:0] branch_code;
input neg, o, zr;
output reg branch;

localparam Bneq = 3'b000;
localparam Beq = 3'b001;
localparam Bgt = 3'b010;
localparam Blt = 3'b011;
localparam Bgte = 3'b100;
localparam Blte = 3'b101;
localparam Bov = 3'b110;
localparam Bun = 3'b111;

always@(*) begin
if(branch_code[3]) begin
        case(branch_code[2:0])
        	Bneq:   if (!zr) branch = 1'b1;
		Beq: if (zr) branch = 1'b1;
		Bgt: if (!zr && !neg) branch = 1'b1;
		Blt: if (neg) branch = 1'b1;
		Bgte: if (zr || !neg) branch = 1'b1;
		Blte: if (zr || neg) branch = 1'b1;
		Bov: if (o) branch = 1'b1;
		Bun: branch = 1'b1;
		default: branch = 1'b0;
        endcase
end
else branch = 1'b0;
end
endmodule

