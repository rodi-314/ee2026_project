`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.10.2024 02:49:52
// Design Name: 
// Module Name: taskB
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


module taskB(
        input clk, 
        input btnC, btnU, btnL, btnR, btnD, 
        input [15:0] sw,
        output [7:0] JX,  
        output [15:0] led,
        output [6:0] seg,
        inout ps2_clk, ps2_data
    );

    // Clocks
    wire clk6p25m;
    flexible_clock_module clk6p25m_mod(.clk(clk), .m(32'd7), .flex_clk(clk6p25m));
    
    // 3.A Oled_Display.v Module
    wire [15:0] oled_data;
    wire frame_begin, sending_pixels, sample_pixel;
    wire [12:0] pixel_index;
    Oled_Display Oled_Display(
        .clk(clk6p25m), .reset(1'b0), 
        .frame_begin(frame_begin), .sending_pixels(sending_pixels), 
        .sample_pixel(sample_pixel), .pixel_index(pixel_index), 
        .pixel_data(oled_data), 
        .cs(JX[0]), .sdin(JX[1]), .sclk(JX[3]), .d_cn(JX[4]), .resn(JX[5]), .vccen(JX[6]), .pmoden(JX[7])
     );

    // Convert pixel_index to xy coordinates
     wire [6:0] x;
     wire [5:0] y;
     pixel_index_to_xy pixel_index_to_xy_mod(.pixel_index(pixel_index), .x(x), .y(y));
     
     // 4.B
     task_4b task_4b_mod(
        .clk(clk), .btnU(btnU), .btnC(btnC), .btnD(btnD),
        .x(x), .y(y), .oled_data(oled_data)
     );

endmodule
