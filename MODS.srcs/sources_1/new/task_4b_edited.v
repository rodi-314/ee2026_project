`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.10.2024
// Design Name: 
// Module Name: task_4b
// Project Name: 
// Target Devices: Basys 3 Board
// Tool Versions: 
// Description: 
// This module draws 12 squares on an OLED display, allows selection via switches,
// makes selected squares blink at 1 Hz, and rearranges selected squares left/right
// using left and right buttons with proper debouncing and edge detection.
//
// Dependencies: 
// - flexible_clock_module: Generates necessary clock signals.
// - debounce: Debouncing module for button inputs.
//
// Revision:
// Revision 0.02 - Enhanced with blinking and fixed rearrangement logic
// Additional Comments:
//
//
//////////////////////////////////////////////////////////////////////////////////

module uiux(
    input clk,            // 100 MHz clock on Basys 3
    input clk25m,         // 25 MHz clock
    input clk2k,          // 2 kHz clock
    input clk50,          // 50 Hz --> '20 Hz' clock, due to legacy naming
    input clk1,           // 1 Hz clock
    input btnU,           // Unused in current context
    input btnC,           // Unused in current context
    input btnD,           // Unused in current context
    input btnR,           // Right rearrange button
    input btnL,           // Left rearrange button
    input restart,        // Reset button
    input [15:0] sw,      // Switches [11:0] correspond to squares
    input [6:0] x,        // OLED X coordinate
    input [5:0] y,        // OLED Y coordinate
    input [6:0] mx,        // Mouse X coordinate
    input [5:0] my,        // Mouse Y coordinate
    input [3:0] mz,        // Mouse Z coordinate
    input left,          // Mouse left button
    input middle,          // Mouse middle button
    input right,          // Mouse right button
    input [12:0] pixel_index, // OLED display index (added)
    //input [107:0] player_hand // 18 by 6 bit to be received from UART and game logic 
    output reg [15:0] oled_data,  // OLED data output
    output [15:0] led,  // LED output
    output btnL_pulse,
    output btnR_pulse,
    output reg showDiscardDeck = 0
    );
    // added variables from layouts and tiles
    reg [5:0] layout = 0;
    
    reg [15:0] layout_00 [6143:0]; 
    reg [15:0] layout_01 [6143:0]; 
    reg [15:0] layout_02 [6143:0]; 
    reg [15:0] layout_03 [6143:0]; 
    reg [15:0] layout_04 [6143:0]; 
    reg [15:0] layout_10 [6143:0]; 
    reg [15:0] layout_20 [6143:0]; 
    reg [15:0] layout_30 [6143:0]; 
    reg [15:0] layout_40 [6143:0]; 
    reg [15:0] layout_11 [6143:0]; 
    reg [15:0] layout_12 [6143:0]; 
    reg [15:0] layout_21 [6143:0]; 
    reg [15:0] layout_13 [6143:0]; 
    reg [15:0] layout_31 [6143:0]; 
    reg [15:0] layout_22 [6143:0]; 
    
    initial begin
        $readmemh("layout_00.txt",layout_00);
        $readmemh("layout_01.txt",layout_01);
        $readmemh("layout_02.txt",layout_02);
        $readmemh("layout_03.txt",layout_03);
        $readmemh("layout_04.txt",layout_04);
        $readmemh("layout_10.txt",layout_10);
        $readmemh("layout_20.txt",layout_20);
        $readmemh("layout_30.txt",layout_30);
        $readmemh("layout_40.txt",layout_40);
        $readmemh("layout_11.txt",layout_11);
        $readmemh("layout_12.txt",layout_12);
        $readmemh("layout_21.txt",layout_21);
        $readmemh("layout_13.txt",layout_13);
        $readmemh("layout_31.txt",layout_31);
        $readmemh("layout_22.txt",layout_22);
    end
    
    reg [5:0] tile_index_1 = 1, tile_index_2 = 0, tile_index_3 = 0, tile_index_4 = 2, tile_index_5 = 0, tile_index_6 = 0, tile_index_7 = 0, tile_index_8 = 3,
    tile_index_9 = 0, tile_index_10 = 0, tile_index_11 = 4, tile_index_12 = 0, tile_index_13 = 0, incoming_tile_index = 0, discarded_tile_index = 0, 
    kan_1_index, kan_2_index, kan_3_index, kan_4_index;
    
    
    wire [15:0] tile_data_1, tile_data_2, tile_data_3, tile_data_4, tile_data_5, tile_data_6, tile_data_7,
    tile_data_8, tile_data_9, tile_data_10, tile_data_11, tile_data_12, tile_data_13, incoming_tile_data, discarded_tile_data,
    kan_tile_1, kan_tile_2, kan_tile_3, kan_tile_4;
    
    reg [6:0] tile_8_x = 2, tile_9_x = 14, tile_10_x = 26, tile_11_x = 38, tile_12_x = 50, tile_13_x = 62;
    reg [5:0] tile_8_y = 33, tile_9_y = 33, tile_10_y = 33, tile_11_y = 33, tile_12_y = 33, tile_13_y = 33;
    
    reg [6:0] tile_1_x = 2, tile_2_x = 14, tile_3_x = 26, tile_4_x = 38, tile_5_x = 50, tile_6_x = 62, tile_7_x = 74;
    reg [5:0] tile_1_y = 49, tile_2_y = 49, tile_3_y = 49, tile_4_y = 49, tile_5_y = 49, tile_6_y = 49, tile_7_y = 49;

    reg [6:0] incoming_tile_x = 85, discarded_tile_x = 44;
    reg [5:0] incoming_tile_y = 33, discarded_tile_y = 7; 
    
    reg tile_discarded = 1'b0;
    reg player_turn = 1'b0;
    reg cycle_kan = 1'b0;
    
    tile_designs tile_1 (clk, tile_index_1, x-tile_1_x, y-tile_1_y, tile_data_1);
    tile_designs tile_2 (clk, tile_index_2, x-tile_2_x, y-tile_2_y, tile_data_2);
    tile_designs tile_3 (clk, tile_index_3, x-tile_3_x, y-tile_3_y, tile_data_3);
    tile_designs tile_4 (clk, tile_index_4, x-tile_4_x, y-tile_4_y, tile_data_4);
    tile_designs tile_5 (clk, tile_index_5, x-tile_5_x, y-tile_5_y, tile_data_5);
    tile_designs tile_6 (clk, tile_index_6, x-tile_6_x, y-tile_6_y, tile_data_6);
    tile_designs tile_7 (clk, tile_index_7, x-tile_7_x, y-tile_7_y, tile_data_7);
    tile_designs tile_8 (clk, tile_index_8, x-tile_8_x, y-tile_8_y, tile_data_8);
    tile_designs tile_9 (clk, tile_index_9, x-tile_9_x, y-tile_9_y, tile_data_9);
    tile_designs tile_10 (clk, tile_index_10, x-tile_10_x, y-tile_10_y, tile_data_10);
    tile_designs tile_11 (clk, tile_index_11, x-tile_11_x, y-tile_11_y, tile_data_11);
    tile_designs tile_12 (clk, tile_index_12, x-tile_12_x, y-tile_12_y, tile_data_12);
    tile_designs tile_13 (clk, tile_index_13, x-tile_13_x, y-tile_13_y, tile_data_13);
    tile_designs incoming_tile (clk, incoming_tile_index, x-incoming_tile_x, y-incoming_tile_y, incoming_tile_data);
    tile_designs discarded_tile (clk, discarded_tile_index, x-discarded_tile_x, y-discarded_tile_y, discarded_tile_data);
    tile_designs kan_1 (clk, tile_index_13, x-(tile_13_x+8), y-tile_13_y, kan_tile_1);
    tile_designs kan_2 (clk, tile_index_10, x-(tile_10_x+8), y-tile_10_y, kan_tile_2);
    tile_designs kan_3 (clk, tile_index_3, x-(tile_3_x+8), y-tile_6_y, kan_tile_3);
    tile_designs kan_4 (clk, tile_index_6, x-(tile_6_x+8), y-tile_6_y, kan_tile_4);

    // Registers to track cursor position
    reg [6:0] last_x, last_y;
    reg [6:0] start_x, start_y; // Starting point of gesture

    reg [6:0] emote_offset = 50;
    reg [7:0] emote_wait = 0;
    reg [1:0] emote = 0; // 0: dont show; 1: emerging; 2: fully emerged; 3: retreating
    reg emote_i = 0; // 0: laugh, 1: cry

    reg select_emote = 1;

    reg [4:0] blink = 0;
    reg blinkUp = 0;

    reg [15:0] cursor1_data [255:0];
    reg [15:0] cursor2_data [255:0];
    reg [15:0] cursorcool_data [255:0];
    reg [15:0] cursor4_data [255:0];
    reg [15:0] cursor5_data [255:0];
    reg [15:0] emote_data [2499:0];
    reg [15:0] emote2_data [2499:0];
    reg [15:0] eye_data [195:0];
    reg [15:0] eye2_data [195:0];
    reg [15:0] eye3_data [195:0];
    reg [15:0] eye4_data [195:0];

    reg cursorIsCool = 0;

    initial begin
        $readmemh("cursor1.txt", cursor1_data);
        $readmemh("cursor2.txt", cursor2_data);
        $readmemh("cursor3.txt", cursorcool_data);
        $readmemh("cursorright.txt", cursor4_data);
        $readmemh("cursorleft.txt", cursor5_data);
        $readmemh("emote.txt", emote_data);
        $readmemh("emote2.txt", emote2_data);
        $readmemh("eye.txt", eye_data);
        $readmemh("eye2.txt", eye2_data);
        $readmemh("eye3.txt", eye3_data);
        $readmemh("eye4.txt", eye4_data);
    end

    // Flags for detecting gestures instantaneously (2 for tick for each stroke, southeast northeast)
    reg straight_left, straight_right, tick_se, tick_ne;
    // Flags for detecting gestures (complete)
    integer gesture_left, gesture_right, gesture_tick_se, gesture_tick_ne;

    // Right button state tracking
    reg right_button_last, right_button_current;

    assign led[15] = gesture_left>0;
    assign led[14] = gesture_right>0;
    assign led[13] = gesture_tick_se>0;
    assign led[12] = gesture_tick_ne>0;
    assign led[11] = straight_left;
    assign led[10] = straight_right;
    assign led[9] = tick_se;
    assign led[8] = tick_ne;
    
    // ----------------------------------
    // Debounce Modules for btnL and btnR
    // ----------------------------------
    
    // Instantiate debounce for btnL
    debounce debounce_btnL (
        .CLOCK(clk2k),
        .pbC(btnL),
        .debounced_pulse(btnL_pulse)
    );
    
    // Instantiate debounce for btnR
    debounce debounce_btnR (
        .CLOCK(clk2k),
        .pbC(btnR),
        .debounced_pulse(btnR_pulse)
    );
    
    // ----------------------------------
    // Square Colors (Distinct)
    // 5-6-5 RGB Format
    // ----------------------------------
    wire [15:0] square_colors [11:0];
    assign square_colors[0]  = 16'hF800; // Red
    assign square_colors[1]  = 16'h07E0; // Green
    assign square_colors[2]  = 16'h001F; // Blue
    assign square_colors[3]  = 16'hFFE0; // Yellow
    assign square_colors[4]  = 16'hF81F; // Magenta
    assign square_colors[5]  = 16'h07FF; // Cyan
    assign square_colors[6]  = 16'hFFFF; // White
    assign square_colors[7]  = 16'hE000; // Dark Red
    assign square_colors[8]  = 16'h03E0; // Dark Green
    assign square_colors[9]  = 16'h000F; // Dark Blue
    assign square_colors[10] = 16'hFFE0; // Yellow
    assign square_colors[11] = 16'hF81F; // Magenta
    
    // ----------------------------------
    // Square Ordering Registers for Each Row
    // ----------------------------------
    reg [3:0] row1_order [5:0]; // Row 1: 6 squares (indices 0-5)
    reg [3:0] row2_order [5:0]; // Row 2: 6 squares (indices 6-11)
    reg [3:0] temp;
    
    integer j; // Procedural loop counter
    
    // ----------------------------------
    // Initialize Ordering and Handle Rearrangement
    // ----------------------------------
    always @(posedge clk2k or posedge restart) begin
        if (restart) begin
            // Initialize row1_order with indices 0-5
            for (j = 0; j < 6; j = j + 1) begin
                row1_order[j] = j;
                row2_order[j] = j + 6;
            end
        end
        else begin
    
            // Handle Right Button Press: Shift selected squares right
            if (btnR_pulse) begin
                // Row 1: Shift Right
                for (j = 4; j >= 0; j = j - 1) begin
                    if (sw[row1_order[j]] && ~sw[row1_order[j+1]]) begin
                        // Swap with the right neighbor
                        temp = row1_order[j];
                        row1_order[j]   = row1_order[j+1];
                        row1_order[j+1] = temp;
                    end
                end
    
                // Row 2: Shift Right
                for (j = 4; j >= 0; j = j - 1) begin
                    if (sw[row2_order[j]] && ~sw[row2_order[j+1]]) begin
                        // Swap with the right neighbor
                        temp = row2_order[j];
                        row2_order[j]   = row2_order[j+1];
                        row2_order[j+1] = temp;
                    end
                end
            end
            
            // Handle Left Button Press: Shift selected squares left
            else if (btnL_pulse) begin
                // Row 1: Shift Left
                for (j = 1; j < 6; j = j + 1) begin
                    if (sw[row1_order[j]] && ~sw[row1_order[j-1]]) begin
                        // Swap with the left neighbor
                        temp = row1_order[j];
                        row1_order[j]   = row1_order[j-1];
                        row1_order[j-1] = temp;
                    end
                end
    
                // Row 2: Shift Left
                for (j = 1; j < 6; j = j + 1) begin
                    if (sw[row2_order[j]] && ~sw[row2_order[j-1]]) begin
                        // Swap with the left neighbor
                        temp = row2_order[j];
                        row2_order[j]   = row2_order[j-1];
                        row2_order[j-1] = temp;
                    end
                end
            end
        end
        
        case (layout)
            6'o00 : layout = (cycle_kan) ? 6'o10 : 6'o01;
            6'o01 : layout = 6'o02;
            6'o02 : layout = 6'o03;
            6'o03 : layout = 6'o04;
            6'o04 : begin
                layout = 6'o00;
                cycle_kan = 1'b1;
                end
                
            6'o10 : layout = 6'o20;
            6'o20 : layout = 6'o30;
            6'o30 : layout = 6'o40;            
            6'o40 : begin
                layout = 6'o11;
                cycle_kan = 1'b0;
                end
            
            6'o11 : layout = 6'o12;
            6'o12 : layout = 6'o13;
            6'o13 : layout = 6'o31;
            6'o31 : layout = 6'o21;
            6'o21 : layout = 6'o22;
            6'o22 : begin
                layout = 6'o00;
                tile_discarded <= ~tile_discarded;
                player_turn <= ~player_turn;
                end
            endcase
        
    end

    
    // ----------------------------------
    // Define Square Positions
    // 2 rows, 6 columns each
    // ----------------------------------
    localparam SQUARE_WIDTH  = 10;
    localparam SQUARE_HEIGHT = 10;
    localparam X_SPACING     = 5;
    localparam Y1_BASE       = 10;
    localparam Y2_BASE       = 30;
    
    // Calculate X positions for 6 columns with spacing
    wire [6:0] x_start [5:0];
    wire [6:0] x_end   [5:0];
    genvar i_gen; // Separate genvar for generate blocks
    
    generate
        for (i_gen = 0; i_gen < 6; i_gen = i_gen + 1) begin : x_positions
            assign x_start[i_gen] = 10 + i_gen * (SQUARE_WIDTH + X_SPACING);
            assign x_end[i_gen]   = x_start[i_gen] + SQUARE_WIDTH;
        end
    endgenerate
    
    // ----------------------------------
    // Assign oled_data Based on Current Square Positions and Colors
    // ----------------------------------
    always @ (posedge clk25m) begin
        oled_data = 16'h8888; // Default background color (black)
        
        // form initial background
        
        //affix specific designs based on initial hand
        
//        tile_index_1 = player_hand[5:0];
//        tile_index_2 = player_hand[11:6];
//        tile_index_3 = player_hand[17:12];
//        tile_index_4 = player_hand[23:18];
//        tile_index_5 = player_hand[29:24];
//        tile_index_6 = player_hand[35:30];
//        tile_index_7 = player_hand[41:36];
//        tile_index_8 = player_hand[47:42];
//        tile_index_9 = player_hand[53:48];
//        tile_index_10 = player_hand[59:54];
//        tile_index_11 = player_hand[65:60];
//        tile_index_12 = player_hand[71:66];
//        tile_index_13 = player_hand[77:72];
//        incoming_tile_index = player_hand[83:78];
                    
        case (layout)
        6'o01 : begin
            oled_data = layout_01[pixel_index]; // 1x 3-set
            tile_12_x = tile_11_x+8;
            tile_13_x = tile_12_x+8;
            end
            
        6'o02 : begin
            oled_data = layout_02[pixel_index]; // 2x 3-set
            tile_9_x = tile_8_x + 8;
            tile_10_x = tile_9_x + 8;
            tile_11_x = tile_10_x +12;
            tile_12_x = tile_11_x + 8;
            tile_13_x = tile_12_x + 8;
            end
            
        
        6'o03 : begin
            oled_data = layout_03[pixel_index]; // 3x 3-set
            tile_2_x = tile_1_x +8;
            tile_3_x = tile_2_x + 8;
            tile_4_x = tile_3_x + 12;
            tile_5_x = tile_4_x + 12;
            tile_6_x = tile_5_x + 12;
            tile_7_x = tile_6_x + 12;
            tile_4_x = tile_3_x + 12;
            tile_9_x = tile_8_x + 8;
            tile_10_x = tile_9_x + 8;
            tile_11_x = tile_10_x +12;
            tile_12_x = tile_11_x + 8;
            tile_13_x = tile_12_x + 8;
            end
        
        
        6'o04 : begin
            oled_data = layout_04[pixel_index]; // 4x 3-set
            tile_2_x = tile_1_x + 8;
            tile_3_x = tile_2_x + 8;
            tile_4_x = tile_3_x +12;
            tile_5_x = tile_4_x + 8;
            tile_6_x = tile_5_x + 8;
            tile_7_x = tile_6_x + 12;
            tile_9_x = tile_8_x + 8;
            tile_10_x = tile_9_x + 8;
            tile_11_x = tile_10_x +12;
            tile_12_x = tile_11_x + 8;
            tile_13_x = tile_12_x + 8;
            end
        
        6'o10 : begin
            oled_data = layout_10[pixel_index]; // 1x 4-set
            tile_12_x = tile_11_x + 8;
            tile_13_x =  tile_12_x + 8;
            
            if (x >= tile_13_x +8 && x < tile_13_x + 16 && y >= tile_13_y && y < tile_13_y +13) begin
                oled_data = kan_tile_1;
                end
            end
            
        6'o20 : begin
            oled_data = layout_20[pixel_index]; // 2x 4-set
            
            tile_9_x = tile_8_x + 8;
            tile_10_x =  tile_9_x + 8;
            
            if (x >= tile_10_x +8 && x < tile_10_x + 16 && y >= tile_10_y && y < tile_10_y +13) begin
                oled_data = kan_tile_2;
                end            
            
            tile_12_x = tile_11_x + 8;
            tile_13_x =  tile_12_x + 8;
            
            if (x >= tile_13_x+8 && x < tile_13_x + 16 && y >= tile_13_y && y < tile_13_y +13) begin
                oled_data = kan_tile_1;
                end
            end
            
        6'o30 : begin
            oled_data = layout_30[pixel_index]; // 3x 4-set        
            
            tile_2_x = tile_1_x + 8;
            tile_3_x =  tile_2_x + 8;
            
            if (x >= tile_3_x+8 && x < tile_3_x + 16 && y >= tile_3_y && y < tile_3_y +13) begin
                oled_data = kan_tile_3;
                end     
            
            tile_9_x = tile_8_x + 8;
            tile_10_x =  tile_9_x + 8;
            
            if (x >= tile_10_x + 8 && x < tile_10_x + 16 && y >= tile_10_y && y < tile_10_y +13) begin
                oled_data = kan_tile_2;
                end            
            
            tile_12_x = tile_11_x + 8;
            tile_13_x =  tile_12_x + 8;
            
            if (x >= tile_13_x + 8 && x < tile_13_x + 16 && y >= tile_13_y && y < tile_13_y +13) begin
                oled_data = kan_tile_1;
                end
            end
        
        6'o40 :begin 
            oled_data = layout_40[pixel_index]; // 4x 4-set
            
            tile_5_x = tile_4_x + 8;
            tile_6_x =  tile_5_x + 8;
            
            if (x >= tile_6_x +8 && x < tile_6_x + 16 && y >= tile_6_y && y < tile_6_y +13) begin
                oled_data = kan_tile_4;
                end         
            
            tile_2_x = tile_1_x + 8;
            tile_3_x =  tile_2_x + 8;
            
            if (x >= tile_3_x +8 && x < tile_3_x + 16 && y >= tile_3_y && y < tile_3_y +13) begin
                oled_data = kan_tile_3;
                end     
            
            tile_9_x = tile_8_x + 8;
            tile_10_x =  tile_9_x + 8;
            
            if (x >= tile_10_x +8 && x < tile_10_x + 16 && y >= tile_10_y && y < tile_10_y +13) begin
                oled_data = kan_tile_2;
                end            
            
            tile_12_x = tile_11_x + 8;
            tile_13_x =  tile_12_x + 8;
            
            if (x >= tile_13_x + 8 && x < tile_13_x + 16 && y >= tile_13_y && y < tile_13_y +13) begin
                oled_data = kan_tile_1;
                end
            end
        
        6'o11 : begin
            oled_data = layout_11[pixel_index]; // 1x 4-set, 1x 3-set
            tile_2_x = tile_1_x +8;
            tile_3_x = tile_2_x + 8;
            tile_4_x = tile_3_x + 12;
            tile_5_x = tile_4_x + 12;
            tile_6_x = tile_5_x + 12;
            tile_7_x = tile_6_x + 12;
            tile_9_x = tile_8_x + 8;
            tile_10_x =  tile_9_x + 8;
            
            if (x >= tile_10_x +8 && x < tile_10_x + 16 && y >= tile_10_y && y < tile_10_y +13) begin
                oled_data = kan_tile_2;
                end        
            tile_11_x = tile_10_x + 8 + 12;
            tile_12_x = tile_11_x + 12;
            tile_13_x = tile_12_x + 12;
            
            end
            
        6'o12 : begin
            oled_data = layout_12[pixel_index]; // 1x 4-set, 2x 3-set
            tile_2_x = tile_1_x +8;
            tile_3_x = tile_2_x + 8;
            tile_4_x = tile_3_x + 12;
            tile_9_x = tile_8_x + 8;
            tile_10_x =  tile_9_x + 8;
            tile_11_x = tile_10_x + 8 + 12;
            tile_12_x = tile_11_x + 8;
            tile_13_x = tile_12_x + 8;
            if (x >= tile_13_x +8 && x < tile_13_x + 16 && y >= tile_13_y && y < tile_13_y +13) begin
                oled_data = kan_tile_1;
                end
            end
        
        6'o13 :begin 
            oled_data = layout_13[pixel_index]; // 1x 4-set, 3x 3-set
            tile_2_x = tile_1_x +8;
            tile_3_x = tile_2_x + 8;
            tile_4_x = tile_3_x + 12;
            tile_5_x = tile_4_x +8;
            tile_6_x = tile_5_x + 8;
            tile_7_x = tile_6_x + 12;            
            tile_9_x = tile_8_x + 8;
            tile_10_x =  tile_9_x + 8;
            tile_12_x = tile_11_x + 8;
            tile_13_x = tile_12_x + 8;
            if (x >= tile_10_x +8 && x < tile_10_x + 16 && y >= tile_10_y && y < tile_10_y +13) begin
                oled_data = kan_tile_2;
                end   
            end
            
        6'o21 : begin 
            oled_data = layout_21[pixel_index]; // 2x 4-set , 1x 3-set
            
            tile_2_x = tile_1_x + 8;
            tile_3_x =  tile_2_x + 8;
            if (x >= tile_3_x+8 && x < tile_3_x + 16 && y >= tile_3_y && y < tile_3_y +13) begin
                oled_data = kan_tile_3;
                end     
            
            tile_4_x = tile_3_x + 8 + 12;
            tile_5_x = tile_4_x + 12;
            tile_6_x = tile_5_x + 12;
            tile_7_x = tile_6_x + 12;
            
            tile_9_x = tile_8_x + 8;
            tile_10_x =  tile_9_x + 8;
            if (x >= tile_10_x + 8 && x < tile_10_x + 16 && y >= tile_10_y && y < tile_10_y +13) begin
                oled_data = kan_tile_2;
                end
                
            tile_11_x = tile_10_x + 8 +12;
            tile_12_x = tile_11_x + 8;
            tile_13_x = tile_12_x + 8;
            
            end
        
        6'o22 : begin
            oled_data = layout_22[pixel_index]; // 2x 4-set, 2x 3-set
    
            
            tile_2_x = tile_1_x + 8;
            tile_3_x =  tile_2_x + 8;
            if (x >= tile_3_x+8 && x < tile_3_x + 16 && y >= tile_3_y && y < tile_3_y +13) begin
                oled_data = kan_tile_3;
                end     
                
            tile_4_x = tile_3_x + 8 +12;
            tile_5_x = tile_4_x + 8;
            tile_6_x = tile_5_x + 8;
            tile_7_x = tile_6_x + 12;
            
            tile_9_x = tile_8_x + 8;
            tile_10_x =  tile_9_x + 8;
            if (x >= tile_10_x + 8 && x < tile_10_x + 16 && y >= tile_10_y && y < tile_10_y +13) begin
                oled_data = kan_tile_2;
                end
                
            tile_11_x = tile_10_x + 8 + 12;
            tile_12_x = tile_11_x + 8;
            tile_13_x = tile_12_x + 8;
                
            end
        
        6'o31 : begin 
            oled_data = layout_31[pixel_index]; // 3x 4-set, 1x 3-set
            
            tile_2_x = tile_1_x + 8;
            tile_3_x = tile_2_x + 8;
            
            if (x >= tile_3_x+8 && x < tile_3_x + 16 && y >= tile_3_y && y < tile_3_y +13) begin
                oled_data = kan_tile_3;
                end     
                
            tile_4_x = tile_3_x +8 + 12;
            
            tile_5_x = tile_4_x + 8;
            tile_6_x = tile_5_x + 8;
            
            tile_7_x = tile_6_x + 12;
            
    
            
            tile_9_x = tile_8_x + 8;
            tile_10_x =  tile_9_x + 8;
            
            if (x >= tile_10_x + 8 && x < tile_10_x + 16 && y >= tile_10_y && y < tile_10_y +13) begin
                oled_data = kan_tile_2;
                end            
            
            tile_11_x = tile_10_x + 8 + 12;
            tile_12_x = tile_11_x + 8;
            tile_13_x =  tile_12_x + 8;
            
            if (x >= tile_13_x + 8 && x < tile_13_x + 16 && y >= tile_13_y && y < tile_13_y +13) begin
                oled_data = kan_tile_1;
                end
            end
            
        default : begin
            oled_data = layout_00[pixel_index]; //standard layout
            tile_8_x = 2; tile_9_x = 14; tile_10_x = 26; tile_11_x = 38; tile_12_x = 50; tile_13_x = 62;
            tile_1_x = 2; tile_2_x = 14; tile_3_x = 26; tile_4_x = 38; tile_5_x = 50; tile_6_x = 62; tile_7_x = 74;
            end
        endcase
        
        if (tile_discarded) begin
            if (x >= 44 && x < 53) begin
                if (y == 6 || y == 20) begin
                    oled_data = 16'h0000;
                    end
                end
                
            if (y >= 7 && y < 20) begin
                if (x == 43 || x == 53) begin
                    oled_data = 16'hFFFF; 
                    end
                end
            
            if (y >= 7 && y < 20) begin
                if (x == 52) begin
                    oled_data = 16'hFEC7;
                    end
                end
                
            if (x >= discarded_tile_x && x < discarded_tile_x + 8 && y >= discarded_tile_y && y < discarded_tile_y +13) begin
                oled_data = discarded_tile_data;
                end
            end
            
        if (player_turn) begin
            if (x >= 44 && x < 53) begin
                if (y == 6 || y == 20) begin
                    oled_data = 16'h0000;
                    end
                end
            
            if (y >= 7 && y < 20) begin
                if (x == 43 || x == 53) begin
                    oled_data = 16'hFFFF; 
                    end
                end
            
            if (y >= 7 && y < 20) begin
                if (x == 52) begin
                    oled_data = 16'hFEC7;
                    end
                end
                
            if (x >= incoming_tile_x && x < incoming_tile_x + 8 && y >= tile_13_y && y < tile_13_y +13) begin
                oled_data = incoming_tile_data;
                end
            end
        
        if (x >= tile_1_x && x< tile_1_x + 8 && y >= tile_1_y && y < tile_1_y +13) begin
            oled_data = tile_data_1;
            end
            
        if (x >= tile_2_x && x< tile_2_x + 8 && y >= tile_2_y && y < tile_2_y +13) begin
            oled_data = tile_data_2;
            end
            
        if (x >= tile_3_x && x< tile_3_x + 8 && y >= tile_3_y && y < tile_3_y +13) begin
            oled_data = tile_data_3;
            end
            
        if (x >= tile_4_x && x< tile_4_x + 8 && y >= tile_4_y && y < tile_4_y +13) begin
            oled_data = tile_data_4;
            end
            
        if (x >= tile_5_x && x< tile_5_x + 8 && y >= tile_5_y && y < tile_5_y +13) begin
            oled_data = tile_data_5;
            end
            
        if (x >= tile_6_x && x< tile_6_x + 8 && y >= tile_6_y && y < tile_6_y +13) begin
            oled_data = tile_data_6;
            end
            
        if (x >= tile_7_x && x< tile_7_x + 8 && y >= tile_7_y && y < tile_7_y +13) begin
            oled_data = tile_data_7;
            end
            
        if (x >= tile_8_x && x< tile_8_x + 8 && y >= tile_8_y && y < tile_8_y +13) begin
            oled_data = tile_data_8;
            end
            
        if (x >= tile_9_x && x< tile_9_x + 8 && y >= tile_9_y && y < tile_9_y +13) begin
            oled_data = tile_data_9;
            end
            
        if (x >= tile_10_x && x< tile_10_x + 8 && y >= tile_10_y && y < tile_10_y +13) begin
            oled_data = tile_data_10;
            end
            
        if (x >= tile_11_x && x< tile_11_x + 8 && y >= tile_11_y && y < tile_11_y +13) begin
            oled_data = tile_data_11;
            end
            
            
        if (x >= tile_12_x && x< tile_12_x + 8 && y >= tile_12_y && y < tile_12_y +13) begin
            oled_data = tile_data_12;
            end
                
        if (x >= tile_13_x && x< tile_13_x + 8 && y >= tile_13_y && y < tile_13_y +13) begin
            oled_data = tile_data_13;
            end

        // New cycle, check if cursor hits any tiles (so it will display cool sign)
        if (x==0 && y==0) begin
            cursorIsCool <= 0;
            // Row 1: Check if y is within Row 1 range
            if (my+4 >= Y1_BASE && my+4 < (Y1_BASE + SQUARE_HEIGHT)) begin
                for (j = 0; j < 6; j = j + 1) begin
                    if (mx+4 >= x_start[j] && mx+4 < x_end[j]) cursorIsCool <= 1;
                end
            end
        
            // Row 2: Check if y is within Row 2 range
            else if (my+4 >= Y2_BASE && my+4 < (Y2_BASE + SQUARE_HEIGHT)) begin
                for (j = 0; j < 6; j = j + 1) begin
                    if (mx+4 >= x_start[j] && mx+4 < x_end[j]) cursorIsCool <= 1;
                end
            end

            if (select_emote) cursorIsCool <= my>=6 && my<=56;
        end
    
        // Row 1: Check if y is within Row 1 range
        if (y >= Y1_BASE && y < (Y1_BASE + SQUARE_HEIGHT)) begin
            for (j = 0; j < 6; j = j + 1) begin
                if (x >= x_start[j] && x < x_end[j]) begin
                    if (sw[row1_order[j]]) begin
                        // If selected, apply blinking
                        if (clk1)
                            oled_data = square_colors[row1_order[j]];
                        else
                            oled_data = 16'h0000; // Off (black)
                    end
                    else begin
                        // If not selected, display normally
                        oled_data = square_colors[row1_order[j]];
                    end
                end
            end
        end
    
        // Row 2: Check if y is within Row 2 range
        else if (y >= Y2_BASE && y < (Y2_BASE + SQUARE_HEIGHT)) begin
            for (j = 0; j < 6; j = j + 1) begin
                if (x >= x_start[j] && x < x_end[j]) begin
                    if (sw[row2_order[j]]) begin
                        // If selected, apply blinking
                        if (clk1)
                            oled_data = square_colors[row2_order[j]];
                        else
                            oled_data = 16'h0000; // Off (black)
                    end
                    else begin
                        // If not selected, display normally
                        oled_data = square_colors[row2_order[j]];
                    end
                end
            end
        end

    // Show HUD
    if (x<14 && y<14) begin
        case (blink)
            1, 2, 3, 4, 5: oled_data = eye2_data[14*y+x];
            6, 7, 8, 9, 10: oled_data = eye3_data[14*y+x];
            11, 12, 13, 14, 15: oled_data = eye3_data[14*y+x];
            default: oled_data = eye_data[14*y+x];
        endcase
    end

    // Display emote selection pop-up
    if (select_emote && y>=6 && y<56) begin
        oled_data = {oled_data[15:11]>>2, oled_data[10:5]>>2, oled_data[4:0]>>2};
        if (x<50 && emote_data[50*(y-6) + x]) begin
            oled_data = emote_data[50*(y-6) + x];
            if (clk1) oled_data = {oled_data[15:11]>>1, oled_data[10:5]>>1, oled_data[4:0]>>1};
        end
        if (x>=47 && emote2_data[50*(y-6) + x - 47]) begin
            oled_data = emote2_data[50*(y-6) + x - 47];
            if (!clk1) oled_data = {oled_data[15:11]>>1, oled_data[10:5]>>1, oled_data[4:0]>>1};
        end
    end

    // Display different cursors based on different scenarios
    if ((x-mx >=0) && (x-mx < 16) && (y-my >=0) && (y-my < 16)) begin
        if (right) begin
            if (gesture_right>0) begin if(cursor4_data[16*(y-my) + x-mx]) oled_data = cursor4_data[16*(y-my) + x-mx]; end
            else if (gesture_left>0) begin if(cursor5_data[16*(y-my) + x-mx]) oled_data = cursor5_data[16*(y-my) + x-mx]; end
            else if (cursor2_data[16*(y-my) + x-mx]) oled_data = cursor2_data[16*(y-my) + x-mx];
        end else begin
            if (cursorIsCool) begin if (cursorcool_data[16*(y-my) + x-mx]) oled_data = cursorcool_data[16*(y-my) + x-mx]; end
            else if (cursor1_data[16*(y-my) + x-mx]) oled_data = cursor1_data[16*(y-my) + x-mx];
        end
    end

    // Display emotes
    if (emote && y>13+emote_offset && x<50) begin
        if (emote_i==0 && emote_data[50*(y-emote_offset-14) + x]) oled_data = emote_data[50*(y-emote_offset-14) + x];
        else if (emote_i==1 && emote2_data[50*(y-emote_offset-14) + x]) oled_data = emote2_data[50*(y-emote_offset-14) + x];
    end

    end

    integer dx, dy;
    // Gesture detection logic
    always @(posedge clk50) begin
        // Update right button state
        right_button_current <= right; 
        if (right_button_current && !right_button_last) begin
            // Right button pressed, initialize gesture tracking
            start_x <= mx;
            start_y <= my;
            last_x <= mx;
            last_y <= my;
            
            // Clear gesture flags
            gesture_left = -1;
            gesture_right = -1;
            gesture_tick_se = -1;
            gesture_tick_ne = -1;
        end
        right_button_last <= right_button_current;
        // Clear immediate gesture flags
        straight_left <= 0;
        straight_right <= 0;
        tick_se <= 0;
        tick_ne <= 0;

        if (right) begin
            // Gesture tracking is active
            // Calculate movement deltas
            dx = mx - start_x;
            dy = my - start_y;

            // Straight Left: dx < 0, minimal vertical movement
            if (dx < -20 && (dy < 10 || dy > -10)) straight_left <= 1;
            
            // Straight Right: dx > 0, minimal vertical movement
            if (dx > 20 && (dy < 10 || dy > -10)) straight_right <= 1;

            // Tick Gesture Detection
            // Check if cursor first moves diagonally down-right
            // then sharply up-right
            if (dx > 5 && dy > 15) begin
                // Detected first diagonal segment (down-right)
                tick_se <= 1;
                // Update last positions, for use for tick up gesture
                last_x <= mx;
                last_y <= my;
            end

            if (gesture_tick_se>500) begin
                dx = mx - last_x;
                dy = my - last_y;
                
                if (dx > 5 && dy < -15) begin
                    tick_ne <= 1;
                end
            end

            gesture_left <= (gesture_left==0) ? 0: (gesture_left==-1) ? (straight_left ? 1 : -1) : (straight_left ? gesture_left+straight_left: 0);
            gesture_right <= (gesture_right==0) ? 0: (gesture_right==-1) ? (straight_right ? 1 : -1) : (straight_right ? gesture_right+straight_right: 0);
            gesture_tick_se <= (gesture_tick_se==0) ? 0: (gesture_tick_se==-1) ? (tick_se ? 1 : -1) : (gesture_tick_ne==-1 && tick_se ? gesture_tick_se+tick_se: gesture_tick_se);
            gesture_tick_ne <= gesture_tick_se==-1 ? gesture_tick_ne:  (gesture_tick_ne==-1) ? (tick_ne ? 1 : -1) : (tick_ne ? gesture_tick_ne+tick_ne: 0);
            
        end
    end

    reg prevIsLeft = 0;
    always @ (posedge clk50) begin
        if (middle && !emote) begin
            if (!select_emote) select_emote <= 1; // only for debug
        end else if (select_emote && prevIsLeft && !left) begin
            select_emote <= 0;
            emote_i <= mx>47;
            emote <= 1;
        end
        
        case (emote)
            1: begin
                if (emote_offset) emote_offset <= emote_offset-1;
                else emote <= 2;
            end
            2: begin
                if (emote_wait<40) emote_wait <= emote_wait+1;
                else begin
                    emote_wait <= 0;
                    emote <= 3;
                end
            end
            3: begin
                if (emote_offset<50) emote_offset <= emote_offset+1;
                else emote <= 0;
            end
        endcase

        prevIsLeft <= left;
    end

    always @ (posedge clk50) begin
        if (mx<14 && my<14) begin
            if (blink) begin
                if (blinkUp) blink <= blink+1;
                else blink <= blink-1;
                blinkUp <= (blink==15) ? 0: blinkUp;
            end else begin
                blink <= 1;
                blinkUp <= 1;
            end
        end
    end
    
endmodule