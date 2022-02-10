`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/11/07 23:01:37
// Design Name: 
// Module Name: data_memory
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

module DataMemory 
#(
    parameter SZ = 2047,
    parameter LOGSZ = 11
    )
(
    input wire reset,
    input wire clock,
    input wire [31:0] PCvalue,
    input wire[31:0] address,
    input wire writeEnabled,
    input wire[31:0] writeInput,
    input Controller ctl,
    output wire[31:0] readResult
    );
    
    
    reg [31:0] data [SZ:0];
    reg [31:0] ReadTmp;
    assign readResult = ReadTmp;
    
//    assign readResult = data[address [LOGSZ + 1:2]];
    
    always_comb begin
        if (ctl.MemRead == 1) begin
            case (ctl.MemGrain)
                2'b00: begin
                    if (address[1:0] != 2'b00) begin
                        $display("@%h: *%h SignalException AddressError", PCvalue, address);
                        $finish;
                    end
                    ReadTmp = data[address [LOGSZ + 1:2]];
                    end
                2'b01: begin
                    ReadTmp = {{24{ctl.MemSign & data[address [LOGSZ + 1:2]][8*address[1:0]+7 +: 1]}}, data[address [LOGSZ + 1:2]][8*address[1:0] +: 8]};
                    end
                2'b10: begin
                    if (address[0] != 1'b0) begin
                        $display("@%h: *%h SignalException AddressError", PCvalue, address);
                        $finish;
                    end
                    ReadTmp = {{16{ctl.MemSign & data[address [LOGSZ + 1:2]][16*address[1]+15 +: 1]}}, data[address [LOGSZ + 1:2]][16*address[1] +: 16]};
                    end
            endcase
        end
    end
    
    integer i;
    
    always_ff @(posedge clock ) begin
        if (reset) begin 
            for (i = 0; i< SZ;i = i + 1)
            begin
                data[i] <= 'h00000000;
            end
        end 
        else begin
            if (writeEnabled )
            begin 
                case (ctl.MemGrain)
                    2'b00: begin
                        if (address[1:0] != 2'b00) begin
                            $display("@%h: *%h SignalException AddressError", PCvalue, address);
                            $finish;
                        end
                        data[address [LOGSZ + 1:2]] = writeInput;
                        // $display("@%h: *%h <= %h", PCvalue, {address[31:2], 2'b00}, data[address [LOGSZ + 1:2]]);
                        end
                    2'b01: begin
                        data[address [LOGSZ + 1:2]][8*address[1:0] +: 8] = writeInput[7:0];
                        // $display("@%h: *%h <= %h", PCvalue, {address[31:2], 2'b00}, data[address [LOGSZ + 1:2]]);
                        end
                    2'b10: begin
                        if (address[0] != 1'b0) begin
                            $display("@%h: *%h SignalException AddressError", PCvalue, address);
                            $finish;
                        end
                        data[address [LOGSZ + 1:2]][16*address[1] +: 16] = writeInput[15:0];
                        // $display("@%h: *%h <= %h", PCvalue, {address[31:2], 2'b00}, data[address [LOGSZ + 1:2]]);
                        end
                endcase
                
                $display("@%h: *%h <= %h", PCvalue, {address[31:2], 2'b00}, data[address [LOGSZ + 1:2]]);
            end
        end
    end
    
    
endmodule
