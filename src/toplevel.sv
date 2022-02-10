`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/20 15:40:03
// Design Name: 
// Module Name: toplevel
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

module TopLevel(
    input wire reset,
    input wire clock
    );
    
    
    PipelineCPU cpu(
        .reset(reset),
        .clock(clock)
        );
    
endmodule
