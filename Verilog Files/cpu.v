////////////////////////////////////////////////////////////////////////////////
// CPU module                                                                 //
// Andrew Gailey and Zach York                                                //
////////////////////////////////////////////////////////////////////////////////
module cpu(output reg hlt, input clk, input rst_n, output [15:0]pc);

// Intermediate wires and Control signals
wire[15:0] addr_plus, instr, dst, p0, p1, rd_data, ALU_out, src1, shift_src1, src0, ID_p1_out, EX_p1_out;
wire re0, re1, we, z, ov, mem_we, mem_re, pc_hlt, pc_hold, bubble, IF_set_nop, ID_set_nop, initial_hlt, 
     ID_hlt_forward, EX_hlt_forward, MEM_hlt_forward; //,nonsat;
wire [3:0] shamt, p0_addr, p1_addr, dst_addr, branch_code;
wire [2:0] funct, src1sel, src0sel;
wire [1:0] flag_en, flag_en_out, dst_sel, sw_p1_sel, ID_flag_en_out;
wire branch, jumpR, addz, addz_we, we_out, i_rdy, d_rdy;

// Flops
reg EX_we, ID_we, MEM_we, ID_mem_re, ID_mem_we, MEM_mem_re, IF_nop, ID_hlt, ID_addz, ID_jumpR, 
    EX_hlt, EX_mem_re, EX_mem_we, EX_sw_p1_sel, MEM_hlt, zr, neg, o; //, ID_nonsat;
reg [1:0] ID_flag_en, ID_dst_sel, EX_dst_sel, ID_sw_p1_sel;
reg [2:0] ID_src1sel, ID_src0sel, ID_funct;
reg [3:0] ID_shamt, MEM_dst_addr, ID_dst_addr, EX_dst_addr, ID_branch_code, EX_branch_code;
reg [15:0] IF_instr, IF_addr_plus, ID_instr, ID_addr_plus, MEM_dst, ID_p0, ID_p1, EX_addr_plus, EX_p1, EX_ALU_out;


//////////////////////
// Cache Controller //
//////////////////////

// Cache
CC Cache(instr, i_rdy, rd_data, d_rdy, clk, rst_n, pc, 1'b1, EX_ALU_out, EX_p1_out, EX_mem_re, EX_mem_we);


/////////////////////
//// Fetch Stage ////
/////////////////////

// Control signals
assign IF_set_nop = branch || jumpR || ID_jumpR || pc_hlt;
assign pc_hlt = EX_hlt || hlt;
assign pc_hold = initial_hlt || ID_hlt || bubble || ~i_rdy || ~d_rdy;

// PC
PC_sc PC(pc, addr_plus, pc_hlt, pc_hold, rst_n, clk, ALU_out, src1, branch, ID_jumpR);

// Fetch Flops
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin // Async Reset
        IF_addr_plus <= 16'h0000;
        IF_instr <= 16'h0000;
        IF_nop <= 1'b1;
    end
    else if (!i_rdy || !d_rdy) begin // Hold if caches not ready
        IF_addr_plus <= IF_addr_plus;
        IF_instr <= IF_instr;
        IF_nop <= IF_nop;
    end
    else if (IF_set_nop) begin // Insert NOP
        IF_addr_plus <= 16'h0000;
        IF_instr <= 16'h0000;
        IF_nop <= 1'b1;
    end
    else if (bubble) begin // Insert Bubble
        IF_addr_plus <= IF_addr_plus;
        IF_instr <= IF_instr;
        IF_nop <= IF_nop;
    end
    else begin // Latch next instruction
        IF_addr_plus <= addr_plus;
        IF_instr <= instr;
        IF_nop <= 1'b0;
    end
end


///////////////////////////////////
// Decode (and Writeback) Stages //
///////////////////////////////////

// Control signals
assign ID_set_nop = branch || bubble || ID_hlt || EX_hlt || hlt || IF_nop;

// Instruction Decode
ID decode(IF_instr, src1sel, initial_hlt, shamt, funct, p0_addr, re0, p1_addr, re1, dst_addr, we, 
          src0sel, flag_en, mem_re, mem_we, dst_sel, branch_code, jumpR, ID_dst_addr, ID_we, 
          EX_dst_addr, EX_we, ID_mem_re, EX_mem_re, bubble, addz, sw_p1_sel); //, nonsat);

// Register File
rf register(clk,p0_addr,p1_addr,p0,p1,re0,re1,EX_dst_addr,dst,EX_we,hlt);

// Decode Flops
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin // Async Reset
        ID_instr <= 16'h0000;
        ID_addr_plus <= 16'h0000;
        ID_hlt <= 1'b0;
        ID_src1sel <= 3'b000;
        ID_src0sel <= 3'b000;
        ID_shamt <= 4'b0000;
        ID_funct <= 3'b000;
        ID_dst_addr <= 4'b0000;
        ID_we <= 0;
        ID_flag_en <= 2'b00;
        ID_mem_re <= 1'b0;
        ID_mem_we <= 1'b0;
        ID_dst_sel <= 2'b00;
        ID_p0 <= 16'h0000;
        ID_p1 <= 16'h0000;
        ID_addz <= 1'b0;
        ID_jumpR <= 1'b0;
        ID_branch_code <= 4'b0000;
        //ID_nonsat <= 1'b0;
        ID_sw_p1_sel <= 2'b00;
    end
    else if (!i_rdy || !d_rdy) begin // Hold if caches not ready
        ID_instr <= ID_instr;
        ID_addr_plus <= ID_addr_plus;
        ID_hlt <= ID_hlt;
        ID_src1sel <= ID_src1sel;
        ID_src0sel <= ID_src0sel;
        ID_shamt <= ID_shamt;
        ID_funct <= ID_funct;
        ID_dst_addr <= ID_dst_addr;
        ID_we <= ID_we;
        ID_flag_en <= ID_flag_en;
        ID_mem_re <= ID_mem_re;
        ID_mem_we <= ID_mem_we;
        ID_dst_sel <= ID_dst_sel;
        ID_p0 <= ID_p0;
        ID_p1 <= ID_p1;
        ID_addz <= ID_addz;
        ID_jumpR <= ID_jumpR;
        ID_branch_code <= ID_branch_code;
        //ID_nonsat <= ID_nonsat;
        ID_sw_p1_sel <= ID_sw_p1_sel;
    end
    else if (ID_set_nop) begin // Insert NOP
        ID_instr <= 16'h0000;
        ID_addr_plus <= 16'h0000;
        ID_hlt <= 1'b0;
        ID_src1sel <= 3'b000;
        ID_src0sel <= 3'b000;
        ID_shamt <= 4'b0000;
        ID_funct <= 3'b000;
        ID_dst_addr <= 4'b0000;
        ID_we <= 0;
        ID_flag_en <= 2'b00;
        ID_mem_re <= 1'b0;
        ID_mem_we <= 1'b0;
        ID_dst_sel <= 2'b00;
        ID_p0 <= 16'h0000;
        ID_p1 <= 16'h0000;
        ID_addz <= 1'b0;
        ID_jumpR <= 1'b0;
        ID_branch_code <= 4'b0000;
        //ID_nonsat <= 1'b0;
        ID_sw_p1_sel <= 2'b00;
    end
    else begin // Latch next instruction
        ID_instr <= IF_instr;
        ID_addr_plus <= IF_addr_plus;
        ID_hlt <= initial_hlt;
        ID_src1sel <= src1sel;
        ID_src0sel <= src0sel;
        ID_shamt <= shamt;
        ID_funct <= funct;
        ID_dst_addr <= dst_addr;
        ID_we <= we;
        ID_flag_en <= flag_en;
        ID_mem_re <= mem_re;
        ID_mem_we <= mem_we;
        ID_dst_sel <= dst_sel;
        ID_p0 <= p0;
        ID_p1 <= p1;
        ID_addz <= addz;
        ID_jumpR <= jumpR;
        ID_branch_code <= branch_code;
        //ID_nonsat <= nonsat;
        ID_sw_p1_sel <= sw_p1_sel;
    end
end


///////////////////
// Execute Stage //
///////////////////

// Control signals
assign addz_we = ID_addz ? zr : ID_we;
assign ID_p1_out = ID_sw_p1_sel[0] ? MEM_dst : ID_p1;

// Source Muxes
SRC1_MUX choose(src1, shift_src1, ID_instr[7:0], ID_p1, EX_ALU_out, MEM_dst, ID_src1sel, ID_addr_plus);
SRC0_MUX choose0(src0, ID_instr[11:0], ID_p0, EX_ALU_out, MEM_dst, ID_src0sel);

// ALU
ALU execution(ALU_out, ov, z, ID_shamt, ID_funct, src1, shift_src1, src0); //, ID_nonsat);

// Branch Control (Branches are resolved in this stage)
branch_control bc(branch, neg, o, zr, ID_branch_code);

// Flag Flops; Each has Async Reset and only latches if enabled, no branch is taken, and caches are ready
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) neg <= 1'b0;
    else if(ID_flag_en[1] && !branch && i_rdy && d_rdy) neg <= ALU_out[15];
    else neg <= neg;
end
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) zr <= 1'b0;
    else if(ID_flag_en[0] && !branch && i_rdy && d_rdy) zr <= z;
    else zr <= zr;
end 
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) o <= 1'b0;
    else if(ID_flag_en[1] && !branch && i_rdy && d_rdy) o <= ov;
    else o <= o;
end

// Execute Flops
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin // Async Reset
        EX_addr_plus <= 16'h0000;
        EX_hlt <= 1'b0;
        EX_dst_addr <= 4'b0000;
        EX_we <= 0;
        EX_mem_re <= 1'b0;
        EX_mem_we <= 1'b0;
        EX_dst_sel <= 2'b00;
        EX_p1 <= 16'h0000;
        EX_ALU_out <= 16'h0000;
        EX_branch_code <= 4'b0000;
        EX_sw_p1_sel <= 1'b0;
    end
    else if (!i_rdy || !d_rdy) begin // Hold if caches are not ready
        EX_addr_plus <= EX_addr_plus;
        EX_hlt <= EX_hlt;
        EX_dst_addr <= EX_dst_addr;
        EX_we <= EX_we;
        EX_mem_re <= EX_mem_re;
        EX_mem_we <= EX_mem_we;
        EX_dst_sel <= EX_dst_sel;
        EX_p1 <= EX_p1;
        EX_ALU_out <= EX_ALU_out;
        EX_branch_code <= EX_branch_code;
        EX_sw_p1_sel <= EX_sw_p1_sel;
    end
    else begin // Latch next instruction
        EX_addr_plus <= ID_addr_plus;
        EX_hlt <= ID_hlt;
        EX_dst_addr <= ID_dst_addr;
        EX_we <= addz_we;
        EX_mem_re <= ID_mem_re;
        EX_mem_we <= ID_mem_we;
        EX_dst_sel <= ID_dst_sel;
        EX_p1 <= ID_p1_out;
        EX_ALU_out <= ALU_out;
        EX_branch_code <= ID_branch_code;
        EX_sw_p1_sel <= ID_sw_p1_sel[1];
    end
end


//////////////////
// Memory Stage //
//////////////////

// Control Signals
assign EX_p1_out = EX_sw_p1_sel ? MEM_dst : EX_p1;

// Writeback Data Mux
assign dst = EX_dst_sel[1] ? (EX_dst_sel[0] ? rd_data 
                                            : EX_addr_plus) 
                           : (EX_dst_sel[0] ? rd_data 
                                            : EX_ALU_out);

// Memory Flops
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin // Async Reset
        MEM_hlt <= 1'b0;
        MEM_dst_addr <= 4'b0000;
        MEM_we <= 0;
        MEM_dst <= 16'h0000;
    end
    else if (!i_rdy || !d_rdy) begin // Hold if caches are not ready
        MEM_hlt <= MEM_hlt;
        MEM_dst_addr <= MEM_dst_addr;
        MEM_we <= MEM_we;
        MEM_dst <= MEM_dst;
    end
    else begin // Latch next instruction
        MEM_hlt <= EX_hlt;
        MEM_dst_addr <= EX_dst_addr;
        MEM_we <= EX_we;
        MEM_dst <= dst;
    end
end


/////////////////////
// Halt Forwarding //
/////////////////////

// Outbound halt signal; only set on clock low (so decode outputs and addz_we have time to settle)
always@(*) begin
    if(~clk) hlt = MEM_hlt || ID_hlt_forward || EX_hlt_forward || MEM_hlt_forward;
end

// Forwarding from ID
assign ID_hlt_forward = initial_hlt && !MEM_we && !EX_we && !addz_we && !EX_mem_we && !ID_mem_we && !branch && !ID_jumpR;

// Forwarding from EX
assign EX_hlt_forward = ID_hlt && !MEM_we && !EX_we && !EX_mem_we;

// Forwarding from MEM
assign MEM_hlt_forward = EX_hlt && !MEM_we;

endmodule 
