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


module master(input clk, clk1m, btnU, btnC, btnD, btnL, btnR, input [15:0] sw, input [6:0] x, input [5:0] y, output reg [15:0] oled_data = 16'h0, 
    output reg [15:0] led = 0,
    output reg [6:0] seg,
    output reg [3:0] an
    );

    // LFSR
    wire [7:0] lfsr;   
    lfsr lfsr_mod (clk, 0, lfsr);
    
    // Hands
    reg [5:0] draw_pile[135:0], hand_0[17:0], hand_1[17:0], hand_2[17:0], hand_3[17:0];
    
    // Setup variables
    reg shuffle, shuffling, shuffled, started_shuffling, initialised, start_game = 0;
    reg [7:0] shuffle_index = 0;
    reg [7:0] random_number, random_index;
    reg [5:0] tile_value;
    
    // Game variables
    reg [1:0] player = 0;
    reg [7:0] draw_pile_index = 52;
    wire [3:0] discard_index;
    reg [3:0] shift_index, check_index = 0;
    reg [5:0] discard_tile;
    reg tile_discarded = 0;
    reg pon, chi, kan = 0;
    reg [2:0] kan_count_0, kan_count_1, kan_count_2, kan_count_3 = 0;
    reg checked_pon_chi_kan = 0;
    reg [1:0] same_tile_counter = 0;
    reg [3:0] chi_checker = 0;
    reg pon_possible, kan_possible = 0;
    reg [2:0] chi_possible = 0;
    
    // Button/counter variables
    reg btnC_pressed, btnU_pressed, btnD_pressed, btnL_pressed, btnR_pressed = 0;
    wire [31:0] btnC_counter, btnU_counter, btnD_counter, btnL_counter, btnR_counter, tile_discarded_counter;
    assign discard_index = sw[7:4];
    // One-hot to integer converter
    //one_hot_to_integer one_hot_to_integer_mod(.clk(clk), .array(sw[13:0]), .int(discard_index));
    counter_200ms btnC_counter_mod(.clk1m(clk1m), .btn_pressed(btnC_pressed), .counter(btnC_counter));
    counter_200ms btnU_counter_mod(.clk1m(clk1m), .btn_pressed(btnC_pressed), .counter(btnU_counter));
    counter_200ms btnD_counter_mod(.clk1m(clk1m), .btn_pressed(btnC_pressed), .counter(btnD_counter));
    counter_200ms btnL_counter_mod(.clk1m(clk1m), .btn_pressed(btnC_pressed), .counter(btnL_counter));
    counter_200ms btnR_counter_mod(.clk1m(clk1m), .btn_pressed(btnC_pressed), .counter(btnR_counter));
    counter_5s tile_discarded_counter_mod(.clk1m(clk1m), .tile_discarded(tile_discarded), .counter(tile_discarded_counter));

    // Shuffle all tiles in draw pile
    always @ (posedge clk1m) begin
        // Initialise tiles
        if (!initialised) begin
            $readmemb("C:/Users/rodi3/Documents/EE2026 Project/ee2026_project/MODS.srcs/sources_1/new/tiles.txt", draw_pile);
            initialised = 1;
        end
        
//        // Shuffle tiles
        if (shuffle && !shuffling) begin
            shuffle_index = 136;
            shuffle = 0;
            shuffling = 1;
        end
        else if (shuffle_index == 1) begin
            shuffling = 0;
            shuffled = 1;
        end
        random_number <= lfsr;
        // Fisher-Yates shuffle algorithm
        if (shuffle_index > 0) begin
            random_index = random_number % shuffle_index;
            tile_value = draw_pile[shuffle_index - 1];
            draw_pile[shuffle_index - 1] = draw_pile[random_index];
            draw_pile[random_index] = tile_value;
            
            // Distribute tiles to hands
            if (shuffle_index >= 40 && shuffle_index < 53) begin
                hand_0[shuffle_index - 40] = draw_pile[shuffle_index - 1];
            end
            if (shuffle_index >= 27 && shuffle_index < 40) begin
                hand_1[shuffle_index - 27] = draw_pile[shuffle_index - 1];
            end
            if (shuffle_index >= 14 && shuffle_index < 27) begin
                hand_2[shuffle_index - 14] = draw_pile[shuffle_index - 1];
            end
            if (shuffle_index < 14) begin
                hand_3[shuffle_index - 1] = draw_pile[shuffle_index - 1];
            end
            
            shuffle_index = shuffle_index - 1;
        end

        // Game setup
        start_game = btnC;
        if (start_game) begin
            if (!started_shuffling) begin
                shuffle = 1;
                started_shuffling = 1;
                btnC_pressed = 1;
            end
        end
        
        // Game in progress
        if (shuffled) begin
            oled_data = 16'hFFFF;
            // Reset buttons
            if (!btnC && btnC_pressed && btnC_counter == 200000) begin
                btnC_pressed = 0;
            end
            if (!btnU && btnU_pressed && btnU_counter == 200000) begin
                btnU_pressed = 0;
            end
            if (!btnD && btnD_pressed && btnD_counter == 200000) begin
                btnD_pressed = 0;
            end
            if (!btnL && btnL_pressed && btnL_counter == 200000) begin
                btnL_pressed = 0;
            end
            if (!btnR && btnR_pressed && btnR_counter == 200000) begin
                btnR_pressed = 0;
            end
            
            // Draw game
            if (draw_pile_index == 121) begin
                
            end
            
            // Draw and discard tile during turn
            if (player == 0) begin
                // Collect tiles
                if (!tile_discarded) begin
                    if (pon || chi) begin
                        hand_0[13] = discard_tile;
                    end
                    else if (kan) begin
                        hand_0[13 + kan_count_0] = discard_tile;
                        hand_0[13] = draw_pile[draw_pile_index];
                    end
                    else begin
                        hand_0[13] = draw_pile[draw_pile_index];
                    end
                end
                // Discard selected tile
                if (btnC && !btnC_pressed) begin
                    btnC_pressed = 1;
                    discard_tile = hand_0[discard_index];
                    for (shift_index = 0; shift_index < 13; shift_index = shift_index + 1) begin
                        if (shift_index >= discard_index) begin
                            hand_0[shift_index] = hand_0[shift_index + 1];
                        end
                    end
                    hand_0[13] = 0;
                    draw_pile_index = draw_pile_index + 1;
                    tile_discarded = 1;
                    pon = 0;
                    chi = 0;
                    kan = 0;
                end
            end
            else if (player == 1) begin
                if (!tile_discarded) begin
                    if (pon || chi) begin
                        hand_1[13] = discard_tile;
                    end
                    else if (kan) begin
                        hand_1[13 + kan_count_1] = discard_tile;
                        hand_1[13] = draw_pile[draw_pile_index];
                    end
                    else begin
                        hand_1[13] = draw_pile[draw_pile_index];
                    end
                end
                if (btnC && !btnC_pressed) begin
                    btnC_pressed = 1;
                    discard_tile = hand_1[discard_index];
                    for (shift_index = 0; shift_index < 13; shift_index = shift_index + 1) begin
                        if (shift_index >= discard_index) begin
                            hand_1[shift_index] = hand_1[shift_index + 1];
                        end
                    end
                    draw_pile_index = draw_pile_index + 1;
                    hand_1[13] = 0;
                    tile_discarded = 1;
                    pon = 0;
                    chi = 0;
                    kan = 0;
                end
            end
            else if (player == 2) begin
                if (!tile_discarded) begin
                    if (pon || chi) begin
                        hand_2[13] = discard_tile;
                    end
                    else if (kan) begin
                        hand_2[13 + kan_count_2] = discard_tile;
                        hand_2[13] = draw_pile[draw_pile_index];
                    end
                    else begin
                        hand_2[13] = draw_pile[draw_pile_index];
                    end
                end
                if (btnC && !btnC_pressed) begin
                    btnC_pressed = 1;
                    discard_tile = hand_2[discard_index];
                    for (shift_index = 0; shift_index < 13; shift_index = shift_index + 1) begin
                        if (shift_index >= discard_index) begin
                            hand_2[shift_index] = hand_2[shift_index + 1];
                        end
                    end
                    draw_pile_index = draw_pile_index + 1;
                    hand_2[13] = 0;
                    tile_discarded = 1;
                    pon = 0;
                    chi = 0;
                    kan = 0;
                end
            end
            else if (player == 3) begin
                if (!tile_discarded) begin
                    if (pon || chi) begin
                        hand_3[13] = discard_tile;
                    end
                    else if (kan) begin
                        hand_3[13 + kan_count_3] = discard_tile;
                        hand_3[13] = draw_pile[draw_pile_index];
                    end
                    else begin
                        hand_3[13] = draw_pile[draw_pile_index];
                    end
                end
                if (btnC && !btnC_pressed) begin
                    btnC_pressed = 1;
                    discard_tile = hand_3[discard_index];
                    for (shift_index = 0; shift_index < 13; shift_index = shift_index + 1) begin
                        if (shift_index >= discard_index) begin
                            hand_3[shift_index] = hand_3[shift_index + 1];
                        end
                    end
                    draw_pile_index = draw_pile_index + 1;
                    hand_3[13] = 0;
                    tile_discarded = 1;
                    pon = 0;
                    chi = 0;
                    kan = 0;
                end
            end
            
            // Wait 5s after tile is discarded
            if (tile_discarded && tile_discarded_counter == 5000000) begin
                tile_discarded = 0;
                player = player + 1;
            end
            
            // pon, chi, or kan
            if (tile_discarded) begin
                // Check for pon/chi/kan
                if (!checked_pon_chi_kan) begin
                    checked_pon_chi_kan = 1;
                    same_tile_counter = 0;
                    chi_checker = 0;
                    pon_possible = 0;
                    kan_possible = 0;
                    chi_possible = 0;
                    for (check_index = 0; check_index < 13; check_index = check_index + 1) begin
                        if (hand_0[check_index] == discard_tile) begin
                            same_tile_counter = same_tile_counter + 1;
                        end
                        else if (hand_0[check_index] == discard_tile - 2) begin
                            chi_checker[3] = 1;
                        end
                        else if (hand_0[check_index] == discard_tile - 1) begin
                            chi_checker[2] = 1;
                        end
                        else if (hand_0[check_index] == discard_tile + 1) begin
                            chi_checker[1] = 1;
                        end
                        else if (hand_0[check_index] == discard_tile + 2) begin
                            chi_checker[0] = 1;
                        end
                    end
                    if (same_tile_counter >= 2) begin
                        pon_possible = 1;
                    end
                    if (same_tile_counter == 3) begin
                        kan_possible = 1;
                    end
                    if (discard_tile < 30) begin
                        if (discard_tile % 10 == 1) begin
                            chi_possible[2] = (chi_checker[1:0] == 2'b11) ? 1 : 0;
                        end
                        else if (discard_tile % 10 == 2) begin
                            chi_possible[2] = (chi_checker[1:0] == 2'b11) ? 1 : 0;
                            chi_possible[1] = (chi_checker[2:1] == 2'b11) ? 1 : 0;
                        end
                        else if (discard_tile % 10 == 8) begin
                            chi_possible[1] = (chi_checker[2:1] == 2'b11) ? 1 : 0;
                            chi_possible[0] = (chi_checker[3:2] == 2'b11) ? 1 : 0;
                        end
                        else if (discard_tile % 10 == 9) begin
                            chi_possible[0] = (chi_checker[3:2] == 2'b11) ? 1 : 0;
                        end
                        else begin
                            chi_possible[2] = (chi_checker[1:0] == 2'b11) ? 1 : 0;
                            chi_possible[1] = (chi_checker[2:1] == 2'b11) ? 1 : 0;
                            chi_possible[0] = (chi_checker[3:2] == 2'b11) ? 1 : 0;
                        end
                    end
                end
                
                // Player 0 pon/chi/kan
                case (sw[3:0])
                    4'b0001: begin
                        if (player != 0 && btnL && !btnL_pressed) begin
                            pon = 1;
                            tile_discarded = 0;
                            player = 0;
                        end
                        else if (player != 0 && btnU && !btnU_pressed) begin
                            chi = 1;
                            tile_discarded = 0;
                            player = 0;
                        end
                        else if (player != 0 && btnR && !btnR_pressed) begin
                            kan = 1;
                            kan_count_0 = kan_count_0 + 1;
                            tile_discarded = 0;
                            player = 0;
                        end
                    end
                    4'b0010: begin
                        if (player != 1 && btnL && !btnL_pressed) begin
                            pon = 1;
                            tile_discarded = 0;
                            player = 1;
                        end
                        else if (player != 1 && btnU && !btnU_pressed) begin
                            chi = 1;
                            tile_discarded = 0;
                            player = 1;
                        end
                        else if (player != 1 && btnR && !btnR_pressed) begin
                            kan = 1;
                            kan_count_1 = kan_count_1 + 1;
                            tile_discarded = 0;
                            player = 1;
                        end
                    end
                    4'b0100: begin
                        if (player != 2 && btnL && !btnL_pressed) begin
                            pon = 1;
                            tile_discarded = 0;
                            player = 2;
                        end
                        else if (player != 2 && btnU && !btnU_pressed) begin
                            chi = 1;
                            tile_discarded = 0;
                            player = 2;
                        end
                        else if (player != 2 && btnR && !btnR_pressed) begin
                            kan = 1;
                            kan_count_2 = kan_count_2 + 1;
                            tile_discarded = 0;
                            player = 2;
                        end
                    end
                    4'b1000: begin
                        if (player != 3 && btnL && !btnL_pressed) begin
                            pon = 1;
                            tile_discarded = 0;
                            player = 3;
                        end
                        else if (player != 3 && btnU && !btnU_pressed) begin
                            chi = 1;
                            tile_discarded = 0;
                            player = 3;
                        end
                        else if (player != 3 && btnR && !btnR_pressed) begin
                            kan = 1;
                            kan_count_3 = kan_count_3 + 1;
                            tile_discarded = 0;
                            player = 3;
                        end
                    end
                endcase
            end
        end
    end
        
    wire clk1k, clk1p0;
    flexible_clock_module clk1p0_mod(.clk(clk), .m(32'd49999999), .flex_clk(clk1p0));
    flexible_clock_module clk1k_mod(.clk(clk), .m(32'd49999), .flex_clk(clk1k));
    // Incrementing counter to show 13 drawn tiles
    reg [15:0] display_hand_index = 0;
    always @ (posedge clk1p0) begin
        display_hand_index = (display_hand_index == 17) ? 0: display_hand_index + 1;
    end
    
    // Show hands on 7-segment display and LEDs
    reg counter = 0;
    reg [3:0] digit;
    always @ (posedge clk1k) begin
        if (!counter) begin
            an = 4'b1110;
            case (sw[15:14])
                2'b00: digit = hand_0[display_hand_index] % 10;
                2'b01: digit = hand_1[display_hand_index] % 10;
                2'b10: digit = hand_2[display_hand_index] % 10;
                2'b11: digit = hand_3[display_hand_index] % 10;
            endcase
        end
        else begin
            an = 4'b1101;
            case (sw[15:14])
                2'b00: digit = hand_0[display_hand_index] / 10;
                2'b01: digit = hand_1[display_hand_index] / 10;
                2'b10: digit = hand_2[display_hand_index] / 10;
                2'b11: digit = hand_3[display_hand_index] / 10;
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
        led = draw_pile[display_hand_index];   
        led = display_hand_index;
        led[13:0] = 1 << display_hand_index;
        led[15:14] = player;
        counter = !counter;
    end
    
endmodule
