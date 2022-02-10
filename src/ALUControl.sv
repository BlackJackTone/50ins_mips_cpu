`timescale 1ps / 1ps

`include "my_lib.sv"

module ALUControl(
    ALUOp,
    Funct,
    Ctl
    );
    input wire [3:0] ALUOp;
    input wire [5:0] Funct;
    output wire [3:0] Ctl;
    
    reg [3:0] tmp;
    assign Ctl = tmp;
    
    always_comb begin
        if (ALUOp == 0) begin
            tmp = 4'b0010;
        end
        else if (ALUOp == 2'b01) begin
            tmp = 4'b0110;
        end
        else if (ALUOp == 2'b10) begin
            case (Funct)
//                SLL
                6'b000000: tmp = 4'b1000;
//                SRL
                6'b000010: tmp = 4'b1001;
//                SRA
                6'b000011: tmp = 4'b1011;
//                SLLV
                6'b000100: tmp = 4'b1000;
//                SRLV
                6'b000110: tmp = 4'b1001;
//                SRAV
                6'b000111: tmp = 4'b1011;
//                ADD
                6'b100000: tmp = 4'b0010;
//                ADDU
                6'b100001: tmp = 4'b0010;
//                SUB
                6'b100010: tmp = 4'b0110;
//                SUBU
                6'b100011: tmp = 4'b0110;
//                AND
                6'b100100: tmp = 4'b0000;
//                OR
                6'b100101: tmp = 4'b0001;
//                XOR
                6'b100110: tmp = 4'b0011;
//                NOR
                6'b100111: tmp = 4'b0100;
//                SLT
                6'b101010: tmp = 4'b0111;
//                SLTU
                6'b101011: tmp = 4'b0101;
            endcase
        end
        else if (ALUOp & 4'b1000) begin
            case (ALUOp[2:0])
//                ANDI
                3'b001: tmp = 4'b0000;
//                ORI
                3'b010: tmp = 4'b0001;
//                XORI
                3'b011: tmp = 4'b0011;
//                STLI
                3'b100: tmp = 4'b0111;
//                STLIU
                3'b101: tmp = 4'b0101;
            endcase
        end
    end
endmodule
