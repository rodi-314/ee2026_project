`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.11.2024 01:28:50
// Design Name: 
// Module Name: counter_200ms
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


module counter_200ms(input clk1m, btn_pressed, output reg [31:0] counter);
    always @ (posedge clk1m) begin
        counter = (counter == 200000) ? 200000 : (btn_pressed ? counter + 1 : 0);
    end
endmodule
