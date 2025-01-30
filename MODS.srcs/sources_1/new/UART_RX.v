`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.11.2024 22:06:22
// Design Name: 
// Module Name: UART_RX
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


module UART_RX(
    input clk,                 // System clock (100 MHz)
    input reset,               // Active-high reset
    input rx,                  // UART receive line
    output reg [5:0] tile,     // Received tile data (6 bits)
    output reg [1:0] move,     // Received special move code (2 bits)
    output reg [2:0] chi,      // Received chi configuration data (3 bits)
    output reg turn,
    output reg [1:0] packet_type_received, // Packet type identifier
    output reg data_ready      // Data received flag
);

    parameter PACKET_TYPE_TILE = 2'b00;
    parameter PACKET_TYPE_MOVE = 2'b01;
    parameter PACKET_TYPE_TURN = 2'b10;

    // UART Parameters
    parameter CLK_FREQ   = 100_000; // 100 MHz
    parameter BAUD_RATE  = 9600;
    parameter BAUD_CNT   = CLK_FREQ / BAUD_RATE; // Baud rate counter

    // State Encoding
    parameter IDLE = 2'b00;
    parameter RECEIVE = 2'b01;
    parameter HOLD = 2'b10;

    // Registers and Wires
    reg [1:0] state;
    reg [31:0] baud_counter;
    reg [3:0] bit_index;    // Bit index (0 to 9)
    reg [9:0] rx_shift_reg; // Shift register for start bit, data bits, and stop bit
    reg [7:0] received_byte; // Received data byte

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state                <= IDLE;
            baud_counter         <= 32'd0;
            bit_index            <= 4'd0;
            data_ready           <= 1'b0;
            rx_shift_reg         <= 10'd0;
            received_byte        <= 8'd0;
            packet_type_received <= 2'b00;
        end else begin
            case (state)
                IDLE: begin
                    data_ready   <= 1'b0;
                    if (rx == 1'b0) begin // Start bit detected
                        state <= RECEIVE;
                        baud_counter <= BAUD_CNT / 2; // Sample in the middle
                        bit_index <= 4'd0;
                    end
                end

                RECEIVE: begin
                    if (baud_counter < BAUD_CNT - 1) begin
                        baud_counter <= baud_counter + 1;
                    end
                    else begin
                        baud_counter <= 0;
                        rx_shift_reg[bit_index] <= rx; // Capture received bit
                        if (bit_index < 4'd9) begin
                            bit_index <= bit_index + 1;
                        end 
                        else begin
                            // Frame received, process data
                            received_byte <= rx_shift_reg[8:1]; // Extract data bits
                            packet_type_received <= rx_shift_reg[8:7]; // Bits [8:7] are packet type
                            case (rx_shift_reg[8:7]) // Packet type
                                PACKET_TYPE_TILE: begin // Discarded Tile
                                    tile <= rx_shift_reg[6:1]; // Bits [5:0]
                                    move <= 0;
                                    turn <= 0;
                                    data_ready <= 1'b1;
                                end
                                PACKET_TYPE_MOVE: begin // Special Move
                                    move <= rx_shift_reg[2:1]; // Bits [1:0]
                                    chi <= rx_shift_reg[5:3];
                                    tile <= 0;
                                    turn <= 0;
                                    data_ready <= 1'b1;
                                end
                                PACKET_TYPE_TURN: begin
                                    move <= 0;
                                    tile <= 0;
                                    turn <= 1'b1;
                                    data_ready <= 1'b1;
                                end
                                default: begin
                                    // Reserved or unknown packet type
                                    data_ready <= 1'b0;
                                end
                            endcase
                            state <= IDLE;
                            baud_counter <= 0;
                            bit_index = 0;
                        end
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end

endmodule