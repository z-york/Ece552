// Andrew Gailey and Zach York
module PC_sc(addr, addr_plus, hlt, hold, rst, clk, EX_ALU_out, EX_p1, br, jump);

input [15:0] EX_ALU_out, EX_p1;           // For jumps
output reg [15:0] addr;         // PC address
output [15:0] addr_plus;        // PC address + 1
input hlt, hold, rst, clk, br, jump;        // Controls

// Latch with async reset; halt tells latch to hold, otherwise adds 1 on posedge of clk
always@(posedge clk, negedge rst) begin
        if (!rst) addr <= 16'b0;
        else if (!hlt) begin
                if (!br) begin
			if (!jump) begin
				if(!hold) addr <= addr_plus;
				else addr <= addr;
			end
			else addr <= EX_p1;
		end
                else addr <= EX_ALU_out;
        end
        else addr <= addr;
end

assign addr_plus = addr + 1;

endmodule
