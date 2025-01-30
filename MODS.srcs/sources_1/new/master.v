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


module master(input clk, clk1m, btnC, btnU, btnD, btnL, btnR, input [15:0] sw, input [6:0] x, input [5:0] y, output [15:0] oled_data, 
    input clk25m,         // 25 MHz clock
    input clk2k,          // 2 kHz clock
    input clk50,          // 50 Hz --> '20 Hz' clock, due to legacy naming
    input clk1,           // 1 Hz clock
    input restart,        // Reset button
    input [6:0] mx,        // Mouse X coordinate
    input [5:0] my,        // Mouse Y coordinate
    input [3:0] mz,        // Mouse Z coordinate
    input left,          // Mouse left button
    input middle,          // Mouse middle button
    input right,          // Mouse right button
    input [12:0] pixel_index, // OLED display index (added)
    output reg [15:0] led = 0,
    output reg [6:0] seg,
    output reg [3:0] an,
    output [2:0] uart_tx,
    input [2:0] uart_rx,
    input is_master,
    output [107:0] flattened_hand
    );

    // LFSR
    wire [7:0] lfsr;   
    lfsr lfsr_mod (clk, 0, lfsr);
    
    // Hands
    reg [5:0] draw_pile[135:0], hand_0[17:0], hand_1[17:0], hand_2[17:0], hand_3[17:0];
    reg [5:0] hand_index;
    
    // Setup variables
    reg shuffle = 0;
    reg [7:0] shuffle_index = 0;
    reg [7:0] random_number, random_index;
    reg [5:0] tile_value;
    reg shuffling = 0;
    reg initialised = 0;
    reg start_game = 0;
    reg started_shuffling = 0;
    reg shuffled = 0;
    reg distributed_tiles = 0;

    // Clocks
    wire clk_100_000Hz;
    flexible_clock_module (clk, 499, clk_100_000Hz);
    wire clk_50_000Hz;
    flexible_clock_module (clk, 999, clk_50_000Hz);
    wire slow_clk;
    flexible_clock_module (clk, 49_999_999, slow_clk);
    
        // Jing Yen's Part
        reg [5:0] temp;
        integer j;
        wire btnL_pulse, btnR_pulse, btnC_pulse;
    
        // Instantiate debounce for btnL
        debounce debounce_btnL (
            .CLOCK(clk_50_000Hz),
            .pbC(btnL),
            .debounced_pulse(btnL_pulse)
        );
        
        // Instantiate debounce for btnR
        debounce debounce_btnR (
            .CLOCK(clk_50_000Hz),
            .pbC(btnR),
            .debounced_pulse(btnR_pulse)
        );
    
        // Instantiate debounce for btnC
        debounce debounce_btnC (
            .CLOCK(clk_50_000Hz),
            .pbC(btnC),
            .debounced_pulse(btnC_pulse)
        );

    
    // UART variables
    reg [2:0] transmit = 0;
    reg [2:0] transmitted = 0;
    wire [2:0] busy;
    reg [3:0] tile_count = 0;
    reg [5:0] tx_tile1, tx_tile2, tx_tile3;
    reg [1:0] tx_move1, tx_move2, tx_move3;
    reg [2:0] tx_chi1, tx_chi2, tx_chi3;
    reg [1:0] packet_type1, packet_type2, packet_type3;
    
    UART_TX uarttx1 (
        .clk(clk_100_000Hz),
        .reset(btnL),
        .tile(tx_tile1),
        .move(tx_move1),
        .chi(tx_chi1),
        .packet_type(packet_type1),
        .transmit(transmit[0]),
        .tx(uart_tx[0]),
        .busy(busy[0])
    );
    
    UART_TX uarttx2 (
        .clk(clk_100_000Hz),
        .reset(btnL),
        .tile(tx_tile2),
        .move(tx_move2),
        .chi(tx_chi2),
        .packet_type(packet_type2),
        .transmit(transmit[1]),
        .tx(uart_tx[1]),
        .busy(busy[1])
    );
    
    UART_TX uarttx3 (
        .clk(clk_100_000Hz),
        .reset(btnL),
        .tile(tx_tile3),
        .move(tx_move3),
        .chi(tx_chi3),
        .packet_type(packet_type3),
        .transmit(transmit[2]),
        .tx(uart_tx[2]),
        .busy(busy[2])
    );
    
    wire [5:0] received_tile1, received_tile2, received_tile3;
    wire [1:0] received_move1, received_move2, received_move3;
    wire [2:0] received_chi1, received_chi2, received_chi3;
    wire received_turn1, received_turn2, received_turn3;
    wire data_ready1, data_ready2, data_ready3;
    wire [1:0] rx_packet_type1, rx_packet_type2, rx_packet_type3;
    
    UART_RX uartrx1 (
        .clk(clk_100_000Hz),
        .reset(btnL),
        .rx(uart_rx[0]),
        .tile(received_tile1),
        .move(received_move1),
        .chi(received_chi1),
        .turn(received_turn1),
        .data_ready(data_ready1),
        .packet_type_received(rx_packet_type1)
    );
    
    UART_RX uartrx2 (
        .clk(clk_100_000Hz),
        .reset(btnL),
        .rx(uart_rx[1]),
        .tile(received_tile2),
        .move(received_move2),
        .chi(received_chi2),
        .turn(received_turn2),
        .data_ready(data_ready2),
        .packet_type_received(rx_packet_type2)
    );
    
    UART_RX uartrx3 (
        .clk(clk_100_000Hz),
        .reset(btnL),
        .rx(uart_rx[2]),
        .tile(received_tile3),
        .move(received_move3),
        .chi(received_chi3),
        .turn(received_turn3),
        .data_ready(data_ready3),
        .packet_type_received(rx_packet_type3)
    );
    
    // Game variables
    reg [1:0] player = 0;
    reg [7:0] draw_pile_index = 52;
    wire [3:0] discard_index;
    reg [3:0] shift_index = 0;
    reg [3:0] check_index = 0;
    reg [5:0] discard_tile;
    reg tile_discarded = 0;
    reg pon = 0;
    reg chi = 0;
    reg kan = 0;
    reg [2:0] kan_count_0 = 0;
    reg [2:0] kan_count_1 = 0;
    reg [2:0] kan_count_2 = 0;
    reg [2:0] kan_count_3 = 0;
    reg checked_pon_chi_kan = 0;
    reg [1:0] same_tile_counter = 0;
    reg [3:0] chi_checker = 0;
    reg pon_possible = 0;
    reg kan_possible = 0;
    reg [2:0] chi_possible = 0;
    
    reg player_done = 0;
    
    // Button/counter variables
    reg btnC_pressed = 0;
    reg btnU_pressed = 0;
    reg btnD_pressed = 0; 
    reg btnL_pressed = 0;
    reg btnR_pressed = 0;
    wire [31:0] btnC_counter, btnU_counter, btnD_counter, btnL_counter, btnR_counter, tile_discarded_counter;
    //assign discard_index = sw[7:4];
    // One-hot to integer converter
    one_hot_to_integer one_hot_to_integer_mod(.clk(clk), .array(sw[13:0]), .int(discard_index));
    counter_200ms btnC_counter_mod(.clk1m(clk1m), .btn_pressed(btnC_pressed), .counter(btnC_counter));
    counter_200ms btnU_counter_mod(.clk1m(clk1m), .btn_pressed(btnU_pressed), .counter(btnU_counter));
    counter_200ms btnD_counter_mod(.clk1m(clk1m), .btn_pressed(btnD_pressed), .counter(btnD_counter));
    counter_200ms btnL_counter_mod(.clk1m(clk1m), .btn_pressed(btnL_pressed), .counter(btnL_counter));
    counter_200ms btnR_counter_mod(.clk1m(clk1m), .btn_pressed(btnR_pressed), .counter(btnR_counter));
    counter_5s tile_discarded_counter_mod(.clk1m(clk1m), .tile_discarded(tile_discarded), .counter(tile_discarded_counter));

    wire [15:0] fake_led;
    //wire btnL_pulse, btnR_pulse;
//    wire [107:0] flattened_hand; // 18 elements * 6 bits = 108 bits

    // Flatten the 2D array into the 1D wire
    genvar i;
    generate
        for (i = 0; i < 18; i = i + 1) begin : flattening
            assign flattened_hand[i*6 +: 6] = hand_0[i];
        end
    endgenerate
//    uiux uiux_mod(
//        .clk(clk), .clk25m(clk25m), .clk2k(clk2k), .clk50(clk50), .clk1(clk1), .btnU(btnU), .btnC(btnC), .btnD(btnD), .btnR(btnR), .btnL(btnL), .sw(sw), .restart(btnC),
//        .x(x), .y(y), .mz(0), .mx(mx), .my(my), .player_hand(flattened_hand), .led(fake_led), .left(left), .middle(middle), .right(right), .oled_data(oled_data), .btnL_pulse(btnL_pulse), .btnR_pulse(btnR_pulse),
//        .pixel_index(pixel_index)
//    );

    // Shuffle all tiles in draw pile
    always @ (posedge clk_50_000Hz) begin
        if (is_master) begin
            // Handle Right Button Press: Shift selected squares right
            if (btnR_pulse) begin
                // Shift Right
                for (j = 12; j >= 0; j = j - 1) begin
                    if (sw[j] && ~sw[j+1]) begin
                        // Swap with the right neighbor
                        temp = hand_0[j];
                        hand_0[j]   = hand_0[j+1];
                        hand_0[j+1] = temp;
                    end
                end
            end
            
            // Handle Left Button Press: Shift selected squares left
            else if (btnL_pulse) begin
                // Shift Left
                for (j = 1; j < 14; j = j + 1) begin
                    if (sw[j] && ~sw[j-1]) begin
                        // Swap with the left neighbor
                        temp = hand_0[j];
                        hand_0[j] = hand_0[j-1];
                        hand_0[j-1] = temp;
                    end
                end
            end

            // Initialise tiles
            if (!initialised) begin
                $readmemb("tiles.txt", draw_pile);
                initialised = 1;
                for (hand_index = 0; hand_index < 18; hand_index = hand_index + 1) begin
                    hand_0[hand_index] = 0;
                    hand_1[hand_index] = 0;
                    hand_2[hand_index] = 0;
                    hand_3[hand_index] = 0;
                end
            end
            
            // Shuffle tiles
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
            
            // Start game
            if (start_game) begin
                if (!started_shuffling) begin
                    shuffle = 1;
                    started_shuffling = 1;
                end
            end
            else if (btnC && !btnC_pressed) begin
                start_game = 1;
                btnC_pressed = 1;
            end

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
            
            // Distribute tiles
            if (shuffled && !distributed_tiles) begin
                packet_type1 = 2'b00;
                packet_type2 = 2'b00;
                packet_type3 = 2'b00;
                if (tile_count < 13) begin
                    tx_tile1 = hand_1[tile_count];
                    tx_tile2 = hand_2[tile_count];
                    tx_tile3 = hand_3[tile_count];
                    //led[15] <= 1;
                    if (!busy[0] && !busy[1] && !busy[2]) begin
                        transmit[0] = 1;
                        transmit[1] = 1;
                        transmit[2] = 1;
                        tile_count = tile_count + 1;
                    end
                    else begin
                        transmit[0] = 0;
                        transmit[1] = 0;
                        transmit[2] = 0;
                    end
                end
                else begin
                    distributed_tiles = 1;
                    transmit[0] = 0;
                    transmit[1] = 0;
                    transmit[2] = 0;
                end
            end
            
            // Rounds start
            if (distributed_tiles) begin
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
                    if (btnC && !btnC_pressed && !tile_discarded) begin
                        btnC_pressed = 1;
                        discard_tile = hand_0[discard_index];
                        for (shift_index = 0; shift_index < 13; shift_index = shift_index + 1) begin
                            if (shift_index >= discard_index) begin
                                hand_0[shift_index] = hand_0[shift_index + 1];
                            end
                        end
                        if (!(pon || chi)) begin
                            draw_pile_index = draw_pile_index + 1;
                        end
                        hand_0[13] = 0;
                        tile_discarded = 1;
                        pon = 0;
                        chi = 0;
                        kan = 0;
                    end
                end
                else if (player == 1) begin
                    transmitted[1] = 0;
                    transmitted[2] = 0;
                    packet_type1 = 2'b00;
                    tx_tile1 = draw_pile[draw_pile_index];
                    if (!busy[0] && !transmitted[0]) begin
                        transmit[0] = 1;
                        transmitted[0] = 1;
                        draw_pile_index = draw_pile_index + 1;
                    end
                    else begin
                        transmit[0] = 0;
                    end
                end
                else if (player == 2) begin
                    transmitted[0] = 0;
                    transmitted[2] = 0;
                    packet_type2 = 2'b00;
                    tx_tile2 = draw_pile[draw_pile_index];
                    if (!busy[1] && !transmitted[1]) begin
                        transmit[1] = 1;
                        transmitted[1] = 1;
                        draw_pile_index = draw_pile_index + 1;
                    end
                    else begin
                        transmit[1] = 0;
                    end
                end
                else if (player == 3) begin
                    transmitted[0] = 0;
                    transmitted[1] = 0;
                    packet_type3 = 2'b00;
                    tx_tile3 = draw_pile[draw_pile_index];
                    if (!busy[2] && !transmitted[2]) begin
                        transmit[2] = 1;
                        transmitted[2] = 1;
                        draw_pile_index = draw_pile_index + 1;
                    end
                    else begin
                        transmit[2] = 0;
                    end
                end
                
                // Wait 5s after tile is discarded
                if (tile_discarded && tile_discarded_counter == 50000) begin
                    tile_discarded = 0;
                    player = player + 1;
                end
                
                if (player != 0 && player_done) begin
                    tile_discarded = 1;
                end
                
//                if (btnU & !btnU_pressed) begin
//                    btnU_pressed = 1;
//                    tile_discarded = 1;
//                end
                
            end
        end
    end
    
    reg prev_data_ready1 = 0;
    reg prev_data_ready2 = 0;
    reg prev_data_ready3 = 0;
    always @(posedge clk_100_000Hz) begin
        if (tile_discarded) begin
            player_done = 0;
        end
        if (data_ready1 && !prev_data_ready1 && rx_packet_type1 == 2'b00) begin
            led[6] = 1;
            player_done = 1;
        end
        else if (data_ready2 && !prev_data_ready2 && rx_packet_type2 == 2'b00) begin
            player_done = 1;
            led[7] = 1;
        end
        else if (data_ready3 && !prev_data_ready3 && rx_packet_type3 == 2'b00) begin
            player_done = 1;
            led[8] = 1;
        end
        prev_data_ready1 <= data_ready1;
        prev_data_ready2 <= data_ready2;
        prev_data_ready3 <= data_ready3;
    end
    
    reg [4:0] display_index = 0;
    always @(posedge slow_clk or posedge btnL) begin
        if (is_master) begin
           if (btnL) begin
                display_index <= 0;
            end else begin
                if (display_index < 17) begin
                    display_index <= display_index + 1;
                end else begin
                    display_index <= 0; // Wrap around to cycle through the hand
                end
                led[15:14] <= player;
                led[13:9] <= display_index;
                led[5:0] <= hand_0[display_index]; // Display the current tile on LEDs
            end 
        end
    end

//    wire clk1k, clk1p0;
//    flexible_clock_module clk1p0_mod(.clk(clk), .m(32'd49999999), .flex_clk(clk1p0));
//    flexible_clock_module clk1k_mod(.clk(clk), .m(32'd49999), .flex_clk(clk1k));
//    // Incrementing counter to show 13 drawn tiles
//    reg [15:0] display_hand_index = 0;
//    always @ (posedge clk1p0) begin
//        display_hand_index = (display_hand_index == 17) ? 0: display_hand_index + 1;
//    end
    
//    // Show hands on 7-segment display and LEDs
//    reg counter = 0;
//    reg [3:0] digit;   
//     always @ (posedge clk1k) begin
//       if (!counter) begin
//           an = 4'b1110;
//           digit = hand_0[display_hand_index] % 10;
//       end
//       else begin
//           an = 4'b1101;
//           digit = hand_0[display_hand_index] / 10;
//       end
//       case (digit)
//           0: seg = 7'b1000000;
//           1: seg = 7'b1111001;
//           2: seg = 7'b0100100;
//           3: seg = 7'b0110000;
//           4: seg = 7'b0011001;
//           5: seg = 7'b0010010;
//           6: seg = 7'b0000010;
//           7: seg = 7'b1111000;
//           8: seg = 7'b0000000;
//           9: seg = 7'b0010000;
//       endcase
//       led = 1 << display_hand_index;
//       counter = !counter;
//   end
    
endmodule
