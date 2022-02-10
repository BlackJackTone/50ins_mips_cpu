`timescale 1ps / 1ps
`include "my_lib.sv"

module GeneralPurposeRegisters(
    input reset ,
    input clock ,
    input [31:0] PCvalue,
    input [4:0] rs ,
    input [4:0] rt ,
    input [4:0] rd ,
    input WriteEnable ,
    input [31:0] WriteValue ,
    output [31:0] ReadValue0 ,
    output [31:0] ReadValue1
    );
    
    // wire [31:0] ReadValue0;
    // wire [31:0] ReadValue1;
    
    reg [31:0] RegGrp [31:0];
    
    assign ReadValue0 = RegGrp[rs];
    assign ReadValue1 = RegGrp[rt];
    
    integer i;
    always_ff @ (posedge clock) begin
        if (reset) begin
            for ( i = 0; i < 32; ++i)
                RegGrp[i] <= 0;
        end
        if (WriteEnable) begin
            if (rd != 0) begin
                RegGrp[rd] <= WriteValue; 
            end
            $display("@%h: $%d <= %h", PCvalue, rd, WriteValue);
        end
    end
    
endmodule 
