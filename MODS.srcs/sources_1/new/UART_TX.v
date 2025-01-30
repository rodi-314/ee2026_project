`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.11.2024 22:05:28
// Design Name: 
// Module Name: UART_TX
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


module UART_TX(
    input clk,                // System clock (100 MHz)
    input reset,              // Active-high reset
    input [5:0] tile,         // Tile data (6 bits)
    input [1:0] move,         // Special move code (2 bits)
    input [2:0] chi,          // Chi configuration (3 bits)
    input [1:0] packet_type,  // Packet type identifier
    input transmit,           // Signal to start transmission
    output reg tx = 1,            // UART transmit line
    output reg busy = 0           // Transmitter busy flag
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
    parameter SEND = 2'b01;
    
    // Registers and Wires
    reg [1:0] state = IDLE;
    reg [31:0] baud_counter;
    reg [3:0] bit_index;    // Bit index (0 to 9)
    reg [9:0] tx_shift_reg; // Shift register for start bit, data bits, and stop bit
    reg [7:0] data_byte;    // Data byte to be transmitted

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state         <= IDLE;
            tx            <= 1'b1; // UART idle state is high
            busy          <= 1'b0;
            baud_counter  <= 32'd0;
            bit_index     <= 4'd0;
            tx_shift_reg  <= 10'd0;
            data_byte     <= 8'd0;
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    busy <= 1'b0;
                    if (transmit) begin
                        busy <= 1'b1;
                        // Construct data byte with packet type and data
                        data_byte[7:6] <= packet_type;
                        case (packet_type)
                            PACKET_TYPE_TILE: begin // Discarded Tile
                                //data_byte[5:0] <= tile;
                                tx_shift_reg <= {1'b1, packet_type, tile, 1'b0};
                            end
                            PACKET_TYPE_MOVE: begin // Special Move
                                if (move == 2'b00) begin  // If special move is CHI
                                     //data_byte[5] <= 1'b0;
                                     //data_byte[4:2] <= chi; // Insert CHI configuration
                                     //data_byte[1:0] <= move;
                                     tx_shift_reg <= {1'b1, packet_type, 1'b0, chi, move, 1'b0};
                                end
                                else begin
                                    //data_byte[5:2] <= 4'b0000;
                                    //data_byte[1:0] <= move;
                                    tx_shift_reg <= {1'b1, packet_type, 4'b0000, move, 1'b0};
                                end
                            end
                            PACKET_TYPE_TURN: begin
                                //data_byte[5:0] <= 6'b000000;
                                tx_shift_reg <= {1'b1, packet_type, 6'b000000, 1'b0};
                            end
                            default: begin
                                data_byte[5:0] <= 6'b000000; // Reserved or unused
                            end
                        endcase
                        // Load the UART shift register with start bit, data byte, and stop bit
                        //tx_shift_reg <= {1'b1, data_byte, 1'b0}; // [Stop Bit][Data Bits][Start Bit]
                        bit_index <= 4'd0;
                        baud_counter <= 32'd0;
                        state <= SEND;
                    end
                end

                SEND: begin
                    tx <= tx_shift_reg[bit_index]; // Transmit current bit
                    if (baud_counter < BAUD_CNT - 1)
                        baud_counter <= baud_counter + 1;
                    else begin
                        baud_counter <= 32'd0;
                        if (bit_index < 4'd9) begin
                            bit_index <= bit_index + 1;
                        end 
                        else begin
                            state <= IDLE;
                            bit_index = 0;
                            busy <= 1'b0;
                        end
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end

endmodule
