`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/27 14:42:32
// Design Name: 
// Module Name: axi_stream_to_axi_intf
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


module axi_stream_to_axi_intf #(
    parameter int unsigned DATA_WIDTH = 0,
    parameter int unsigned ADDR_WIDTH = 0
)(
    AXI_STREAM.Slave in,
    input axi_pkg::cache_t slv_aw_cache_i,
    input axi_pkg::cache_t slv_ar_cache_i,
    AXI_BUS.Master  out
);
    localparam int unsigned AxiSize = axi_pkg::size_t'($unsigned($clog2(DATA_WIDTH/8)));

    // pragma translate_off
    initial begin
        assert(in.ADDR_WIDTH == out.ADDR_WIDTH);
        assert(in.DATA_WIDTH == out.DATA_WIDTH);
        assert(DATA_WIDTH    == out.DATA_WIDTH);
    end
    // pragma translate_on

    assign out.aw_id     = '0;
    assign out.aw_addr   = in.aw_addr;
    assign out.aw_len    = '0;
    assign out.aw_size   = AxiSize;
    assign out.aw_burst  = axi_pkg::BURST_FIXED;
    assign out.aw_lock   = '0;
    assign out.aw_cache  = slv_aw_cache_i;
    assign out.aw_prot   = '0;
    assign out.aw_qos    = '0;
    assign out.aw_region = '0;
    assign out.aw_atop   = '0;
    assign out.aw_user   = '0;
    assign out.aw_valid  = in.aw_valid;
    assign in.aw_ready   = out.aw_ready;

    assign out.w_data    = in.w_data;
    assign out.w_strb    = in.w_strb;
    assign out.w_last    = '1;
    assign out.w_user    = '0;
    assign out.w_valid   = in.w_valid;
    assign in.w_ready    = out.w_ready;

    assign in.b_resp     = out.b_resp;
    assign in.b_valid    = out.b_valid;
    assign out.b_ready   = in.b_ready;

    assign out.ar_id     = '0;
    assign out.ar_addr   = in.ar_addr;
    assign out.ar_len    = '0;
    assign out.ar_size   = AxiSize;
    assign out.ar_burst  = axi_pkg::BURST_FIXED;
    assign out.ar_lock   = '0;
    assign out.ar_cache  = slv_ar_cache_i;
    assign out.ar_prot   = '0;
    assign out.ar_qos    = '0;
    assign out.ar_region = '0;
    assign out.ar_user   = '0;
    assign out.ar_valid  = in.ar_valid;
    assign in.ar_ready   = out.ar_ready;

    assign in.r_data     = out.r_data;
    assign in.r_resp     = out.r_resp;
    assign in.r_valid    = out.r_valid;
    assign out.r_ready   = in.r_ready;


endmodule
