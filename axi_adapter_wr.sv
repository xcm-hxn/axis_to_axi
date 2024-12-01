`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/29 15:41:29
// Design Name: 
// Module Name: axi_adapter_wr
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



module axi_adapter_wr # (
    parameter int unsigned AXI_DATA_WIDTH = 'd32
)(
    input logic axi_aclk,
    input logic axi_aresetn,

    //AXIS_SLAVE
    axi_stream.Slave    s_axis_in,
    //AXI_MASTER
    axi_bus.Master      m_axi_out      
);

    localparam int unsigned s_addr_bit_offset 

    typedef enum bit[1:0] {
        FSM_IDLE,
        FSM_DATA,
        FSM_DATA_2,
        FSM_RESP

    } FSM_STATE;

    FSM_STATE       fsm_curr, frame_next;

    typedef enum logic [0:0] {
        frame_reg,
        frame_next
    } fram;

    fram        fram_t;

    always_ff@(posedge axi_aclk or negedge axi_aresetn) begin
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

        case (fsm_curr)
            FSM_IDLE: begin
                s_axis_in.
            end
        endcase        
    end 

endmodule
