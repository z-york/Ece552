// Andrew Gailey and Zach York
module cpu(output reg hlt, input clk, input rst_n, output [15:0]pc);

        reg zr, neg, o;                                 // Zero Flag Latch

        wire[15:0] addr_plus, instr, dst, p0, p1, rd_data, ALU_out, src1, src0;
        wire re0, re1, we, z, mem_we, mem_re, pc_hlt, bubble, IF_set_nop, initial_hlt;
        wire [3:0] shamt, p0_addr, p1_addr, dst_addr, branch_code;
        wire [2:0] funct, src1sel, src0sel;
        wire [1:0] flag_en, flag_en_out, dst_sel, ID_flag_en_out;
	wire branch, jumpR, addz, addz_we, we_out;
	// FLOP OUTPUTS //
	reg EX_we, ID_we, MEM_we, ID_mem_re, ID_mem_we, MEM_mem_re, ID_nop, IF_nop, ID_set_nop, ID_hlt, ID_addz, ID_jumpR,EX_hlt, EX_mem_re, EX_mem_we;
	reg [1:0] ID_flag_en, ID_dst_sel, EX_dst_sel;
	reg [2:0] ID_src1sel, ID_src0sel, ID_funct;
	reg [3:0] ID_shamt, MEM_dst_addr, ID_dst_addr, EX_dst_addr, ID_branch_code, EX_branch_code;
	reg [15:0] IF_instr, IF_addr_plus, ID_instr, ID_addr_plus, MEM_dst, ID_p0, ID_p1, EX_addr_plus, EX_p1, EX_ALU_out;

	assign flag_en_out = {2{!IF_nop}} & flag_en;
	assign ID_flag_en_out = {2{!ID_nop}} & ID_flag_en;
	assign we_out = {!IF_nop} & we;

        // Instantiate each piece according to specifications
        //// FETCH ////
        assign IF_set_nop = branch || jumpR || ID_jumpR;
	assign pc_hlt = initial_hlt || ID_hlt || EX_hlt || hlt || bubble;
        PC_sc PC(pc, addr_plus, pc_hlt, rst_n, clk, EX_ALU_out, src1, branch, ID_jumpR);
        IM Mem(clk, pc, 1'b1,instr);
	// FETCH FLOPS
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			IF_addr_plus <= 16'h0000;
			IF_instr <= 16'h0000;
			IF_nop <= 1'b1;
		end
		else if (IF_set_nop) begin
			IF_addr_plus <= 16'h0000;
			IF_instr <= 16'h0000;
			IF_nop <= 1'b1;
		end
		else if (bubble) begin
			IF_addr_plus <= IF_addr_plus;
			IF_instr <= IF_instr;
			IF_nop <= IF_nop;
		end
		else begin
			IF_addr_plus <= addr_plus;
			IF_instr <= instr;
			IF_nop <= 1'b0;
		end
	end

        //// END FETCH////
	////
        //// DECODE (and WRITEBACK) ////
        ID decode(IF_instr, zr, src1sel, initial_hlt, shamt, funct, p0_addr, re0, p1_addr, re1, dst_addr, we, src0sel, flag_en, mem_re, mem_we, dst_sel, neg, o, branch_code, jumpR, ID_dst_addr, ID_we, EX_dst_addr, EX_we, ID_mem_re, EX_mem_re, bubble, addz);
        rf register(clk,p0_addr,p1_addr,p0,p1,re0,re1,EX_dst_addr,dst,EX_we,hlt);
	// DECODE FLOPS
	always@(branch) begin
		ID_set_nop = branch;
	end
	always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
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
			ID_nop <= 1'b1;
		end
		else if (ID_set_nop) begin
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
			ID_nop <= 1'b1;
		end
		else begin
			ID_instr <= IF_instr;
			ID_addr_plus <= IF_addr_plus;
			ID_hlt <= initial_hlt;
			ID_src1sel <= src1sel;
			ID_src0sel <= src0sel;
			ID_shamt <= shamt;
			ID_funct <= funct;
			ID_dst_addr <= dst_addr;
			ID_we <= we_out;
			ID_flag_en <= flag_en_out;
			ID_mem_re <= mem_re;
			ID_mem_we <= mem_we;
			ID_dst_sel <= dst_sel;
			ID_p0 <= p0;
			ID_p1 <= p1;
			ID_addz <= addz;
			ID_jumpR <= jumpR;
			ID_branch_code <= branch_code;
			ID_nop <= 1'b0;
		end
	end
	//// END DECODE ////

        //// EXECUTE ////
        SRC1_MUX choose(src1, ID_instr[7:0], ID_p1, EX_ALU_out, MEM_dst, ID_src1sel, ID_addr_plus);
        SRC0_MUX choose0(src0, ID_instr[11:0], ID_p0, EX_ALU_out, MEM_dst, ID_src0sel);
        ALU execution(ALU_out, ov, z, ID_shamt, ID_funct, src1, src0);
	// EXECUTE FLOPS
	// flags
	always@(posedge clk or negedge rst_n) begin
                if(!rst_n) neg <= 1'b0;
                else if(ID_flag_en_out[1]) neg <= ALU_out[15];
                else neg <= neg;
        end

        always@(posedge clk or negedge rst_n) begin
                if(!rst_n) zr <= 1'b0;
                else if(ID_flag_en_out[0]) zr <= z;
                else zr <= zr;
        end 

        always@(posedge clk or negedge rst_n) begin
                if(!rst_n) o <= 1'b0;
                else if(ID_flag_en_out[1]) o <= ov;
                else o <= o;
        end
	// The rest
	assign addz_we = ID_addz ? zr : ID_we;
        always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
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
		end
		else if (branch) begin
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
		end
		else begin
			EX_addr_plus <= ID_addr_plus;
			EX_hlt <= ID_hlt;
			EX_dst_addr <= ID_dst_addr;
			EX_we <= addz_we;
			EX_mem_re <= ID_mem_re;
			EX_mem_we <= ID_mem_we;
			EX_dst_sel <= ID_dst_sel;
			EX_p1 <= src1;
			EX_ALU_out <= ALU_out;
			EX_branch_code <= ID_branch_code;
		end
	end

        //// MEM ////
        DM mem(clk, EX_ALU_out, EX_mem_re, EX_mem_we, EX_p1, rd_data);
        DST_MUX destination(dst, EX_ALU_out, rd_data, EX_addr_plus, EX_dst_sel);
        // MEM FLOPS
        always@(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			hlt <= 1'b0;
			MEM_dst_addr <= 4'b0000;
			MEM_we <= 0;
			MEM_dst <= 16'h0000;
		end
		else begin
			hlt <= EX_hlt;
			MEM_dst_addr <= EX_dst_addr;
			MEM_we <= EX_we;
			MEM_dst <= dst;
		end
	end
        
	// Branch Control
        branch_control bc(branch, neg, o, zr, EX_branch_code);
endmodule 
