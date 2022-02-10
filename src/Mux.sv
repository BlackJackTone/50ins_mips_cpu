`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/08 15:42:48
// Design Name: 
// Module Name: Mux
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

module Mux #(
    parameter MUX_LEN = 32
    )
(
    input [(MUX_LEN-1):0] in0,
    input [(MUX_LEN-1):0] in1,
    output [(MUX_LEN-1):0] out,
    input sig
    );
    assign out = sig ? in1 : in0;
endmodule
