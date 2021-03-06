`include "./ctrl_def.v"
`include "./instr_def.v"

module ctrl(
  input clk,
  input [31:0] currentPC,
  input [31:0] instr,
  output reg PCWrite,
  output reg PCWriteCond,
  output reg MemWrite,
  output reg[1:0] MemtoReg,
  output reg IRWrite,
  output reg[1:0] PCSrc,
  output reg[4:0] ALUOp,
  output reg[1:0] ALUSrcA,
  output reg[1:0] ALUSrcB,
  output reg RegWrite,
  output reg[1:0] RegDst,
  output reg[1:0] EXTOp 
  );
 
  wire[5:0] OP;
  wire[5:0] Funct;
  integer state; 
  integer fd;

  initial 
  begin
    state = 0;
    fd = $fopen("results.txt","w");
  end

  assign OP = instr[31:26];
  assign Funct = instr[5:0];  

  
  always @(posedge clk) 
  begin
    $fwrite(fd, "------currentPC: 0x%x   instruction: 0x%x------\n", currentPC, instr);
    $fwrite(fd, "       **state: %d**\n", state);
    $fwrite(fd, "PCSource: %b  ", PCSrc);
    $fwrite(fd, "PCWrite: %b  ", PCWrite);
    $fwrite(fd, "PCWriteCond: %b\n", PCWriteCond);
    $fwrite(fd, "MemWrite: %b  ", MemWrite);
    $fwrite(fd, "IRWrite: %b   ", IRWrite);
    $fwrite(fd, "RegDst: %b   ", RegDst);
    $fwrite(fd, "RegWrite: %b   ", RegWrite);
    $fwrite(fd, "MemtoReg: %b\n", MemtoReg);
    $fwrite(fd, "ALUSrcA: %b   ", ALUSrcA);
    $fwrite(fd, "ALUSrcB: %b   ", ALUSrcB);
    $fwrite(fd, "ALUOp: %b   ", ALUOp);
    $fwrite(fd, "EXTOp: %b\n", EXTOp);
    
    case(state)
      0:begin
        PCSrc = 2'b00;
        PCWriteCond = 0;
        PCWrite = 1;
        MemWrite = 0;
        MemtoReg  = 2'b00;
        RegWrite = 0;
        RegDst = 2'b00;
        IRWrite = 1;
        ALUSrcA = 2'b00;
        ALUSrcB = 2'b01;
        ALUOp = `ALUOP_ADD;
        EXTOp = `EXTOP_ZERO;
        state = 1;
      end
      
      
      1:begin
        PCSrc = 2'b00;
        PCWriteCond = 0;
        PCWrite = 0;
        MemWrite = 0;
        MemtoReg  = 2'b00;
        RegWrite = 0;
        RegDst = 2'b00;
        IRWrite = 0;
        ALUSrcA = 2'b00;
        ALUSrcB = 2'b11;
        ALUOp = `ALUOP_ADD;
        EXTOp = `EXTOP_ZERO;
       
        case(OP)
          `OP_LW, 
          `OP_SW,
          `OP_LB,
          `OP_LBU,
          `OP_LH,
          `OP_LHU,
          `OP_SB,
          `OP_SH: state = 2;
          
          `OP_ADDI,
          `OP_ADDIU,
          `OP_ANDI,
          `OP_ORI,
          `OP_XORI,
          `OP_LUI,
          `OP_SLTI,
          `OP_SLTIU: state = 5;
            
          `OP_BEQ,
          `OP_BNE,
          `OP_BLEZ,
          `OP_BGTZ,
          `OP_BLTZ,
          `OP_BGEZ: state = 7;
          
          `OP_RTYPE:
          begin
            if(Funct == `FUNCT_JALR)
              state = 6;
            else 
              state = 5;
          end
          
          `OP_J: state = 8;
          `OP_JAL: state = 6;
         
        endcase
      end
      
      
      2:begin
        PCSrc = 2'b00;
        PCWriteCond = 0;
        PCWrite = 0;
        MemWrite = 0;
        MemtoReg  = 2'b00;
        RegWrite = 0;
        RegDst = 2'b00;
        IRWrite = 0;
        ALUSrcA = 2'b01;
        ALUSrcB = 2'b10;
        ALUOp = `ALUOP_ADD;
        EXTOp = `EXTOP_ZERO;        
        state = 3;
      end
             
             
      3:begin     
        PCSrc = 2'b00;
        PCWriteCond = 0;
        PCWrite = 0;
        MemtoReg  = 2'b00;
        RegWrite = 0;        
        RegDst = 2'b00;
        IRWrite = 0;
        ALUSrcA = 2'b00;
        ALUSrcB = 2'b10;
        RegDst = 2'b00;
        ALUOp = `ALUOP_ADD;
        EXTOp = `EXTOP_ZERO;
        state = 0;
        case(OP)
          `OP_SW,
          `OP_SB,
          `OP_SH:
          begin
            MemWrite = 1;
            state = 0;
          end
          `OP_LW,
          `OP_LB,
          `OP_LBU,
          `OP_LH,
          `OP_LHU:
          begin
            MemWrite = 0;
            state = 4;
          end  
        endcase    
      end
      
        
      4:begin   //`OP_LW, `OP_LB, `OP_LBU, `OP_LH, `OP_LHU
        PCSrc = 2'b00;
        PCWriteCond = 0;
        PCWrite = 0;
        MemWrite = 0;
        MemtoReg  = 2'b01;
        RegWrite = 1;
        RegDst = 2'b00;
        IRWrite = 0;
        ALUSrcA = 2'b00;
        ALUSrcB = 2'b10;
        ALUOp = `ALUOP_ADD;
        EXTOp = `EXTOP_ZERO;
        state = 0;
      end
        
        
      5:begin
        PCSrc = 2'b00;
        PCWriteCond = 0;
        PCWrite = 0;
        MemWrite = 0;
        MemtoReg  = 2'b00;
        RegWrite = 0;
        RegDst = 2'b00;
        IRWrite = 0;
        EXTOp = `EXTOP_ZERO;
        case(OP)  
          `OP_RTYPE:
          begin
            ALUSrcB = 2'b00;
            case(Funct)
              `FUNCT_ADD,
              `FUNCT_ADDU: 
              begin
                ALUSrcA = 2'b01;
                ALUOp = `ALUOP_ADD;
                state = 6;
              end
              `FUNCT_SUB,
              `FUNCT_SUBU: 
              begin
                ALUSrcA = 2'b01;
                ALUOp = `ALUOP_SUB;
                state = 6;
              end
              `FUNCT_AND: 
              begin
                ALUSrcA = 2'b01;
                ALUOp = `ALUOP_AND;
                state = 6;
              end
              `FUNCT_OR: 
              begin
                ALUSrcA = 2'b01;
                ALUOp = `ALUOP_OR;
                state = 6;
              end
              `FUNCT_XOR: 
              begin
                ALUSrcA = 2'b01; 
                ALUOp = `ALUOP_XOR;
                state = 6;
              end
              `FUNCT_NOR: 
              begin
                ALUSrcA = 2'b01;
                ALUOp = `ALUOP_NOR;
                state = 6;
              end
              `FUNCT_SLL:
              begin
                ALUSrcA = 2'b10;
                ALUOp = `ALUOP_SLL;
                state = 6;
              end
              `FUNCT_SLLV: 
              begin
                ALUSrcA = 2'b01;
                ALUOp = `ALUOP_SLL;
                state = 6;
              end
              `FUNCT_SRL:
              begin
                ALUSrcA = 2'b10;
                ALUOp = `ALUOP_SRL;
                state = 6;
              end
              `FUNCT_SRLV:
              begin
                ALUSrcA = 2'b01;
                ALUOp = `ALUOP_SRL;
                state = 6;
              end
              `FUNCT_SRA:
              begin
                ALUSrcA = 2'b10;
                ALUOp = `ALUOP_SRA;
                state = 6;
              end
              `FUNCT_SRAV: 
              begin
                ALUSrcA = 2'b01;
                ALUOp = `ALUOP_SRA;
                state = 6;
              end
              `FUNCT_SLT: 
              begin
                ALUSrcA = 2'b01;
                ALUOp = `ALUOP_SLT; 
                state = 6;
              end
              `FUNCT_SLTU: 
              begin
                ALUSrcA = 2'b01;
                ALUOp = `ALUOP_SLTU; 
                state = 6;
              end
              `FUNCT_JALR,
              `FUNCT_JR:
              begin
                ALUSrcA = 2'b01;
                ALUOp = `ALUOP_ADD;
                state = 8;
              end              
            endcase
          end
          
          `OP_ADDI:
          begin
            ALUSrcA = 2'b01;
            ALUSrcB = 2'b10;
            ALUOp = `ALUOP_ADD;
            state = 6;
          end
          `OP_ADDIU:
          begin
            EXTOp = `EXTOP_SIGN;
            ALUSrcA = 2'b01;
            ALUSrcB = 2'b10;
            ALUOp = `ALUOP_ADD;
            state = 6;
          end
          `OP_ANDI:
          begin
            ALUSrcA = 2'b01;
            ALUSrcB = 2'b10;
            ALUOp = `ALUOP_AND;
            state = 6;
          end
          `OP_ORI:
          begin
            ALUSrcA = 2'b01;
            ALUSrcB = 2'b10;
            ALUOp = `ALUOP_OR;
            state = 6;
          end
          `OP_XORI:
          begin
            ALUSrcA = 2'b01;
            ALUSrcB = 2'b10;
            ALUOp = `ALUOP_XOR;
            state = 6;
          end
          `OP_LUI:
          begin 
            ALUSrcA = 2'b01;
            ALUSrcB = 2'b10;
            ALUOp = `ALUOP_LUI;
            state = 6;
          end
          `OP_SLTI:
          begin
            ALUSrcA = 2'b01;
            ALUSrcB = 2'b10;
            ALUOp = `ALUOP_SLT; 
            state = 6;
          end
          `OP_SLTIU: 
          begin
            ALUSrcA = 2'b01;
            ALUSrcB = 2'b10;
            ALUOp = `ALUOP_SLTU;
            state = 6;
          end
        endcase
      end
        
      6:begin
        PCSrc = 2'b00;
        PCWriteCond = 0;
        PCWrite = 0;
        MemWrite = 0;
        RegWrite = 1;
        IRWrite = 0;
        ALUSrcA = 2'b00;
        ALUSrcB = 2'b10;
        ALUOp = `ALUOP_ADD;
        EXTOp = `EXTOP_ZERO;
        case(OP)
          `OP_RTYPE: 
          begin
            if(Funct == `FUNCT_JALR)
              begin
                RegDst = 2'b01; 
                MemtoReg = 2'b10;
                state = 5;
              end
            else
              begin  
                RegDst = 2'b01;
                MemtoReg = 2'b00;
                state = 0;
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
            RegDst = 2'b00;
            MemtoReg = 2'b00;
            state = 0;
          end
          `OP_JAL:
          begin     
            RegDst = 2'b10; 
            MemtoReg = 2'b10;
            state = 8;
          end
        endcase
      end
                 
      7:begin
        PCSrc = 2'b01;
        PCWriteCond = 1;
        PCWrite = 0;
        MemWrite = 0;
        MemtoReg  = 2'b00;
        RegWrite = 0;
        RegDst = 2'b00;
        IRWrite = 0;
        ALUSrcA = 2'b01;
        ALUSrcB = 2'b00;
        EXTOp = `EXTOP_ZERO;
        case(OP)
          `OP_BEQ: ALUOp = `ALUOP_SUB;
          `OP_BNE: ALUOp = `ALUOP_BNE;
          `OP_BLEZ: ALUOp = `ALUOP_BLEZ;
          `OP_BGTZ: ALUOp = `ALUOP_BGTZ;
          `OP_BLTZ,
          `OP_BGEZ: 
          begin
            if(instr[20:16] == 5'b0) //`OP_BLTZ
              ALUOp = `ALUOP_BLTZ;
            else                     //`OP_BGEZ
              ALUOp = `ALUOP_BGEZ;  
          end
        endcase
        state = 0;      
      end
        
      8:begin
        PCWriteCond = 0;
        PCWrite = 1;
        MemWrite = 0;
        MemtoReg  = 2'b00;
        RegWrite = 0;
        RegDst = 2'b00;
        IRWrite = 0;
        ALUSrcA = 2'b00;
        ALUSrcB = 2'b10;
        ALUOp = `ALUOP_ADD;
        EXTOp = `EXTOP_ZERO;
        case(OP)
          `OP_J,
          `OP_JAL: PCSrc = 2'b10;
          `OP_RTYPE:PCSrc = 2'b01; 
        endcase 
        state = 0;
      end  
         
    endcase
  end
  
     
endmodule
      
  