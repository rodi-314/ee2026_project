`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.10.2024 03:01:53
// Design Name: 
// Module Name: task_4b
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


module task_4b(
        input clk, btnU, btnC, btnD,
        input [6:0] x, 
        input [5:0] y, 
        output reg [15:0] oled_data
    );

    wire clk25m;
    flexible_clock_module clk25m_mod(.clk(clk), .m(32'd1), .flex_clk(clk25m));
    
    wire [1:0] s1_counter, s2_counter, s3_counter;
    s123_input s1_input_mod(.clk25m(clk25m), .btn(btnU), .sx_counter(s1_counter));
    s123_input s2_input_mod(.clk25m(clk25m), .btn(btnC), .sx_counter(s2_counter));
    s123_input s3_input_mod(.clk25m(clk25m), .btn(btnD), .sx_counter(s3_counter));
    
    wire [15:0] s1_oled_data, s2_oled_data, s3_oled_data, s4_oled_data;
    s123_control s1_control_mod(.clk25m(clk25m), .sx_counter(s1_counter), .sx_oled_data(s1_oled_data));
    s123_control s2_control_mod(.clk25m(clk25m), .sx_counter(s2_counter), .sx_oled_data(s2_oled_data));
    s123_control s3_control_mod(.clk25m(clk25m), .sx_counter(s3_counter), .sx_oled_data(s3_oled_data));
    s4_control s4_control_mod(
        .clk25m(clk25m),
        .s1_counter(s1_counter), 
        .s2_counter(s2_counter), 
        .s3_counter(s3_counter), 
        .s4_oled_data(s4_oled_data)
    );
    
    always @ (posedge clk25m) begin
    
        // Within middle square range
        if (x >= 43 && x < 53) begin
            // 1st (top) square
            if (y >= 5 && y < 15) begin
                oled_data <= s1_oled_data;
            end
            // 2nd square
            else if (y >= 20 && y < 30) begin
                oled_data <= s2_oled_data;
            end
            // 3rd square
            else if (y >= 35 && y < 45) begin
                oled_data <= s3_oled_data;
            end
            // 4th square
            else if (y >= 50 && y < 60) begin
                oled_data <= s4_oled_data;
            end
            // Outside range
            else begin
                oled_data <= 16'h0000;
            end
        end
        // Outside range
        else begin
            oled_data <= 16'h0000;
        end
    end
    
endmodule
