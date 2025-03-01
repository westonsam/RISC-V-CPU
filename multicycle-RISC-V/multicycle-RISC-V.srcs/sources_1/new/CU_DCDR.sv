`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly San Luis Obispo
// Engineer: Samuel Weston & Phillipe Bakhirev
// Create Date: 01/15/2025
// Module Name: CU_DCDR
//////////////////////////////////////////////////////////////////////////////////


module CU_DCDR(
    input logic IR_30,
    input logic [6:0] IR_OPCODE,
    input logic [2:0] IR_FUNCT,
    input logic BR_EQ,
    input logic BR_LT,
    input logic BR_LTU,
    output logic [3:0] ALU_FUN,
    output logic ALU_SRCA,
    output logic [1:0] ALU_SRCB,
    output logic [2:0] PC_SOURCE,
    output logic [1:0] RF_WR_SEL
    );
    
    always_comb begin

        ALU_FUN = 4'b0000;
        ALU_SRCA = 1'b0;
        ALU_SRCB = 2'b00;
        PC_SOURCE = 3'b000;
        RF_WR_SEL = 2'b00;
        
        case (IR_OPCODE)
            7'b0010111: begin // AUIPC
                ALU_SRCA = 1'b1;
                ALU_SRCB = 2'b11;
                RF_WR_SEL = 2'b11;
            end
            7'b1101111: begin // JAL
                PC_SOURCE = 3'b011;
            end
            7'b1100111: begin // JALR
                PC_SOURCE = 3'b001;
            end
            7'b0100011: begin // STORE
                ALU_SRCB = 2'b10;
            end
            7'b0000011: begin // LOAD
                ALU_SRCB = 2'b01;
                RF_WR_SEL = 2'b10;
            end
            7'b0110111: begin // LUI
                ALU_FUN = 4'b1001;
                ALU_SRCA = 1'b1;
                RF_WR_SEL = 2'b11;
            end
            7'b0010011: begin // I-Type
                ALU_SRCB = 2'b01;
                RF_WR_SEL = 2'b11;
                
                case (IR_FUNCT)
                    3'b000: begin ALU_FUN = 4'b0000; end
                    3'b001: begin ALU_FUN = 4'b0001; end
                    3'b010: begin ALU_FUN = 4'b0010; end
                    3'b011: begin ALU_FUN = 4'b0011; end
                    3'b100: begin ALU_FUN = 4'b0100; end
                    3'b101: begin

                        case(IR_30)
                            1'b0: begin ALU_FUN = 4'b0101; end
                            1'b1: begin ALU_FUN = 4'b1101; end
                            default: begin end
                        endcase
                    end
                    3'b110: begin ALU_FUN = 4'b0110; end
                    3'b111: begin ALU_FUN = 4'b0111; end
                endcase
            end
            7'b0110011: begin // R-Type
                RF_WR_SEL = 2'b11;
                ALU_FUN = {IR_30, IR_FUNCT};
            end
            7'b1100011: begin // B-Type
                case(IR_FUNCT)
                    3'b000: begin                   // BEQ
                        if (BR_EQ == 1'b1) begin
                            PC_SOURCE = 3'b010;
                        end
                        else
                            PC_SOURCE = 3'b000; 
                    end
                    
                    3'b001: begin                   // BNE
                        if (BR_EQ == 1'b0) begin
                            PC_SOURCE = 3'b010;
                        end
                        else
                            PC_SOURCE = 3'b000; 
                    end
                    
                    3'b100: begin                   // BLT
                        if (BR_LT == 1'b1) begin
                            PC_SOURCE = 3'b010;
                        end
                        else
                            PC_SOURCE = 3'b000;
                    end
                    
                    3'b101: begin                   // BGE
                        if (BR_LT == 1'b0) begin
                            PC_SOURCE = 3'b010;
                        end
                        else
                            PC_SOURCE = 3'b000;
                    end
                    
                    3'b110: begin                   // BLTU
                        if (BR_LTU == 1'b1) begin
                            PC_SOURCE = 3'b010;
                        end
                        else
                            PC_SOURCE = 3'b000;
                    end
                    
                    3'b111: begin                   // BGEU
                        if (BR_LTU == 1'b0) begin
                            PC_SOURCE = 3'b010;
                        end
                        else
                            PC_SOURCE = 3'b000;
                    end
                endcase
            end
            default: begin end
        endcase
    end
    
endmodule
