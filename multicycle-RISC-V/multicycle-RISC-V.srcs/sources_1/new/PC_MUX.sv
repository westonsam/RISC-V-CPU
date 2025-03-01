`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly San Luis Obispo
// Engineer: Samuel Weston & Phillipe Bakhirev
// Create Date: 01/15/2025
// Module Name: PC_MUX
//////////////////////////////////////////////////////////////////////////////////

module PC_MUX(
    input logic [31:0] PC_OUT_PLUS_FOUR,
    input logic [31:0] JALR,
    input logic [31:0] BRANCH,
    input logic [31:0] JAL,
    input logic [31:0] MTVEC,
    input logic [31:0] MEPC,
    input logic [2:0] PC_SOURCE,
    output logic [31:0] PC_MUX_OUT
    );

    always_comb begin
        case(PC_SOURCE)
            3'b000: begin PC_MUX_OUT = PC_OUT_PLUS_FOUR;
            end
            3'b001: begin PC_MUX_OUT = JALR;
            end
            3'b010: begin PC_MUX_OUT = BRANCH;
            end
            3'b011: begin PC_MUX_OUT = JAL;
            end
            3'b100: begin PC_MUX_OUT = MTVEC;
            end
            3'b101: begin PC_MUX_OUT = MEPC;
            end
            3'b110: begin PC_MUX_OUT = 32'h00000006; // SET FOR DEBUG. VALUE NOT POSSIBLE
            end
            3'b111: begin PC_MUX_OUT = 32'h00000007; // SET FOR DEBUG. VALUE NOT POSSIBLE
            end
            default: begin PC_MUX_OUT = 32'h00000000; // SET FOR DEBUG. VALUE NOT POSSIBLE
            end
        endcase
    end
endmodule