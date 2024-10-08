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


module s123_input(input clk, btn, output reg [1:0] sx_counter = 0);

    wire clk2k;
    flexible_clock_module clk2k_mod(.clk(clk), .m(32'd24999), .flex_clk(clk2k));

    reg button_pressed = 0;
    wire [31:0] time_after_press;
    debouncer_200ms debouncer_200ms_mod(.clk2k(clk2k), .button_pressed(button_pressed), .counter(time_after_press));

    always @ (posedge clk2k) begin
        // When button is pressed
        if (btn && !button_pressed) begin
            sx_counter <= sx_counter + 1;
            button_pressed <= 1;
        end
        // When button is released
        else if (!btn && button_pressed && time_after_press == 400) begin
            button_pressed <= 0;
        end
    end
    
endmodule
