`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/29 15:41:29
// Design Name: 
// Module Name: axis_to_axi_intf
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



module axis_to_axi_intf #(
    parameter int unsigned AXI_DATA_WIDTH    = 'd32,
    parameter int unsigned AXI_ADDR_WIDTH    = 'd32,
    parameter int unsigned AXI_ID_WIDTH      = 'd0,
    parameter int unsigned AXI_MAX_BURST_LEN = 'd16,
    
    parameter int unsigned AXI_USER_WIDTH    = 'd0,
    parameter int unsigned AXIS_DATA_WIDTH   = 'd64,
    parameter int unsigned AXIS_KEEP_WITDH   = 'd8,
    parameter int unsigned AXIS_ID_WIDTH     = 'd0,
    parameter int unsigned AXIS_DEST_WIDTH   = 'd0,
    parameter int unsigned AXIS_USER_WIDTH   = 'd0  
)(
    input logic axi_aclk,
    input logic axi_aresetn,

    //AXIS_SLAVE
    axi_stream.Slave    s_axis_in,
    //AXI_MASTER
    axi_bus.Master      m_axi_out

);

    localparam int unsigned AXI_STRB_WIDTH = (AXI_DATA_WIDTH/8) ;

    typedef enum logic [1:0] {
        OKAY,
        EXOKAY,
        SLVERR,
        DECERR
    } AXI_RESP;

    typedef enum bit [2:0] {
        FSM_IDLE,
        FSM_START,
        FSM_WRITE,
        FSM_FINISH_BURST,
        FSM_DROP_DATA
    } FSM_STATE;

    FSM_STATE       fsm_curr, fsm_next;

    typedef enum logic [0:0]{
        frame_reg,
        frame_next
    } frame;

    frame       frame_t;

    //internal datapath
    typedef struct packed {
        logic [AXI_DATA_WIDTH-1:0] wdata_int;
        logic [AXI_STRB_WIDTH-1:0] wstrb_int;
        logic                      wlast_int;
        logic                      wvalid_int;
        logic                      wready_int;
    } m_axi;

    m_axi m_axi_t;

    //output data_path logic
    typedef struct packed {
        //WR_ADDR_CH
        logic [AXI_ID_WIDTH-1:0]   aw_id_reg;
        logic [AXI_ADDR_WIDTH-1:0] aw_addr_reg;
        logic                      aw_len_reg;
        logic                      aw_size_reg;
        logic                      aw_burst_reg;
        logic                      aw_lock_reg;
        logic                      aw_cache_reg;
        logic                      aw_prot_reg;
        logic                      aw_qos_reg;
        logic                      aw_region_reg;
        logic                      aw_user_reg;
        logic                      aw_valid_reg;
        logic                      aw_ready_reg;

        //WR_DATA_CH
        logic                      w_id_reg;
        logic                      w_data_reg;
        logic                      w_strb_reg;
        logic                      w_last_reg;
        logic                      w_user_reg;
        logic                      w_valid_reg;
        logic                      w_ready_reg;

        //WR_RESP_CH
        logic                b_id;
        logic     b_resp;     //S~M
        user_t              b_user;
        logic               b_valid;    //S~M
        logic               b_ready;    //M~S

        //RD_ADDR_CH
        logic                ar_id;
        logic              ar_addr;
        logic      ar_len;
        logic     ar_size;
        logic    ar_burst;
        logic               ar_lock;
        logic    ar_cache;
        logic     ar_prot;
        logic      ar_qos;
        logic   ar_region;
        user_t              ar_user;
        logic               ar_valid;
        logic               ar_ready;

        //RD_DATA_CH
        logic                r_id;
        logic              r_data;
        logic     r_resp;
        logic               r_last;
        user_t              r_user;
        logic               r_valid;
        logic               r_ready

    } m_axi_reg;

    always_ff@(posedge axi_aclk or negedge axi_aresetn) begin
        if(!axi_aresetn) begin
            fsm_curr <= FSM_IDLE;
        end 
        else begin
            fsm_curr <= fsm_next;
        end
    end 

    always_comb begin

    end 

    always_comb begin
        m_axi_t.wdata_int = 
    end

    always_ff@(posedge axi_aclk) begin
        //datapath

    end 

endmodule