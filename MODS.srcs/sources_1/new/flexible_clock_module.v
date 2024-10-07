`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.10.2024 17:21:20
// Design Name: 
// Module Name: flexible_clock_module
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


module flexible_clock_module(input clk, input [31:0] m, output reg flex_clk = 0);

    reg [31:0] COUNT = 0;
    
    always @ (posedge clk) begin
        COUNT <= (COUNT == m) ? 0 : COUNT + 1;
        flex_clk <= (COUNT == 0) ? ~flex_clk : flex_clk;
    end
        
endmodule
