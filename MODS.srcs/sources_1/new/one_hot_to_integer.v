`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.11.2024 22:53:36
// Design Name: 
// Module Name: one_hot_to_integer
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


module one_hot_to_integer(input clk, input [13:0] array, output reg [3:0] int);
    always @ (posedge clk) begin
        case (array)
            14'b10_0000_0000_0000: int = 13;
            14'b01_0000_0000_0000: int = 12;
            14'b00_1000_0000_0000: int = 11;
            14'b00_0100_0000_0000: int = 10;
            14'b00_0010_0000_0000: int = 9;
            14'b00_0001_0000_0000: int = 8;
            14'b00_0000_1000_0000: int = 7;
            14'b00_0000_0100_0000: int = 6;
            14'b00_0000_0010_0000: int = 5;
            14'b00_0000_0001_0000: int = 4;
            14'b00_0000_0000_1000: int = 3;
            14'b00_0000_0000_0100: int = 2;
            14'b00_0000_0000_0010: int = 1;
            14'b00_0000_0000_0001: int = 0;
            default: int = 13;
        endcase
    end
endmodule
