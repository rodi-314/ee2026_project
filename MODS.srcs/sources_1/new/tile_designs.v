`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.11.2024 19:43:59
// Design Name: 
// Module Name: tile_designs
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


module tile_designs(input clk, input [5:0] tile_index, input [6:0] x, input [5:0] y, output reg [15:0] oled_data = 0);

    reg [15:0] tong_1 [103:0];
    reg [15:0] tong_2 [103:0];
    reg [15:0] tong_3 [103:0];
    reg [15:0] tong_4 [103:0];
    reg [15:0] tong_5 [103:0];
    reg [15:0] tong_6 [103:0];
    reg [15:0] tong_7 [103:0];
    reg [15:0] tong_8 [103:0];
    reg [15:0] tong_9 [103:0];
    reg [15:0] wan_1 [103:0];
    reg [15:0] wan_2 [103:0];
    reg [15:0] wan_3 [103:0];
    reg [15:0] wan_4 [103:0];
    reg [15:0] wan_5 [103:0];
    reg [15:0] wan_6 [103:0];
    reg [15:0] wan_7 [103:0];
    reg [15:0] wan_8 [103:0];
    reg [15:0] wan_9 [103:0];
    reg [15:0] suo_1 [103:0];
    reg [15:0] suo_2 [103:0];
    reg [15:0] suo_3 [103:0];
    reg [15:0] suo_4 [103:0];
    reg [15:0] suo_5 [103:0];
    reg [15:0] suo_6 [103:0];
    reg [15:0] suo_7 [103:0];
    reg [15:0] suo_8 [103:0];
    reg [15:0] suo_9 [103:0];
    reg [15:0] dong [103:0];
    reg [15:0] nan [103:0];
    reg [15:0] xi [103:0];
    reg [15:0] bei [103:0];
    reg [15:0] hongzhong [103:0];
    reg [15:0] baiban [103:0];
    reg [15:0] facai [103:0];
    
     initial begin
        $readmemh("1tong.txt", tong_1);
        $readmemh("2tong.txt", tong_2);
        $readmemh("3tong.txt", tong_3);
        $readmemh("4tong.txt", tong_4);
        $readmemh("5tong.txt", tong_5);
        $readmemh("6tong.txt", tong_6);
        $readmemh("7tong.txt", tong_7);
        $readmemh("8tong.txt", tong_8);
        $readmemh("9tong.txt", tong_9);
        $readmemh("1wan.txt", wan_1);
        $readmemh("2wan.txt", wan_2);
        $readmemh("3wan.txt", wan_3);
        $readmemh("4wan.txt", wan_4);
        $readmemh("5wan.txt", wan_5);
        $readmemh("6wan.txt", wan_6);
        $readmemh("7wan.txt", wan_7);
        $readmemh("8wan.txt", wan_8);
        $readmemh("9wan.txt", wan_9);
        $readmemh("1suo.txt", suo_1);
        $readmemh("2suo.txt", suo_2);
        $readmemh("3suo.txt", suo_3);
        $readmemh("4suo.txt", suo_4);
        $readmemh("5suo.txt", suo_5);
        $readmemh("6suo.txt", suo_6);
        $readmemh("7suo.txt", suo_7);
        $readmemh("8suo.txt", suo_8);
        $readmemh("9suo.txt", suo_9);
        $readmemh("dong.txt", dong);
        $readmemh("nan.txt", nan);
        $readmemh("xi.txt", xi);
        $readmemh("bei.txt", bei);
        $readmemh("hongzhong.txt", hongzhong);
        $readmemh("baiban.txt", baiban);
        $readmemh("facai.txt", facai);
     end
    
    always @ (posedge clk) begin
        case (tile_index)
            1 : oled_data = tong_1[(8 * y) + x];
            2 : oled_data = tong_2[(8 * y) + x];
            3 : oled_data = tong_3[(8 * y) + x];
            4 : oled_data = tong_4[(8 * y) + x];
            5 : oled_data = tong_5[(8 * y) + x];
            6 : oled_data = tong_6[(8 * y) + x];
            7 : oled_data = tong_7[(8 * y) + x];
            8 : oled_data = tong_8[(8 * y) + x];
            9 : oled_data = tong_9[(8 * y) + x];
            11 : oled_data = wan_1[(8 * y) + x];
            12 : oled_data = wan_2[(8 * y) + x];
            13 : oled_data = wan_3[(8 * y) + x];
            14 : oled_data = wan_4[(8 * y) + x];
            15 : oled_data = wan_5[(8 * y) + x];
            16 : oled_data = wan_6[(8 * y) + x];
            17 : oled_data = wan_7[(8 * y) + x];
            18 : oled_data = wan_8[(8 * y) + x];
            19 : oled_data = wan_9[(8 * y) + x];
            21 : oled_data = suo_1[(8 * y) + x];
            22 : oled_data = suo_2[(8 * y) + x];
            23 : oled_data = suo_3[(8 * y) + x];
            24 : oled_data = suo_4[(8 * y) + x];
            25 : oled_data = suo_5[(8 * y) + x];
            26 : oled_data = suo_6[(8 * y) + x];
            27 : oled_data = suo_7[(8 * y) + x];
            28 : oled_data = suo_8[(8 * y) + x];
            29 : oled_data = suo_9[(8 * y) + x];
            30: oled_data = dong[(8 * y) + x];
            31: oled_data = nan[(8 * y) + x];
            32: oled_data = xi[(8 * y) + x];
            33: oled_data = bei[(8 * y) + x];
            34: oled_data = hongzhong[(8 * y) + x];
            35: oled_data = baiban[(8 * y) + x];
            36: oled_data = facai[(8 * y) + x];
            default : oled_data = 16'hFEC7;
        endcase
        
        end
    /*
    integer for_i = 0;
    reg [15:0] tile_data = 0;
    
    initial begin
        for ( for_i = 0; for_i < 16; for_i = for_i + 1 ) begin
            tile_data[for_i] = this_tile[8*y + x + 16 - for_i];
        end
        oled_data = tile_data;
    end
    */
    
    
endmodule
    
