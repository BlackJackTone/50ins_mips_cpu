`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/30 12:37:17
// Design Name: 
// Module Name: PC
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

module ProgramCounter(
    reset,
    clock,
    in,
    pcValue
    );
    
    
    input wire reset;
    input wire clock;
    input wire [31:0] in;
    output wire [31:0] pcValue;
    
    reg[31:0] pc;
    
    assign pcValue = pc ;
    
    always_ff @(posedge clock )
    begin
        if (reset) begin 
            pc <= 'h00003000;
        end 
        else begin
            pc <= in;
        end
    end
endmodule
