`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Samuel Weston & Phillipe Bakhirev
// Module Name: PC_MUX
// Create Date: 02/27/2025
//////////////////////////////////////////////////////////////////////////////////

module PC_MUX(
    input logic [31:0] PC_OUT_PLUS_FOUR,
    input logic [31:0] JALR,
    input logic [31:0] BRANCH,
    input logic [31:0] JAL,
    input logic [31:0] MTVEC,
    input logic [31:0] MEPC,
    input logic [2:0] PC_SEL,
    output logic [31:0] PC_MUX_OUT
    );
    
    always_comb begin
        case(PC_SEL)
            3'b000: begin PC_MUX_OUT = PC_OUT_PLUS_FOUR;
            end
            3'b001: begin PC_MUX_OUT = JALR;
            end
            3'b010: begin PC_MUX_OUT = BRANCH;
            end
            3'b011: begin PC_MUX_OUT = JAL;
            end
            default: begin PC_MUX_OUT = 32'h00000000;
            end
        endcase
    end
endmodule