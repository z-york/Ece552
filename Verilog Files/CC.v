// Andrew Gailey and Zach York
module CC(output [15:0]instr, output i_rdy_out, output [15:0]rd_data, output d_rdy, input clk, input rst_n, input [15:0]i_addr, input i_en, input [15:0]d_addr, input [15:0]wrt_data, input re, input we);

wire i_rdy, m_rdy, i_dirty;
wire [13:0] m_addr;
wire [63:0] i_rd_data, m_rd_data, m_wrt_data, i_rd_data_muxed;
wire [7:0] i_tag;

reg m_re, m_we, i_we, i_rdy_forward, m_addr_sel;
reg [2:0] state, next_state;

// States
localparam IDLE = 3'b000;
localparam IFILL = 3'b001;

// State Flow
always@(posedge clk, negedge rst_n) begin
    if(!rst_n) state <= IDLE;
    else state <= next_state;
end

////////////////////////
//////// Icache ////////
////////////////////////
assign i_rdy_out = i_rdy_forward || i_rdy;
cache Icache(clk, rst_n, i_addr[15:2], m_rd_data, 1'b0, i_we, 1'b1, i_rd_data, i_tag, i_rdy, i_dirty);

// Output Word Selection (using 2 MSBs in the preserved address). Forward from mem-reads to save 1 cycle per cache fill.
assign i_rd_data_muxed = i_rdy_forward ? m_rd_data
                                       : i_rd_data;
assign instr = i_addr[1] ? (i_addr[0] ? i_rd_data_muxed[63:48]   // 11
                                      : i_rd_data_muxed[47:32])  // 10
                         : (i_addr[0] ? i_rd_data_muxed[31:16]   // 01
                                      : i_rd_data_muxed[15:0]);  // 00

////////////////////////
//////// Dcache ////////
////////////////////////


///////////////////////
//////// U-MEM ////////
///////////////////////
unified_mem Umem(clk, rst_n, m_addr, m_re, m_we, m_wrt_data, m_rd_data, m_rdy);

// Input Selection
assign m_addr = m_addr_sel ? d_addr[15:2]
                           : i_addr[15:2];

///////////////////////////////
//////// State Machine ////////
///////////////////////////////
always@(*) begin
    // Defaults
    next_state = IDLE;
    m_addr_sel = 1'b0;
    m_re = 1'b0;
    m_we = 1'b0;
    i_we = 1'b0;
    i_rdy_forward = 1'b0;

    case (state)
        IDLE: begin
            if(!i_rdy) begin
                next_state = IFILL;
                m_re = 1'b1;
            end
        end
        IFILL: begin
            i_we = m_rdy;
            i_rdy_forward = m_rdy;
            if(!m_rdy) next_state = IFILL;
            else next_state = IDLE;
        end
        default: next_state = IDLE;
    endcase
end


endmodule
