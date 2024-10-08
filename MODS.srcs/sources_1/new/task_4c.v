`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.10.2024 15:40:22
// Design Name: 
// Module Name: task_4c
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


module task_4c(
    input clk,
    input btnC, btnU,
    input [6:0] x,
    input [5:0] y,
    output reg [15:0] oled_data = 16'h0000
    );
    
    wire clk25m, clk10;
    reg TR_corner = 1'b0, BR_corner = 1'b0, trigger_forward = 1'b0, trigger_backward = 1'b0, moving_back = 1'b0, post_first = 1'b0;
    flexible_clock_module clk25m_mod(.clk(clk), .m(32'd1), .out_clk(clk25m));
    flexible_clock_module clk10_mod(.clk(clk), .m(32'd4_999_999), .out_clk(clk10)); //0.1s timer
    reg pause = 0;
    reg [6:0] init_square_x_L = 2, init_square_x_R = 17;
    reg [5:0] init_square_y = 2;
    reg [6:0] section_1_x_L = 2, section_1_x_R = 2;
    reg [5:0] section_1_y = 2;
    reg [6:0] section_2_x = 77;
    reg [5:0] section_2_y_T = 2, section_2_y_B = 2;    
    reg [6:0] section_3_x_L = 92, section_3_x_R = 92;
    reg [5:0] section_3_y = 62;
    
    reg [6:0] start_square_x_L_rev = 2, start_square_x_R_rev = 17;
    reg [5:0] start_square_y = 62;
    reg [6:0] section_1_x_L_rev = 92, section_1_x_R_rev = 92;
    reg [5:0] section_1_y_rev = 2;
    reg [6:0] section_2_x_rev = 77;
    reg [5:0] section_2_y_T_rev = 62, section_2_y_B_rev = 62;    
    reg [6:0] section_3_x_L_rev = 2, section_3_x_R_rev = 2;
    reg [5:0] section_3_y_rev = 62;
        
    always @ (posedge clk25m) begin
        if (x > init_square_x_L && x <= init_square_x_R) begin // 2 and 17
            if (y > init_square_y && y <= init_square_y + 15) begin // 2 and 17
                oled_data <= 16'h07E0;
                end
            end
        else if (x > section_1_x_L && x <= section_1_x_R) begin // starts from 2, R goes to 92
            if (y > section_1_y && y <= section_1_y + 15) begin // 2 and 17
                oled_data <= 16'h07E0;
                end
            end
        else if (x > section_2_x && x <= section_2_x + 15) begin // 77 and 92
            if (y > section_2_y_T && y <= section_2_y_B) begin // starts from 2, B goes to 62
                oled_data <= 16'h07E0;
                end
            end
        else if (x > section_3_x_L && x <= section_3_x_R) begin //starts from 92, L goes to 2
            if (y > section_3_y_rev && y <= section_3_y_rev - 15) begin // 62 and 47
                oled_data <= 16'h07E0;
                end
            end
            
        // reverse section
        else if (x > start_square_x_L_rev && x <= start_square_x_R_rev) begin // 2 and 17
            if (y > start_square_y && y <= start_square_y - 15) begin // 62 and 47
                oled_data <= (post_first) ? 16'hF800 : 16'h0000;
                end
            end
        else if (x > section_1_x_L_rev && x <= section_1_x_R_rev) begin // starts from 92, L goes to 2
            if (y > section_1_y_rev && y <= section_1_y_rev + 15) begin // 2 and 17
                oled_data <= (post_first) ? 16'hF800 : 16'h0000;
                end
            end

        else if (x > section_2_x_rev && x <= section_2_x_rev + 15) begin // 77 and 92
            if (y > section_2_y_T_rev && y <= section_2_y_B_rev) begin // starts from 62, T goes to 2 
                oled_data <= (post_first) ? 16'hF800 : 16'h0000;
                end
            end
        else if (x > section_3_x_L_rev && x <= section_3_x_R_rev) begin // starts from 2, R goes to 92
            if (y > section_3_y_rev && y <= section_3_y_rev - 15) begin // 62 and 47
                oled_data <= (post_first) ? 16'hF800 : 16'h0000;
                end
            end
        else
            oled_data = 16'h0000;
            
        trigger_forward = (btnC) ? (1 ^ moving_back) : (trigger_forward ^ moving_back);
        trigger_backward = (btnU) ? (1 & moving_back) : (trigger_backward & moving_back);
    end
    
    always @ (posedge clk10) begin
    
        if (trigger_forward) begin
            if(!TR_corner) begin

                if (section_1_x_R > 91) begin
                    pause = pause + 1;
                    if (pause == 20) begin
                        TR_corner <= 1'b1;
                        pause = 0;
                        end
                    end
                else begin
                    section_1_x_R <= section_1_x_R + 3;
                    if (post_first)
                        section_1_x_L_rev <= (section_1_x_L_rev < 92) ? section_1_x_L_rev - 3 : section_1_x_L_rev;
                    end
                end
                
            else if(!BR_corner) begin

                if (section_2_y_B > 61) begin
                   pause = pause + 1;
                   if (pause == 20) begin
                       BR_corner <= 1'b1;
                       pause = 0;
                       end
                   end
                else begin
                    section_2_y_B <= section_2_y_B + 3;
                    if (post_first)
                        section_2_y_T_rev <= (section_2_y_T_rev < 62) ? section_2_y_T_rev + 3 : section_2_y_T_rev;
                    end
                end
                   
            else begin
                if (section_3_x_L < 3) begin
                    pause = pause + 1;
                    if (pause == 20) begin
                        TR_corner = 1'b0;
                        BR_corner = 1'b0;
                        moving_back = 1'b1;
                        post_first = 1'b1;
                        pause <= 0;
                        end
                    end
                else begin
                    section_3_x_L <= section_3_x_L - 3;
                    if (post_first)
                        section_3_x_R_rev <= (section_3_x_R_rev > 2) ? section_3_x_R_rev - 3 : section_3_x_R_rev;
                    end
                end
            end //forward moving
            
        else if (trigger_backward) begin
            if(!BR_corner) begin
                if (section_1_x_R_rev > 91)
                    BR_corner <= 1'b1;
                else begin
                    section_3_x_R_rev <= section_1_x_R_rev + 5;
                    section_3_x_L <= (section_3_x_L < 92) ? section_3_x_L + 5 : section_3_x_L;
                    end
                end
                
            else if(!TR_corner) begin
                if (section_2_y_B < 3) 
                    TR_corner <= 1'b1;
                else begin
                    section_2_y_T_rev <= section_2_y_T_rev - 5;
                    section_2_y_B <= (section_2_y_B > 2) ? section_2_y_B - 5 : section_2_y_B;
                    end
                end
                
            else begin
                if (section_3_x_L_rev < 3) begin
                    moving_back = 1'b0;
                    TR_corner = 1'b0;
                    BR_corner = 1'b0;
                    init_square_x_R = 17;
                    end
                    
                else begin
                    section_3_x_L_rev <= section_3_x_L_rev - 5;
                    section_3_x_R <= (section_3_x_R > 2) ? section_3_x_R - 5 : section_3_x_R;
                    end
                end
                
            end //backward moving
            
        end // always block
    
endmodule
