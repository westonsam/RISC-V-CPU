`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly San Luis Obispo
// Engineer: Samuel Weston & Phillipe Bakhirev
// Create Date: 01/15/2025
// Module Name: CU_FSM
//////////////////////////////////////////////////////////////////////////////////

module CU_FSM(
    input logic CLK,
    input logic RST,
    input logic [6:0] IR_OPCODE,
    output logic PC_WRITE,
    output logic REG_WRITE,
    output logic MEM_WE2,
    output logic MEM_RDEN1,
    output logic MEM_RDEN2,
    output logic rst
    );
    
    typedef enum {INIT, FETCH, EXEC, WRITE_BACK} state;
    state NS, PS;
    
    // State register
    always_ff@(posedge CLK) begin
        if (RST == 1'b1)
            PS <= INIT;
        else
            PS <= NS;
    end
    
    always_comb begin
        PC_WRITE = 1'b0;
        REG_WRITE = 1'b0;
        MEM_WE2 = 1'b0;
        MEM_RDEN1 = 1'b0;
        MEM_RDEN2 = 1'b0;
        rst = 1'b0;
        
        case(PS)
            INIT: begin 
                NS = FETCH;
                rst = 1'b1;
            end
            
            FETCH: begin 
                NS = EXEC;
                MEM_RDEN1 = 1'b1;
            end
            
            EXEC: begin
                NS = FETCH;
                case (IR_OPCODE)
                    7'b0010111: begin // AUIPC
                        PC_WRITE = 1'b1;
                        REG_WRITE = 1'b1;
                    end
                    7'b1101111: begin // JAL
                        PC_WRITE = 1'b1;
                        REG_WRITE = 1'b1;
                    end
                    7'b1100111: begin // JALR
                        PC_WRITE = 1'b1;
                        REG_WRITE = 1'b1;
                    end
                    7'b0100011: begin // STORE
                        PC_WRITE = 1'b1;
                        MEM_WE2 = 1'b1;
                    end
                    7'b0000011: begin // LOAD
                        NS = WRITE_BACK;
                        MEM_RDEN2 = 1'b1;
                        PC_WRITE = 1'b0;
                        REG_WRITE = 1'b0;
                    end
                    7'b0110111: begin // LUI
                        PC_WRITE = 1'b1;
                        REG_WRITE = 1'b1;
                    end
                    7'b0010011: begin // I-type
                        PC_WRITE = 1'b1;
                        REG_WRITE = 1'b1;
                    end
                    7'b0110011: begin // R-type
                        PC_WRITE = 1'b1;
                        REG_WRITE = 1'b1;
                    end
                    7'b1100011: begin // B-type
                        PC_WRITE = 1'b1;
                    end
                    default: begin end
                endcase
            end
            
            WRITE_BACK: begin
                NS = FETCH;
                PC_WRITE = 1'b1;
                REG_WRITE = 1'b1;
            end
            
            default: begin
                NS = INIT;
            end
        endcase
    end
    
endmodule
