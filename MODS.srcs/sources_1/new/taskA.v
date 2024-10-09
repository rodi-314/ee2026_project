`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.10.2024 02:48:43
// Design Name: 
// Module Name: taskA
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


module taskA(
    input CLOCK,
    input pbC,
    input pbU,
    input restart,
    output [7:0] JBa
    );
    
    wire clk6p25m, clk_25MHz, clk2kHz, frame_begin, sending_pixels, sample_pixel, wire_upMode;
    wire [12:0] pixel_index;
    reg [15:0] oled_data;
    wire [2:0] pattern;
    reg upMode = 0;
    assign wire_upMode = upMode;
    clk_divider u1 (CLOCK, 7, clk6p25m); 
    clk_divider u2 (CLOCK, 1, clk_25MHz);
    clk_divider u3 (CLOCK, 24999, clk2kHz);
    Oled_Display oled (clk6p25m, 0, frame_begin, sending_pixels, sample_pixel, pixel_index, oled_data, JBa[0], JBa[1], JBa[3], JBa[4], JBa[5], JBa[6], JBa[7]);
    debounce debouncer (clk2kHz, pbC, wire_upMode, pattern);
    
    wire [6:0] x = pixel_index % 96;
    wire [5:0] y = pixel_index / 96;
    reg [6:0] x_centre = 96 / 2;
    reg [5:0] y_centre = 64 / 2;
    reg [6:0] outer_radius = 17;
    reg [6:0] inner_radius = 14;
    reg [6:0] small_radius = 4;
    wire [13:0] circle = (x - x_centre)*(x - x_centre) + (y - y_centre)*(y - y_centre);
    always@(posedge clk_25MHz) begin
        oled_data = 16'h0000;
        if (restart) begin
            upMode = 0;
        end
        else begin
            if ((x >= 2 && x <= 4 && y >= 2 && y <= 59) || (x >= 90 && x <= 92 && y >= 2 && y <= 59) || (x >= 2 && x <= 92 && y >= 2 && y <= 4) || (x >= 2 && x <= 92 && y >= 57 && y <= 59)) begin
                oled_data = 16'hF800;
            end
            if (pbU) begin
                upMode = 1;
            end
            if (upMode) begin
                if (circle <= outer_radius*outer_radius && circle >= inner_radius*inner_radius) begin
                    oled_data = 16'hFD60;
                end
            end
            if (pattern >= 4 && pattern <= 6) begin
                if (circle <= outer_radius*outer_radius && circle >= inner_radius*inner_radius) begin
                    oled_data = 16'hFFFF;
                end
            end
            if (pattern) begin
                if (pattern == 1) begin
                    if (circle <= small_radius*small_radius) begin
                        oled_data = 16'h07E0;
                    end
                end
                else if (pattern == 2) begin
                    if (circle <= small_radius*small_radius) begin
                        oled_data = 16'hFD60;
                    end
                end
                else if (pattern == 3) begin
                    if (circle <= small_radius*small_radius) begin
                        oled_data = 16'hF800;
                    end
                end
                else if (pattern == 4) begin
                    if ((x >= 45 && x <= 51) && (y >= 29 && y <= 35)) begin
                        oled_data = 16'h07E0;
                    end
                end
                else if (pattern == 5) begin
                    if ((x >= 45 && x <= 51) && (y >= 29 && y <= 35)) begin
                        oled_data = 16'hFD60;
                    end
                end
                else if (pattern == 6) begin
                    if ((x >= 45 && x <= 51) && (y >= 29 && y <= 35)) begin
                        oled_data = 16'hF800;
                    end
                end
            end
        end
    end
    
endmodule
