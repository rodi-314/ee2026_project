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


module task_4d(
    input clk, input btnC, input btnU, input btnR, input btnL, input btnD,
    input [6:0] x, 
    input [5:0] y, 
    output reg [15:0] oled_data
    );

    reg [6:0] posX=3;
    reg [6:0] posY=3;
    reg willCollide = 0;
    reg [2:0] motion = 0; // 0: stop, 1: left, 2: right, 3: up, 4: down

    wire clk25m, clkslow;
    flexible_clock_module clk25m_mod(.clk(clk), .m(32'd1), .flex_clk(clk25m));
    flexible_clock_module clkslow_mod(.clk(clk), .m(32'd2499999), .flex_clk(clkslow));
    
    always @ (posedge clk25m)
    begin
        if (y>=posY-3 && y<=posY+3 && x>=posX-3 && x<=posX+3) oled_data <= 16'b00000_111111_00000;
        else if (y>=22 && y<=43 && x>=37 && x<=57) oled_data <= (motion==0) ? 16'b11111_000000_00000 : 16'b11111_100000_00000;
        else oled_data <= 16'b00000_000000_00000;
    end
    
    always @ (posedge clkslow)
    begin
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

endmodule
