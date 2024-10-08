`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.10.2024 02:52:45
// Design Name: 
// Module Name: debounce
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


module debounce(
    input CLOCK,
    input pbC,
    input upMode, 
    output reg [2:0] pattern = 0
    );
    
    reg [31:0] counter = 0;
    reg pbC_prev = 0;
    reg active = 0;
    
    always@(posedge CLOCK) begin
        if (upMode) begin
            if (!active) begin
                if (pbC == 1 && pbC_prev == 0) begin
                    pattern <= (pattern >= 6) ? 1 : pattern + 1;
                    active <= 1;
                    counter <= 0;
                end
            end
            else begin
                if (counter < 400) begin
                    counter <= counter + 1;
                end
                else begin
                    active <= 0;
                end
            end
            pbC_prev <= pbC;
        end
    end
    
endmodule
