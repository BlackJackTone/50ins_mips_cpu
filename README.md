# 50条指令流水线CPU设计

## 控制信号

所有使用的控制信号如下
```verilog
typedef struct packed{
    logic RegDst;
    logic Jump;
    logic Branch;
    logic MemRead;
    logic Mem2Reg;
    logic [3:0] ALUOp;
    logic Imm2UpReg;
    logic JumpReg;
    logic WriteRA;
    logic MemWrite;
    logic ALUSrc;
    logic RegWrite;
    logic ImmSign;
    logic SaImm;
    logic Shift;
    mdu_operation_t MduOp;
    logic MduStart;
    logic [1:0] MemGrain;
    logic MemSign;
    logic InsException;
}Controller;
```

## 旁路

除EX需要从旁路来的数据外，由于在ID处理分支和跳转，需额外设计复杂程度相似的另外一条旁路，处理EX级中结果直接通过wire进入ID运算的情况

## 阻塞

由于分支和跳转需要ID判定早于其他EX才开始计算的指令，lw除了面对其他有冒险的指令外，需要对于分支和跳转多加MEM级的旁路，或者多阻塞一周期，本次实现选择多加一周期阻塞
对于MDU带来的阻塞，采取检测EX级是否使用MDU并与busy信号做与，一旦满足条件就阻塞前两级，并把之EX_MEM寄存器清空

## 异常

对于非对齐内存的读写进行异常处理，`LH,LHU,SH`的异常逻辑如下，`LW,SW`与其类似

```c++
vAddr <- sign_extend(offset) + GPR[base]
if vAddr[0] != 0 then
    SignalException(AddressError)
endif
```
