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
    output reg [15:0] led,
    output reg [6:0] seg,
    output reg [3:0] an,
    inout ps2_clk, ps2_data
    );

    // Clocks
    wire clk6p25m, clk1m, clk1k, clk1p0;
    flexible_clock_module clk6p25m_mod(.clk(clk), .m(32'd7), .flex_clk(clk6p25m));
    flexible_clock_module clk1m_mod(.clk(clk), .m(32'd49), .flex_clk(clk1m));
    flexible_clock_module clk1k_mod(.clk(clk), .m(32'd49999), .flex_clk(clk1k));
    flexible_clock_module clk1p0_mod(.clk(clk), .m(32'd49999999), .flex_clk(clk1p0));
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
    
    wire [7:0] random_number;   
    lfsr lfsr_mod (clk, 0, random_number);
    
    reg [5:0] draw_pile[135:0]; 
    reg [7:0] shuffle_index, move_index;
    reg [5:0] tile_value;
    reg button_pressed = 0;
    reg round_start = 1;
    reg initialised = 0;
    
    // Shuffle all tiles in draw pile
    always @ (posedge clk1m) begin
        if (!initialised) begin
            $readmemb("C:/Users/rodi3/Documents/EE2026 Project/mahjong_game_logic/ee2026_project/MODS.srcs/sources_1/new/tiles.txt", draw_pile);
            initialised = 1;
//            for (duplicate = 0; duplicate < 4; duplicate = duplicate + 1) begin
//                for (tile = 1; tile < 10; tile = tile + 1) begin
//                    draw_pile[index] = tile;
//                    index = index + 1;
//                end
//                for (tile = 11; tile < 20; tile = tile + 1) begin
//                    draw_pile[index] = tile;
//                    index = index + 1;
//                end
//                for (tile = 21; tile < 30; tile = tile + 1) begin
//                    draw_pile[index] = tile;
//                    index = index + 1;
//                end
//                for (tile = 30; tile < 37; tile = tile + 1) begin
//                    draw_pile[index] = tile;
//                    index = index + 1;
//                end
//            end
        end
        if (sw[0] && !button_pressed) begin
            button_pressed = 1;
            shuffle_index = 136;
        end
        else if (!sw[0] && button_pressed && shuffle_index == 1) begin
            button_pressed = 0;
        end
        
        if (shuffle_index > 1) begin
            if (round_start) begin
                move_index = random_number % shuffle_index;
                tile_value = draw_pile[move_index];
                round_start = 0;
            end
            if (move_index == shuffle_index - 1) begin
                draw_pile[shuffle_index - 1] = tile_value;
                round_start = 1;
                shuffle_index = shuffle_index - 1;
            end
            else begin
                draw_pile[move_index] = draw_pile[move_index + 1];
                move_index = move_index + 1;
            end          
        end
    end
    
    // Incrementing counter to show 13 drawn tiles
    reg [3:0] hand_index = 0;
    always @ (posedge clk1p0) begin
        hand_index = (hand_index < 12) ? hand_index + 1 : 0;
    end
    
    // Show shuffled drawn tiles in hand on 7-segment display and LEDs
    reg counter = 0;
    reg [3:0] digit;
    always @ (posedge clk1k) begin
        if (!button_pressed) begin
            if (!counter) begin
                an = 4'b1110;
                digit = draw_pile[hand_index] % 10;
            end
            else begin
                an = 4'b1101;
                digit = draw_pile[hand_index] / 10;
            end
            case (digit)
                0: seg = 7'b1000000;
                1: seg = 7'b1111001;
                2: seg = 7'b0100100;
                3: seg = 7'b0110000;
                4: seg = 7'b0011001;
                5: seg = 7'b0010010;
                6: seg = 7'b0000010;
                7: seg = 7'b1111000;
                8: seg = 7'b0000000;
                9: seg = 7'b0010000;
            endcase
            led = draw_pile[hand_index];   
            counter = !counter;
        end
    end

endmodule