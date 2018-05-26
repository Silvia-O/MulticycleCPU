`include "./ctrl_def.v"
`include "./instr_def.v"

module ctrl(
  input clk,
  input rst,
  input [31:0] currentPC,
  input [31:0] instr,
  output [1:0] IorD_o,
  output PCWrite_o,
  output PCWriteCond_o,
  output MemWrite_o,
  output [1:0] MemtoReg_o,
  output IRWrite_o,
  output [1:0] PCSrc_o,
  output [4:0] ALUOp_o,
  output [1:0] ALUSrcA_o,
  output [1:0] ALUSrcB_o,
  output RegWrite_o,
  output [1:0] RegDst_o,
  output [1:0] EXTOp_o,
  output [3:0] state_o
  );
 
  wire[5:0] OP;
  wire[5:0] Funct;
  integer fd;
  reg PCWrite, PCWriteCond, MemWrite, IRWrite, RegWrite;
  reg[1:0] IorD, MemtoReg, PCSrc, ALUSrcA, ALUSrcB, RegDst, EXTOp;
  reg[3:0] state, next_state;
  reg[4:0] ALUOp;

  assign OP = instr[31:26];
  assign Funct = instr[5:0];  
  
  always@(posedge clk or posedge rst)
  begin
    if(rst)
      state <= 4'b0000;
    else
      state <= next_state;
  end
    
  always @(*) 
  begin   
    case(state)
      4'b0000:begin
        IorD <= 2'b00;
        PCSrc <= 2'b00;
        PCWriteCond <= 0;
        PCWrite <= 1;
        MemWrite <= 0;
        MemtoReg  <= 2'b00;
        RegWrite <= 0;
        RegDst <= 2'b00;
        IRWrite <= 1;
        ALUSrcA <= 2'b00;
        ALUSrcB <= 2'b01;
        ALUOp <= `ALUOP_ADD;
        EXTOp <= `EXTOP_ZERO;
        next_state = 4'b0001;
      end
      
      
      4'b0001:begin
        IorD <= 2'b01;
        PCSrc <= 2'b00;
        PCWriteCond <= 0;
        PCWrite <= 0;
        MemWrite <= 0;
        MemtoReg <= 2'b00;
        RegWrite <= 0;
        RegDst <= 2'b00;
        IRWrite <= 0;
        ALUSrcA <= 2'b00;
        ALUSrcB <= 2'b11;
        ALUOp <= `ALUOP_ADD;
        EXTOp <= `EXTOP_ZERO;
       
        case(OP)
          `OP_LW, 
          `OP_SW,
          `OP_LB,
          `OP_LBU,
          `OP_LH,
          `OP_LHU,
          `OP_SB,
          `OP_SH: next_state = 4'b0010;
          
          `OP_ADDI,
          `OP_ADDIU,
          `OP_ANDI,
          `OP_ORI,
          `OP_XORI,
          `OP_LUI,
          `OP_SLTI,
          `OP_SLTIU: next_state = 4'b0101;
            
          `OP_BEQ,
          `OP_BNE,
          `OP_BLEZ,
          `OP_BGTZ,
          `OP_BLTZ,
          `OP_BGEZ: next_state = 4'b0111;
          
          `OP_RTYPE:
          begin
            if(Funct == `FUNCT_JALR)
              next_state = 4'b0110;
            else 
              next_state = 4'b0101;
          end
          
          `OP_J: next_state = 4'b1000;
          `OP_JAL: next_state = 4'b0110;
         
        endcase
      end
      
      
      4'b0010:begin
        IorD <= 2'b01;
        PCSrc <= 2'b00;
        PCWriteCond <= 0;
        PCWrite <= 0;
        MemWrite <= 0;
        MemtoReg <= 2'b00;
        RegWrite <= 0;
        RegDst <= 2'b00;
        IRWrite <= 0;
        ALUSrcA <= 2'b01;
        ALUSrcB <= 2'b10;
        ALUOp <= `ALUOP_ADD;
        EXTOp <= `EXTOP_ZERO;        
        next_state = 4'b0011;
      end
             
             
      4'b0011:begin    
        IorD <= 2'b01; 
        PCSrc <= 2'b00;
        PCWriteCond <= 0;
        PCWrite <= 0;
        MemtoReg <= 2'b00;
        RegWrite <= 0;        
        RegDst <= 2'b00;
        IRWrite <= 0;
        ALUSrcA <= 2'b00;
        ALUSrcB <= 2'b10;
        RegDst <= 2'b00;
        ALUOp <= `ALUOP_ADD;
        EXTOp <= `EXTOP_ZERO;
        next_state = 4'b0000;
        case(OP)
          `OP_SW,
          `OP_SB,
          `OP_SH:
          begin
            MemWrite <= 1;
            next_state = 4'b0000;
          end
          `OP_LW,
          `OP_LB,
          `OP_LBU,
          `OP_LH,
          `OP_LHU:
          begin
            MemWrite <= 0;
            next_state = 4'b0100;
          end  
        endcase    
      end
      
        
      4'b0100:begin   //`OP_LW, `OP_LB, `OP_LBU, `OP_LH, `OP_LHU
        IorD <= 2'b01;
        PCSrc <= 2'b00;
        PCWriteCond <= 0;
        PCWrite <= 0;
        MemWrite <= 0;
        MemtoReg <= 2'b01;
        RegWrite <= 1;
        RegDst <= 2'b00;
        IRWrite <= 0;
        ALUSrcA <= 2'b00;
        ALUSrcB <= 2'b10;
        ALUOp <= `ALUOP_ADD;
        EXTOp <= `EXTOP_ZERO;
        next_state = 4'b0000;
      end
        
        
      4'b0101:begin
        IorD <= 2'b01;
        PCSrc <= 2'b00;
        PCWriteCond <= 0;
        PCWrite <= 0;
        MemWrite <= 0;
        MemtoReg <= 2'b00;
        RegWrite <= 0;
        RegDst <= 2'b00;
        IRWrite <= 0;
        EXTOp <= `EXTOP_ZERO;
        case(OP)  
          `OP_RTYPE:
          begin
            ALUSrcB <= 2'b00;
            case(Funct)
              `FUNCT_ADD,
              `FUNCT_ADDU: 
              begin
                ALUSrcA <= 2'b01;
                ALUOp <= `ALUOP_ADD;
                next_state = 4'b0110;
              end
              `FUNCT_SUB,
              `FUNCT_SUBU: 
              begin
                ALUSrcA <= 2'b01;
                ALUOp <= `ALUOP_SUB;
                next_state = 4'b0110;
              end
              `FUNCT_AND: 
              begin
                ALUSrcA <= 2'b01;
                ALUOp <= `ALUOP_AND;
                next_state = 4'b0110;
              end
              `FUNCT_OR: 
              begin
                ALUSrcA <= 2'b01;
                ALUOp <= `ALUOP_OR;
                next_state = 4'b0110;
              end
              `FUNCT_XOR: 
              begin
                ALUSrcA <= 2'b01; 
                ALUOp <= `ALUOP_XOR;
                next_state = 4'b0110;
              end
              `FUNCT_NOR: 
              begin
                ALUSrcA <= 2'b01;
                ALUOp <= `ALUOP_NOR;
                next_state = 4'b0110;
              end
              `FUNCT_SLL:
              begin
                ALUSrcA <= 2'b10;
                ALUOp <= `ALUOP_SLL;
                next_state = 4'b0110;
              end
              `FUNCT_SLLV: 
              begin
                ALUSrcA <= 2'b01;
                ALUOp <= `ALUOP_SLL;
                next_state = 4'b0110;
              end
              `FUNCT_SRL:
              begin
                ALUSrcA <= 2'b10;
                ALUOp <= `ALUOP_SRL;
                next_state = 4'b0110;
              end
              `FUNCT_SRLV:
              begin
                ALUSrcA <= 2'b01;
                ALUOp <= `ALUOP_SRL;
                next_state = 4'b0110;
              end
              `FUNCT_SRA:
              begin
                ALUSrcA <= 2'b10;
                ALUOp <= `ALUOP_SRA;
                next_state = 4'b0110;
              end
              `FUNCT_SRAV: 
              begin
                ALUSrcA <= 2'b01;
                ALUOp <= `ALUOP_SRA;
                next_state = 4'b0110;
              end
              `FUNCT_SLT: 
              begin
                ALUSrcA <= 2'b01;
                ALUOp <= `ALUOP_SLT; 
                next_state = 4'b0110;
              end
              `FUNCT_SLTU: 
              begin
                ALUSrcA <= 2'b01;
                ALUOp <= `ALUOP_SLTU; 
                next_state = 4'b0110;
              end
              `FUNCT_JALR,
              `FUNCT_JR:
              begin
                ALUSrcA <= 2'b01;
                ALUOp <= `ALUOP_ADD;
                next_state = 4'b1000;
              end              
            endcase
          end
          
          `OP_ADDI:
          begin
            ALUSrcA <= 2'b01;
            ALUSrcB <= 2'b10;
            ALUOp <= `ALUOP_ADD;
            next_state = 4'b0110;
          end
          `OP_ADDIU:
          begin
            EXTOp <= `EXTOP_SIGN;
            ALUSrcA <= 2'b01;
            ALUSrcB <= 2'b10;
            ALUOp <= `ALUOP_ADD;
            next_state = 4'b0110;
          end
          `OP_ANDI:
          begin
            ALUSrcA <= 2'b01;
            ALUSrcB <= 2'b10;
            ALUOp <= `ALUOP_AND;
            next_state = 4'b0110;
          end
          `OP_ORI:
          begin
            ALUSrcA <= 2'b01;
            ALUSrcB <= 2'b10;
            ALUOp <= `ALUOP_OR;
            next_state = 4'b0110;
          end
          `OP_XORI:
          begin
            ALUSrcA <= 2'b01;
            ALUSrcB <= 2'b10;
            ALUOp <= `ALUOP_XOR;
            next_state = 4'b0110;
          end
          `OP_LUI:
          begin 
            ALUSrcA <= 2'b01;
            ALUSrcB <= 2'b10;
            ALUOp <= `ALUOP_LUI;
            next_state = 4'b0110;
          end
          `OP_SLTI:
          begin
            ALUSrcA <= 2'b01;
            ALUSrcB <= 2'b10;
            ALUOp <= `ALUOP_SLT; 
            next_state = 4'b0110;
          end
          `OP_SLTIU: 
          begin
            ALUSrcA <= 2'b01;
            ALUSrcB <= 2'b10;
            ALUOp <= `ALUOP_SLTU;
            next_state = 4'b0110;
          end
        endcase
      end
        
      4'b0110:begin
        IorD <= 2'b01;
        PCSrc <= 2'b00;
        PCWriteCond <= 0;
        PCWrite <= 0;
        MemWrite <= 0;
        RegWrite <= 1;
        IRWrite <= 0;
        ALUSrcA <= 2'b00;
        ALUSrcB <= 2'b10;
        ALUOp <= `ALUOP_ADD;
        EXTOp <= `EXTOP_ZERO;
        case(OP)
          `OP_RTYPE: 
          begin
            if(Funct == `FUNCT_JALR)
              begin
                RegDst <= 2'b01; 
                MemtoReg <= 2'b10;
                next_state = 4'b0101;
              end
            else
              begin  
                RegDst <= 2'b01;
                MemtoReg <= 2'b00;
                next_state = 4'b0000;
              end
          end
          `OP_ADDI,
          `OP_ADDIU,
          `OP_ANDI,
          `OP_ORI,
          `OP_XORI,
          `OP_LUI,
          `OP_SLTI,
          `OP_SLTIU: 
          begin
            RegDst <= 2'b00;
            MemtoReg <= 2'b00;
            next_state = 4'b0000;
          end
          `OP_JAL:
          begin     
            RegDst <= 2'b10; 
            MemtoReg <= 2'b10;
            next_state = 4'b1000;
          end
        endcase
      end
                 
      4'b0111:begin
        IorD <= 2'b01;
        PCSrc <= 2'b01;
        PCWriteCond <= 1;
        PCWrite <= 0;
        MemWrite <= 0;
        MemtoReg <= 2'b00;
        RegWrite <= 0;
        RegDst <= 2'b00;
        IRWrite <= 0;
        ALUSrcA <= 2'b01;
        ALUSrcB <= 2'b00;
        EXTOp <= `EXTOP_ZERO;
        case(OP)
          `OP_BEQ: ALUOp <= `ALUOP_SUB;
          `OP_BNE: ALUOp <= `ALUOP_BNE;
          `OP_BLEZ: ALUOp <= `ALUOP_BLEZ;
          `OP_BGTZ: ALUOp <= `ALUOP_BGTZ;
          `OP_BLTZ,
          `OP_BGEZ: 
          begin
            if(instr[20:16] == 5'b0) //`OP_BLTZ
              ALUOp <= `ALUOP_BLTZ;
            else                     //`OP_BGEZ
              ALUOp <= `ALUOP_BGEZ;  
          end
        endcase
        next_state = 4'b0000;      
      end
        
      4'b1000:begin
        PCWriteCond <= 0;
        PCWrite <= 1;
        MemWrite <= 0;
        MemtoReg <= 2'b00;
        RegWrite <= 0;
        RegDst <= 2'b00;
        IRWrite <= 0;
        ALUSrcA <= 2'b00;
        ALUSrcB <= 2'b10;
        ALUOp <= `ALUOP_ADD;
        EXTOp <= `EXTOP_ZERO;
        case(OP)
          `OP_J,
          `OP_JAL: PCSrc <= 2'b10;
          `OP_RTYPE:PCSrc <= 2'b01; 
        endcase 
        next_state = 4'b0000;
      end  
         
    endcase
  end
  
  assign IorD_o = IorD;
  assign PCWrite_o = PCWrite;
  assign PCWriteCond_o = PCWriteCond;
  assign MemWrite_o = MemWrite;
  assign MemtoReg_o = MemtoReg;
  assign IRWrite_o = IRWrite;
  assign PCSrc_o = PCSrc;
  assign ALUOp_o = ALUOp;
  assign ALUSrcA_o = ALUSrcA;
  assign ALUSrcB_o = ALUSrcB;
  assign RegWrite_o = RegWrite;
  assign RegDst_o = RegDst;
  assign EXTOp_o = EXTOp;
  assign state_o = state;
     
endmodule
      
  