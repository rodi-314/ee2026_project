`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.10.2024 02:27:42
// Design Name: 
// Module Name: pixel_index_to_xy
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


module pixel_index_to_xy(input [12:0] pixel_index, output [6:0] x, output [5:0] y);

    assign x = pixel_index % 96;
    assign y = pixel_index / 96;
    
endmodule
