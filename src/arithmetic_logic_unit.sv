`timescale 1ps / 1ps
`include "my_lib.sv"

module ArithmeticLogicUnit(
    PCValue,
    ReadData0,
    ReadData1,
    Exp,
    Ctl,
    Res,
    Zero
    );
    input wire [31:0] PCValue;
    input wire [31:0] ReadData0, ReadData1;
    input wire [3:0] Ctl;
    input wire Exp;
    output wire [31:0] Res;
    output wire Zero;
    
    reg [31:0] tmp;
    assign Res = tmp;
    
    reg ZeroFlag;
    assign Zero = ZeroFlag;
    
    always_comb begin
        case(Ctl)
            4'b1000: tmp = ReadData0 << ReadData1;
            4'b1001: tmp = ReadData0 >> ReadData1;
            4'b1011: tmp = ($signed(ReadData0)) >>> ReadData1;
            4'b0010: begin
                tmp = ReadData0 + ReadData1;
                if ( (({tmp[31], tmp} != ({ReadData0[31], ReadData0} + {ReadData1[31], ReadData1})) & Exp)== 1) begin
                    $display("@%h: SignalException IntegerOverflow)", PCValue);
                    $finish;
                end
                end
            4'b0110: begin
                tmp = ReadData0 - ReadData1;
                if ( (({tmp[31], tmp} != ({ReadData0[31], ReadData0} - {ReadData1[31], ReadData1})) & Exp)== 1) begin
                    $display("@%h: SignalException IntegerOverflow)", PCValue);
                    $finish;
                end
                end
            4'b0000: tmp = ReadData0 & ReadData1;
            4'b0001: tmp = ReadData0 | ReadData1;
            4'b0011: tmp = ReadData0 ^ ReadData1;
            4'b0100: tmp = ~(ReadData0 | ReadData1);
            4'b0111: tmp = $signed(ReadData0) < $signed(ReadData1);
            4'b0101: tmp = ReadData0 < ReadData1;
            
        endcase
        if (tmp === 0)
            ZeroFlag = 1;
        else
            ZeroFlag = 0;
    end

endmodule 