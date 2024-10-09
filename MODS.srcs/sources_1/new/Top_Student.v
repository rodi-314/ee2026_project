`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//  STUDENT A NAME: 
//  STUDENT B NAME:
//  STUDENT C NAME: 
//  STUDENT D NAME:  
//
//////////////////////////////////////////////////////////////////////////////////


module Top_Student (input CLOCK, input [15:0] sw, input pbC, input pbU, output reg [15:0] led, output reg [7:0] JB); 
    
    wire [7:0] outputA, outputB, outputC, outputD, outputS;
    wire [3:0] password;
    wire clk7Hz;
    reg restart = 1;
    wire restart_wire;
    assign restart_wire = restart;
    assign password[0] = (sw == 16'h11C5) ? 1 : 0;
    assign password[1] = (sw == 16'h12C5) ? 1 : 0;
    assign password[2] = (sw == 16'h13C5) ? 1 : 0;
    assign password[3] = (sw == 16'h14C5) ? 1 : 0;
    clk_divider clk7hz (CLOCK, 7142856, clk7Hz);
    start S (CLOCK, outputS);
    taskA A (CLOCK, pbC, pbU, restart_wire, outputA);
    always@(*) begin
        if (!password) begin
            restart = 1;
            JB = outputS;
            led = sw;
        end
        else if (password[0]) begin
            restart = 0;
            JB = outputA;
            led[0] = clk7Hz;
            led[2] = clk7Hz;
            led[6] = clk7Hz;
            led[7] = clk7Hz;
            led[8] = clk7Hz;
        end
        else if (password[1]) begin
            restart = 0;
            JB = outputS;
        end
        else if (password[2]) begin
            restart = 0;
            JB = outputS;
        end
        else if (password[3]) begin
            restart = 0;
            JB = outputS;
        end
    end
   
endmodule