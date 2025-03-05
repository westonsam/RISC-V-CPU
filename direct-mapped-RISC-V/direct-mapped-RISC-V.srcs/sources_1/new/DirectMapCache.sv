`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer:  Samuel Weston & Phillipe Bakhirev
// Module Name: Direct Map Cache
// Create Date: 02/28/2025
//////////////////////////////////////////////////////////////////////////////////

module DirectMapCache(
            input [31:0] PC,
            input CLK,
            input update,
            input logic [31:0] w0,
            input logic [31:0] w1,
            input logic [31:0] w2, 
            input logic [31:0] w3,
            input logic [31:0] w4, 
            input logic [31:0] w5,
            input logic [31:0] w6, 
            input logic [31:0] w7,
            output logic [31:0] rd,
            output logic hit, 
            output logic miss
);

    parameter NUM_BLOCKS = 16;
    parameter BLOCK_SIZE = 8;
    parameter INDEX_SIZE = 4;
    parameter WORD_OFFSET_SIZE = 3;
    parameter BYTE_OFFSET = 0;
    parameter TAG_SIZE = 32 - INDEX_SIZE - WORD_OFFSET_SIZE - BYTE_OFFSET;
    
    logic [31:0] data[NUM_BLOCKS-1:0][BLOCK_SIZE-1:0];
    logic [TAG_SIZE-1:0] tags[NUM_BLOCKS-1:0];
    logic valid_bits[NUM_BLOCKS-1:0];
    logic [3:0] index;
    logic [TAG_SIZE-1:0]cache_tag, pc_tag;
    logic [2:0] pc_offset;
    
    initial begin
        int i;int j;
        for(i = 0; i < NUM_BLOCKS; i = i + 1) begin //initializing RAM to 0
            for(j=0; j < BLOCK_SIZE; j = j + 1) begin
                data[i][j] = 32'b0;
                tags[i] = 32'b0;
                valid_bits[i] = 1'b0;
            end
        end
    end
    
    assign index = PC[8:5];
    assign validity = valid_bits[index];
    assign cache_tag = tags[index];
    assign pc_offset = PC[4:2];
    assign pc_tag = PC[31:9];
 
    assign hit = (validity && (cache_tag == pc_tag));
    assign miss = !hit;
    
//    always_comb begin
//        rd = 32'h00000013; //nop
//        if(hit) rd = data[index][pc_offset];
//    end
    
    always_ff @(posedge CLK) begin // Was Negedge
        if(update) begin
            data[index][0]      <= w0;
            data[index][1]      <= w1;
            data[index][2]      <= w2;
            data[index][3]      <= w3;
            data[index][4]      <= w4;
            data[index][5]      <= w5;
            data[index][6]      <= w6;
            data[index][7]      <= w7;
            tags[index]         <= pc_tag;
            valid_bits[index]   <= 1'b1;
        end
//        assign hit = (validity && (cache_tag == pc_tag));
//        assign miss = !hit;
        rd = 32'h00000013; //nop
        if(hit) rd = data[index][pc_offset];
    end
endmodule