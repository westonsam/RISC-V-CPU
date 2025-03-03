`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer:  Samuel Weston & Phillipe Bakhirev
// Module Name: PIPELINED_OTTER_CPU WITH HAZARD HANDLING AND DATA FORWARDING
// Create Date: 02/27/2025
//////////////////////////////////////////////////////////////////////////////////

typedef enum logic [6:0] {
           LUI      = 7'b0110111,
           AUIPC    = 7'b0010111,
           JAL      = 7'b1101111,
           JALR     = 7'b1100111,
           BRANCH   = 7'b1100011,
           LOAD     = 7'b0000011,
           STORE    = 7'b0100011,
           OP_IMM   = 7'b0010011,
           OP       = 7'b0110011,
           SYSTEM   = 7'b1110011
 } opcode_t;
        
typedef struct packed{
    opcode_t opcode;
    logic [4:0] rs1_addr;
    logic [4:0] rs2_addr;
    logic [4:0] rd_addr;
    logic rs1_used;
    logic rs2_used;
    logic rd_used;
    logic [3:0] alu_fun;
    logic memWrite;
    logic memRead2;
    logic regWrite;
    logic [31:0] pc;
    logic [1:0] rf_wr_sel;
    logic [2:0] mem_type;
    logic [31:0]U_immed, I_immed, S_immed, J_type, B_type;
    logic [31:0] rs1;
} instr_t;

module OTTER_MCU(input CLK,
                input INTR,
                input RESET,
                input [31:0] IOBUS_IN,
                output [31:0] IOBUS_OUT,
                output [31:0] IOBUS_ADDR,
                output logic IOBUS_WR 
);           

    wire    [31:0] next_pc, aluBin, aluAin, aluResult, rfIn, mem_data;
    wire    [31:0] HazardAout, HazardBout;
    wire    [31:0] jalr, branch, jump;
    wire    [2:0]  PC_SEL;
    wire    [1:0]  opB_sel;
    wire           opA_sel;
    wire           BR_EN;
    logic [31:0] IR;

    // Instruction Fetch
    instr_t        de_ex_inst, de_inst, ex_mem_inst, mem_wb_inst;
    logic   [31:0] pc, B_type, J_type, rs2;
    logic   [31:0] if_de_pc;
    logic   [31:0] if_de_next_pc;
    logic   [1:0]  ForwardA, ForwardB;
    logic          br_lt, br_eq, br_ltu;
    logic          pcWrite, memRead1;

    // DE_EX
    logic   [31:0] de_ex_pc;
    logic   [31:0] de_ex_next_pc;
    logic   [31:0] de_ex_rs2;
    logic   [1:0]  de_ex_opB_sel;
    logic          de_ex_opA_sel;

    // EX_MEM
    logic   [31:0] ex_mem_next_pc;
    logic   [31:0] ex_mem_rs2;
    logic   [31:0] ex_mem_HazardBout;
    logic   [31:0] ex_mem_aluRes;
    
    // MEM_WB
    logic   [31:0] mem_wb_next_pc;
    logic   [31:0] mem_wb_aluRes;

    // HAZARDS
    logic          stall, stalled, stalled2, flush, flushed;
    
    // CACHE
    wire [31:0] w0, w1, w2, w3, w4, w5, w6, w7;
    wire cacheHit, cacheMiss, fsmRST, update, pcStall;
    wire [31:0] cacheIM, memoryIM, imOut;
              
//    assign pcWrite = (!stall && (!pcStall || (BR_EN) ) );    //dont update the PC while we are stalling for new DOUT1

//==== Instruction Fetch ===========================================
       
    PC PC  (
       .CLK        (CLK),
       .RST        (RESET),
       .PC_WRITE   (pcWrite),
       .PC_SEL     (PC_SEL),
       .JALR       (jalr),
       .BRANCH     (branch),
       .JAL        (jump),
       .MTVEC      (),
       .MEPC       (),
       .PC_OUT     (pc),
       .PC_OUT_INC (next_pc)
    );
    always_comb begin
        if (!stall && (!pcStall || (BR_EN) )) begin
            pcWrite <= 1'b1;
            if_de_pc        <= pc;
            if_de_next_pc   <= next_pc;
        end
        else begin
            pcWrite <= 1'b0;
            if_de_pc <= if_de_pc;
            if_de_next_pc <= if_de_next_pc; 
        end
    end
//    always_comb begin
//        if (BR_EN) begin
//            IR <= 8'h00000013;
//        end
//        else begin
//            IR <= imOut;
//        end
//    end
//    always_comb begin
//        if (stall) begin
//            pcWrite         <= 1'b0;
//            memRead1        <= 1'b0;
//        end
//        else begin
//            if_de_pc        <= pc;
//            if_de_next_pc   <= next_pc;
//            pcWrite         <= 1'b1;
//            memRead1        <= 1'b1;
//        end
//    end  
    
    always_ff @(posedge CLK) begin
        if(!stall) begin
            stalled         <= 1'b0;
            memRead1        <= 1'b1;
        end
        else if(stall) begin
            stalled         <=1'b1;
            memRead1        <= 1'b0;
        end   
    end

    always_ff @(posedge CLK) begin
        if (stalled) begin
            stalled2 <= 1'b1;
        end
        else begin
            stalled2 <=1'b0;
        end
end    

//==== Decode ===========================================
    
    opcode_t OPCODE;
    assign OPCODE = opcode_t'(IR[6:0]);
    assign de_inst.rs1_addr=IR[19:15];
    assign de_inst.rs2_addr=IR[24:20];
    assign de_inst.rd_addr=IR[11:7];
    assign de_inst.opcode=OPCODE;
    assign de_inst.mem_type=IR[14:12];

//==== Hazard Detection ===========================================
   
    assign de_inst.rs1_used=    de_inst.rs1_addr  != 0    
                                && de_inst.opcode != LUI 
                                && de_inst.opcode != AUIPC
                                && de_inst.opcode != JAL;
    
    assign de_inst.rs2_used=    de_inst.rs2_addr  != 0   
                                && de_inst.opcode != OP_IMM
                                && de_inst.opcode != LUI
                                && de_inst.opcode != AUIPC
                                && de_inst.opcode != JAL;
                                
    assign de_inst.rd_used=     de_inst.rd_addr   != 0    
                                && de_inst.opcode != BRANCH 
                                && de_inst.opcode != STORE;
                                
    // Instantiate Hazard Unit
    Hazard_Detection Hazard_Detection_Unit(
        // RS1 AND RS2                      
        .rs1_d              (de_inst.rs1_addr),
        .rs2_d              (de_inst.rs2_addr),
        .de_rs1_used        (de_inst.rs1_used), 
        .de_rs2_used        (de_inst.rs2_used),
        .rs1_e              (de_ex_inst.rs1_addr),
        .rs2_e              (de_ex_inst.rs2_addr),
        .de_ex_rs1_used     (de_ex_inst.rs1_used),
        .de_ex_rs2_used     (de_ex_inst.rs2_used),
        // RD 
        .id_ex_rd           (de_ex_inst.rd_addr),
        .mem_rd_used        (ex_mem_inst.rd_used),          
        .wb_rd_used         (mem_wb_inst.rd_used),
        .ex_mem_rd          (ex_mem_inst.rd_addr),
        .mem_wb_rd          (mem_wb_inst.rd_addr),
        // OTHER
        .ex_mem_regWrite    (ex_mem_inst.regWrite),
        .mem_wb_regWrite    (mem_wb_inst.regWrite),
        .memRead2           (de_ex_inst.memRead2),
        .stalled            (stalled),
        .stalled2           (stalled2),
        .pcSource           (PC_SEL),
        .ForwardA           (ForwardA),
        .ForwardB           (ForwardB),
        .stall              (stall),
        .flush              (flush),
        .opcode             (de_inst.opcode),
        .de_ex_rf_wr_sel    (de_ex_inst.rf_wr_sel)
    );

//==== End of Hazard Detection ===========================================
 
    // Instantiate Decoder
    CU_DCDR CU_DCDR (
        .IR_30      (IR[30]),
        .IR_OPCODE  (OPCODE),
        .IR_FUNCT   (IR[14:12]),
        .BR_EQ      (br_eq),       
        .BR_LT      (br_lt),
        .BR_LTU     (br_ltu),
        .ALU_FUN    (de_inst.alu_fun),
        .ALU_SRCA   (opA_sel),
        .ALU_SRCB   (opB_sel),
        .RF_WR_SEL  (de_inst.rf_wr_sel),
        .REG_WRITE  (de_inst.regWrite),
        .MEM_WRITE  (de_inst.memWrite),
        .MEM_READ_2 (de_inst.memRead2)
    );
    
    // Instantiate Immediate Generator
    ImmediateGenerator ImmGen(
        .IR     (IR[31:7]),
        .U_TYPE (de_inst.U_immed),
        .I_TYPE (de_inst.I_immed),
        .S_TYPE (de_inst.S_immed),
        .B_TYPE (de_inst.B_type),
        .J_TYPE (de_inst.J_type)
    );

    // Instantiate Register
    REG_FILE RegFile(
        .CLK    (CLK),
        .EN     (mem_wb_inst.regWrite),
        .ADR1   (de_inst.rs1_addr),
        .ADR2   (de_inst.rs2_addr),
        .WA     (mem_wb_inst.rd_addr),
        .WD     (rfIn),
        .RS1    (de_inst.rs1),
        .RS2    (rs2)
    );

	always_ff @ (posedge CLK) begin
	    if(flush) begin
            de_ex_inst      <= 0;

            de_ex_opA_sel   <= 0;
            de_ex_opB_sel   <= 0;
            de_ex_rs2       <= 0;
               
            de_ex_next_pc   <= 0;
            de_ex_pc        <= 0;
            flushed         <= 1;
	    end
	    else if(flushed) begin
            de_ex_inst      <= 0;
               
            de_ex_opA_sel   <= 0;
            de_ex_opB_sel   <= 0;
            de_ex_rs2       <= 0;
              
            de_ex_next_pc   <= 0;
            de_ex_pc        <= 0; 
            flushed         <= 0;
        end     
        else if(stall || (pcStall && !BR_EN)) begin
            de_ex_inst      <= de_ex_inst;      
            de_ex_rs2       <= de_ex_rs2;
            de_ex_pc        <= de_ex_pc;	       
               
            de_ex_opA_sel   <= de_ex_opA_sel;
            de_ex_opB_sel   <= de_ex_opB_sel;
            de_ex_next_pc   <= de_ex_next_pc;
	    end
	    else begin
            de_ex_inst      <= de_inst;
            de_ex_rs2       <= rs2;
             
            de_ex_opA_sel   <= opA_sel;
            de_ex_opB_sel   <= opB_sel;	       
            de_ex_next_pc   <= if_de_next_pc;
            de_ex_pc        <= if_de_pc;
	    end
	end

//==== Execute ======================================================
    
    // Instantiate ALU
    ALU ALU (
        .ALU_FUN    (de_ex_inst.alu_fun),  
        .SRC_A      (aluAin),
        .SRC_B      (aluBin), 
        .RESULT     (aluResult)
     );
    
    // Instantiate Branch Condition Generator
    BCG BCG(
        .RS1        (HazardAout),
        .RS2        (HazardBout),
        .func3      (de_ex_inst.mem_type),
        .opcode     (de_ex_inst.opcode),
        .PC_SOURCE  (PC_SEL),
        .branch     (BR_EN)
    );
        
    // Instantiate Branch Address Generator
    BAG BAG(
        .RS1        (HazardAout),
        .I_TYPE     (de_ex_inst.I_immed),
        .J_TYPE     (de_ex_inst.J_type),
        .B_TYPE     (de_ex_inst.B_type),
        .FROM_PC    (de_ex_pc),
        .JAL        (jump),
        .BRANCH     (branch),
        .JALR       (jalr)  
    );
    
    // Instantiate Hazard MUX A
    FourMux HazardMUXA (
       .ZERO        (de_ex_inst.rs1),     
       .ONE         (rfIn),
       .TWO         (ex_mem_aluRes),
       .THREE       (31'b0),
       .SEL         (ForwardA),
       .OUT         (HazardAout)
    );
    
    // Instantiate Hazard MUX B
    FourMux HazardMUXB (  
       .ZERO        (de_ex_rs2),
       .ONE         (rfIn),
       .TWO         (ex_mem_aluRes),
       .THREE       (31'b0),
       .SEL         (ForwardB),
       .OUT         (HazardBout)
    );

    // Instantiate ALU MUX A
    TwoMux AluMuxA  (
        .SEL        (de_ex_opA_sel),   
        .RS1        (HazardAout),
        .U_TYPE     (de_ex_inst.U_immed),
        .OUT        (aluAin)  
    );

    // Instantiate ALU MUX B   
    FourMux AluMuxB (
        .SEL        (de_ex_opB_sel),
        .ZERO       (HazardBout),
        .ONE        (de_ex_inst.I_immed),
        .TWO        (de_ex_inst.S_immed),
        .THREE      (de_ex_pc),
        .OUT        (aluBin)  
    );

    always_ff @ (posedge CLK) begin  
        begin
            ex_mem_inst         <= de_ex_inst;
            ex_mem_rs2          <= de_ex_rs2;
            ex_mem_aluRes       <= aluResult;
            ex_mem_next_pc      <= de_ex_next_pc;
            ex_mem_HazardBout   <= HazardBout;
        end
    end

//==== Memory ======================================================
     
    // Insantiate 8 Word Cache Loader
    InstructionMem OneTo8Inst(
        .a(pc), //address
        .w0(w0),
        .w1(w1),
        .w2(w2),
        .w3(w3),
        .w4(w4), 
        .w5(w5),
        .w6(w6),
        .w7(w7)
    );
    
    // Instantiate Cache FSM
    CacheFSM CacheFSM(
        .hit(cacheHit), 
        .miss(cacheMiss), 
        .CLK(CLK), 
        .RST(fsmRST), 
        .update(update), 
        .pc_stall(pcStall)
    );
    
    // Instantiate Main Cache
    DirectMapCache Cache(
            .PC(pc),
            .CLK(CLK),
            .update(update),
            .w0(w0),
            .w1(w1),
            .w2(w2), 
            .w3(w3),
            .w4(w4), 
            .w5(w5),
            .w6(w6), 
            .w7(w7),
            .rd(IR), 
            .hit(cacheHit), 
            .miss(cacheMiss)
    );
    
    // Instantiate Main Memory
    OTTER_mem_byte Memory (
        .MEM_CLK    (CLK),
        .MEM_READ1  (memRead1),
        .MEM_READ2  (ex_mem_inst.memRead2),
        .MEM_WRITE2 (ex_mem_inst.memWrite),        
        .MEM_ADDR1  (),                     // Disconnected
        .MEM_ADDR2  (ex_mem_aluRes),          
        .MEM_DIN2   (ex_mem_HazardBout),
        .MEM_SIZE   (ex_mem_inst.mem_type[1:0]),     
        .MEM_SIGN   (ex_mem_inst.mem_type[2]),          
        .IO_IN      (IOBUS_IN),
        .IO_WR      (IOBUS_WR),
        .MEM_DOUT1  (memoryIM),
        .MEM_DOUT2  (mem_data),
        .ERR        (memERR)
    );     

    assign IOBUS_ADDR   = ex_mem_aluRes;
    assign IOBUS_OUT    = ex_mem_rs2;

    always_ff @ (posedge CLK) begin
        mem_wb_inst     <= ex_mem_inst;
        mem_wb_next_pc  <= ex_mem_next_pc;
        mem_wb_aluRes   <= ex_mem_aluRes;
    end
    
//==== Write Back ==================================================
     
    FourMux RegMux (
        .SEL   (mem_wb_inst.rf_wr_sel),
        .ZERO  (mem_wb_next_pc),
        .ONE   (0),
        .TWO   (mem_data),
        .THREE (mem_wb_aluRes),
        .OUT   (rfIn)  
    );
    
endmodule