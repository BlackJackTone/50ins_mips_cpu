
`ifndef LALA
`define LALA

`include "MultiplicationDivisionUnit.sv"

typedef struct packed{
    logic RegDst;
    logic Jump;
    logic Branch;
    logic MemRead;
    logic Mem2Reg;
    logic [3:0] ALUOp;
    logic Imm2UpReg;
    logic JumpReg;
    logic WriteRA;
    logic MemWrite;
    logic ALUSrc;
    logic RegWrite;
    logic ImmSign;
    logic SaImm;
    logic Shift;
    mdu_operation_t MduOp;
    logic MduStart;
    logic [1:0] MemGrain;
    logic MemSign;
    logic InsException;
}Controller;

typedef struct packed {
    logic [5:0] opcode;
    logic [4:0] rs;
    logic [4:0] rt;
    logic [4:0] rd;
    logic [4:0] shamt;
    logic [5:0] funct;
}R_form;

typedef struct packed {
    logic [5:0] opcode;
    logic [4:0] rs;
    logic [4:0] rt;
    logic [15:0] imm;
}I_form;

typedef struct packed {
    logic [5:0] opcode;
    logic [25:0] addr;
}J_form;

typedef union packed {
    R_form R;
    I_form I;
    J_form J;
}Instruction;

typedef struct packed {
    Instruction ins;
    Controller ctl;
    logic [3:0] ALUCtlSig;
    logic ALUZero;
    logic [31:0] PC;
    logic [31:0] rs_val;
    logic [31:0] rt_val;
    logic [31:0] ALUoperand;
    logic [31:0] rd_val;
    logic [31:0] imm_val;
    logic [4:0] rs;
    logic [4:0] rt;
    logic [4:0] rd;
}PipelineReg;

`endif