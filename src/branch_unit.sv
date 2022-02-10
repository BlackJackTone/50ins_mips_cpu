`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/21 14:33:20
// Design Name: 
// Module Name: branch_unit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//typedef struct packed{
//    logic RegDst;
//    logic Jump;
//    logic Branch;
//    logic MemRead;
//    logic Mem2Reg;
//    logic [3:0] ALUOp;
//    logic Imm2UpReg;
//    logic JumpReg;
//    logic WriteRA;
//    logic MemWrite;
//    logic ALUSrc;
//    logic RegWrite;
//    logic ImmSign;
//    logic SaImm;
//    logic Shift;
//}Controller;
`include "my_lib.sv"

module BranchUnit(
    input wire[31:0] in0,
    input wire[31:0] in1,
    input wire[3:0] ALUOp,
    output wire out
//    in0,
//    in1,
//    ctl,
//    out
    );
    
//    input wire[31:0] in0;
//    input wire[31:0] in1;
//    input Controller ctl;
//    output wire out;
    
    
    reg tmp;
    assign out = tmp;
    
    always_comb begin
        case(ALUOp)
            4'b0001: tmp = (in0 == in1);
            4'b0010: tmp = (in0 != in1);
            4'b0011: tmp = ($signed(in0) <= 0);
            4'b0100: tmp = ($signed(in0) > 0);
            4'b0101: tmp = ($signed(in0) >= 0);
            4'b0110: tmp = ($signed(in0) < 0);
        endcase
    end

endmodule
