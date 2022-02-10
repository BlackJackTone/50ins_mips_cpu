`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/08 15:49:12
// Design Name: 
// Module Name: SignExtend
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

module IMMExtend
#(
    parameter LEN_BEFOR = 16,
    parameter LEN_AFTER = 32
    )
(
    input wire [(LEN_BEFOR-1):0] in,
    input wire imm_sign,
    output wire [(LEN_AFTER-1):0] out
    );
    assign out = {{(LEN_AFTER - LEN_BEFOR){ in[LEN_BEFOR-1] & imm_sign }}, in};
endmodule
