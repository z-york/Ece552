////////////////////////////////////////////////////////////////////////////////
// Instruction Decode module                                                  //
// Andrew Gailey and Zach York                                                //
////////////////////////////////////////////////////////////////////////////////
module ID(input [15:0]instr, output reg [2:0] src1sel_out, output reg hlt, output reg [3:0] shamt, 
          output reg [2:0] funct, output reg [3:0] p0_addr, output reg re0, output reg [3:0] p1_addr, 
          output reg re1, output reg [3:0] dst_addr, output reg we_out, output reg [2:0] src0sel_out, 
          output reg [1:0] flag_en, output reg mem_re, output reg mem_we, output reg [1:0] dst_sel, 
          output reg [3:0] branch_code, output reg jumpR, input [3:0]ID_dst, input ID_we, 
          input [3:0]EX_dst, input EX_we, input ID_mem_re, input EX_mem_re, output bubble, 
          output reg addz, output reg [1:0] sw_p1_sel); //, output reg nonsat);

// Intermediate wires
reg [2:0] src0sel, src1sel;
reg bubble0, bubble1, we;

// Define the opcodes
localparam ADD = 4'b0000;
localparam ADDz = 4'b0001;
localparam SUB = 4'b0010;
localparam AND = 4'b0011;
localparam NOR = 4'b0100;
localparam SLL = 4'b0101;
localparam SRL = 4'b0110;
localparam SRA = 4'b0111;
localparam LLB = 4'b1011;
localparam LHB = 4'b1010;
localparam HLT = 4'b1111;
localparam LW  = 4'b1000;
localparam SW  = 4'b1001;
localparam JAL = 4'b1101;
localparam JR  = 4'b1110;
localparam B  = 4'b1100;
localparam Bneq = 3'b000;
localparam Beq = 3'b001;
localparam Bgt = 3'b010;
localparam Blt = 3'b011;
localparam Bgte = 3'b100;
localparam Blte = 3'b101;
localparam Bov = 3'b110;
localparam Bun = 3'b111;


//////////////////////
// Forwarding Logic //
//////////////////////

// Two sources could cause a bubble, signal for either
assign bubble = bubble0 || bubble1;

always@(*) begin
// Defaults
src1sel_out = src1sel; // Allows forwarding of values to SRC1
bubble1 = 1'b0;
sw_p1_sel = 2'b00; // Allows forwarding of values to Dcache write input
src0sel_out = src0sel; // Allows forwarding of values to SRC0
bubble0 = 1'b0;

// Forward for RAW in SRC0 from next instruction
if ((p0_addr != 4'b0000) && (p0_addr == ID_dst) && ID_we) begin
    if (ID_mem_re) begin // Load/Use = bubble
        bubble0 = 1'b1;
        src0sel_out = 3'b000;
    end
    else begin // Forward
        src0sel_out = 3'b111;
        bubble0 = 1'b0;
    end
end
// Forward for RAW in SRC0 from 2nd to next instruction
else if ((p0_addr != 4'b0000) && (p0_addr == EX_dst) && EX_we) begin
    src0sel_out = 3'b100;
    bubble0 = 1'b0;
end
// Forward for RAW in SRC1 from next instruction
if ((p1_addr != 4'b0000) && (p1_addr == ID_dst) && ID_we) begin
    if (instr[15:12] == SW) begin // Special forward for Mem-write input
        src1sel_out = src1sel;
        bubble1 = 1'b0;
        sw_p1_sel = 2'b10;
    end
    else if (ID_mem_re) begin // Load/Use = bubble
        bubble1 = 1'b1;
        src1sel_out = 3'b000;
        sw_p1_sel = 2'b00;
    end
    else begin // Forward
        src1sel_out = 3'b111;
        bubble1 = 1'b0;
        sw_p1_sel = 2'b00;
    end
end
// Forward for RAW in SRC1 from 2nd to next instruction
else if ((p1_addr != 4'b0000) && (p1_addr == EX_dst) && EX_we) begin
    if (instr[15:12] == SW) begin // Special forward for Mem-write input
        src1sel_out = src1sel;
        bubble1 = 1'b0;
        sw_p1_sel = 2'b01;
    end
    else begin // Forward
        src1sel_out = 3'b100;
        bubble1 = 1'b0;
        sw_p1_sel = 2'b00;
    end
end
end


////////////////////
// Decoding Logic //
////////////////////
always@(*) begin
// Default values
addz = 1'b0;            // Signals muxing of write-enable with zero flag
//nonsat = 1'b0;          // Signals no saturation for address calculation
src1sel = 3'b000;       // Selects SRC1
src0sel = 3'b000;       // Selects SRC0
hlt = 1'b0;             // Signals HLT
re0 =1'b1;              // Read enable for SRC0
re1 = 1'b1;             // Read enable for SRC1
we = 1'b0;              // Register File write enable
shamt = instr[3:0];     // Shift Amount
p0_addr = 4'b0000;      // SRC0 register
p1_addr = 4'b0000;      // SRC1 register
dst_addr = instr[11:8]; // Destination register
funct   = 3'b0;         // ALU Function code
flag_en = 2'b00;        // Flag enables
dst_sel = 2'b00;        // Mem-stage data output selection
mem_re = 1'b0;          // Memory read enable
mem_we = 1'b0;          // Memory write enable
branch_code = 4'h0;     // Branch Condition code
jumpR = 1'b0;           // Signals Jump to register value

// Specify which controls are changed from default for each operation
case (instr[15:12])
    ADD: begin
        flag_en = 2'b11;
        we = 1'b1;
        p0_addr = instr[3:0];
        p1_addr = instr[7:4];
    end
    ADDz: begin
        addz = 1'b1;
        flag_en = 2'b11;
        we = 1'b1;
        p0_addr = instr[3:0];
        p1_addr = instr[7:4];
    end
    SUB: begin
        funct = 3'b001;
        flag_en = 2'b11;
        we = 1'b1;
        p0_addr = instr[3:0];
        p1_addr = instr[7:4];
    end
    AND: begin
        //nonsat = 1'b1;
        funct = 3'b010;
        flag_en = 2'b01;
        we = 1'b1;
        p0_addr = instr[3:0];
        p1_addr = instr[7:4];
    end
    NOR: begin
        //nonsat = 1'b1;
        funct = 3'b011;
        flag_en = 2'b01;
        we = 1'b1;
        p0_addr = instr[3:0];
        p1_addr = instr[7:4];
    end
    SLL: begin
        //nonsat = 1'b1;
        funct = 3'b100;
        flag_en = 2'b01;
        we = 1'b1;
        p0_addr = instr[3:0];
        p1_addr = instr[7:4];
    end
    SRL: begin
        //nonsat = 1'b1;
        funct = 3'b101;
        flag_en = 2'b01;
        we = 1'b1;
        p0_addr = instr[3:0];
        p1_addr = instr[7:4];
    end
    SRA: begin
        //nonsat = 1'b1;
        funct = 3'b110;
        flag_en = 2'b01;
        we = 1'b1;
        p0_addr = instr[3:0];
        p1_addr = instr[7:4];
    end
    LLB: begin
        //nonsat = 1'b1;
        src1sel = 3'b001;
        p0_addr = 4'b0000;
        we = 1'b1;
    end
    LHB: begin
        //nonsat = 1'b1;
        funct = 3'b111;
        src1sel = 3'b001;
        p0_addr = instr[11:8];
        we = 1'b1;
    end
    HLT: begin
        hlt = 1'b1;
    end
    LW: begin
        //nonsat = 1'b1;
        p0_addr = instr[7:4];
        src1sel = 3'b010;
        mem_re = 1;
        dst_sel = 2'b01;
        we = 1'b1;
    end
    SW: begin
        //nonsat = 1'b1;
        p0_addr = instr[7:4];
        p1_addr = instr[11:8];
        src1sel = 3'b010;
        mem_we = 1;
    end
    JAL: begin
        //nonsat = 1'b1;
        dst_addr = 4'b1111;
        src1sel = 3'b011;
        dst_sel = 2'b10;
        src0sel = 3'b010;
        branch_code = 4'b1111;
        we = 1'b1;
    end
    JR: begin
        //nonsat = 1'b1;
        jumpR = 1'b1;
        p1_addr = instr[7:4];
    end
    B: begin
        //nonsat = 1'b1;
        src1sel = 3'b011;
        src0sel = 3'b001;
        branch_code[3] = 1'b1;
        branch_code[2:0] = instr[11:9];
    end
endcase
end

// Forbid writing to Register 0
always@(dst_addr or we) begin
    we_out = |dst_addr ? we : 1'b0;
end

endmodule
