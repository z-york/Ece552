////////////////////////////////////////////////////////////////////////////////
// Program Counter module                                                     //
// Andrew Gailey and Zach York                                                //
////////////////////////////////////////////////////////////////////////////////
module PC_sc(output reg [15:0]addr, output [15:0]addr_plus, input hlt, input hold, input rst, 
             input clk, input [15:0]EX_ALU_out, input [15:0]EX_p1, input br, input jump);

// Instruction Address Flop
always@(posedge clk, negedge rst) begin
if (!rst) addr <= 16'b0; // Async Reset
else if (hlt) addr <= addr; // Hold address
else if (br) addr <= EX_ALU_out; // Branch to ALU output
else if (jump) addr <= EX_p1;  // Jump to register value
else if (hold) addr <= addr; // Hold address
else addr <= addr_plus; // No signals = increment address
end

// The next address
assign addr_plus = addr + 1;

endmodule


