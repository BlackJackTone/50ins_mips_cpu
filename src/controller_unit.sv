
`include "my_lib.sv"

module ControllerUnit(
    input Instruction ins,
    output Controller ctl
    );
    
    reg fini;
    initial begin
        fini = 0;
    end
    wire [2:0] lala;
    assign lala = MDU_READ_HI;
    always_comb begin
        ctl = 0;
        // if (fini == 1) begin
        //     $finish;
        // end
        // not nop
        if (ins != 0) begin
            case(ins.R.opcode)
    //                R-format
                6'b000000: begin
//                    SYSCALL
                        if (ins.R.funct == 6'b001100) begin
                            // fini = 1;
                        end
//                    JR
                        else if (ins.R.funct == 6'b001000) begin
                            ctl.Jump = 1;
                            ctl.JumpReg = 1;
                        end
//                    JALR
                        else if (ins.R.funct == 6'b001001) begin
                            ctl.Jump = 1;
                            ctl.JumpReg = 1;
                            ctl.WriteRA = 1;
                            ctl.RegWrite = 1;
                        end
//    MDU_READ_HI,010000
//    MDU_READ_LO,010010
//    MDU_WRITE_HI,010001
//    MDU_WRITE_LO,010011
//    MDU_START_SIGNED_MUL,011000
//    MDU_START_UNSIGNED_MUL,011001
//    MDU_START_SIGNED_DIV,011010
//    MDU_START_UNSIGNED_DIV 011011
//    MULT / MULTU / DIV / DIVU / MFHI / MTHI / MFLO / MTLO
//                    MFHI
                        else if (ins.R.funct == 6'b010000) begin
                            ctl.RegWrite = 1;
                            ctl.MduStart = 1;
                            ctl.MduOp = MDU_READ_HI;
                        end
//                    MHLO
                        else if (ins.R.funct == 6'b010010) begin
                            ctl.RegWrite = 1;
                            ctl.MduStart = 1;
                            ctl.MduOp = MDU_READ_LO;
                        end
//                    MTHI
                        else if (ins.R.funct == 6'b010001) begin
                            ctl.MduStart = 1;
                            ctl.MduOp = MDU_WRITE_HI;
                        end
//                    MTLO
                        else if (ins.R.funct == 6'b010011) begin
                            ctl.MduStart = 1;
                            ctl.MduOp = MDU_WRITE_LO;
                        end
//                    MULT
                        else if (ins.R.funct == 6'b011000) begin
                            ctl.MduStart = 1;
                            ctl.MduOp = MDU_START_SIGNED_MUL;
                        end
//                    MULTU
                        else if (ins.R.funct == 6'b011001) begin
                            ctl.MduStart = 1;
                            ctl.MduOp = MDU_START_UNSIGNED_MUL;
                        end
//                    DIV
                        else if (ins.R.funct == 6'b011010) begin
                            ctl.MduStart = 1;
                            ctl.MduOp = MDU_START_SIGNED_DIV;
                        end
//                    DIVU
                        else if (ins.R.funct == 6'b011011) begin
                            ctl.MduStart = 1;
                            ctl.MduOp = MDU_START_UNSIGNED_DIV;
                        end
                        else begin
                            ctl.RegDst = 1;
                            ctl.RegWrite = 1;
                            ctl.ALUOp[1] = 1;
                            ctl.ImmSign = 1;
//                    ADD
                            if (ins.R.funct == 6'b100000) begin
                                ctl.InsException = 1;
                            end
//                    SUB
                            if (ins.R.funct == 6'b100010) begin
                                ctl.InsException = 1;
                            end
                            
//                    SLL SRL SRA SLLV SRLV SRAV 
                            if (ins.R.funct == 6'b000000 || ins.R.funct == 6'b000010 || ins.R.funct == 6'b000011 || ins.R.funct == 6'b000100 || ins.R.funct == 6'b000110 || ins.R.funct == 6'b000111) begin
                                ctl.Shift = 1;
                            end
                            
//                    SLL SRL SRA
                            if (ins.R.funct == 6'b000000 || ins.R.funct == 6'b000010 || ins.R.funct == 6'b000011) begin
                                ctl.SaImm = 1;
                            end
                        end
                    end
    //                ADDI
                6'b001000: begin
                        ctl.InsException = 1;
                        ctl.ALUSrc = 1;
                        ctl.RegWrite = 1;
                        ctl.ImmSign = 1;
                    end
    //                ADDIU
                6'b001001: begin
                        ctl.ALUSrc = 1;
                        ctl.RegWrite = 1;
                        ctl.ImmSign = 1;
                    end
    //                ANDI
                6'b001100: begin
                        ctl.ALUSrc = 1;
                        ctl.RegWrite = 1;
                        ctl.ALUOp[3] = 1;
                        ctl.ALUOp[0] = 1;
                    end
    //                ORI
                6'b001101: begin
                        ctl.ALUSrc = 1;
                        ctl.RegWrite = 1;
                        ctl.ALUOp[3] = 1;
                        ctl.ALUOp[1] = 1;
                    end
    //                XORI
                6'b001110: begin
                        ctl.ALUSrc = 1;
                        ctl.RegWrite = 1;
                        ctl.ALUOp[3] = 1;
                        ctl.ALUOp[1] = 1;
                        ctl.ALUOp[0] = 1;
                    end
    //                STLI
                6'b001010: begin
                        ctl.ALUSrc = 1;
                        ctl.RegWrite = 1;
                        ctl.ImmSign = 1;
                        ctl.ALUOp[3] = 1;
                        ctl.ALUOp[2] = 1;
                    end
    //                STLIU
                6'b001011: begin
                        ctl.ALUSrc = 1;
                        ctl.RegWrite = 1;
                        ctl.ImmSign = 1;
                        ctl.ALUOp[3] = 1;
                        ctl.ALUOp[2] = 1;
                        ctl.ALUOp[0] = 1;
                    end
    //                BEQ
                6'b000100: begin
                        ctl.Branch = 1;
                        ctl.ALUOp[0] = 1;
                        ctl.ImmSign = 1;
                    end
    //                BNE
                6'b000101: begin
                        ctl.Branch = 1;
                        ctl.ALUOp[1] = 1;
                        ctl.ImmSign = 1;
                    end
    //                BLEZ
                6'b000110: begin
                        ctl.Branch = 1;
                        ctl.ALUOp[0] = 1;
                        ctl.ALUOp[1] = 1;
                        ctl.ImmSign = 1;
                    end
    //                BGTZ
                6'b000111: begin
                        ctl.Branch = 1;
                        ctl.ALUOp[2] = 1;
                        ctl.ImmSign = 1;
                    end
    //                BGEZ BLTZ
                6'b000001: begin
                        ctl.Branch = 1;
                        ctl.ALUOp[2] = 1;
                        ctl.ImmSign = 1;
                        if (ins.R.rt == 5'b00001) begin
                            ctl.ALUOp[0] = 1;
                        end
                        else begin
                            ctl.ALUOp[1] = 1;
                        end
                    end
    //                J
                6'b000010: begin
                        ctl.Jump = 1;
                    end
    //                JAL
                6'b000011: begin
                        ctl.Jump = 1;
                        ctl.WriteRA = 1;
                        ctl.RegWrite = 1;
                    end
    //                LUI
                6'b001111: begin
                        ctl.ALUSrc = 1;
                        ctl.RegWrite = 1;
                        ctl.Imm2UpReg = 1;
                    end
    //                LB
                6'b100000: begin
                        ctl.ALUSrc = 1;
                        ctl.Mem2Reg = 1;
                        ctl.RegWrite = 1;
                        ctl.MemRead = 1;
                        ctl.ImmSign = 1;
                        ctl.MemSign = 1;
                        ctl.MemGrain[0] = 1;
                    end
    //                LBU
                6'b100100: begin
                        ctl.ALUSrc = 1;
                        ctl.Mem2Reg = 1;
                        ctl.RegWrite = 1;
                        ctl.MemRead = 1;
                        ctl.ImmSign = 1;
                        ctl.MemGrain[0] = 1;
                    end
    //                LH
                6'b100001: begin
                        ctl.ALUSrc = 1;
                        ctl.Mem2Reg = 1;
                        ctl.RegWrite = 1;
                        ctl.MemRead = 1;
                        ctl.ImmSign = 1;
                        ctl.MemSign = 1;
                        ctl.MemGrain[1] = 1;
                    end
    //                LHU
                6'b100101: begin
                        ctl.ALUSrc = 1;
                        ctl.Mem2Reg = 1;
                        ctl.RegWrite = 1;
                        ctl.MemRead = 1;
                        ctl.ImmSign = 1;
                        ctl.MemGrain[1] = 1;
                    end
    //                LW
                6'b100011: begin
                        ctl.ALUSrc = 1;
                        ctl.Mem2Reg = 1;
                        ctl.RegWrite = 1;
                        ctl.MemRead = 1;
                        ctl.ImmSign = 1;
                    end
    //                SB
                6'b101000: begin
                        ctl.ALUSrc = 1;
                        ctl.MemWrite = 1;
                        ctl.ImmSign = 1;
                        ctl.MemGrain[0] = 1;
                    end
    //                SH
                6'b101001: begin
                        ctl.ALUSrc = 1;
                        ctl.MemWrite = 1;
                        ctl.ImmSign = 1;
                        ctl.MemGrain[1] = 1;
                    end
    //                SW
                6'b101011: begin
                        ctl.ALUSrc = 1;
                        ctl.MemWrite = 1;
                        ctl.ImmSign = 1;
                    end
            endcase
        end
    end
    
endmodule 