// Andrew Gailey and Zach York
module CC(output [15:0]instr, output i_rdy_out, output [15:0]d_rd_data_out, output d_rdy_out, input clk, input rst_n, input [15:0]i_addr, input i_en, input [15:0]d_addr, input [15:0]wrt_data, input d_re_in, input d_we_in);

wire i_rdy, m_rdy, i_dirty, d_dirty, d_rdy;
wire [13:0] m_addr, d_addr_muxed;
wire [63:0] i_rd_data, m_rd_data, d_rd_data, i_rd_data_muxed, d_w_data_muxed, d_rd_data_muxed, d_w_data_premux;
wire [7:0] i_tag, d_tag;

reg m_re, m_we, i_we, i_rdy_forward, m_addr_sel, d_rdy_forward, d_re, d_we, d_w_dirty;
reg [2:0] state, next_state;

// States
localparam IDLE = 3'b000;
localparam IFILL = 3'b001;
localparam EVICT = 3'b010;
localparam WFILL = 3'b011;
localparam RFILL = 3'b110;

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

// Output Word Selection. Forward from mem-reads to save 1 cycle per cache fill.
assign i_rd_data_muxed = i_rdy_forward ? m_rd_data
                                       : i_rd_data;
assign instr = i_addr[1] ? (i_addr[0] ? i_rd_data_muxed[63:48]   // 11
                                      : i_rd_data_muxed[47:32])  // 10
                         : (i_addr[0] ? i_rd_data_muxed[31:16]   // 01
                                      : i_rd_data_muxed[15:0]);  // 00

////////////////////////
//////// Dcache ////////
////////////////////////
assign d_rdy_out = d_rdy_forward || d_rdy || (~d_re_in && ~d_we_in);
cache Dcache(clk, rst_n, d_addr[15:2], d_w_data_muxed, d_w_dirty, d_we, d_re, d_rd_data, d_tag, d_rdy, d_dirty);
// Input Word Selection. Write data is muxed into either the previous line or the currently filling line.
//      or if we're only doing a read fill then no muxing is needed.
assign d_w_data_premux = d_rdy ? d_rd_data
                               : m_rd_data;
assign d_w_data_muxed = d_re_in ? m_rd_data
                                : (d_addr[1] ? (d_addr[0] ? {wrt_data,               d_w_data_premux[47:32],
                                                             d_w_data_premux[31:16], d_w_data_premux[15:0]}   // 11
                                                          : {d_w_data_premux[63:48], wrt_data,
                                                             d_w_data_premux[31:16], d_w_data_premux[15:0]})  // 10
                                             : (d_addr[0] ? {d_w_data_premux[63:48], d_w_data_premux[47:32],
                                                             wrt_data,               d_w_data_premux[15:0]}   // 01
                                                          : {d_w_data_premux[63:48], d_w_data_premux[47:32],
                                                             d_w_data_premux[31:16], wrt_data             }));// 00

// Output Word Selection. Forward from mem-reads to save 1 cycle per cache fill.
assign d_rd_data_muxed = d_rdy_forward ? m_rd_data
                                       : d_rd_data;
assign d_rd_data_out = d_addr[1] ? (d_addr[0] ? d_rd_data_muxed[63:48]   // 11
                                              : d_rd_data_muxed[47:32])  // 10
                                 : (d_addr[0] ? d_rd_data_muxed[31:16]   // 01
                                              : d_rd_data_muxed[15:0]);  // 00

///////////////////////
//////// U-MEM ////////
///////////////////////
unified_mem Umem(clk, rst_n, m_addr, m_re, m_we, d_rd_data, m_rd_data, m_rdy);

// Input Selection
assign d_addr_muxed = m_re ? d_addr[15:2]
                           : {d_tag, d_addr[7:2]};
assign m_addr = m_addr_sel ? d_addr_muxed
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
    d_re = d_re_in || d_we_in;
    d_we = 1'b0;
    d_w_dirty = 1'b0;
    d_rdy_forward = 1'b0;

    case (state)
        IDLE: begin
            d_we = d_we_in && d_rdy && i_rdy_out;
            d_w_dirty = d_we;
            if(!i_rdy) begin
                next_state = IFILL;
                m_re = 1'b1;
            end
            else if(!d_rdy) begin
                if(d_we_in) begin
                    if(d_dirty) begin
                        next_state = EVICT;
                        m_we = 1'b1;
                        m_addr_sel = 1'b1;
                    end
                    else begin
                        next_state = WFILL;
                        m_re = 1'b1;
                        m_addr_sel = 1'b1;
                    end
                end
                else if(d_re_in) begin
                    if(d_dirty) begin
                        next_state = EVICT;
                        m_we = 1'b1;
                        m_addr_sel = 1'b1;
                    end
                    else begin

                    end
                end
            end
        end
        IFILL: begin
            i_we = m_rdy;
            i_rdy_forward = m_rdy;
            d_we = d_we_in && d_rdy && i_rdy_out;
            d_w_dirty = d_we;
            if(!m_rdy) next_state = IFILL;
            else next_state = IDLE;
        end
        EVICT: begin
            if(!m_rdy) next_state = EVICT;
            else if(d_we_in) next_state = WFILL;
            else next_state = RFILL;
        end
        WFILL: begin
            m_re = 1'b1;
            m_addr_sel = 1'b1;
            d_we = m_rdy;
            d_rdy_forward = m_rdy;
            if(!m_rdy) next_state = WFILL;
            else next_state = IDLE;
        end
        RFILL: begin
            m_re = 1'b1;
            m_addr_sel = 1'b1;
            d_we = m_rdy;
            d_rdy_forward = m_rdy;
            if(!m_rdy) next_state = RFILL;
            else next_state = IDLE;
        end
        default: next_state = IDLE;
    endcase
end


endmodule
