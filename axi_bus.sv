`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/28 09:25:57
// Design Name: 
// Module Name: axi_bus
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


interface axi_bus #(
    parameter int unsigned AXI_ADDR_WIDTH = 0,
    parameter int unsigned AXI_DATA_WIDTH = 0,
    parameter int unsigned AXI_ID_WIDTH   = 0,
    parameter int unsigned AXI_USER_WIDTH = 0
);
    localparam  int unsigned AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8;

    typedef logic [AXI_ID_WIDTH-1:0]   id_t;
    typedef logic [AXI_ADDR_WIDTH-1:0] addr_t;
    typedef logic [AXI_DATA_WIDTH-1:0] data_t;
    typedef logic [AXI_STRB_WIDTH-1:0] strb_t;
    typedef logic [AXI_USER_WIDTH-1:0] user_t;

    //WR_ADDR_CH
    id_t                aw_id;      //wr_addr id
    addr_t              aw_addr;    //wr_addr
    axi_pkg::len_t      aw_len;     //wr_burst_len INCR:1~256
    axi_pkg::size_t     aw_size;    //wr_burst_size 1、2、4、8、16、32、64、128
    axi_pkg::burst_t    aw_burst;   //2'b00 FIXED; 2'b01 INCR; 2'b10 WRAP; 2'b11 Reserved 
    logic               aw_lock;
    axi_pkg::cache_t    aw_cache;
    axi_pkg::prot_t     aw_prot;
    axi_pkg::qos_t      aw_qos;
    axi_pkg::region_t   aw_region;
    user_t              aw_user;
    logic               aw_valid;   //M~S
    logic               aw_ready;   //S-M

    //WR_DATA_CH
    id_t                w_id;
    data_t              w_data;
    strb_t              w_strb;     //wstrb[n:0]~wdata[8n+7:8n]
    logic               w_last;     //the data ending
    user_t              w_user;
    logic               w_valid;    //M~S
    logic               w_ready;    //S-M

    //WR_RESP_CH
    id_t                b_id;
    axi_pkg::resp_t     b_resp;     //S~M
    user_t              b_user;
    logic               b_valid;    //S~M
    logic               b_ready;    //M~S

    //RD_ADDR_CH
    id_t                ar_id;
    addr_t              ar_addr;
    axi_pkg::len_t      ar_len;
    axi_pkg::size_t     ar_size;
    axi_pkg::burst_t    ar_burst;
    logic               ar_lock;
    axi_pkg::cache_t    ar_cache;
    axi_pkg::prot_t     ar_prot;
    axi_pkg::qos_t      ar_qos;
    axi_pkg::region_t   ar_region;
    user_t              ar_user;
    logic               ar_valid;
    logic               ar_ready;

    //RD_DATA_CH
    id_t                r_id;
    data_t              r_data;
    axi_pkg::resp_t     r_resp;
    logic               r_last;
    user_t              r_user;
    logic               r_valid;
    logic               r_ready;

    modport Master (
        output aw_id, aw_addr, aw_len, aw_size, aw_burst, aw_lock, aw_cache, aw_prot, aw_qos, aw_region, aw_user, aw_valid, input aw_ready,
        output w_data, w_strb, w_last, w_user, w_valid, input w_ready,
        input b_id, b_resp, b_user, b_valid, output b_ready,
        output ar_id, ar_addr, ar_len, ar_size, ar_burst, ar_lock, ar_cache, ar_prot, ar_qos, ar_region, ar_user, ar_valid, input ar_ready,
        input r_id, r_data, r_resp, r_last, r_user, r_valid, output r_ready
    );

    modport Slave (
        input aw_id, aw_addr, aw_len, aw_size, aw_burst, aw_lock, aw_cache, aw_prot, aw_qos, aw_region, aw_user, aw_valid, output aw_ready,
        input w_data, w_strb, w_last, w_user, w_valid, output w_ready,
        output b_id, b_resp, b_user, b_valid, input b_ready,
        input ar_id, ar_addr, ar_len, ar_size, ar_burst, ar_lock, ar_cache, ar_prot, ar_qos, ar_region, ar_user, ar_valid, output ar_ready,
        output r_id, r_data, r_resp, r_last, r_user, r_valid, input r_ready
    );

    modport Monitor (
        input aw_id, aw_addr, aw_len, aw_size, aw_burst, aw_lock, aw_cache, aw_prot, aw_qos, aw_region, aw_user, aw_valid, aw_ready,
            w_data, w_strb, w_last, w_user, w_valid, w_ready,
            b_id, b_resp, b_user, b_valid, b_ready,
            ar_id, ar_addr, ar_len, ar_size, ar_burst, ar_lock, ar_cache, ar_prot, ar_qos, ar_region, ar_user, ar_valid, ar_ready,
            r_id, r_data, r_resp, r_last, r_user, r_valid, r_ready
    );  


endinterface
