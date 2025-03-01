`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly San Luis Obispo
// Engineer: Samuel Weston & Phillipe Bakhirev
// Create Date: 01/15/2025
// Module Name: RISC-V-CPU
//////////////////////////////////////////////////////////////////////////////////

module RISCV(
    input logic RST,
    input logic [31:0] IOBUS_IN,
    input logic CLK,
    output logic IOBUS_WR,
    output logic [31:0] IOBUS_OUT,
    output logic [31:0] IOBUS_ADDR
    );
    
    // Logic for PC
    logic pc_rst, pc_write;
    logic [2:0] pc_source;
    logic [31:0] pc_out, pc_out_inc, jalr, branch, jal;
    
    // Logic for Memory, RegFile, Immediate Generator, and RegFile Mux    
    logic [13:0] addr1;
    assign addr1 = pc_out[15:2];
    logic mem_rden1, mem_rden2, mem_we2;
    logic [31:0] dout2, ir;
    logic sign;
    assign sign = ir[14];
    logic [1:0] size;
    assign size = ir[13:12];
    
    // Logic for RegFile  
    logic reg_wr;
    logic [1:0] rf_wr_sel;
    logic [4:0] reg_adr1;
    assign reg_adr1 = ir[19:15]; 
    logic [4:0] reg_adr2;
    assign reg_adr2 = ir[24:20]; 
    logic [4:0] reg_wa;
    assign reg_wa = ir[11:7];
    
    // Logic for Immediate Generator
    logic [24:0] imgen_ir;
    assign imgen_ir = ir[31:7];
    logic [31:0] wd, rs1;
    
    // Logic for Branch Address Generator
    logic [31:0] Utype, Itype, Stype, Btype, Jtype;
    
    // Logic for ALU and ALU MUXes
    logic alu_src_a;
    logic [1:0] alu_src_b;
    logic [3:0] alu_fun;
    logic [31:0] srcA, srcB;
    
    // Logic for Branch Condition Generator
    logic br_eq, br_lt, br_ltu;
    
    // Logic for FSM and DCDR
    logic ir30;
    assign ir30 = ir[30];
    logic [6:0] opcode;
    assign opcode = ir[6:0];
    logic [2:0] funct;
    assign funct = ir[14:12]; 

    // Instantiate PC
    PC OTTER_PC(
        .CLK(CLK), 
        .RST(pc_rst), 
        .PC_WRITE(pc_write), 
        .PC_SOURCE(pc_source),
        .JALR(jalr), 
        .JAL(jal), 
        .BRANCH(branch), 
        .MTVEC(32'b0), 
        .MEPC(32'b0),
        .PC_OUT(pc_out), 
        .PC_OUT_INC(pc_out_inc)
    );

    //Instantiate Memory Module  
    Memory OTTER_MEMORY(
        .MEM_CLK(CLK), 
        .MEM_RDEN1(mem_rden1), 
        .MEM_RDEN2(mem_rden2), 
        .MEM_WE2(mem_we2), 
        .MEM_ADDR1(addr1), 
        .MEM_ADDR2(IOBUS_ADDR), 
        .MEM_DIN2(IOBUS_OUT), 
        .MEM_SIZE(size),
        .MEM_SIGN(sign), 
        .IO_IN(IOBUS_IN), 
        .IO_WR(IOBUS_WR), 
        .MEM_DOUT1(ir), 
        .MEM_DOUT2(dout2)
    );
    
    // Instantiate RegFile Mux
    FourMUX OTTER_REG_MUX(
        .SEL(rf_wr_sel), 
        .ZERO(pc_out_inc), 
        .ONE(32'b0), 
        .TWO(dout2), 
        .THREE(IOBUS_ADDR),
        .OUT(wd)
    );
    
    // Instantiate RegFile   
    REG_FILE OTTER_REG_FILE(
        .CLK(CLK), 
        .EN(reg_wr), 
        .ADR1(reg_adr1), 
        .ADR2(reg_adr2), 
        .WA(reg_wa), 
        .WD(wd), 
        .RS1(rs1), 
        .RS2(IOBUS_OUT)
    );
    
    // Instantiate Immediate Generator
    ImmediateGenerator OTTER_IMGEN(
        .IR(imgen_ir), 
        .U_TYPE(Utype), 
        .I_TYPE(Itype), 
        .S_TYPE(Stype),
        .B_TYPE(Btype), 
        .J_TYPE(Jtype)
    );
    
    // Instantiate Branch Address Generator  
    BAG OTTER_BAG(
        .RS1(rs1), 
        .I_TYPE(Itype), 
        .J_TYPE(Jtype), 
        .B_TYPE(Btype), 
        .FROM_PC(pc_out),
        .JAL(jal), 
        .JALR(jalr), 
        .BRANCH(branch)
    );

    // Instantiate ALU MUXes   
    TwoMUX ALU_MUXA(
        .ALU_SRC_A(alu_src_a), 
        .RS1(rs1), 
        .U_TYPE(Utype), 
        .SRC_A(srcA)
    );
    
    FourMUX ALU_MUXB(
        .SEL(alu_src_b), 
        .ZERO(IOBUS_OUT), 
        .ONE(Itype), 
        .TWO(Stype), 
        .THREE(pc_out), 
        .OUT(srcB)
    );
    
    // Instantiate ALU
    ALU OTTER_ALU(
        .SRC_A(srcA), 
        .SRC_B(srcB), 
        .ALU_FUN(alu_fun), 
        .RESULT(IOBUS_ADDR)
    );
    
    // Instantiate Branch Condition Generator
    BCG OTTER_BCG(
        .RS1(rs1), 
        .RS2(IOBUS_OUT), 
        .BR_EQ(br_eq), 
        .BR_LT(br_lt), 
        .BR_LTU(br_ltu)
    );
    
    // Instantiate Decoder 
    CU_DCDR OTTER_DCDR(.IR_30(ir30), .IR_OPCODE(opcode), .IR_FUNCT(funct), .BR_EQ(br_eq), .BR_LT(br_lt),
     .BR_LTU(br_ltu), .ALU_FUN(alu_fun), .ALU_SRCA(alu_src_a), .ALU_SRCB(alu_src_b), .PC_SOURCE(pc_source),
      .RF_WR_SEL(rf_wr_sel));
    
    // Instantiate FSM
    CU_FSM OTTER_FSM(.CLK(CLK), .RST(RST), .IR_OPCODE(opcode), 
        .PC_WRITE(pc_write), .REG_WRITE(reg_wr), .MEM_WE2(mem_we2), 
        .MEM_RDEN1(mem_rden1), .MEM_RDEN2(mem_rden2), .rst(pc_rst));
    
endmodule

