`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.10.2024 14:45:06
// Design Name: 
// Module Name: clk6p25m
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


module clk25m(input clk, output reg clk25m = 0);

    reg [31:0] COUNT = 0;
    
    always @ (posedge clk) begin
        COUNT <= (COUNT == 1) ? 0 : COUNT + 1;
        clk25m <= (COUNT == 0) ? ~clk25m : clk25m;
    end
        
endmodule
