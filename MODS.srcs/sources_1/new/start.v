`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.10.2024 02:53:29
// Design Name: 
// Module Name: start
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


module start(
    input CLOCK,
    input [12:0] pixel_index,
    output reg [15:0] oled_data
    );
    
 // Define coordinates for each segment based on your OLED size and resolution
   wire [6:0] x = pixel_index % 96;  // 96 is the width of the OLED screen
   wire [5:0] y = pixel_index / 96;  // 64 is the height of the OLED screen

   // Define boundaries for the segments of each digit
   // Adjust these coordinates based on your specific OLED resolution and position
   parameter X_OFFSET_0 = 10;  // X offset for the '0' digit
   parameter X_OFFSET_3 = 50;  // X offset for the '3' digit

   // Segments for the '0' digit
   wire seg0_top = (x >= X_OFFSET_0 + 0 && x <= X_OFFSET_0 + 8) && (y >= 10 && y <= 12);
   wire seg0_bottom = (x >= X_OFFSET_0 + 0 && x <= X_OFFSET_0 + 8) && (y >= 50 && y <= 52);
   wire seg0_top_left = (x >= X_OFFSET_0 + 0 && x <= X_OFFSET_0 + 2) && (y >= 10 && y <= 50);
   wire seg0_top_right = (x >= X_OFFSET_0 + 6 && x <= X_OFFSET_0 + 8) && (y >= 10 && y <= 50);

   // Segments for the '3' digit
   wire seg3_top = (x >= X_OFFSET_3 + 0 && x <= X_OFFSET_3 + 8) && (y >= 10 && y <= 12);
   wire seg3_middle = (x >= X_OFFSET_3 + 0 && x <= X_OFFSET_3 + 8) && (y >= 30 && y <= 32);
   wire seg3_bottom = (x >= X_OFFSET_3 + 0 && x <= X_OFFSET_3 + 8) && (y >= 50 && y <= 52);
   wire seg3_top_right = (x >= X_OFFSET_3 + 6 && x <= X_OFFSET_3 + 8) && (y >= 10 && y <= 32);
   wire seg3_bottom_right = (x >= X_OFFSET_3 + 6 && x <= X_OFFSET_3 + 8) && (y >= 32 && y <= 50);

   always @(posedge CLOCK) begin
       // Set the default background color (black)
       oled_data = 16'h0000;

       // Display '0'
       if (seg0_top || seg0_bottom || seg0_top_left || seg0_top_right) begin
           oled_data = 16'hFFFF; // White color for the segments
       end

       // Display '3'
       if (seg3_top || seg3_middle || seg3_bottom || seg3_top_right || seg3_bottom_right) begin
           oled_data = 16'hFFFF; // White color for the segments
       end
   end

    
endmodule
