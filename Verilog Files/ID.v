// Andrew Gailey and Zach York
module ID(instr, zr, src1sel_out, hlt, shamt, funct, p0_addr, re0, p1_addr, re1, dst_addr, we, src0sel_out, flag_en, mem_re, mem_we, dst_sel, neg, ov, branch_code, jumpR, ID_dst, ID_we, EX_dst, EX_we, ID_mem_re, EX_mem_re, bubble, addz, sw_p1_sel);
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

        input[15:0] instr;
	input [3:0] ID_dst, EX_dst;
        input zr, neg, ov, ID_we, EX_we, ID_mem_re, EX_mem_re;
        output reg hlt, re0, re1, we, mem_re, mem_we, jumpR, addz;    // Controls
        output reg [3:0] shamt, p0_addr, p1_addr, dst_addr,     // Shamt and reg addresses
                         branch_code;
        output reg [2:0] funct, src1sel_out, src0sel_out;       // Function bits for ALU
        output reg [1:0] flag_en, dst_sel, sw_p1_sel;
	output bubble;
	reg [2:0] src0sel, src1sel;
	reg bubble0, bubble1;

        // Forwarding Logic
	assign bubble = bubble0 || bubble1;
	always@(*) begin
	//bubble = bubble0 || bubble1;
	if ((p0_addr != 4'b0000) && (p0_addr == ID_dst) && ID_we) begin
		if (ID_mem_re) begin
			bubble0 = 1'b1;
			src0sel_out = 3'b000;
		end
		else begin
			src0sel_out = 3'b111;
			bubble0 = 1'b0;
		end
	end
        else if ((p0_addr != 4'b0000) && (p0_addr == EX_dst) && EX_we) begin
		src0sel_out = 3'b100;
		bubble0 = 1'b0;
	end
	else begin
		src0sel_out = src0sel;
		bubble0 = 1'b0;
	end

	if ((p1_addr != 4'b0000) && (p1_addr == ID_dst) && ID_we) begin
		if (instr[15:12] == SW) begin
			src1sel_out = src1sel;
			bubble1 = 1'b0;
			sw_p1_sel = 2'b10;
		end
		else if (ID_mem_re) begin
			bubble1 = 1'b1;
			src1sel_out = 3'b000;
			sw_p1_sel = 2'b00;
		end
		else begin
			src1sel_out = 3'b111;
			bubble1 = 1'b0;
			sw_p1_sel = 2'b00;
		end
	end
        else if ((p1_addr != 4'b0000) && (p1_addr == EX_dst) && EX_we) begin
		if (instr[15:12] == SW) begin
			src1sel_out = src1sel;
			bubble1 = 1'b0;
			sw_p1_sel = 2'b01;
		end
		else begin
			src1sel_out = 3'b100;
			bubble1 = 1'b0;
			sw_p1_sel = 2'b00;
		end
	end
	else begin
		src1sel_out = src1sel;
		bubble1 = 1'b0;
		sw_p1_sel = 2'b00;
        end
	end
        
        always@(*) begin
        // Default values
	addz = 1'b0;
        src1sel = 3'b000;
        src0sel = 3'b000;
        hlt = 1'b0;
        re0 =1'b1;
        re1     = 1'b1;
        we = 1'b0;
        shamt = instr[3:0];
	p0_addr = 4'b0000;
	p1_addr = 4'b0000;
        dst_addr        = instr[11:8];
        funct   = 3'b0;
        flag_en = 2'b00;
        dst_sel = 2'b00;
        mem_re = 1'b0;
        mem_we = 1'b0;
	branch_code = 4'h0;
        jumpR = 1'b0;
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
                        funct = 3'b010;
                        flag_en = 2'b01;
        		we = 1'b1;
        		p0_addr = instr[3:0];
        		p1_addr = instr[7:4];
                end
                NOR: begin
                        funct = 3'b011;
                        flag_en = 2'b01;
        		we = 1'b1;
        		p0_addr = instr[3:0];
        		p1_addr = instr[7:4];
                end
                SLL: begin
                        funct = 3'b100;
                        flag_en = 2'b01;
        		we = 1'b1;
        		p0_addr = instr[3:0];
        		p1_addr = instr[7:4];
                end
                SRL: begin
                        funct = 3'b101;
                        flag_en = 2'b01;
        		we = 1'b1;
        		p0_addr = instr[3:0];
        		p1_addr = instr[7:4];
                end
                SRA: begin
                        funct = 3'b110;
                        flag_en = 2'b01;
        		we = 1'b1;
        		p0_addr = instr[3:0];
        		p1_addr = instr[7:4];
                end
                LLB: begin
                        src1sel = 3'b001;
                        p0_addr = 4'b0000;
        		we = 1'b1;
                end
                LHB: begin
                        funct = 3'b111;
                        src1sel = 3'b001;
                        p0_addr = instr[11:8];
        		we = 1'b1;
                end
                HLT: begin
                        hlt = 1'b1;
                end
                LW: begin
                        p0_addr = instr[7:4];
                        src1sel = 3'b010;
                        mem_re = 1;
                        dst_sel = 2'b01;
        		we = 1'b1;
                end
                SW: begin
                        p0_addr = instr[7:4];
                        p1_addr = instr[11:8];
                        src1sel = 3'b010;
                        mem_we = 1;
                end
                JAL: begin
                        dst_addr = 4'b1111;
                        src1sel = 3'b011;
                        dst_sel = 2'b10;
                        src0sel = 3'b010;
                        branch_code = 4'b1111;
        		we = 1'b1;
                end
                JR: begin
                        jumpR = 1'b1;
        		p1_addr = instr[7:4];
                end
                B: begin
                        src1sel = 3'b011;
                        src0sel = 3'b001;
			branch_code[3] = 1'b1;
                        branch_code[2:0] = instr[11:9];
                end
                default: begin
                end
endcase
end
endmodule
