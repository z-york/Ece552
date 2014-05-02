//Andrew Gailey and Zach York
module ALU (dst, ov, zr, shamt, func, src1, shift_src1, src0, nonsat);

output [15:0] dst;
output ov, zr;
input [3:0] shamt;
input [15:0] src1, shift_src1, src0;
input [2:0] func;
input nonsat;

wire [15:0] shift, tmpsrc1, tmpsrc0, norout, andout, addout0, addout;
wire [1:0] Sel;
wire [3:0] shamt0;
wire cin, lhb, zr_addout, zr_shift, zr_andout, zr_norout;

Shifter shiftsrc1(shift, shift_src1, shamt0, Sel);
assign lhb = &func;

assign tmpsrc0 = (lhb) ? {8'h00, src0[7:0]} 
                       : func[0] ? (~src0) 
                                 : src0;
assign cin = func[2] ? 1'b0 
                     : func[0];

// Decode func bits
assign Sel = func[2] ? (func[1] ? (func[0] ? 2'b10 
                                           :  2'b11) 
                                : (func[0] ? 2'b01 
                                           : 2'b10))  
                     : 2'b0;


assign shamt0 = (lhb) ? 4'b1000 
                      : shamt;
assign tmpsrc1 = func[2] ? shift 
                         : src1;

assign addout0 = tmpsrc1 + tmpsrc0 + cin;
assign andout = src0 & src1;
assign norout = ~(src0 | src1);

assign ov = nonsat ? 1'b0 
                   : func[2] ? 1'b0 
                             : func[1] ? 1'b0 
                                       : (~(tmpsrc0[15] ^ tmpsrc1[15])) ? (tmpsrc0[15] ^ addout0[15])
                                                                        : 1'b0 ;
assign addout = ov ? (src1[15] ? 16'h8000 
                               : 16'h7FFF) 
                   : addout0;

assign dst = func[2] ? (lhb ? addout 
                            : shift) 
                     : (func[1] ? (func[0] ? norout 
                                           : andout) 
                                : addout);
// Original zero: Zero Accumulator
//assign zr = ~(|dst);

// Alternate zero: Zero Detect
//assign zr_detect = dst + 16'hFFFF;
//assign zr = !zr_detect[16];

// Alternate zero: Zero Parallel Detect
assign zr_addout = ~(|dst); // No idea why this synthesizes with less slack than "~(|addout0)" but it does
assign zr_shift = ~(|shift);
assign zr_norout = ~(|norout);
assign zr_andout = ~(|andout);
  // zr selection = parallel with dst selection
assign zr = func[2] ? (lhb ? zr_addout 
                            : zr_shift) 
                     : (func[1] ? (func[0] ? zr_norout 
                                           : zr_andout) 
                                : zr_addout);
endmodule
