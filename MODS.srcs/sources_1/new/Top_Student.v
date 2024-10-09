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


module Top_Student(
        input clk, 
        input btnC, btnU, btnL, btnR, btnD, 
        input [15:0] sw,
        output [7:0] JX,  
        output reg [15:0] led
    );

    // Clocks
    wire clk6p25m, clk7Hz, clk1Hz, clk6Hz;
    flexible_clock_module clk6p25m_mod(.clk(clk), .m(32'd7), .flex_clk(clk6p25m));
    flexible_clock_module clk7Hz_mod (.clk(clk), .m(7142856), .flex_clk(clk7Hz));
    flexible_clock_module clk1Hz_mod (.clk(clk), .m(49999999), .flex_clk(clk1Hz));
    flexible_clock_module clk6Hz_mod (.clk(clk), .m(8333332), .flex_clk(clk6Hz));
    
    // 3.A Oled_Display.v Module
    reg [15:0] oled_data;
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
     
     wire [15:0] outputA, outputB, outputC, outputD, outputS;
     wire [3:0] password;
     reg restart = 1;
     wire restart_wire;
     assign restart_wire = restart;
     assign password[0] = (sw == 16'h11C5) ? 1 : 0;
     assign password[1] = (sw == 16'h2161) ? 1 : 0;
     assign password[2] = (sw == 16'h13C5) ? 1 : 0;
     assign password[3] = (sw == 16'h8135) ? 1 : 0;
     
     // Modules
     start S (clk, pixel_index, outputS);
     taskA A (clk, btnC, btnU, restart_wire, pixel_index, outputA);
     task_4b task_4b_mod(
         .clk(clk), .btnU(btnU), .btnC(btnC), .btnD(btnD), .restart(restart),
         .x(x), .y(y), .oled_data(outputB)
     );
     taskD D (clk, btnC, btnU, btnR, btnL, btnD, x, y, restart_wire, outputD);
     
     always @ (*) begin
         if (!password) begin
             restart = 1;
             oled_data = outputS;
             led = sw;
         end
         else if (password[0]) begin
             restart = 0;
             led = (1'b1 << 12) + (clk6Hz << 8) + (clk6Hz << 7) + (clk6Hz << 6) + (clk6Hz << 2) + (clk6Hz);
             oled_data = outputA;
         end
         else if (password[1]) begin
             restart = 0;
             led = (1'b1 << 13) + (clk1Hz << 8) + (clk1Hz << 6) + (clk1Hz << 5) + (clk1Hz);
             oled_data = outputB;
         end
         else if (password[2]) begin
             restart = 0;
             oled_data = outputS;
         end
         else if (password[3]) begin
             restart = 0;
             led = (1'b1 << 15) + (clk6Hz << 8) + (clk6Hz << 5) + (clk6Hz << 4) + (clk6Hz << 2) + (clk6Hz);
             oled_data = outputD;
         end
     end

endmodule