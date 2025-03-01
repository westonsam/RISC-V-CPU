`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly San Luis Obispo
// Engineer: Samuel Weston & Phillipe Bakhirev
// Create Date: 01/15/2025
// Module Name: TwoMUX
//////////////////////////////////////////////////////////////////////////////////

module TwoMUX(
    input logic SEL,
    input logic [31:0] RS1,
    input logic [31:0] U_TYPE,
    output logic [31:0] OUT
    );
    
    // Generic Two to One MUX
    always_comb begin
        case(SEL)
            1'b0: begin OUT = RS1; end
            1'b1: begin OUT = U_TYPE; end
        endcase
    end
    
endmodule
