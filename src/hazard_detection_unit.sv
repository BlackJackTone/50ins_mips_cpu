`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/07 00:08:47
// Design Name: 
// Module Name: hazard_detection_unit
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

module HazardDetectionUnit(
    input wire MduBusy,
    input PipelineReg IF_ID_Reg,
    input PipelineReg ID_EX_Reg,
    input PipelineReg EX_MEM_Reg,
    input PipelineReg MEM_WB_Reg,
    input PipelineReg future_ID_EX_Reg,
    output reg Flush,
    output reg MduFlush
    );
    always_comb begin
        if (ID_EX_Reg.ctl.MemRead == 1) begin
            if (ID_EX_Reg.rd == future_ID_EX_Reg.rs || ID_EX_Reg.rd == future_ID_EX_Reg.rt)
                Flush = 1;
        end
        else if (EX_MEM_Reg.ctl.MemRead == 1 && (future_ID_EX_Reg.ctl.Branch == 1 || future_ID_EX_Reg.ctl.JumpReg == 1)) begin
            if (EX_MEM_Reg.rd == future_ID_EX_Reg.rs || ID_EX_Reg.rd == future_ID_EX_Reg.rt)
                Flush = 1;
        end
        else if (ID_EX_Reg.ctl.RegWrite == 1 && ID_EX_Reg.rd != 0 && ID_EX_Reg.rd == future_ID_EX_Reg.rs && (future_ID_EX_Reg.ctl.Branch == 1 || future_ID_EX_Reg.ctl.JumpReg == 1)) begin
            Flush = 1;
        end
        else if (ID_EX_Reg.ctl.RegWrite == 1 && ID_EX_Reg.rd != 0 && ID_EX_Reg.rd == future_ID_EX_Reg.rt && (future_ID_EX_Reg.ctl.Branch == 1 || future_ID_EX_Reg.ctl.JumpReg == 1)) begin
            Flush = 1;
        end
        else begin
            Flush = 0;
        end
        
        if ( (MduBusy & (ID_EX_Reg.ctl.MduStart) ) == 1 ) begin
            MduFlush = 1;
        end
        else begin
            MduFlush = 0;
        end
    end
endmodule
