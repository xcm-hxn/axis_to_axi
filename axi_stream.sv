`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/28 10:44:15
// Design Name: 
// Module Name: axi_stream
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


interface axi_stream #(
    parameter int unsigned AXIS_DATA_WIDTH = 0,
    parameter int unsigned AXIS_ID_WIDTH   = 0,
    parameter int unsigned AXIS_DEST_WIDTH = 0,
    parameter int unsigned AXIS_USER_WIDTH = 0
);
    localparam int unsigned AXIS_KEEP_WITDH = ((AXIS_DATA_WIDTH+7)/8);

    typedef logic [AXIS_DATA_WIDTH-1:0] data_t;
    typedef logic [AXIS_KEEP_WITDH-1:0] keep_t;    
    typedef logic [AXIS_ID_WIDTH-1:0]   id_t;
    typedef logic [AXIS_DEST_WIDTH-1:0] dest_t;
    typedef logic [AXIS_USER_WIDTH-1:0] user_t;        
          
    //SIGNAL DEFINE
    data_t                      tdata;
    keep_t                      tkeep;
    logic                       tvalid;
    logic                       tready;
    logic                       tlast;
    id_t                        tid;
    dest_t                      tdest;
    user_t                      tuser;


    modport Master (
        output tdata, tkeep, tvalid, input tready,
        output tlast, tid, tdest, tuser
    );

    modport Slave (
        input  tdata, tkeep, tvalid, tlast, tid, tdest, tuser,
        output tready
    );

endinterface
