// Andrew Gailey and Zach York
module cpu_tb();

reg clk, rst_n;	// CPU Controls
wire hlt; // Halt output
wire [15:0] pc;
// Instantiate CPU
cpu cpu1(hlt, clk, rst_n, pc);
	
integer cycle_count = 0;

// Testing
initial begin
begin
    $dumpfile("test.vcd");
    $dumpvars(0,cpu1);
 end
	// Initialize Clock
	clk = 0;
	// Reset the machine to ensure PC points to address x0000
	rst_n = 0; clk = 1;
	#5;
	rst_n = 1; clk = 0;
	#5;
	// Run whatever is in instruction memory until hlt is asserted
	while (hlt != 1 && cycle_count != 100000) begin
		clk = 1;
		#5;
		clk = 0;
		#5;
		cycle_count = cycle_count + 1;
	end
	$display("FINAL PC: %h", pc);
	$display("Cycles: %d", cycle_count);
	// Reset puts PC back to 0 and de-asserts hlt
	cycle_count = 0;
	rst_n = 0; clk = 1;
	#5;
	rst_n = 1; clk = 0;
	#5;
	$display("2nd time through the instructions:");
	// Run through instr mem again, shows that halt does not reset regs
	while (hlt != 1 && cycle_count != 100000) begin
		clk = 1;
		#5;
		clk = 0;
		#5;
		cycle_count = cycle_count + 1;
	end
	$display("FINAL PC: %h", pc);
	$display("Cycles: %d", cycle_count);
end
endmodule
	
	
