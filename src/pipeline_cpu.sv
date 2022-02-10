`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/12/07 00:29:23
// Design Name: 
// Module Name: pipeline_cpu
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


module PipelineCPU(
    input wire reset,
    input wire clock
    );
// Variable Declaration

// Module embedding
    // Instruction ins;
    // Controller ctl;

    PipelineReg IF_ID_Reg, ID_EX_Reg, EX_MEM_Reg, MEM_WB_Reg;
    PipelineReg future_IF_ID_Reg, future_ID_EX_Reg, future_EX_MEM_Reg, future_MEM_WB_Reg;



//    PC+4
    reg [31:0] NextPC;

    wire Flush;
    wire MduBusy;
    wire MduFlush;

    HazardDetectionUnit HDU(
        .MduBusy(MduBusy),
        .IF_ID_Reg(IF_ID_Reg),
        .ID_EX_Reg(ID_EX_Reg),
        .EX_MEM_Reg(EX_MEM_Reg),
        .MEM_WB_Reg(MEM_WB_Reg),
        .future_ID_EX_Reg(future_ID_EX_Reg),
        .Flush(Flush),
        .MduFlush(MduFlush)
    );

    PipelineRegister IF_ID(
        .reset(reset),
        .clock(clock),
        .inreg(future_IF_ID_Reg),
        .outreg(IF_ID_Reg)
    );
    PipelineRegister ID_EX(
        .reset(reset | Flush),
        .clock(clock),
        .inreg(MduFlush ? ID_EX_Reg : future_ID_EX_Reg),
        .outreg(ID_EX_Reg)
    );
    PipelineRegister EX_MEM(
        .reset(reset | MduFlush),
        .clock(clock),
        .inreg(future_EX_MEM_Reg),
        .outreg(EX_MEM_Reg)
    );
    PipelineRegister MEM_WB(
        .reset(reset),
        .clock(clock),
        .inreg(future_MEM_WB_Reg),
        .outreg(MEM_WB_Reg)
    );

    wire [2:0] ForwardA, ForwardB, ForwardC, ForwardD;

    ForwardingUnit FWDU(
        .IF_ID_Reg(IF_ID_Reg),
        .ID_EX_Reg(ID_EX_Reg),
        .EX_MEM_Reg(EX_MEM_Reg),
        .MEM_WB_Reg(MEM_WB_Reg),
        .future_ID_EX_Reg(future_ID_EX_Reg),
        .ForwardA(ForwardA),
        .ForwardB(ForwardB),
        .ForwardC(ForwardC),
        .ForwardD(ForwardD)
    );
/////////////////////////////////////////////   IF    ///////////////////////////////////////////////////////

    wire [31:0] PCnew;
    
    ProgramCounter PC(
        .reset(reset),
        .clock(clock),
        .in(NextPC),
        .pcValue(PCnew)
    );


    Instruction InsFetch;
//    IM
    InstructionMemory IM(
        .reset(reset) ,
        .clock(clock) ,
        .addr(future_IF_ID_Reg.PC) ,
        .ins(InsFetch)
    );
    
    always_comb begin
        future_IF_ID_Reg = 0;
        future_IF_ID_Reg.ins = InsFetch;
//    STALL
        if ((Flush | MduFlush) == 1) begin
            future_IF_ID_Reg.PC = IF_ID_Reg.PC;
        end
        else begin
            future_IF_ID_Reg.PC = PCnew;
        end
    end

/////////////////////////////////////////////   ID    ///////////////////////////////////////////////////////

//    CU

    Controller CtlFetch;
    ControllerUnit CU(
        .ins(IF_ID_Reg.ins),
        .ctl(CtlFetch)
    );

    wire [31:0] raw_rs, raw_rt;
    GeneralPurposeRegisters RegGrp(
        .reset(reset) ,
        .clock(clock) ,
        .PCvalue(MEM_WB_Reg.PC) ,
        .rs(future_ID_EX_Reg.rs) ,
        .rt(future_ID_EX_Reg.rt) ,
        .rd(MEM_WB_Reg.rd),
        .WriteEnable(MEM_WB_Reg.ctl.RegWrite) ,
        .WriteValue(MEM_WB_Reg.rd_val) ,                       //   waiting for the wb
        .ReadValue0(raw_rs) ,
        .ReadValue1(raw_rt)
    );

    wire [31:0] ImmFetch;

    IMMExtend Extd(
        .in(IF_ID_Reg.ins.I.imm),
        .imm_sign(future_ID_EX_Reg.ctl.ImmSign),
        .out(ImmFetch)
    );
    
    wire [3:0] ALUCtlSigFetch;

    ALUControl ALUCtl(
        .ALUOp(future_ID_EX_Reg.ctl.ALUOp),
        .Funct(IF_ID_Reg.ins.R.funct),
        .Ctl(ALUCtlSigFetch)
    );

    //    Branch
    wire [31:0] BaseAddressing;
    wire BranchRun;
    
    Adder Adder_Branch(
        .in0(IF_ID_Reg.PC+4) ,
        .in1({future_ID_EX_Reg.imm_val[29:0],2'b00}) ,
        .out(BaseAddressing)
    );
    BranchUnit BU(
        .in0(future_ID_EX_Reg.rs_val),
        .in1(future_ID_EX_Reg.rt_val),
        .ALUOp(future_ID_EX_Reg.ctl.ALUOp),
        .out(BranchRun)
    );
    
//    J & Branch
    
    wire [31:0] PsuedoDrctAddr;
    wire [31:0] PCplus4;
    assign PCplus4 = IF_ID_Reg.PC + 4;
    assign PsuedoDrctAddr = {PCplus4[31:28], IF_ID_Reg.ins.J.addr[25:0], 2'b00};


    always_comb begin
        future_ID_EX_Reg = IF_ID_Reg;
        future_ID_EX_Reg.ctl = CtlFetch;
        future_ID_EX_Reg.imm_val = ImmFetch;
        future_ID_EX_Reg.ALUCtlSig = ALUCtlSigFetch;
    // determine operand
        if (future_ID_EX_Reg.ctl.WriteRA == 1) begin
            if (future_ID_EX_Reg.ctl.JumpReg == 1) begin
                future_ID_EX_Reg.rs = IF_ID_Reg.ins.R.rs;
                future_ID_EX_Reg.rt = 0;
                future_ID_EX_Reg.rd = IF_ID_Reg.ins.R.rd;
            end
            else begin
                future_ID_EX_Reg.rs = 0;
                future_ID_EX_Reg.rt = 0;
                future_ID_EX_Reg.rd = 5'b11111;
            end
        end
        else if (future_ID_EX_Reg.ctl.Shift == 1) begin
            future_ID_EX_Reg.rs = IF_ID_Reg.ins.R.rt;
            future_ID_EX_Reg.rt = IF_ID_Reg.ins.R.rs;
            future_ID_EX_Reg.rd = IF_ID_Reg.ins.R.rd;
        end
        else if (future_ID_EX_Reg.ctl.RegDst == 1) begin
            future_ID_EX_Reg.rs = IF_ID_Reg.ins.R.rs;
            future_ID_EX_Reg.rt = IF_ID_Reg.ins.R.rt;
            future_ID_EX_Reg.rd = IF_ID_Reg.ins.R.rd;
        end
        else if (future_ID_EX_Reg.ctl.MemWrite == 1 || future_ID_EX_Reg.ctl.Branch || future_ID_EX_Reg.ctl.MduStart) begin
            future_ID_EX_Reg.rs = IF_ID_Reg.ins.R.rs;
            future_ID_EX_Reg.rt = IF_ID_Reg.ins.R.rt;
            future_ID_EX_Reg.rd = IF_ID_Reg.ins.R.rd;
        end
        else begin
            future_ID_EX_Reg.rs = IF_ID_Reg.ins.R.rs;
            future_ID_EX_Reg.rt = 0;
            future_ID_EX_Reg.rd = IF_ID_Reg.ins.R.rt;
        end

    // forward
        case (ForwardC)
           3'b000: future_ID_EX_Reg.rs_val = raw_rs;
           3'b001: future_ID_EX_Reg.rs_val = MEM_WB_Reg.rd_val;
           3'b010: future_ID_EX_Reg.rs_val = EX_MEM_Reg.rd_val; 
           3'b100: future_ID_EX_Reg.rs_val = future_EX_MEM_Reg.rd_val; 
       endcase
       case (ForwardD)
           3'b000: future_ID_EX_Reg.rt_val = raw_rt;
           3'b001: future_ID_EX_Reg.rt_val = MEM_WB_Reg.rd_val;
           3'b010: future_ID_EX_Reg.rt_val = EX_MEM_Reg.rd_val; 
           3'b100: future_ID_EX_Reg.rt_val = future_EX_MEM_Reg.rd_val; 
       endcase
       
//     next PC
        if ((Flush | MduFlush) == 1) begin
            NextPC = future_IF_ID_Reg.PC + 4;
        end
        else begin
            if (future_ID_EX_Reg.ctl.Jump == 1) begin
                if (future_ID_EX_Reg.ctl.JumpReg == 1) begin
                    NextPC = future_ID_EX_Reg.rs_val;
                end
                else begin
                    NextPC = PsuedoDrctAddr;
                end
            end
            else begin
                if ( (future_ID_EX_Reg.ctl.Branch & BranchRun) == 1) begin
                    NextPC = BaseAddressing;
                end
                else begin
                    // NextPC = IF_ID_Reg.PC + 4;
                    NextPC = future_IF_ID_Reg.PC + 4;
                end
            end
        end
    end
    

/////////////////////////////////////////////   EX    ///////////////////////////////////////////////////////

   
    wire [31:0] AluRes;
    wire ALUZeroFetch;

    ArithmeticLogicUnit ALU (
        .PCValue(ID_EX_Reg.PC),
        .ReadData0(future_EX_MEM_Reg.rs_val),
        .ReadData1(future_EX_MEM_Reg.ALUoperand),
        .Exp(ID_EX_Reg.ctl.InsException),
        .Ctl(ID_EX_Reg.ALUCtlSig),
        .Res(AluRes),
        .Zero(ALUZeroFetch)
    );
    
    wire [31:0] MduRes;
    
    MultiplicationDivisionUnit MDU(
        .reset(reset) ,
        .clock(clock) ,
        .operand1(future_EX_MEM_Reg.rs_val),
        .operand2(future_EX_MEM_Reg.ALUoperand),
        .operation(ID_EX_Reg.ctl.MduOp),
        .start(ID_EX_Reg.ctl.MduStart & (ID_EX_Reg.ctl.MduOp > MDU_WRITE_LO)),
        .busy(MduBusy),
        .dataRead(MduRes)
    );
    
    always_comb begin
        future_EX_MEM_Reg = ID_EX_Reg;
        future_EX_MEM_Reg.ALUZero = ALUZeroFetch;
    // forward
        case (ForwardA)
            3'b000: future_EX_MEM_Reg.rs_val = ID_EX_Reg.rs_val;
            3'b001: future_EX_MEM_Reg.rs_val = MEM_WB_Reg.rd_val;
            3'b010: future_EX_MEM_Reg.rs_val = EX_MEM_Reg.rd_val; 
        endcase
        case (ForwardB)
            3'b000: future_EX_MEM_Reg.rt_val = ID_EX_Reg.rt_val;
            3'b001: future_EX_MEM_Reg.rt_val = MEM_WB_Reg.rd_val;
            3'b010: future_EX_MEM_Reg.rt_val = EX_MEM_Reg.rd_val; 
        endcase
//    ALU operand
        if (ID_EX_Reg.ctl.ALUSrc == 1) begin
            if (ID_EX_Reg.ctl.Imm2UpReg == 1) begin
                future_EX_MEM_Reg.ALUoperand = {ID_EX_Reg.ins.I.imm,16'b0};
            end
            else begin
                future_EX_MEM_Reg.ALUoperand = ID_EX_Reg.imm_val;
            end
        end
        else if (ID_EX_Reg.ctl.Shift == 1) begin
            if (ID_EX_Reg.ctl.SaImm == 1) begin
                future_EX_MEM_Reg.ALUoperand = ID_EX_Reg.ins.R.shamt;
            end
            else begin
                future_EX_MEM_Reg.ALUoperand = {{27{(1'b0)}}, future_EX_MEM_Reg.rt_val[4:0]};
            end
        end
        else if (ID_EX_Reg.ctl.WriteRA == 1) begin
            future_EX_MEM_Reg.ALUoperand = ID_EX_Reg.PC + 8 - future_EX_MEM_Reg.rs_val;
        end
        else begin
            future_EX_MEM_Reg.ALUoperand = future_EX_MEM_Reg.rt_val;
        end
        // rd_val
        if ((ID_EX_Reg.ctl.MduStart & (ID_EX_Reg.ctl.MduOp < MDU_WRITE_HI)) == 1) begin
            future_EX_MEM_Reg.rd_val = MduRes;
        end
        else begin
            future_EX_MEM_Reg.rd_val = AluRes;
        end
    end

    




/////////////////////////////////////////////   MEM   ///////////////////////////////////////////////////////
//    DM
    wire [31:0] DMRes;
    
   always @ (negedge clock) begin
    //    $display("%h+%h=%h", future_EX_MEM_Reg.rs_val, future_EX_MEM_Reg.rt_val, AluRes);
    //    $display("%h+%h=%h", future_EX_MEM_Reg.rs_val, future_EX_MEM_Reg.ALUoperand, AluRes);
    //    $display("%h %h", ForwardA, ForwardB);
    //    $display("IF_ID_Reg\t\t\t%h", IF_ID_Reg);
    //    $display("future_ID_EX_Reg\t\t%h", future_ID_EX_Reg);
    //    $display("ID_EX_Reg\t\t\t%h", ID_EX_Reg);
    //    $display("ID_EX_Reg,ALUCtlSig%h", ID_EX_Reg.ALUCtlSig);
    //    $display("ID_EX_Reg,ALUZero%h", ID_EX_Reg.ALUZero);
    //    $display("ID_EX_Reg,PC%h", ID_EX_Reg.PC);
    //    $display("ID_EX_Reg,rs%h", ID_EX_Reg.rs_val);
    //    $display("future_EX_MEM_Reg\t\t%h", future_EX_MEM_Reg.rt_val);
    //    $display("EX_MEM_Reg\t\t\t%d", EX_MEM_Reg.rt);
    //    $display("EX_MEM_Reg\t\t\t%h", EX_MEM_Reg.rt_val);
    //    $display("future_MEM_WB_Reg\t\t%h", future_MEM_WB_Reg);
    //    $display("MEM_WB_Reg\t\t\t%h", MEM_WB_Reg);
   end
    DataMemory DM(
        .reset(reset) ,
        .clock(clock) ,
        .PCvalue(EX_MEM_Reg.PC) ,
        .address(EX_MEM_Reg.rd_val) ,
        .writeEnabled(EX_MEM_Reg.ctl.MemWrite) ,
        .writeInput(EX_MEM_Reg.rt_val) ,
        .ctl(EX_MEM_Reg.ctl) ,
        .readResult(DMRes)
    );
    
    always_comb begin
        future_MEM_WB_Reg = EX_MEM_Reg;

    // determine rd_val with ctl
        if (EX_MEM_Reg.ctl.Mem2Reg == 1) begin
            future_MEM_WB_Reg.rd_val = DMRes;
        end
        else begin
            future_MEM_WB_Reg.rd_val = EX_MEM_Reg.rd_val;
        end
    end
/////////////////////////////////////////////   WB    ///////////////////////////////////////////////////////

    always @(posedge clock) begin
        // syscall
        if( (MEM_WB_Reg.ins.R.funct == 6'b001100) && (MEM_WB_Reg.ins.R.opcode == 6'b000000) ) begin
            $finish;
        end
    end
    
endmodule
