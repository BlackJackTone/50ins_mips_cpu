`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/07 00:08:47
// Design Name: 
// Module Name: ForwardingUnit
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

`include "my_lib.sv"

module ForwardingUnit(
    input PipelineReg IF_ID_Reg,
    input PipelineReg ID_EX_Reg,
    input PipelineReg EX_MEM_Reg,
    input PipelineReg MEM_WB_Reg,
    input PipelineReg future_ID_EX_Reg,
    output reg [2:0] ForwardA,
    output reg [2:0] ForwardB,
    output reg [2:0] ForwardC,
    output reg [2:0] ForwardD
    );

    always_comb begin
///////////////        EX   //////////
        // rs
        if (EX_MEM_Reg.ctl.RegWrite == 1 && EX_MEM_Reg.rd != 0 && EX_MEM_Reg.rd == ID_EX_Reg.rs) begin
            ForwardA = 3'b010;
        end
        else if (MEM_WB_Reg.ctl.RegWrite == 1 && MEM_WB_Reg.rd != 0 && MEM_WB_Reg.rd == ID_EX_Reg.rs) begin
            ForwardA = 3'b001;
        end
        else begin
            ForwardA = 3'b000;
        end

        //rt
        if (EX_MEM_Reg.ctl.RegWrite == 1 && EX_MEM_Reg.rd != 0 && EX_MEM_Reg.rd == ID_EX_Reg.rt) begin
            ForwardB = 3'b010;
        end
        else if (MEM_WB_Reg.ctl.RegWrite == 1 && MEM_WB_Reg.rd != 0 && MEM_WB_Reg.rd == ID_EX_Reg.rt) begin
            ForwardB = 3'b001;
        end
        else begin
            ForwardB = 3'b000;
        end

///////////////      ID //////////

        // rs
        if (ID_EX_Reg.ctl.RegWrite == 1 && ID_EX_Reg.rd != 0 && ID_EX_Reg.rd == future_ID_EX_Reg.rs) begin
            ForwardC = 3'b100;
            // ForwardC = 3'b000;
        end
        else if (EX_MEM_Reg.ctl.RegWrite == 1 && EX_MEM_Reg.rd != 0 && EX_MEM_Reg.rd == future_ID_EX_Reg.rs) begin
            ForwardC = 3'b010;
        end
        else if (MEM_WB_Reg.ctl.RegWrite == 1 && MEM_WB_Reg.rd != 0 && MEM_WB_Reg.rd == future_ID_EX_Reg.rs) begin
            ForwardC = 3'b001;
        end
        else begin
            ForwardC = 3'b000;
        end

        //rt
        if (ID_EX_Reg.ctl.RegWrite == 1 && ID_EX_Reg.rd != 0 && ID_EX_Reg.rd == future_ID_EX_Reg.rt) begin
            ForwardD = 3'b100;
            // ForwardD = 3'b000;
        end
        else if (EX_MEM_Reg.ctl.RegWrite == 1 && EX_MEM_Reg.rd != 0 && EX_MEM_Reg.rd == future_ID_EX_Reg.rt) begin
            ForwardD = 3'b010;
        end
        else if (MEM_WB_Reg.ctl.RegWrite == 1 && MEM_WB_Reg.rd != 0 && MEM_WB_Reg.rd == future_ID_EX_Reg.rt) begin
            ForwardD = 3'b001;
        end
        else begin
            ForwardD = 3'b000;
        end
    end

endmodule
