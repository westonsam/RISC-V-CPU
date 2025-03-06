`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer:  S. Weston & Phillipe Bakhirev
// Module Name: RISC-V Test Bench
// Create Date: 01/15/2025
//////////////////////////////////////////////////////////////////////////////////

module Otter_TB2();
    // Simulation Test Bench
    logic clk, intr, rst, wr;
    logic [31:0] in, iobus_out, iobus_addr;
    
    OTTER_MCU CPU(
        .CLK(clk), 
        .IOBUS_IN(in), 
        .RESET(rst),
        .IOBUS_OUT(iobus_out), 
        .IOBUS_ADDR(iobus_addr), 
        .IOBUS_WR(wr)
    );
    
    initial begin
    clk = 0;
    rst = 1'b1;
    end
    always begin
    #10 clk = ~clk; end
    always begin
    #60 rst = 0;
     in = 32'h0;
    end
endmodule
