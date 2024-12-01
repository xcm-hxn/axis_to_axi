`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/27 11:50:29
// Design Name: 
// Module Name: axi_stream_to_axi
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module axi_stream_to_axi #(
    parameter int unsigned AXI_DATA_WIDTH  = 'd32,
    parameter int unsigned AXI_ADDR_WIDTH  = 'd32,
    parameter int unsigned AXIS_DATA_WIDTH = 'd64,
    parameter int unsigned AXIS_KEEP_WITDH = 'd8,
    parameter int unsigned AXIS_ID_WIDTH   = 'd0,
    parameter int unsigned AXIS_DEST_WIDTH = 'd0,
    parameter int unsigned AXIS_USER_WIDTH = 'd0,

    parameter KEEP_ENABLE = (AXI_DATA_WIDTH > 8),
    parameter ID_ENABLE   = 0,
    parameter DEST_ENABLE = 0,
    parameter USER_ENABLE = 0
)(
    input logic axi_aclk,
    input logic axi_aresetn,

    //AXIS_SLAVE
    axi_stream.Slave    s_axis_in,
    //AXIS_MASTER
    axi_stream.Master   m_axis_out,
    //AXI_MASTER
    axi_bus.Master      m_axi_out
    
);
    //internal datapath
    typedef struct packed {
        logic [AXIS_DATA_WIDTH-1:0] tdata_int;
        logic [AXIS_KEEP_WITDH-1:0] tkeep_int;
        logic                       tvalid_int;
        logic                       tread_int_reg;
        logic                       tlast_int;
        logic [AXIS_ID_WIDTH-1:0]   tid_int;
        logic [AXIS_DEST_WIDTH-1:0] tdest_int;
        logic [AXIS_USER_WIDTH-1:0] tuser_int;
        logic                       tread_int_early;
    } m_axis;

    m_axis m_axis_t;

    //datapath control signals
    typedef struct packed {
        logic                       last_word;
        logic [AXIS_ID_WIDTH-1:0]   last_word_id_reg;
        logic [AXIS_DEST_WIDTH-1:0] last_wrod_dest_reg;
        logic [AXIS_USER_WIDTH-1:0] last_word_user_reg;
    } store;

    store store_t; 

    //payload fpga-to-zynq
    typedef struct packed {
        logic [127:0] pkg_head;
        logic [7:0]   htd_code;
        logic [7:0]   fpga_id;
        logic [7:0]   reserved_0;
        logic [31:0]  pkt_type_id;
        logic [31:0]  reserved_1;
        logic [31:0]  pkt_len;
        logic [127:0] pkg_waddress;
        logic [127:0] pkg_raddress;
        logic [127:0] pkg_wdata;
        logic [127:0] pkg_rdata;
    } payload;

    payload payload_t;

    typedef enum bit [1:0]  {
        FSM_IDLE,
        FSM_TRANSFER,
        FSM_TRUNCATE,
        FSM_WAIT
    } FSM_STATE;

    FSM_STATE       fsm_curr, fsm_next;

    typedef enum logic [0:0] {
        frame_reg,
        frame_next
    } fram;

    fram      fram_t;

    //output data_path logic
    typedef struct packed {
        logic [AXIS_DATA_WIDTH-1:0] tdata_reg;
        logic [AXIS_KEEP_WITDH-1:0] tkeep_reg;
        logic                       tvalid_reg;
        logic                       tvalid_next;
        logic                       tlast_reg;
        logic [AXIS_ID_WIDTH-1:0]   tid_reg;
        logic [AXIS_DEST_WIDTH-1:0] tdest_reg;
        logic [AXIS_USER_WIDTH-1:0] tuser_reg;
    } m_axis_reg;

    m_axis_reg m_axis_reg_t;

    typedef struct packed {
        logic [AXIS_DATA_WIDTH-1:0] temp_tdata_reg;
        logic [AXIS_KEEP_WITDH-1:0] temp_tkeep_reg;
        logic                       temp_tvalid_reg;
        logic                       temp_tvalid_next;
        logic                       temp_tlast_reg;
        logic [AXIS_ID_WIDTH-1:0]   temp_tid_reg;
        logic [AXIS_DEST_WIDTH-1:0] temp_tdest_reg;
        logic [AXIS_USER_WIDTH-1:0] temp_tuser_reg;
    } temp_m_axis_reg;

    temp_m_axis_reg temp_m_axis_reg_t;

    //datapath control
    typedef enum logic [0:0]{in_to_out, in_to_temp, temp_to_out  } store_axis;



    always_ff@(posedge axi_aclk or negedge  axi_aresetn) begin
        if(!axi_aresetn) begin 
            fsm_curr <= FSM_IDLE;
        end 
        else begin 
            fsm_curr <= fsm_next;
        end 
    end 

    always_comb begin
        fram_t.frame_reg  = 1'b0;
        fram_t.frame_next = 1'b0;

        store_t.store_last_word = 1'b0;
        
        s_axis_in.tready   = 1'b0;
        
        if(s_axis_in.tready && s_axis_in.tvalid) begin
            fram_t.frame_next = !s_axis_in.tlast;
        end 

        case (fsm_curr)
            FSM_IDLE: begin
                if(s_axis_in.tvalid) begin
                    //start of frame
                    if(m_axis_t.tread_int_reg) begin
                        s_axis_in.tready = 1'b1;
                        if(s_axis_in.tlast) begin
                            fsm_curr = FSM_IDLE;
                        end
                        else begin
                            fsm_curr = FSM_TRANSFER;
                        end
                    end
                    else begin
                        s_axis_in.tready = 1'b0;
                        fsm_curr = FSM_WAIT;
                    end 
                end
                else begin
                    s_axis_in.tready = 1'b0;
                    fsm_curr = FSM_IDLE;
                end 
            end
            FSM_TRANSFER: begin
                s_axis_in.tready = 1'b1;
                if(s_axis_in.tready && s_axis_in.tvalid) begin
                    //transfer data
                    if(m_axis_t.tread_int_reg) begin
                        if(s_axis_in.tlast) begin
                            fsm_curr = FSM_IDLE;
                        end 
                        else begin
                            fsm_curr = FSM_TRANSFER;
                        end 
                    end 
                    else begin
                        store_t.last_word = 1'b1;
                        fsm_curr = FSM_TRUNCATE;
                    end 
                end
                else begin
                    fsm_curr = FSM_TRUNCATE;
                end 
            end
            FSM_TRUNCATE: begin
                s_axis_in.tready = 1'b1;
                if(m_axis_t.tread_int_reg) begin
                    if(fram_t.frame_next) begin
                        fsm_curr = FSM_WAIT;
                    end 
                    else begin
                        fsm_curr = FSM_IDLE;
                    end 
                end
                else begin
                    fsm_curr = FSM_TRUNCATE;
                end 
            end 
            FSM_WAIT: begin
                s_axis_in.tready = 1'b0;
                if(s_axis_in.tready && s_axis_in.tvalid) begin
                    if(s_axis_in.tlast) begin
                        fsm_curr = FSM_IDLE;
                    end 
                    else begin
                        fsm_curr = FSM_WAIT;
                    end 
                end 
                else begin
                    fsm_curr = FSM_WAIT;
                end 
            end 
            default: begin
                s_axis_in.tready = 1'b0;
                fsm_curr = FSM_IDLE;
            end 
        endcase
    end 

    always_ff@(posedge axi_aclk or negedge axi_aresetn) begin
        if(!axi_aresetn) begin
            m_axis_t.tdata_int  <= {AXIS_DATA_WIDTH{1'b0}};
            m_axis_t.tkeep_int  <= {AXIS_KEEP_WITDH{1'b0}};
            m_axis_t.tvalid_int <= 1'b0;
            m_axis_t.tlast_int  <= 1'b0;
            m_axis_t.tid_int    <= {AXIS_ID_WIDTH{1'b0}};
            m_axis_t.tdest_int  <= {AXIS_DEST_WIDTH{1'b0}};
            m_axis_t.tuser_int  <= {AXIS_USER_WIDTH{1'b0}};
        end 
        else begin
            case (fsm_curr)
                FSM_IDLE: begin
                    if(s_axis_in.tready && s_axis_in.tvalid) begin
                        //start of frame
                        if(m_axis_t.tread_int_reg) begin
                            m_axis_t.tdata_int  <= s_axis_in.tdata;
                            m_axis_t.tkeep_int  <= s_axis_in.tkeep;
                            m_axis_t.tvalid_int <= s_axis_in.tvalid && s_axis_in.tready;
                            m_axis_t.tlast_int  <= s_axis_in.tlast;
                            m_axis_t.tid_int    <= s_axis_in.tid;
                            m_axis_t.tdest_int  <= s_axis_in.tdest;
                            m_axis_t.tuser_int  <= s_axis_in.tuser;
                        end 
                    end 
                end 
                FSM_TRANSFER: begin
                    if(s_axis_in.tready && s_axis_in.tvalid) begin
                        if(m_axis_t.tread_int_reg) begin
                            m_axis_t.tdata_int  <= s_axis_in.tdata;
                            m_axis_t.tkeep_int  <= s_axis_in.tkeep;
                            m_axis_t.tvalid_int <= s_axis_in.tvalid && s_axis_in.tready;
                            m_axis_t.tlast_int  <= s_axis_in.tlast;
                            m_axis_t.tid_int    <= s_axis_in.tid;
                            m_axis_t.tdest_int  <= s_axis_in.tdest;
                            m_axis_t.tuser_int  <= s_axis_in.tuser;
                        end 
                    end 
                end 
                FSM_TRUNCATE: begin
                    if(m_axis_t.tread_int_reg) begin
                        m_axis_t.tdata_int  <= {AXIS_DATA_WIDTH{1'b0}};
                        m_axis_t.tkeep_int  <= {{AXIS_KEEP_WITDH-1{1'b0}},1'b1};
                        m_axis_t.tvalid_int <= 1'b1;
                        m_axis_t.tlast_int  <= 1'b1;
                        m_axis_t.tid_int    <= strb_t.last_word_id_reg;
                        m_axis_t.tdest_int  <= strb_t.last_wrod_dest_reg;
                        m_axis_t.tuser_int  <= strb_t.last_word_user_reg;
                    end 
                end 
            endcase
        end 
    end 

    always_ff@(posedge axi_aclk) begin
        if(store_t.last_word) begin
            store_t.last_word_id_reg   <= s_axis_in.tid;
            store_t.last_wrod_dest_reg <= s_axis_in.tdest;
            store_t.last_word_user_reg <= s_axis_in.tuser;
        end 
    end 

    //datapath control
    always_comb begin
        m_axis_out.tdata  = m_axis_reg_t.tdata_reg;
        m_axis_out.tkeep  = KEEP_ENABLE ? m_axis_reg_t.tkeep_reg : {AXIS_KEEP_WITDH{1'b1}};
        m_axis_out.tvalid = m_axis_reg_t.tvalid_reg;
        m_axis_out.tlast  = m_axis_reg_t.tlast_reg;
        m_axis_out.tid    = ID_ENABLE ? m_axis_reg_t.tid_reg : {AXIS_ID_WIDTH{1'b0}};
        m_axis_out.tdest  = DEST_ENABLE ? m_axis_reg_t.tdest_reg : {AXIS_DEST_WIDTH{1'b0}};
        m_axis_out.tuser  = USER_ENABLE ? m_axis_reg_t.tuser_reg : {AXIS_USER_WIDTH{1'b0}};

        // enable ready input next cycle if output is ready or the temp reg will not be filled on the next cycle (output reg empty or no input)
        m_axis_t.tread_int_early = m_axis_out.tready || (!temp_m_axis_reg_t.temp_tvalid_reg && (!m_axis_reg_t.tvalid_reg || !m_axis_t.tvalid_int));
    end 

    always_comb begin
        //transfer sink ready state to source
        m_axis_reg_t.tvalid_next = m_axis_reg_t.tvalid_reg;
        temp_m_axis_reg_t.temp_tvalid_next = temp_m_axis_reg_t.temp_tvalid_next;

        store_t.in_to_out   = 1'b0;
        store_t.in_to_temp  = 1'b0;
        store_t.temp_to_out = 1'b0;

        if(m_axis_t.tread_int_reg) begin
            //input is ready
            if(m_axis_out.tready || !m_axis_reg_t.tvalid_reg) begin
                //output is ready or currently not valid, transfer data to output
                m_axis_reg_t.tvalid_next = m_axis_t.tvalid_int;
                store_t.in_to_out        = 1'b1;
            end 
            else begin
                //output is not ready, store input in temp
                temp_m_axis_reg_t.tvalid_next = m_axis_t.tvalid_int;
                store_t.in_to_temp            = 1'b1;
            end 
        end 
        else if(m_axi_out.tready) begin
            //input is not ready, but output is ready
            m_axis_reg_t.tvalid_next      = temp_m_axis_reg_t.tvalid_reg;
            temp_m_axis_reg_t.tvalid_next = 1'b0;
            store_t.temp_to_out           = 1'b1;
        end 
    end 

    always_ff@(posedge axi_aclk) begin
        //datapath
        if(store_t.in_to_out) begin
            m_axis_reg_t.tdata_reg <= m_axis_t.tdata_int;
            m_axis_reg_t.tkeep_reg <= m_axis_t.tkeep_int;
            m_axis_reg_t.tlast_reg <= m_axis_t.tlast_int;
            m_axis_reg_t.tid_reg   <= m_axis_t.tid_int;
            m_axis_reg_t.tdest_reg <= m_axis_t.tdest_int;
            m_axis_reg_t.tuser_reg <= m_axis_t.tuser_int;
        end 
        else if(store_t.temp_to_out) begin
            m_axis_reg_t.tdata_reg <= temp_m_axis_reg_t.tdata_reg;
            m_axis_reg_t.tkeep_reg <= temp_m_axis_reg_t.tkeep_reg;
            m_axis_reg_t.tlast_reg <= temp_m_axis_reg_t.tlast_reg;
            m_axis_reg_t.tid_reg   <= temp_m_axis_reg_t.tid_reg;
            m_axis_reg_t.tdest_reg <= temp_m_axis_reg_t.tdest_reg;
            m_axis_reg_t.tuser_reg <= temp_m_axis_reg_t.tuser_reg;
        end 

        if(store_t.in_to_temp) begin
            m_axis_reg_t.tdata_reg <= m_axis_t.tdata_int;
            m_axis_reg_t.tkeep_reg <= m_axis_t.tkeep_int;
            m_axis_reg_t.tlast_reg <= m_axis_t.tlast_int;
            m_axis_reg_t.tid_reg   <= m_axis_t.tid_int;
            m_axis_reg_t.tdest_reg <= m_axis_t.tdest_int;
            m_axis_reg_t.tuser_reg <= m_axis_t.tuser_int;
        end
    end 

    always_ff@(posedge axi_aclk or negedge axi_aresetn) begin
        if(!axi_aresetn) begin
            m_axis_reg_t.tvalid_reg      <= 1'b0;
            m_axis_t.tread_int_reg       <= 1'b0;
            temp_m_axis_reg_t.tvalid_reg <= 1'b0;
        end 
        else begin
            m_axis_reg_t.tvalid_reg      <= m_axis_reg_t.tvalid_next;
            m_axis_t.tread_int_reg       <= m_axis_t.tread_int_early;
            temp_m_axis_reg_t.tvalid_reg <= temp_m_axis_reg_t.tvalid_next;
        end 
    end

    




endmodule
