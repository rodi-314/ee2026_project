`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.11.2024 02:02:16
// Design Name: 
// Module Name: counter_5s
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


module counter_5s(input clk1m, tile_discarded, output reg [31:0] counter);
    always @ (posedge clk1m) begin
        counter = (tile_discarded ? (counter == 5000000 ? 5000000 : counter + 1) : 0);
    end
endmodule
