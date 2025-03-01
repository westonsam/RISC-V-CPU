`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly San Luis Obispo
// Engineer: Samuel Weston & Phillipe Bakhirev
// Create Date: 01/15/2025
// Module Name: PC
//////////////////////////////////////////////////////////////////////////////////

module PC(
    input logic CLK,
    input logic RST,
    input logic PC_WRITE,
    input logic [2:0] PC_SOURCE,
    input logic [31:0] JALR,
    input logic [31:0] BRANCH,
    input logic [31:0] JAL,
    input logic [31:0] MTVEC,
    input logic [31:0] MEPC,
    output logic [31:0] PC_OUT,
    output logic [31:0] PC_OUT_INC
    );

    logic [31:0] PC_OUT_PLUS_FOUR, PC_IN;

    assign PC_OUT_PLUS_FOUR = PC_OUT + 4;
    assign PC_OUT_INC = PC_OUT_PLUS_FOUR;
    
    // Instantiate PC MUX
    PC_MUX PCMUX(.PC_OUT_PLUS_FOUR(PC_OUT_PLUS_FOUR), .JALR(JALR), .BRANCH(BRANCH),
     .JAL(JAL), .MTVEC(MTVEC), .MEPC(MEPC), .PC_SOURCE(PC_SOURCE), .PC_MUX_OUT(PC_IN));
    
    // Instantiate PC Register
    PC_REG PCREG(.CLK(CLK), .RST(RST), .D(PC_WRITE), .IN(PC_IN), .OUT(PC_OUT));
    
endmodule
