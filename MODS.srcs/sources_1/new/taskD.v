`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.10.2024 15:30:49
// Design Name: 
// Module Name: task_4d_mod
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


module taskD(
    input clk, input btnC, input btnU, input btnR, input btnL, input btnD, input restart,
    output [7:0] JBa
    );
    wire [6:0] x; 
    wire [5:0] y;
    reg [6:0] posX=3;
    reg [6:0] posY=3;
    reg willCollide = 0;
    reg [2:0] motion = 0; // 0: stop, 1: left, 2: right, 3: up, 4: down

    wire clk6p25m, clk25m, clkslow, frame_begin, sending_pixels, sample_pixel;
    clk_divider u1 (clk, 32'd7, clk6p25m);
    clk_divider u2 (clk, 32'd1, clk25m);
    clk_divider u3 (clk, 32'd2499999, clkslow);
    
    wire [12:0] pixel_index;
    reg [15:0] oled_data;
    Oled_Display oled (clk6p25m, 0, frame_begin, sending_pixels, sample_pixel, pixel_index, oled_data, JBa[0], JBa[1], JBa[3], JBa[4], JBa[5], JBa[6], JBa[7]);
    
    assign x = pixel_index % 96;
    assign y = pixel_index / 96;
    
    always @ (posedge clk25m)
    begin
        if (y>=posY-3 && y<=posY+3 && x>=posX-3 && x<=posX+3) oled_data <= 16'b00000_111111_00000;
        else if (y>=22 && y<=43 && x>=37 && x<=57) oled_data <= (motion==0) ? 16'b11111_000000_00000 : 16'b11111_100000_00000;
        else oled_data <= 16'b00000_000000_00000;
    end
    
    always @ (posedge clkslow)
    begin
        if (restart)
        begin
            posX <= 3;
            posY <= 3;
            willCollide <= 0;
            motion <= 0;
        end
        else begin
            motion = btnC?0 :btnL?1 :btnR?2 :btnU?3 :btnD?4 :motion;
            if (motion==1) 
            begin
                willCollide = posY>18 && posY<47 && posX-1>33 && posX-1<61;
                if (posX>3 && !willCollide) posX <= posX - 1;
                else motion <= 0;
            end
            if (motion==2)
            begin
                willCollide = posY>18 && posY<47 && posX+1>33 && posX+1<61;
                if (posX<92 && !willCollide) posX <= posX + 1;
                else motion <= 0;
            end
            if (motion==3)
            begin
                willCollide = posY-1>18 && posY-1<47 && posX>33 && posX<61;
                if (posY>3 && !willCollide) posY <= posY - 1;
                else motion <= 0;
            end
            if (motion==4)
            begin
                willCollide = posY+1>18 && posY+1<47 && posX>33 && posX<61;
                if (posY<60 && !willCollide) posY <= posY + 1;
                else motion <= 0;
            end
        end
    end

endmodule
