`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly San Luis Obispo
// Engineer: Samuel Weston & Phillipe Bakhirev
// Create Date: 01/15/2025
// Module Name: PC_REG
//////////////////////////////////////////////////////////////////////////////////

module PC_REG(
    input logic CLK,
    input logic RST,
    input logic D,
    input logic [31:0] IN,
    output logic [31:0] OUT
    );
    
    always_ff@(posedge CLK) begin
        if (RST == 1'b1) begin // PC = 0 if RST HIGH
            OUT <= 32'h00000000;
        end
        else if (D == 1'b1) begin 
            OUT <= IN;  
        end
    end
    
endmodule
