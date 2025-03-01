`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly San Luis Obispo
// Engineer: Samuel Weston & Phillipe Bakhirev
// Create Date: 01/15/2025
// Module Name: ALU
//////////////////////////////////////////////////////////////////////////////////

module ALU(
    input logic [31:0] SRC_A,
    input logic [31:0] SRC_B,
    input logic [3:0] ALU_FUN,
    output logic [31:0] RESULT
    );
    
    always_comb begin
        case(ALU_FUN)
            4'b0000: begin RESULT = SRC_A + SRC_B; end                      //add;
            4'b1000: begin RESULT = SRC_A - SRC_B; end                      //sub;
// logic
            4'b0110: begin RESULT = SRC_A | SRC_B; end                      //or
            4'b0111: begin RESULT = SRC_A & SRC_B; end                      //and
            4'b0100: begin RESULT = SRC_A ^ SRC_B; end                      //xor
// shifting
            4'b0101: begin RESULT = SRC_A >> SRC_B[4:0]; end                //srl
            4'b0001: begin RESULT = SRC_A << SRC_B[4:0]; end                //sll
            4'b1101: begin RESULT = $signed(SRC_A) >>> SRC_B[4:0]; end      //sra
// setting
            4'b0010: begin RESULT = $signed(SRC_A) < $signed(SRC_B); end    //slt
            4'b0011: begin RESULT = SRC_A < SRC_B; end                      //sltu
// copy
            4'b1001: begin RESULT = SRC_A; end                              //lui-copy
            default: begin RESULT = 32'd0; end
        endcase
    end
endmodule
