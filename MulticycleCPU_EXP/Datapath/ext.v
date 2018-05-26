`include "./ctrl_def.v"

module ext(
  input [15:0] Imm16,  //data to extend
  input [1:0] EXTOp,  
  output [31:0] Imm32  //extended result
  );
  
  reg[31:0] Imm;
  
  always@(*)
  begin
    case(EXTOp)
      `EXTOP_ZERO:   //zero extend
        Imm <= {16'b0,Imm16};
      `EXTOP_SIGN:   //sign extend
        Imm <= {{16{Imm16[15]}},Imm16};
      `EXTOP_HIGH:   //extend higher
        Imm <= {Imm16,16'b0};
      default:
        Imm <= {16'b0,Imm16};
    endcase
  end
  
  assign Imm32 = Imm;
  
endmodule
        

