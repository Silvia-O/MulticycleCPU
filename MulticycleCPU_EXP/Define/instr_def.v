`define OP_RTYPE 6'b000000
`define OP_J 6'b000010
`define OP_JAL 6'b000011
`define OP_BEQ 6'b000100
`define OP_BNE 6'b000101
`define OP_BLTZ 6'b000001
`define OP_BGEZ 6'b000001
`define OP_BLEZ 6'b000110
`define OP_BGTZ 6'b000111
`define OP_ADDI 6'b001000
`define OP_ADDIU 6'b001001
`define OP_SLTI 6'b001010
`define OP_SLTIU 6'b001011
`define OP_ANDI 6'b001100
`define OP_ORI 6'b001101
`define OP_XORI 6'b001110
`define OP_LUI 6'b001111
`define OP_LB 6'b100000
`define OP_LBU 6'b100100
`define OP_LH 6'b100001
`define OP_LHU 6'b100101
`define OP_LW 6'b100011
`define OP_SW 6'b101011
`define OP_SB 6'b101000
`define OP_SH 6'b101001
`define FUNCT_ADD 6'b100000
`define FUNCT_ADDU 6'b100001
`define FUNCT_SUB 6'b100010
`define FUNCT_SUBU 6'b100011
`define FUNCT_AND 6'b100100
`define FUNCT_OR 6'b100101
`define FUNCT_XOR 6'b100110
`define FUNCT_NOR 6'b100111
`define FUNCT_SLT 6'b101010
`define FUNCT_SLTU 6'b101011
`define FUNCT_SLL 6'b000000
`define FUNCT_SRL 6'b000010
`define FUNCT_SRA 6'b000011
`define FUNCT_SLLV 6'b000100
`define FUNCT_SRLV 6'b000110
`define FUNCT_SRAV 6'b000111
`define FUNCT_JR 6'b001000
`define FUNCT_JALR 6'b001001
