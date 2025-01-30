`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.10.2024
// Design Name: 
// Module Name: debounce
// Project Name: 
// Target Devices: Basys 3 Board
// Tool Versions: 
// Description: 
// Debounce module that filters out noisy button inputs and generates a single-cycle
// pulse on the rising edge of a stable button press.
//
// Dependencies: None
//
// Revision:
// Revision 0.02 - Added single-cycle pulse generation
// Additional Comments:
//
//
//////////////////////////////////////////////////////////////////////////////////

module debounce(
    input CLOCK,                 // Debounce clock (e.g., 2 kHz) -- now 100khz
    input pbC,                   // Raw button input (active high)
    output reg debounced_pulse  // Single-cycle debounced pulse output
    );

    reg [13:0] COUNT = 0;
    reg pbC_prev = 0;
    
    always @ (posedge CLOCK) begin
        if (pbC && !pbC_prev && !COUNT) begin
            debounced_pulse = 1;
            COUNT = 1;
        end else begin
            debounced_pulse = 0;
            COUNT = COUNT ? COUNT+1 : 0;
        end
        
        pbC_prev = pbC;
    end

endmodule
