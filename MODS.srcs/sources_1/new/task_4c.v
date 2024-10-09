`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.10.2024 03:32:59
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
    input restart,
    output reg [15:0] oled_data = 16'h0000
    );
    
    wire clk25m, clk10;
    reg TR = 1'b0, BR = 1'b0, TR_rev = 1'b0, BR_rev = 1'b0, trigger_forward = 1'b0, trigger_backward = 1'b0, moving_back = 1'b0, post_first = 1'b0;
    flexible_clock_module clk25m_mod(.clk(clk), .m(32'd1), .flex_clk(clk25m));
    flexible_clock_module clk10_mod(.clk(clk), .m(32'd4_999_999), .flex_clk(clk10)); //0.1s timer
    reg ret_square = 0;
    reg [3:0] motion = 4'b0000;
    reg [4:0] pause = 0;
    reg [6:0] init_square_x_L = 2, init_square_x_R = 17;
    reg [5:0] init_square_y = 2;
    reg [6:0] section_1_x_L = 2, section_1_x_R = 2;
    reg [5:0] section_1_y = 2;
    reg [6:0] section_2_x = 77;
    reg [5:0] section_2_y_T = 2, section_2_y_B = 2;    
    reg [6:0] section_3_x_L = 92, section_3_x_R = 92;
    reg [5:0] section_3_y = 47;
    
    reg [6:0] start_square_x_L_rev = 2, start_square_x_R_rev = 17;
    reg [5:0] start_square_y = 47;
    reg [6:0] section_1_x_L_rev = 92, section_1_x_R_rev = 92;
    reg [5:0] section_1_y_rev = 2;
    reg [6:0] section_2_x_rev = 77;
    reg [5:0] section_2_y_T_rev = 62, section_2_y_B_rev = 62;    
    reg [6:0] section_3_x_L_rev = 2, section_3_x_R_rev = 2;
    reg [5:0] section_3_y_rev = 47;
        
    always @ (posedge clk25m) begin
        
        oled_data = 16'h0000;
        
        if (btnC) begin
            trigger_forward = (1 ^ moving_back);
            trigger_backward = 1'b0;
            end
        else
            trigger_forward = (trigger_forward ^ moving_back);
        if (btnU) begin
            trigger_backward = (post_first & moving_back);
            trigger_forward = 1'b0;
            end
        else
            trigger_backward = (trigger_backward & moving_back);
    
        if (x > init_square_x_L && x <= init_square_x_R) begin // 2 and 17
            if (y > init_square_y && y <= init_square_y + 15) begin // 2 and 17
                oled_data = 16'h07E0;
                end
            end
        if (x > section_1_x_L && x <= section_1_x_R) begin // starts from 2, R goes to 92
            if (y > section_1_y && y <= section_1_y + 15) begin // 2 and 17
                oled_data = 16'h07E0;
                end
            end
        if (x > section_2_x && x <= section_2_x + 15) begin // 77 and 92
            if (y > section_2_y_T && y <= section_2_y_B) begin // starts from 2, B goes to 62
                oled_data = 16'h07E0;
                end
            end
        if (x > section_3_x_L && x <= section_3_x_R) begin //starts from 92, L goes to 2
            if (y > section_3_y && y <= section_3_y + 15) begin // 47 and 62
                oled_data = 16'h07E0;
                end
            end
            
        // reverse section
        if (x > start_square_x_L_rev && x <= start_square_x_R_rev && post_first) begin // 2 and 17
            if (y > start_square_y && y <= start_square_y + 15) begin // 47 and 62
                oled_data = 16'hF800;
                end
            end
        if (x > section_1_x_L_rev && x <= section_1_x_R_rev && post_first) begin // starts from 92, L goes to 2
            if (y > section_1_y_rev && y <= section_1_y_rev + 15) begin // 2 and 17
                oled_data = 16'hF800;
                end
            end

        if (x > section_2_x_rev && x <= section_2_x_rev + 15 && post_first) begin // 77 and 92
            if (y > section_2_y_T_rev && y <= section_2_y_B_rev) begin // starts from 62, T goes to 2 
                oled_data = 16'hF800;
                end
            end
        if (x > section_3_x_L_rev && x <= section_3_x_R_rev && post_first) begin // starts from 2, R goes to 92
            if (y > section_3_y_rev && y <= section_3_y_rev + 15) begin // 47 and 62
                oled_data = 16'hF800;
                end
            end
        end
    
    always @ (posedge clk10) begin
    
        if (restart) begin
            section_1_x_R = 2;
            section_2_y_B = 2;
            section_3_x_L = 92;
            section_1_x_L_rev = 92;
            section_2_y_T_rev = 62;
            section_3_x_R_rev = 2;
            post_first = 0;
            TR = 1'b0;
            BR = 1'b0;
            TR_rev = 1'b0;
            BR_rev = 1'b0;
            moving_back = 1'b0;
        end
    
        motion <= trigger_forward ? (!TR ? 1 : (!BR ? 2 : 3)) : (trigger_backward ? (!BR_rev ? 4 : (!TR_rev ? 5 : 6)) : 0);
        
        case (motion)
            0 : begin
                init_square_x_R <= 20;
                end
                
            1 : begin 
                if (section_1_x_R < 92) begin 
                    section_1_x_R = (section_1_x_R < 92) ? section_1_x_R + 3 : section_1_x_R; 
                    if (post_first)
                        section_1_x_L_rev = (section_1_x_L_rev < 92) ? section_1_x_L_rev - 3 : section_1_x_L_rev;
                    end
                else begin
                    pause = pause + 1;
                    if (pause == 20) begin
                        TR <= 1'b1;
                        pause = 0;
                        end
                    end
                end
                
            2 : begin
                if (section_2_y_B < 62) begin 
                    section_2_y_B = (section_2_y_B < 62) ? section_2_y_B + 3 : section_2_y_B; 
                    if (post_first)
                        section_2_y_T_rev = (section_2_y_T_rev < 62) ? section_2_y_T_rev + 3 : section_2_y_T_rev;
                    end
                else begin
                    //2s delay to be had here
                    pause = pause + 1;
                    if (pause == 15) begin
                        BR <= 1'b1;
                        pause = 0;
                        end
                    end
                end
                
            3 : begin
                if (section_3_x_L > 2) begin
                    section_3_x_L = (section_3_x_L > 2) ? section_3_x_L - 3 : section_3_x_L;
                    
                    if (post_first)
                        section_3_x_R_rev = (section_3_x_R_rev > 2) ? section_3_x_R_rev - 3 : section_3_x_R_rev;
                    end
                else begin
                    pause = pause + 1;
                    if (pause == 15) begin
                        moving_back <= 1'b1;
                        post_first <= 1'b1;
                        pause = 0;
                        end
                        
                    end
                end //forward moving
                
            4 : begin
                if (section_3_x_R_rev < 92) begin
                    section_3_x_R_rev = (section_3_x_R_rev < 92) ? section_3_x_R_rev + 5 : section_3_x_R_rev;
                    section_3_x_L = (section_3_x_L < 92) ? section_3_x_L + 5 : section_3_x_L;
                    end
                    
                else begin
                    BR_rev <= 1'b1;
                    end
                end
                
            5: begin
                if (section_2_y_T_rev > 2) begin
                    section_2_y_T_rev = (section_2_y_T_rev > 2) ? section_2_y_T_rev - 5 : section_2_y_T_rev;
                    section_2_y_B = (section_2_y_B > 2) ? section_2_y_B - 5 : section_2_y_B;
                    end
                else begin
                    
                    TR_rev <= 1'b1;
                    end
                end
                
            6: begin
                if (section_1_x_L_rev > 2) begin
                    section_1_x_L_rev = (section_1_x_L_rev > 2) ? section_1_x_L_rev - 5 : section_1_x_L_rev;
                    section_1_x_R = (section_1_x_R > 2) ? section_1_x_R - 5 : section_1_x_R;
                    end
                else begin
                    moving_back <= 1'b0;
                    TR <= 1'b0;
                    BR <= 1'b0;
                    TR_rev <= 1'b0;
                    BR_rev <= 1'b0;
                    section_1_x_R = 17;
                    section_1_x_L_rev = 17;
                    end
                end
            endcase
        
        end // always block
    
endmodule
