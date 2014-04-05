// Andrew Gailey and Zach York
module cpu_tb();

reg clk, rst_n; // CPU Controls
wire hlt;       // Halt output
wire [15:0] pc; // PC address output
        
// Instantiate CPU
cpu cpu1(hlt, clk, rst_n, pc);
        
// Testing
initial begin
        // Initialize Clock
        clk = 0;
        // Reset the machine to ensure PC points to address x0000
        rst_n = 0;
        #5;
        rst_n = 1;
        #5;
        // Run whatever is in instruction memory until hlt is asserted
        while (hlt != 1) begin
                clk = 1;
                #5;
                clk = 0;
                #5;
        end
end
endmodule
        
        
