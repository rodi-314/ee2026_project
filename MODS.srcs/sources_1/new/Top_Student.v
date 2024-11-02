`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//  STUDENT A NAME: 
//  STUDENT B NAME:
//  STUDENT C NAME: 
//  STUDENT D NAME:  
//
//////////////////////////////////////////////////////////////////////////////////


module Top_Student (
    input clk, 
    input btnC, btnU, btnL, btnR, btnD, 
    input [15:0] sw,
    output [7:0] JX,  
    output [15:0] led,
    output [6:0] seg,
    output [3:0] an,
    inout ps2_clk, ps2_data
    );

    // Clocks
    wire clk6p25m, clk1m, clk1k, clk1p0;
    flexible_clock_module clk6p25m_mod(.clk(clk), .m(32'd7), .flex_clk(clk6p25m));
    flexible_clock_module clk1m_mod(.clk(clk), .m(32'd49), .flex_clk(clk1m));
    flexible_clock_module clk1k_mod(.clk(clk), .m(32'd49999), .flex_clk(clk1k));
    flexible_clock_module clk1p0_mod(.clk(clk), .m(32'd49999999), .flex_clk(clk1p0));
    // Unused clocks
//    wire clk12p5m, clk25m;
//    flexible_clock_module clk12p5m_mod(.clk(clk), .m(32'd3), .flex_clk(clk12p5m));
//    flexible_clock_module clk25m_mod(.clk(clk), .m(32'd1), .flex_clk(clk25m));
    
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
     
     // 3.B Mouse_Control.vhd Module
//     wire [11:0] xpos, ypos;
//     wire [3:0] zpos;
//     wire left, middle, right, new_event;
//     reg [11:0] value = 0;
//     reg setx, sety = 0;
//     reg setmax_x = 0; 
//     reg setmax_y = 0;
//     MouseCtl MouseCtl_mod(
//        .clk(clk),
//        .rst(reset),
//        .xpos(xpos),
//        .ypos(ypos),
//        .zpos(zpos),    
//        .left(left), 
//        .middle(middle),     
//        .right(right), 
//        .new_event(new_event), 
//        .value(value),  
//        .setx(setx), 
//        .sety(sety), 
//        .setmax_x(setmax_x),  
//        .setmax_y(setmax_y),  
        
//        .ps2_clk(ps2_clk),    
//        .ps2_data(ps2_data)       
//     );
     
     // 3.C Paint.v Module
//     paint paint_mod(
//         .clk_100M(clk), .clk_25M(clk25m), .clk_12p5M(clk12p5m), .clk_6p25M(clk6p25m), .slow_clk(clk1p0),
//         .mouse_l(left), .reset(right), .enable(1),  
//         .mouse_x(xpos), .mouse_y(ypos),
//         .pixel_index(pixel_index),
//         .led(led),       
//         .seg(seg), 
//         .colour_chooser(oled_data)
//     );

    wire [6:0] x;
    wire [5:0] y;
    pixel_index_to_xy pixel_index_to_xy_mod(.pixel_index(pixel_index), .x(x), .y(y));
    
    master master_mod(.clk(clk), .clk1m(clk1m), .btnU(btnU), .btnC(btnC), .btnD(btnD), .sw(sw), .x(x), .y(y), .oled_data(oled_data), 
        .led(led),
        .seg(seg),
        .an(an));
        
endmodule