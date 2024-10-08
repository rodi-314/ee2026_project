`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.10.2024 06:38:52
// Design Name: 
// Module Name: debouncer_200ms
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


module debouncer_200ms(input clk2k, button_pressed, output reg [31:0] counter = 0);

    always @ (posedge clk2k) begin
        counter <= button_pressed ? (counter < 400 ? counter + 1 : counter) : 0;
    end

endmodule
