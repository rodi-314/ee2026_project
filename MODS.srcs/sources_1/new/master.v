`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.11.2024 19:26:16
// Design Name: 
// Module Name: master
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


module master(input clk, clk1m, btnC, btnD, input [15:0] sw, input [6:0] x, input [5:0] y, output reg [15:0] oled_data = 16'h0, 
    output reg [15:0] led,
    output reg [6:0] seg,
    output reg [3:0] an
    );

    // LFSR
    wire [7:0] lfsr;   
    lfsr lfsr_mod (clk, 0, lfsr);
    
    // Hands
    reg [5:0] draw_pile[135:0]; 
    reg [5:0] hand_1[17:0];
    reg [5:0] hand_2[17:0];
    reg [5:0] hand_3[17:0];
    reg [5:0] hand_4[17:0];
    reg [5:0] hand_index;
    reg [7:0] draw_pile_index;
    
    // Shuffling variables
    reg shuffle = 0;
    reg [7:0] shuffle_index = 1;
    reg [7:0] random_number, random_index;
    reg [5:0] tile_value;
    reg shuffling = 0;
    reg initialised = 0;
    reg start_game = 0;
    reg started_shuffling = 0;
    
    reg button_pressed = 0;
    
    // Unused variables
//    reg round_start = 1;
//    reg [7:0] move_index;
//    reg [2:0] duplicate;
//    reg [5:0] tile;
//    reg [7:0] index;

    // Shuffle all tiles in draw pile
    always @ (posedge clk1m) begin
        if (btnC && !button_pressed) begin
            start_game = 1;
            button_pressed = 1;
        end
        // Initialise tiles
        if (!initialised) begin
            $readmemb("C:/Users/rodi3/Documents/EE2026 Project/ee2026_project/MODS.srcs/sources_1/new/tiles.txt", draw_pile);
            initialised = 1;
            for (hand_index = 0; hand_index < 18; hand_index = hand_index + 1) begin
                hand_1[hand_index] = 0;
                hand_2[hand_index] = 0;
                hand_3[hand_index] = 0;
                hand_4[hand_index] = 0;
            end
            // For loop array initialisation (very slow bitstream generation)
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
        
//        // Shuffle tiles
        if (shuffle && !shuffling) begin
            shuffle_index = 136;
            shuffle = 0;
            shuffling = 1;
        end
        else if (shuffle_index == 1) begin
            shuffling = 0;
        end
        random_number <= lfsr;
        // Fisher-Yates shuffle algorithm
        if (shuffle_index > 0) begin
            random_index = random_number % shuffle_index;
            tile_value = draw_pile[shuffle_index - 1];
            draw_pile[shuffle_index - 1] = draw_pile[random_index];
            draw_pile[random_index] = tile_value;
            
            // Distribute tiles to hands
            if (shuffle_index >= 39 && shuffle_index < 53) begin
                hand_1[shuffle_index - 40] = draw_pile[shuffle_index - 1];
            end
            if (shuffle_index >= 26 && shuffle_index < 39) begin
                hand_2[shuffle_index - 27] = draw_pile[shuffle_index - 1];
            end
            if (shuffle_index >= 13 && shuffle_index < 26) begin
                hand_3[shuffle_index - 14] = draw_pile[shuffle_index - 1];
            end
            if (shuffle_index < 13) begin
                hand_4[shuffle_index - 1] = draw_pile[shuffle_index - 1];
            end
            
            shuffle_index = shuffle_index - 1;
        end
        // O(n^2) random selection algorithm
//        if (shuffle_index > 1) begin
//            if (round_start) begin
//                move_index = random_number % shuffle_index;
//                tile_value = draw_pile[move_index];
//                round_start = 0;
//            end
//            if (move_index == shuffle_index - 1) begin
//                draw_pile[shuffle_index - 1] = tile_value;
//                round_start = 1;
//                shuffle_index = shuffle_index - 1;
//            end
//            else begin
//                draw_pile[move_index] = draw_pile[move_index + 1];
//                move_index = move_index + 1;
//            end          
//        end

//        // Start game
        if (start_game) begin
            if (!started_shuffling) begin
                shuffle = 1;
                started_shuffling = 1;
            end
        end
    end
        
    wire clk1k, clk1p0;
    flexible_clock_module clk1p0_mod(.clk(clk), .m(32'd49999999), .flex_clk(clk1p0));
    flexible_clock_module clk1k_mod(.clk(clk), .m(32'd49999), .flex_clk(clk1k));
    // Incrementing counter to show 13 drawn tiles
    reg [15:0] display_hand_index = 0;
    always @ (posedge clk1p0) begin
        display_hand_index = (display_hand_index == 135) ? 0: (btnD ? 0 : display_hand_index + 1);
    end
    
    // Show shuffled drawn tiles in hand on 7-segment display and LEDs
    reg counter = 0;
    reg [3:0] digit;
    always @ (posedge clk1k) begin
        if (!counter) begin
            an = 4'b1110;
//            digit = draw_pile[display_hand_index] % 10;
            case (sw[4:0])
                5'b00001: digit = draw_pile[display_hand_index] % 10;
                5'b00010: digit = hand_1[display_hand_index] % 10;
                5'b00100: digit = hand_2[display_hand_index] % 10;
                5'b01000: digit = hand_3[display_hand_index] % 10;
                5'b10000: digit = hand_4[display_hand_index] % 10;
            endcase
        end
        else begin
            an = 4'b1101;
//            digit = draw_pile[display_hand_index] / 10;
            case (sw[4:0])
                5'b00001: digit = draw_pile[display_hand_index] / 10;
                5'b00010: digit = hand_1[display_hand_index] / 10;
                5'b00100: digit = hand_2[display_hand_index] / 10;
                5'b01000: digit = hand_3[display_hand_index] / 10;
                5'b10000: digit = hand_4[display_hand_index] / 10;
            endcase
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
//        led = draw_pile[display_hand_index];   
        led = display_hand_index;
        counter = !counter;
    end
    
endmodule
