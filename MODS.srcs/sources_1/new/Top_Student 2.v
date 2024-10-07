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
    input clk, reset, sw4, 
    inout ps2_clk, ps2_data, 
    output [7:0] JX, 
    output [6:0] seg, 
    output [15:0] led
    );

    // Clocks
    wire clk1p0, clk6p25m, clk12p5m, clk25m;
    clk1p0 clk1p0_mod(.clk(clk), .clk1p0(clk1p0));
    clk6p25m clk6p25m_mod(.clk(clk), .clk6p25m(clk6p25m));
    clk12p5m clk12p5m_mod(.clk(clk), .clk12p5m(clk12p5m));
    clk25m clk25m_mod(.clk(clk), .clk25m(clk25m));
    
    // 3.A 
    wire [15:0] oled_data;
    wire frame_begin, sending_pixels, sample_pixel;
    wire [12:0] pixel_index;
    Oled_Display Oled_Display(
        .clk(clk6p25m), .reset(reset), 
        .frame_begin(frame_begin), .sending_pixels(sending_pixels), 
        .sample_pixel(sample_pixel), .pixel_index(pixel_index), 
        .pixel_data(oled_data), 
        .cs(JX[0]), .sdin(JX[1]), .sclk(JX[3]), .d_cn(JX[4]), .resn(JX[5]), .vccen(JX[6]), .pmoden(JX[7])
     );
     
     // 3.B
     wire [11:0] xpos, ypos;
     wire [3:0] zpos;
     wire left, middle, right, new_event;
     reg [11:0] value = 0;
     reg setx, sety = 0;
     reg setmax_x = 0; 
     reg setmax_y = 0;
     MouseCtl MouseCtl_mod(
        .clk(clk),
        .rst(reset),
        .xpos(xpos),
        .ypos(ypos),
        .zpos(zpos),    
        .left(left), 
        .middle(middle),     
        .right(right), 
        .new_event(new_event), 
        .value(value),  
        .setx(setx), 
        .sety(sety), 
        .setmax_x(setmax_x),  
        .setmax_y(setmax_y),  
        
        .ps2_clk(ps2_clk),    
        .ps2_data(ps2_data)       
     );
     
     // 3.C
     paint paint_mod(
         .clk_100M(clk), .clk_25M(clk25m), .clk_12p5M(clk12p5m), .clk_6p25M(clk6p25m), .slow_clk(clk1p0),
         .mouse_l(left), .reset(right), .enable(1),  
         .mouse_x(xpos), .mouse_y(ypos),
         .pixel_index(pixel_index),
         .led(led),       
         .seg(seg), 
         .colour_chooser(oled_data)
     );
     
//     wire x;
//     wire y;
//     assign x = pixel_index 
     
//     always @ (*) begin
//         oled_data <= sw4 ? 16'hF800 : 16'h07E0;
//         led[15] <= left;
//         led[14] <= middle;
//         led[13] <= right;
//      end

endmodule