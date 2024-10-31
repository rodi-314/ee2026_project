`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.10.2024 10:42:09
// Design Name: 
// Module Name: lfsr
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


module lfsr(input clk, rst, output reg [7:0] Q = 8'b00000000);
    always @ (posedge clk) begin
        if (rst) begin
            Q <= 0;
        end
        else begin
            Q <= { Q[6:0], ~(Q[7] ^ Q[6])};
        end
    end
endmodule
