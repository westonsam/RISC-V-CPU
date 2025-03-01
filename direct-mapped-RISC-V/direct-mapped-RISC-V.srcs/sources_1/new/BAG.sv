`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Samuel Weston & Phillipe Bakhirev
// Module Name: BAG
// Create Date: 01/15/2025
//////////////////////////////////////////////////////////////////////////////////

module BAG(
    input logic [31:0] RS1,
    input logic [31:0] I_TYPE,
    input logic [31:0] J_TYPE,
    input logic [31:0] B_TYPE,
    input logic [31:0] FROM_PC,
    output logic [31:0] JAL,
    output logic [31:0] JALR,
    output logic [31:0] BRANCH
    );
    
    // Assign Branch Addresses
    assign JAL = FROM_PC + J_TYPE;
    assign JALR = I_TYPE + RS1;
    assign BRANCH = FROM_PC + B_TYPE;
    
endmodule