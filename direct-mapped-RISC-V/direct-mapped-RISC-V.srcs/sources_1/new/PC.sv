`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Samuel Weston & Phillipe Bakhirev
// Module Name: Program Counter
// Create Date: 01/15/2025
//////////////////////////////////////////////////////////////////////////////////

module PC(
    input logic CLK,
    input logic RST,
    input logic PC_WRITE,
    input logic [2:0] PC_SEL,
    input logic [31:0] JALR,
    input logic [31:0] BRANCH,
    input logic [31:0] JAL,
    input logic [31:0] MTVEC,
    input logic [31:0] MEPC,
    output logic [31:0] PC_OUT,
    output logic [31:0] PC_OUT_INC
    );
    
    // Internal Logic
    logic [31:0] PC_OUT_PLUS_FOUR, PC_IN;
    
    // Assign Outputs
    assign PC_OUT_PLUS_FOUR = PC_OUT + 4;
    assign PC_OUT_INC = PC_OUT_PLUS_FOUR;
    
    // Instantiate PC MUX
    PC_MUX PCMUX(
        .PC_OUT_PLUS_FOUR(PC_OUT_PLUS_FOUR), 
        .JALR(JALR), 
        .BRANCH(BRANCH),
        .JAL(JAL), 
        .MTVEC(MTVEC), 
        .MEPC(MEPC), 
        .PC_SEL(PC_SEL), 
        .PC_MUX_OUT(PC_IN)
    );
        
    // Instantiate PC Reg.
    PC_REG PCREG(
        .CLK(CLK), 
        .RST(RST), 
        .D(PC_WRITE), 
        .IN(PC_IN), 
        .OUT(PC_OUT)
    );
    
endmodule