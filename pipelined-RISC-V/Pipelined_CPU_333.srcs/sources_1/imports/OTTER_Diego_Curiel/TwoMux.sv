`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: California Polytechnic University, San Luis Obispo
// Engineer: Diego Renato Curiel
// Create Date: 02/25/2023 10:55:14 PM
// Module Name: TwoMux
//////////////////////////////////////////////////////////////////////////////////

module TwoMux(
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
