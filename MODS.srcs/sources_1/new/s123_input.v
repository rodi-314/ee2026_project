`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.10.2024 04:43:05
// Design Name: 
// Module Name: s123_input
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


module s123_input(input clk25m, btn, output reg [1:0] sx_counter = 0);

    reg button_pressed = 0;

    always @ (posedge clk25m) begin
        if (btn && !button_pressed) begin
            sx_counter <= sx_counter + 1;
            button_pressed = 1;
        end
        else if (!btn && button_pressed) begin
            button_pressed = 0;
        end
    end
    
endmodule
