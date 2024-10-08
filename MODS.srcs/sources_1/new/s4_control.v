`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.10.2024 04:17:37
// Design Name: 
// Module Name: s123_control
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


module s4_control(
        input clk25m, 
        input [1:0] s1_counter, s2_counter, s3_counter,
        output [15:0] s4_oled_data
    );

    assign s4_oled_data = (s1_counter == 2 && s2_counter == 2 && s3_counter == 2) ? 16'hF800 : 16'hFFFF;
    
endmodule
