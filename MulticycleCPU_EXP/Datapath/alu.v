`include "./ctrl_def.v"

module alu(
  input [31:0] A,    //1st operand
  input [31:0] B,    //2nd operand
  input [4:0] ALUOp,
  output zero,
  output [31:0] result 
  );
  
  reg Zero;
  reg[31:0] Result;
  integer dif;
  
  always@(*)
  begin
    case(ALUOp)
      `ALUOP_ADD:
        Result <= A + B;
      `ALUOP_SUB:
        Result <= A - B;
      `ALUOP_SLL:
        Result <= B << A[4:0];
      `ALUOP_SRL:
        Result <= B >> A[4:0];
      `ALUOP_SRA:
        Result <= B >> A[4:0] | ( {32{B[31]}} << (6'b100000-{1'b0, A[4:0]}));
      `ALUOP_AND:
        Result <= A & B;
      `ALUOP_OR:
        Result <= A | B;
      `ALUOP_XOR:
        Result <= A ^ B;
      `ALUOP_NOR:
        Result <= ~ (A | B);
      `ALUOP_SLT:
      begin
        dif = A - B;
        Result <= ((A[31] && !B[31]) || ((!(A[31] ^ B[31])) && dif[31]))? 32'h1 : 32'h0;
      end
      `ALUOP_SLTU:
        Result <= (A < B)? 32'b1 : 32'b0;
      `ALUOP_LUI:
        Result <= {B[15:0],16'b0};
      `ALUOP_BNE:
        Result <= (A == B)? 32'b1 : 32'b0;
      `ALUOP_BLEZ:
        Result <= (!A[31] && A!=32'b0)? 32'b1: 32'b0;
      `ALUOP_BGTZ:
        Result <= (!A[31] && A!=32'b0)? 32'b0: 32'b1;
      `ALUOP_BLTZ:
        Result <= (A[31])? 32'b0 : 32'b1;
      `ALUOP_BGEZ:
        Result <= (!A[31])? 32'b0 : 32'b1;      
      default: Result <= 32'b0;
    endcase
    
    //branch condition
    if(Result == 32'b0)
      Zero <= 1'b1;
    else
      Zero <= 1'b0;
  end
  
  assign zero = Zero;
  assign result = Result;
  
endmodule
