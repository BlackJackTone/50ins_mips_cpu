`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/06 22:41:25
// Design Name: 
// Module Name: pipeline_register
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

module PipelineRegister(
    input wire reset,
    input wire clock,
    input PipelineReg inreg,
    output PipelineReg outreg
    );

    // parameter PP_REG_SIZE = $clog2(PipelineReg);
    // PipelineReg ppreg;
    reg [$bits(PipelineReg)-1:0] ppreg;
    assign outreg = ppreg;

    always_ff @ (posedge clock) begin
        if (reset == 1) begin
            ppreg <= 0;
        end
        else begin
            ppreg <= inreg;
        end
    end

endmodule
