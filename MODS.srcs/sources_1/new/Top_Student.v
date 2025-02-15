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


module Top_Student (
    input clk, 
    input btnC, btnU, btnL, btnR, btnD, 
    input [15:0] sw,
    output [7:0] JX,  
    output [15:0] led,
    output [6:0] seg,
    output [3:0] an,
    inout ps2_clk, ps2_data,
    output [2:0] JA_tx,
    input slave_rx,
    output slave_tx,
    input [2:0] JA_rx
    );

    // Clocks
    wire clk25m, clk6p25m, clk1m, clk100k, clk2k, clk1k, clk50, clk1p0;
    flexible_clock_module clk25m_mod (.clk(clk), .m(32'd1), .flex_clk(clk25m));
    flexible_clock_module clk6p25m_mod(.clk(clk), .m(32'd7), .flex_clk(clk6p25m));
    flexible_clock_module clk1m_mod(.clk(clk), .m(32'd49), .flex_clk(clk1m));
    flexible_clock_module clk100k_mod (.clk(clk), .m(32'd499), .flex_clk(clk100k));
    flexible_clock_module clk2k_mod (.clk(clk), .m(32'd24999), .flex_clk(clk2k));
    flexible_clock_module clk1k_mod(.clk(clk), .m(32'd49999), .flex_clk(clk1k));
    flexible_clock_module clk50_mod (.clk(clk), .m(32'd999999), .flex_clk(clk50));
    flexible_clock_module clk1p0_mod(.clk(clk), .m(32'd49999999), .flex_clk(clk1p0));
    // Unused clocks
//    wire clk12p5m, clk25m;
//    flexible_clock_module clk12p5m_mod(.clk(clk), .m(32'd3), .flex_clk(clk12p5m));
//    flexible_clock_module clk25m_mod(.clk(clk), .m(32'd1), .flex_clk(clk25m));
    
    // 3.A Oled_Display.v Module
    wire [15:0] oled_data;
    wire [15:0] fake_oled_data;
    wire frame_begin, sending_pixels, sample_pixel;
    wire [12:0] pixel_index;
    Oled_Display Oled_Display(
        .clk(clk6p25m), .reset(1'b0), 
        .frame_begin(frame_begin), .sending_pixels(sending_pixels), 
        .sample_pixel(sample_pixel), .pixel_index(pixel_index), 
        .pixel_data(oled_data), 
        .cs(JX[0]), .sdin(JX[1]), .sclk(JX[3]), .d_cn(JX[4]), .resn(JX[5]), .vccen(JX[6]), .pmoden(JX[7])
     );

    wire [6:0] x;
    wire [5:0] y;
    pixel_index_to_xy pixel_index_to_xy_mod(.pixel_index(pixel_index), .x(x), .y(y));

     // MouseCtl.v Module
    wire [11:0] xpos;
    wire [11:0] ypos;
    wire [6:0] xposScaled;
    wire [5:0] yposScaled;
    wire [3:0] zpos;
    wire left, middle, right, new_event;
    MouseCtl mousectl (.clk(clk), .rst(0), .ps2_clk(ps2_clk), .ps2_data(ps2_data), .value(0), .setx(0), .sety(0), .setmax_x(100), .setmax_y(100),
        .xpos(xpos), .ypos(ypos), .zpos(zpos), .left(left), .middle(middle), .right(right), .new_event(new_event));
     
    reg restart = 0;
    wire restart_wire, btnL_pulse, btnR_pulse;
    assign restart_wire = restart;
    assign xposScaled = xpos/10;
    assign yposScaled = (ypos/10 < 64) ? ypos/10: 63;
     
     // 3.B Mouse_Control.vhd Module
//     wire [11:0] xpos, ypos;
//     wire [3:0] zpos;
//     wire left, middle, right, new_event;
//     reg [11:0] value = 0;
//     reg setx, sety = 0;
//     reg setmax_x = 0; 
//     reg setmax_y = 0;
//     MouseCtl MouseCtl_mod(
//        .clk(clk),
//        .rst(reset),
//        .xpos(xpos),
//        .ypos(ypos),
//        .zpos(zpos),    
//        .left(left), 
//        .middle(middle),     
//        .right(right), 
//        .new_event(new_event), 
//        .value(value),  
//        .setx(setx), 
//        .sety(sety), 
//        .setmax_x(setmax_x),  
//        .setmax_y(setmax_y),  
        
//        .ps2_clk(ps2_clk),    
//        .ps2_data(ps2_data)       
//     );
     
     // 3.C Paint.v Module
//     paint paint_mod(
//         .clk_100M(clk), .clk_25M(clk25m), .clk_12p5M(clk12p5m), .clk_6p25M(clk6p25m), .slow_clk(clk1p0),
//         .mouse_l(left), .reset(right), .enable(1),  
//         .mouse_x(xpos), .mouse_y(ypos),
//         .pixel_index(pixel_index),
//         .led(led),       
//         .seg(seg), 
//         .colour_chooser(oled_data)
//     );
    
    
    reg is_master = 0;
    always @ (posedge clk) begin
        if (sw[15]) begin
            is_master = 1;
        end
    end
    
    wire [15:0] master_oled, slave_oled;
    wire [15:0] master_led, slave_led;
    wire [6:0] master_seg, slave_seg;
    wire [3:0] master_an, slave_an;
    wire [107:0] flattened_hand_master, flattened_hand_slave, flattened_hand;
    
    master master_mod(.clk(clk), .clk1m(clk1m), .btnC(btnC), .btnU(btnU), .btnD(btnD), .btnL(btnL), .btnR(btnR), .sw(sw), .x(x), .y(y), .oled_data(master_oled), 
        .led(master_led),
        .seg(master_seg),
        .an(master_an),
        .uart_tx(JA_tx),
        .uart_rx(JA_rx),
        .is_master(is_master),
        .clk25m(clk25m),
        .clk2k(clk2k),
        .clk50(clk50),
        .clk1(clk1p0),
        .restart(0),
        .mx(xposScaled),
        .my(yposScaled),
        .mz(zpos),
        .left(left),
        .middle(middle),
        .right(right),
        .pixel_index(pixel_index),
        .flattened_hand(flattened_hand_master)
        );
    
    slave slave_mod(
        .clk(clk),
        .clk1m(clk1m),
        .btnC(btnC), 
        .btnU(btnU), 
        .btnD(btnD), 
        .btnL(btnL), 
        .btnR(btnR),
        .sw(sw),
        .uart_rx(slave_rx),
        .uart_tx(slave_tx),
        .is_master(is_master),
        .x(x),
        .y(y),
        .clk25m(clk25m),
        .clk2k(clk2k),
        .clk50(clk50),
        .clk1(clk1p0),
        .restart(0),
        .mx(xposScaled),
        .my(yposScaled),
        .mz(zpos),
        .left(left),
        .middle(middle),
        .right(right),
        .pixel_index(pixel_index),
        .oled_data(slave_oled),
        .led(slave_led),
        .seg(slave_seg),
        .an(slave_an),
        .flattened_hand(flattened_hand_slave)
        );
        
    //assign oled_data = is_master ? master_oled : slave_oled;
    assign led = is_master ? master_led : slave_led;
    assign seg = is_master ? master_seg : slave_seg;
    assign an = is_master ? master_an : slave_an;
    assign flattened_hand = is_master ? flattened_hand_master : flattened_hand_slave;

    wire [15:0] fake_led;
    uiux uiux_mod(
        .clk(clk), .clk25m(clk25m), .clk2k(clk2k), .clk50(clk50), .clk1(clk1p0), .btnU(btnU), .btnC(btnC), .btnD(btnD), .btnR(btnR), .btnL(btnL), .sw(sw), .restart(btnC),
        .x(x), .y(y), .mz(0), .mx(xposScaled), .my(yposScaled), .player_hand(flattened_hand), .led(fake_led), .left(left), .middle(middle), .right(right), .oled_data(oled_data), .btnL_pulse(btnL_pulse), .btnR_pulse(btnR_pulse),
        .pixel_index(pixel_index)
    );
    
    

endmodule