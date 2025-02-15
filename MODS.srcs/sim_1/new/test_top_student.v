`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.10.2024 03:44:19
// Design Name: 
// Module Name: test_top_student
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


module test_top_student(

    );
    
    reg clk, btnC, btnU, btnL, btnR, btnD;
    reg [15:0] sw;
    wire [7:0] JX;
    wire [15:0] led;
    wire [6:0] seg;
    wire [3:0] an;
    wire ps2_clk, ps2_data;
    
    Top_Student dut(
        clk, 
        btnC, btnU, btnL, btnR, btnD, 
        sw,
        JX,  
        led,
        seg,
        an,
        ps2_clk, ps2_data
    );
    
    initial begin
        clk = 0;
        sw = 16'b0000_0000_0000_0001;
        btnC = 0; #1000000;
        btnC = 1; #1000000;
        btnC = 0; #5000000;
        btnC = 1; #1000000;
        btnC = 0; #1000;
        btnC = 1; #10000000;
        btnC = 0; #1000;
    end
    
    always begin
        #5 clk = ~clk;
    end
    
endmodule
