////////////////////////////////////////////////////////////////////////////////
// Branch Control module                                                      //
// Andrew Gailey and Zach York                                                //
////////////////////////////////////////////////////////////////////////////////
module branch_control(output reg branch, input neg, input o, input zr, 
                      input [3:0]branch_code);

// Define the different branch codes
localparam Bneq = 3'b000;
localparam Beq = 3'b001;
localparam Bgt = 3'b010;
localparam Blt = 3'b011;
localparam Bgte = 3'b100;
localparam Blte = 3'b101;
localparam Bov = 3'b110;
localparam Bun = 3'b111;

/////////////////////////
// Branch code decoder //
/////////////////////////
always@(*) begin
branch = 1'b0; // Don't branch by default
    // All 8 reps are used, so a 4th bit signals if decode proceeds at all
    if(branch_code[3]) begin
        // Logic decides if a branch is taken based on the current flags
        case(branch_code[2:0])
        Bneq:if (!zr) branch = 1'b1;
        Beq: if (zr) branch = 1'b1;
        Bgt: if (!zr && !neg) branch = 1'b1;
        Blt: if (neg) branch = 1'b1;
        Bgte:if (zr || !neg) branch = 1'b1;
        Blte:if (zr || neg) branch = 1'b1;
        Bov: if (o) branch = 1'b1;
        Bun: branch = 1'b1;
        endcase
    end
end
endmodule

