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


module s123_control(input clk25m, input [1:0] sx_counter, output reg [15:0] sx_oled_data);

    always @ (posedge clk25m) begin
        case (sx_counter)
            2'd0: sx_oled_data <= 16'hFFFF;
            2'd1: sx_oled_data <= 16'hF800;
            2'd2: sx_oled_data <= 16'h07E0;
            2'd3: sx_oled_data <= 16'h001F;
        endcase
    end
    
endmodule
