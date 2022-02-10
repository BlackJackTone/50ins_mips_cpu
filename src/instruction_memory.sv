`include "my_lib.sv"

module InstructionMemory(
    reset ,
    clock ,
    addr ,
    ins
    );
    input wire reset;
    input wire clock;
    input wire [31:0] addr;
    output Instruction ins;
    
    reg [31:0] im [1023:0];
    assign ins = im[addr[11:2]];
    
    always @ (posedge clock) begin
        if (reset) begin
            $readmemh("./code.txt", im);
//            $display("%h",im[0]);
 //           $display("%h",im[1]);
//             $readmemh("C:\\Users\\tangx\\Desktop\\Pipeline50Test\\code\\0dE.asm.txt", im);
//             $readmemh("C:\\Users\\tangx\\Desktop\\Pipeline50Test\\code\\0eC.asm.txt", im);
//             $readmemh("C:\\Users\\tangx\\Desktop\\Pipeline50Test\\code\\0eL.asm.txt", im);
//             $readmemh("C:\\Users\\tangx\\Desktop\\Pipeline50Test\\code\\0hJ.asm.txt", im);
//             $readmemh("C:\\Users\\tangx\\Desktop\\Pipeline50Test\\code\\0vM.asm.txt", im);
//             $readmemh("C:\\Users\\tangx\\Desktop\\Pipeline50Test\\code\\02H.asm.txt", im);
//             $readmemh("C:\\Users\\tangx\\Desktop\\Pipeline50Test\\code\\08H.asm.txt", im);
//             $readmemh("C:\\Users\\tangx\\Desktop\\Pipeline50Test\\code\\22H.asm.txt", im);
//             $readmemh("C:\\Users\\tangx\\Desktop\\Pipeline50Test\\code\\28H.asm.txt", im);
//             $readmemh("C:\\Users\\tangx\\Desktop\\Pipeline50Test\\code\\82H.asm.txt", im);
//             $readmemh("C:\\Users\\tangx\\Desktop\\Pipeline50Test\\code\\88H.asm.txt", im);
        end
    end
    
endmodule