`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly San Luis Obispo
// Engineer: Samuel Weston & Phillipe Bakhirev
// Create Date: 01/15/2025
// Module Name: FourMUX
//////////////////////////////////////////////////////////////////////////////////

module FourMUX(
    input logic [1:0] SEL,
    input logic [31:0] ZERO,
    input logic [31:0] ONE,
    input logic [31:0] TWO,
    input logic [31:0] THREE,
    output logic [31:0] OUT
    );
    
    // Generic Four To One MUX
    always_comb begin
        case(SEL) 
            2'b00: begin OUT = ZERO; end
            2'b01: begin OUT = ONE; end
            2'b10: begin OUT = TWO; end
            2'b11: begin OUT = THREE; end
            default: begin OUT = 32'b0; end
        endcase
    end
    
endmodule
