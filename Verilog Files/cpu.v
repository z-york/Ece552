// Andrew Gailey and Zach York
module cpu(output hlt, input clk, input rst_n, output [15:0]pc);

        reg zr, neg, o;                                 // Zero Flag Latch
        wire[15:0]      addr_plus, pc,                  // PC address
                        instr,                          // Instruction
                        dst, p0, p1,                    // Register Data
                        rd_data, ALU_out,
                        src1, src0;                     // SRC_MUX Output
        wire re0, re1, we, z, mem_we, mem_re, PC_sel;   // Controls and zero flag
        wire [3:0] shamt, p0_addr, p1_addr, dst_addr;   // Shamt and reg addresses
        wire [2:0] funct;                               // Function bits for ALU
        wire [1:0] src1sel, src0sel, flag_en, dst_sel;
        
        // Instantiate each piece according to specifications
        //// FETCH ////
        PC_sc PC(pc, addr_plus, hlt, rst_n, clk, ALU_out, PC_sel);
        IM Mem(clk, pc, 1'b1,instr);

        //// DECODE (and WRITEBACK) ////
        ID decode(instr, zr, src1sel, hlt, shamt, funct, p0_addr, re0, p1_addr, re1, dst_addr, we, src0sel, flag_en, mem_re, mem_we, dst_sel, neg, o, PC_sel);
        rf register(clk,p0_addr,p1_addr,p0,p1,re0,re1,dst_addr,dst,we,hlt);

        //// EXECUTE ////
        SRC1_MUX choose(src1, instr[7:0], p1, src1sel, addr_plus);
        SRC0_MUX choose0(src0, instr[11:0], p0, src0sel);
        ALU execution(ALU_out, ov, z, shamt, funct, src1, src0);
        DST_MUX destination(dst, ALU_out, rd_data, addr_plus, dst_sel);

        //// MEM ////
        DM mem(clk, ALU_out, mem_re, mem_we, p1, rd_data);
        
        // These latches will be incorporated into the pipeline execute latch block
        always@(posedge clk) begin
                if(!rst_n) neg <= 1'b0;
                else if(flag_en[1]) neg <= ALU_out[15];
                else neg <= neg;
        end

        always@(posedge clk) begin
                if(!rst_n) zr <= 1'b0;
                else if(flag_en[0]) zr <= z;
                else zr <= zr;
        end 

        always@(posedge clk) begin
                if(!rst_n) o <= 1'b0;
                else if(flag_en[1]) o <= ov;
                else o <= o;
        end
        
endmodule 