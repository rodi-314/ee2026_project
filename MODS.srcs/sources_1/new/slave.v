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


module slave(
    input clk,
    input clk1m,
    input btnC, btnU, btnD, btnL, btnR,
    input [15:0] sw,
    input uart_rx,
    output uart_tx,
    input is_master,
    input [6:0] x, input [5:0] y, output [15:0] oled_data,
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
    output [107:0] flattened_hand
    );
    
    wire clk_100_000Hz;
    flexible_clock_module (clk, 499, clk_100_000Hz);
    wire clk_50_000Hz;
    flexible_clock_module (clk, 999, clk_50_000Hz);

    // Jing Yen's Part
        reg [5:0] temp;
        integer j;
        wire btnL_pulse, btnR_pulse, btnC_pulse;
    
        // Instantiate debounce for btnL
        debounce debounce_btnL (
            .CLOCK(clk_100_000Hz),
            .pbC(btnL),
            .debounced_pulse(btnL_pulse)
        );
        
        // Instantiate debounce for btnR
        debounce debounce_btnR (
            .CLOCK(clk_100_000Hz),
            .pbC(btnR),
            .debounced_pulse(btnR_pulse)
        );
    
        // Instantiate debounce for btnC
        debounce debounce_btnC (
            .CLOCK(clk_100_000Hz),
            .pbC(btnC),
            .debounced_pulse(btnC_pulse)
        );
    
    reg [5:0] hand[17:0];
    wire [5:0] received_tile;
    wire [1:0] received_move;
    wire [2:0] received_chi;
    wire received_turn;
    wire data_ready;
    wire [1:0] packet_type;
    reg [3:0] tile_count = 0;
    UART_RX uartrx (
        .clk(clk_100_000Hz),
        .reset(btnL),
        .rx(uart_rx),
        .tile(received_tile),
        .move(received_turn),
        .chi(received_chi),
        .turn(received_turn),
        .data_ready(data_ready),
        .packet_type_received(packet_type)
    );
    
    reg [5:0] tx_tile;
    reg [1:0] tx_move;
    reg [2:0] tx_chi;
    reg [1:0] tx_packet_type;
    reg transmit_tx;
    wire busy_tx;
    reg transmitted = 0;
    
    UART_TX uart_slave (
        .clk(clk_100_000Hz),
        .reset(btnL),
        .tile(tx_tile),
        .move(tx_move),
        .chi(tx_chi),
        .packet_type(tx_packet_type),
        .transmit(transmit_tx),
        .tx(uart_tx),
        .busy(busy_tx)
    );
    
    wire [3:0] discard_index;
    reg [3:0] shift_index = 0;
    
    reg prev_data_ready = 0;
    reg my_turn = 0;
    reg clk_halver = 0;
    always @(posedge clk_100_000Hz /*or posedge btnL*/) begin
        //led[15:10] = received_tile;
        //led[9:6] = tile_count;
        //led[15] = uart_rx;
        /*
        if (btnL) begin
            tile_count <= 0;  // Reset tile count on reset
            prev_data_ready <= 0;
        end 
        
        else */ if (!is_master) begin
            if (data_ready && !prev_data_ready && packet_type == 2'b00 && tile_count < 13) begin
                // Store received tile in the hand array
                hand[tile_count] = received_tile;
                tile_count = tile_count + 1;
            end
            else if (data_ready && !prev_data_ready && packet_type == 2'b00 && tile_count >= 13) begin
                hand[13] = received_tile;
                my_turn = 1;
            end
            if (my_turn && transmitted) begin
                my_turn = 0;
                hand[discard_index] = hand[13];
                hand[13] = 0;
            end
            prev_data_ready <= data_ready;
            
            // Handle Right Button Press: Shift selected squares right
            if (btnR_pulse) begin
                // Shift Right
                for (j = 12; j >= 0; j = j - 1) begin
                    if (sw[j] && ~sw[j+1]) begin
                        // Swap with the right neighbor
                        temp = hand[j];
                        hand[j]   = hand[j+1];
                        hand[j+1] = temp;
                    end
                end
            end
            
            // Handle Left Button Press: Shift selected squares left
            else if (btnL_pulse) begin
                // Shift Left
                for (j = 1; j < 14; j = j + 1) begin
                    if (sw[j] && ~sw[j-1]) begin
                        // Swap with the left neighbor
                        temp = hand[j];
                        hand[j] = hand[j-1];
                        hand[j-1] = temp;
                    end
                end
            end
            
        end
    end //100k clk
    
    // Game variables
    reg [1:0] player = 0;
    reg [7:0] draw_pile_index = 52;
    
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
    
    wire [15:0] fake_led;
    //wire btnL_pulse, btnR_pulse;
//    wire [107:0] flattened_hand; // 18 elements * 6 bits = 108 bits

    // Flatten the 2D array into the 1D wire
    genvar i;
    generate
        for (i = 0; i < 18; i = i + 1) begin : flattening
            assign flattened_hand[i*6 +: 6] = hand[i];
        end
    endgenerate
//    uiux uiux_mod(
//        .clk(clk), .clk25m(clk25m), .clk2k(clk2k), .clk50(clk50), .clk1(clk1), .btnU(btnU), .btnC(btnC), .btnD(btnD), .btnR(btnR), .btnL(btnL), .sw(sw), .restart(btnC),
//        .x(x), .y(y), .mz(0), .mx(mx), .my(my), .player_hand(flattened_hand), .led(fake_led), .left(left), .middle(middle), .right(right), .oled_data(oled_data), .btnL_pulse(btnL_pulse), .btnR_pulse(btnR_pulse),
//        .pixel_index(pixel_index)
//    );

    always @ (posedge clk_50_000Hz) begin

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
        
        if (my_turn) begin
            // Discard selected tile
            if (btnC && !btnC_pressed) begin
                btnC_pressed = 1;
                tx_tile = hand[discard_index];
                tx_packet_type = 2'b00;
                if (!busy_tx && !transmitted) begin
                    transmit_tx = 1;
                    transmitted = 1;
                end
                else begin
                    transmit_tx = 0;
                end
            end
            else begin
                transmit_tx = 0;
            end
        end
        else begin
            transmit_tx = 0;
            transmitted = 0;
        end
    end
    
    reg [4:0] display_index = 0;
    wire slow_clk;
    flexible_clock_module (clk, 49_999_999, slow_clk);
    always @(posedge slow_clk or posedge btnL) begin
        if (!is_master) begin
            if (btnL) begin
                display_index <= 0;
            end
            else if (display_index < 17) begin
                display_index <= display_index + 1;
            end 
            else begin
                display_index <= 0; // Wrap around to cycle through the hand
            end
            led[15:11] <= display_index;
            led[10] <= uart_tx;
            led[5:0] <= hand[display_index]; // Display the current tile on LEDs
        end
    end
    
endmodule
