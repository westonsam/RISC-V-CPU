`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer:  Samuel Weston & Phillipe Bakhirev
// Module Name: Hazard Detection with Stalls, Flushes, and Data Forwarding
// Create Date: 02/27/2025
//////////////////////////////////////////////////////////////////////////////////

module Hazard_Detection(
    input [4:0] rs1_e, rs2_e,rs1_d, rs2_d,
    input de_ex_rs1_used, 
    input de_ex_rs2_used, 
    input mem_rd_used,
    input wb_rd_used, 
    input de_rs1_used,
    input de_rs2_used, 
    input [4:0] ex_mem_rd, 
    input [4:0] mem_wb_rd, 
    input [4:0] id_ex_rd,
    input ex_mem_regWrite,
    input mem_wb_regWrite,
    input memRead2, 
    input stalled,
    input stalled2,
    input [1:0] opB_sel,
    input [2:0] pcSource,
    input [6:0] opcode,
    input [1:0] de_ex_rf_wr_sel,
    input pcStall,
    input ex_mem_load,
    output reg [1:0] ForwardA, 
    output reg [1:0] ForwardB,
    output reg stall, 
    output reg flush_if_de,
    output reg flush_de_ex
    );
     
    always_comb begin
        ForwardA = 2'b00; 
        ForwardB = 2'b00;
        stall = 1'b0; 
        flush_if_de = 1'b0;
        flush_de_ex = 1'b0;
        
        // Conditions for forwarding A
        // RAW, 1 inst above
        if((rs1_e == ex_mem_rd) && ex_mem_regWrite && de_ex_rs1_used && mem_rd_used && !stalled2) begin
            ForwardA = 2'b10;
            if (ex_mem_load) stall = 1'b1;
        end 
        // RAW, 2 inst above
        else if(((rs1_e == mem_wb_rd) && mem_wb_regWrite) && de_ex_rs1_used && wb_rd_used) begin
            ForwardA = 2'b01;
        end        
        
        // Conditions for forwarding B
        // RAW, 1 inst above
        if(((rs2_e == ex_mem_rd) && ex_mem_regWrite) && de_ex_rs2_used && mem_rd_used && !stalled2) begin
            ForwardB = 2'b10;
            if ((opB_sel == 2'b0)&& ex_mem_load) stall = 1'b1;
        end
        // RAW, 2 inst above
        else if(((rs2_e == mem_wb_rd) && mem_wb_regWrite) && de_ex_rs2_used && wb_rd_used)begin
            ForwardB = 2'b01;
        end
       

        // Conditions for flush
        if(pcSource != 0) begin
            flush_if_de = 1'b1;
            flush_de_ex = 1'b1;
        end

    end
endmodule