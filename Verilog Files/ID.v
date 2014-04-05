// Andrew Gailey and Zach York
module ID(instr, zr, src1sel, hlt, shamt, funct, p0_addr, re0, p1_addr, re1, dst_addr, we, src0sel, flag_en, mem_re, mem_we, dst_sel, neg, ov, PC_sel);
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

        input[15:0] instr;                                      // Instruction
        input zr, neg, ov;                                      // Zero flag
        output reg hlt, re0, re1, we, mem_re, mem_we, PC_sel;   // Controls
        output reg [3:0] shamt, p0_addr, p1_addr, dst_addr;     // Shamt and reg addresses
        output reg [2:0] funct;                                 // Function bits for ALU
        
        output reg [1:0] src1sel, src0sel, flag_en, dst_sel;

        
        always@(*) begin
        // Default values
        PC_sel = 0;
        src1sel = 2'b00;
        src0sel = 2'b00;
        hlt = 0;
        re0 =1;
        re1     = 1;
        we = 1;
        shamt = instr[3:0];
        p0_addr = instr[3:0];
        p1_addr = instr[7:4];
        dst_addr        = instr[11:8];
        funct   = 3'b0;
        flag_en = 2'b00;
        dst_sel = 2'b00;
        mem_re = 0;
        mem_we = 0;
        // Specify which controls are changed from default for each operation
        case (instr[15:12])
                ADD: flag_en = 2'b11;
                ADDz: begin
                        we = zr;
                        flag_en = 2'b11;
                end
                SUB: begin
                        funct = 3'b001;
                        flag_en = 2'b11;
                end
                AND: begin
                        funct = 3'b010;
                        flag_en = 2'b01;
                end
                NOR: begin
                        funct = 3'b011;
                        flag_en = 2'b01;
                end
                SLL: begin
                        funct = 3'b100;
                        flag_en = 2'b01;
                end
                SRL: begin
                        funct = 3'b101;
                        flag_en = 2'b01;
                end
                SRA: begin
                        funct = 3'b110;
                        flag_en = 2'b01;
                end
                LLB: begin
                        src1sel = 2'b10;
                        p0_addr = 4'b0000;
                end
                LHB: begin
                        funct = 3'b111;
                        src1sel = 2'b10;
                        p0_addr = instr[11:8];
                end
                HLT: begin
                        we = 0;
                        hlt = 1'b1;
                end
                LW: begin
                        p0_addr = instr[7:4];
                        src1sel = 2'b01;
                        mem_re = 1;
                        dst_sel = 2'b01;
                end
                SW: begin
                        p0_addr = instr[7:4];
                        p1_addr = instr[11:8];
                        we = 0;
                        src1sel = 2'b01;
                        mem_we = 1;
                end
                JAL: begin
                        dst_addr = 4'b1111;
                        src1sel = 2'b11;
                        dst_sel = 2'b10;
                        src0sel = 2'b10;
                        PC_sel = 1;
                end
                JR: begin
                        we = 0;
                        PC_sel = 1;
                end
                B: begin
                        we = 0;
                        src1sel = 2'b11;
                        src0sel = 2'b01;
                        case(instr[11:9])
                                Bneq:   if (!zr) PC_sel = 1'b1;
                                Beq: if (zr) PC_sel = 1'b1;
                                Bgt: if (!zr && !neg) PC_sel = 1'b1;
                                Blt: if (neg) PC_sel = 1'b1;
                                Bgte: if (zr || !neg) PC_sel = 1'b1;
                                Blte: if (zr || neg) PC_sel = 1'b1;
                                Bov: if (ov) PC_sel = 1'b1;
                                Bun: PC_sel = 1'b1;
                                default: PC_sel = 1'b0;
                        endcase
                end
                default: begin
                end
endcase
end
endmodule
