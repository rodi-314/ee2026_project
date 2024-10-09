`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.10.2024 02:52:02
// Design Name: 
// Module Name: clk_divider
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


module clk_divider(
    input CLOCK,
    input [31:0] my_m_value,
    output reg newclock = 0
    );
    
    reg [31:0] count = 0;
    always@(posedge CLOCK) begin
        count <= (count == my_m_value) ? 0 : count + 1;
        newclock <= (count == 0) ? ~newclock : newclock;
    end
    
endmodule
