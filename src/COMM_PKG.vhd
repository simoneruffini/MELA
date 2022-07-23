--------------------------------------------------------------------------------
-- Engineer: Simone Ruffini  [simone.ruffini@studenti.polito.it]
-- Engineer: Matteo Bonora    [matteo.bonora@studenti.polito.it]
-- Engineer: Lorenzo Latella  [s292653@studenti.polito,it]
--
-- Create Date:     Wed May  4 09:47:35 PM CEST 2022
-- Design Name:     Common Package
-- Module Name:     COMM_PKG.vhd  
-- Project Name:    DLX
-- Description:     Common package
--
-- Revision:
-- Revision 00 - Simone Ruffini
--  first implementation
-- Additional Comments:
--
--------------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

package COMM_PKG is
  type controlword_t is array (natural range <>) of STD_LOGIC;

  -- Position of the control word signals. Used internally to map the internal
  -- std_logic_vector to the output signals.
  -- Decode
  constant A_RE : integer := 0;  -- enables the read port 1 of the Register File
  constant B_RE : integer := 1;  -- enables the read port 2 of the Register File
  constant J_TYPE : integer := 2;  -- Selects the right immediate value for the instruction type
  constant REG_WE : integer := 3;  -- enables register file write
  -- Execute
  constant IMM_SEL  : integer := 4;  -- selects the immediate register as the second input for the ALU
  constant PC_SEL   : integer := 5;  -- selects the program counter as the first input for the ALU
  constant ALU_OP1 : integer := 6;  -- alu control bit
  constant ALU_OP2 : integer := 7;  -- alu control bit
  constant ALU_OP3 : integer := 8;  -- alu control bit
  constant ALU_OP4 : integer := 9;  -- alu control bit
  -- Memory
  constant DM_RE  : integer := 10;  -- enables the read-out of the memory
  constant DM_WE  : integer := 11; -- enables the write-in of the memory

  -- Write-back
  constant WB_MUX : integer := 12; -- Selects the output of the datapath
  
  constant CW_SIZE  : integer := 13; -- Length of the control word == Number of control signals

-- Control unit input size
  constant OP_CODE_SIZE : integer :=  6;  -- OPCODE field size
  constant FUNC_SIZE    : integer :=  11; -- FUNC field size



  --    instruction    |        meaning          |           mapping            | additional notes
  -- ADD    RA RB RC   | R[RC] = R[RA] + R[RB]   | RC->RD , RA->RS1, RB->RS2    |
  -- SUB    RA RB RC   | R[RC] = R[RA] - R[RB]   | RC->RD , RA->RS1, RB->RS2    |
  -- AND    RA RB RC   | R[RC] = R[RA] AND R[RB] | RC->RD , RA->RS1, RB->RS2    |
  -- OR     RA RB RC   | R[RC] = R[RA] OR R[RB]  | RC->RD , RA->RS1, RB->RS2    |
  -- ADDI1  RA RB INP1 | R[RB] = R[RA] + INP1    | RB->RD , RA->RS2, INP1->INP1 |
  -- SUBI1  RA RB INP1 | R[RB] = R[RA] - INP1    | RB->RD , RA->RS2, INP1->INP1 |
  -- ANDI1  RA RB INP1 | R[RB] = R[RA] AND INP1  | RB->RD , RA->RS2, INP1->INP1 |
  -- ORI1   RA RB INP1 | R[RB] = R[RA] OR INP1   | RB->RD , RA->RS2, INP1->INP1 |
  -- ADDI2  RA RB INP2 | R[RB] = R[RA] + INP2    | RB->RD , RA->RS1, INP2->INP2 |
  -- SUBI2  RA RB INP2 | R[RB] = R[RA] - INP2    | RB->RD , RA->RS1, INP2->INP2 |
  -- ANDI2  RA RB INP2 | R[RB] = R[RA] AND INP2  | RB->RD , RA->RS1, INP2->INP2 |
  -- ORI2   RA RB INP2 | R[RB] = R[RA] OR INP2   | RB->RD , RA->RS1, INP2->INP2 |
  -- MOV    RA RB  0   | R[RB] = R[RA]           | RB->RD , RA->RS1, INP2->INP2 | RD <= RS1+INP2 (INP2=0)
  -- S_REG1 // RB INP1 | R[RB] = INP1            | RB->RD , RA->RS2, INP1->INP1 | RD <= INP1+RS2 (? RS2=0)
  -- S_REG2 // RB INP1 | R[RB] = INP2            | RB->RD , RA->RS1, INP2->INP2 | RD <= RS1+INP2 (? RS1=0)
  -- S_MEM2 RA RB INP1 | MEM[R[RA]+INP2] = R[RB] | RB->RS2, RA->RS1, INP2->INP2 | MEM[A+INP2] <= RS2 
  -- L_MEM1 RA RB INP1 | R[RB] = MEM[R[RA]+INP1] | RB->RD , RA->RS2, INP1->INP1 | RD <= MEM[INP1+RS2]
  -- L_MEM2 RA RB INP1 | R[RB] = MEM[R[RA]+INP2] | RB->RD , RA->RS1, INP2->INP2 | RD <= MEM[RS1+INP2]

  -- opcodes in integer form
  -- the encoding of the opcodes can be changed to optimize the resulting design
  -- 
  --       OPCODE NAME     | OPCODE VALUE | 
  constant RTYPE_OPCODE_i  : integer := 00; 
  constant ADDI1_OPCODE_i  : integer := 01; 
  constant SUBI1_OPCODE_i  : integer := 02; 
  constant ANDI1_OPCODE_i  : integer := 03; 
  constant ORI1_OPCODE_i   : integer := 04; 
  constant ADDI2_OPCODE_i  : integer := 05; 
  constant SUBI2_OPCODE_i  : integer := 06; 
  constant ANDI2_OPCODE_i  : integer := 07; 
  constant ORI2_OPCODE_i   : integer := 08; 
  constant MOV_OPCODE_i    : integer := 09; 
  constant S_REG1_OPCODE_i : integer := 10; 
  constant S_REG2_OPCODE_i : integer := 11; 
  constant S_MEM2_OPCODE_i : integer := 12; 
  constant L_MEM1_OPCODE_i : integer := 13; 
  constant L_MEM2_OPCODE_i : integer := 14; 

  -- FUNC for R-Type instructions in integer form
  -- the encoding of functions can be changed to optimize the resulting design
  constant ADD_FUNC_i : integer := 00; 
  constant SUB_FUNC_i : integer := 01; 
  constant AND_FUNC_i : integer := 02; 
  constant OR_FUNC_i  : integer := 03; 

  -- ALU control word (ALU1,ALU2 control signals)
  constant ALU_CW_SIZE  : integer := 2;
  constant ALU_ADD_CW   : std_logic_vector(ALU_CW_SIZE-1 downto 0) := "00"; -- ALU1=0 ALU2=0
  constant ALU_SUB_CW   : std_logic_vector(ALU_CW_SIZE-1 downto 0) := "01"; -- ALU1=0 ALU2=1
  constant ALU_AND_CW   : std_logic_vector(ALU_CW_SIZE-1 downto 0) := "10"; -- ALU1=1 ALU2=0
  constant ALU_OR_CW    : std_logic_vector(ALU_CW_SIZE-1 downto 0) := "11"; -- ALU1=1 ALU2=1

  -- R-Type instruction control words
  constant RTYPE_ADD_CW : std_logic_vector(CW_SIZE - 1 downto 0) := (PEN1=>'1', PRF1=>'1', PRF2=>'1', PEN2=>'1', PS1=>'1', PS2=>'0', PALU1=>ALU_ADD_CW(1), PALU2=>ALU_ADD_CW(0), PEN3=>'1', PRM=>'0', PWM=>'0', PS3=>'1', PWF1=>'1');
  constant RTYPE_SUB_CW : std_logic_vector(CW_SIZE - 1 downto 0) := (PEN1=>'1', PRF1=>'1', PRF2=>'1', PEN2=>'1', PS1=>'1', PS2=>'0', PALU1=>ALU_SUB_CW(1), PALU2=>ALU_SUB_CW(0), PEN3=>'1', PRM=>'0', PWM=>'0', PS3=>'1', PWF1=>'1');
  constant RTYPE_AND_CW : std_logic_vector(CW_SIZE - 1 downto 0) := (PEN1=>'1', PRF1=>'1', PRF2=>'1', PEN2=>'1', PS1=>'1', PS2=>'0', PALU1=>ALU_AND_CW(1), PALU2=>ALU_AND_CW(0), PEN3=>'1', PRM=>'0', PWM=>'0', PS3=>'1', PWF1=>'1');
  constant RTYPE_OR_CW  : std_logic_vector(CW_SIZE - 1 downto 0) := (PEN1=>'1', PRF1=>'1', PRF2=>'1', PEN2=>'1', PS1=>'1', PS2=>'0', PALU1=>ALU_OR_CW (1), PALU2=>ALU_OR_CW (0), PEN3=>'1', PRM=>'0', PWM=>'0', PS3=>'1', PWF1=>'1');
  -- generic rtype control word (ALU1,ALU2 will be overwritten)
  constant RTYPE_CW     : std_logic_vector(CW_SIZE - 1 downto 0) := RTYPE_ADD_CW;

  -- I-Type instruction control words
  constant ITYPE_ADDI1_CW  : std_logic_vector(CW_SIZE - 1 downto 0) := (PEN1=>'1', PRF1=>'0', PRF2=>'1', PEN2=>'1', PS1=>'0', PS2=>'0', PALU1=>ALU_ADD_CW(1), PALU2=>ALU_ADD_CW(0), PEN3=>'1', PRM=>'0', PWM=>'0', PS3=>'1', PWF1=>'1');  --(meaning R[RB] = R[RA] + INP1)
  constant ITYPE_SUBI1_CW  : std_logic_vector(CW_SIZE - 1 downto 0) := (PEN1=>'1', PRF1=>'0', PRF2=>'1', PEN2=>'1', PS1=>'0', PS2=>'0', PALU1=>ALU_SUB_CW(1), PALU2=>ALU_SUB_CW(0), PEN3=>'1', PRM=>'0', PWM=>'0', PS3=>'1', PWF1=>'1');  --(meaning R[RB] = R[RA] - INP1)
  constant ITYPE_ANDI1_CW  : std_logic_vector(CW_SIZE - 1 downto 0) := (PEN1=>'1', PRF1=>'0', PRF2=>'1', PEN2=>'1', PS1=>'0', PS2=>'0', PALU1=>ALU_AND_CW(1), PALU2=>ALU_AND_CW(0), PEN3=>'1', PRM=>'0', PWM=>'0', PS3=>'1', PWF1=>'1');  --(meaning R[RB] = R[RA] AND INP1)
  constant ITYPE_ORI1_CW   : std_logic_vector(CW_SIZE - 1 downto 0) := (PEN1=>'1', PRF1=>'0', PRF2=>'1', PEN2=>'1', PS1=>'0', PS2=>'0', PALU1=>ALU_OR_CW (1), PALU2=>ALU_OR_CW (0), PEN3=>'1', PRM=>'0', PWM=>'0', PS3=>'1', PWF1=>'1');  --(meaning R[RB] = R[RA] OR INP1)
  constant ITYPE_ADDI2_CW  : std_logic_vector(CW_SIZE - 1 downto 0) := (PEN1=>'1', PRF1=>'1', PRF2=>'0', PEN2=>'1', PS1=>'1', PS2=>'1', PALU1=>ALU_ADD_CW(1), PALU2=>ALU_ADD_CW(0), PEN3=>'1', PRM=>'0', PWM=>'0', PS3=>'1', PWF1=>'1');  --(meaning R[RB] = R[RA] + INP2)
  constant ITYPE_SUBI2_CW  : std_logic_vector(CW_SIZE - 1 downto 0) := (PEN1=>'1', PRF1=>'1', PRF2=>'0', PEN2=>'1', PS1=>'1', PS2=>'1', PALU1=>ALU_SUB_CW(1), PALU2=>ALU_SUB_CW(0), PEN3=>'1', PRM=>'0', PWM=>'0', PS3=>'1', PWF1=>'1');  --(meaning R[RB] = R[RA] - INP2)
  constant ITYPE_ANDI2_CW  : std_logic_vector(CW_SIZE - 1 downto 0) := (PEN1=>'1', PRF1=>'1', PRF2=>'0', PEN2=>'1', PS1=>'1', PS2=>'1', PALU1=>ALU_AND_CW(1), PALU2=>ALU_AND_CW(0), PEN3=>'1', PRM=>'0', PWM=>'0', PS3=>'1', PWF1=>'1');  --(meaning R[RB] = R[RA] AND INP2)
  constant ITYPE_ORI2_CW   : std_logic_vector(CW_SIZE - 1 downto 0) := (PEN1=>'1', PRF1=>'1', PRF2=>'0', PEN2=>'1', PS1=>'1', PS2=>'1', PALU1=>ALU_OR_CW (1), PALU2=>ALU_OR_CW (0), PEN3=>'1', PRM=>'0', PWM=>'0', PS3=>'1', PWF1=>'1');  --(meaning R[RB] = R[RA] OR INP2)
  constant ITYPE_MOV_CW    : std_logic_vector(CW_SIZE - 1 downto 0) := (PEN1=>'1', PRF1=>'1', PRF2=>'0', PEN2=>'1', PS1=>'1', PS2=>'1', PALU1=>ALU_ADD_CW(1), PALU2=>ALU_ADD_CW(0), PEN3=>'0', PRM=>'0', PWM=>'0', PS3=>'1', PWF1=>'1');  --(meaning R[RB] = R[RA])
  constant ITYPE_S_REG1_CW : std_logic_vector(CW_SIZE - 1 downto 0) := (PEN1=>'1', PRF1=>'0', PRF2=>'0', PEN2=>'1', PS1=>'0', PS2=>'0', PALU1=>ALU_ADD_CW(1), PALU2=>ALU_ADD_CW(0), PEN3=>'0', PRM=>'0', PWM=>'0', PS3=>'1', PWF1=>'1');  --(meaning R[RD] = INP1)
  constant ITYPE_S_REG2_CW : std_logic_vector(CW_SIZE - 1 downto 0) := (PEN1=>'1', PRF1=>'0', PRF2=>'0', PEN2=>'1', PS1=>'1', PS2=>'1', PALU1=>ALU_ADD_CW(1), PALU2=>ALU_ADD_CW(0), PEN3=>'0', PRM=>'0', PWM=>'0', PS3=>'1', PWF1=>'1');  --(meaning R[RD] = INP2)
  constant ITYPE_S_MEM2_CW : std_logic_vector(CW_SIZE - 1 downto 0) := (PEN1=>'1', PRF1=>'1', PRF2=>'1', PEN2=>'1', PS1=>'1', PS2=>'1', PALU1=>ALU_ADD_CW(1), PALU2=>ALU_ADD_CW(0), PEN3=>'1', PRM=>'0', PWM=>'1', PS3=>'0', PWF1=>'0');  --(meaning MEM[R[RA]+INP2] = R[RB])
  constant ITYPE_L_MEM1_CW : std_logic_vector(CW_SIZE - 1 downto 0) := (PEN1=>'1', PRF1=>'0', PRF2=>'1', PEN2=>'1', PS1=>'0', PS2=>'0', PALU1=>ALU_ADD_CW(1), PALU2=>ALU_ADD_CW(0), PEN3=>'1', PRM=>'1', PWM=>'0', PS3=>'0', PWF1=>'1');  --(meaning R[RB] = MEM[R[RA]+INP1])
  constant ITYPE_L_MEM2_CW : std_logic_vector(CW_SIZE - 1 downto 0) := (PEN1=>'1', PRF1=>'1', PRF2=>'0', PEN2=>'1', PS1=>'1', PS2=>'1', PALU1=>ALU_ADD_CW(1), PALU2=>ALU_ADD_CW(0), PEN3=>'1', PRM=>'1', PWM=>'0', PS3=>'0', PWF1=>'1');  --(meaning R[RB] = MEM[R[RA]+INP2])


  -- BORING CONVERSIONS --
  -- opcodes in std_logic_vector form
  constant RTYPE_OPCODE  : std_logic_vector(OP_CODE_SIZE-1 downto 0) := std_logic_vector(to_unsigned( RTYPE_OPCODE_i ,OP_CODE_SIZE)); 
  constant ADDI1_OPCODE  : std_logic_vector(OP_CODE_SIZE-1 downto 0) := std_logic_vector(to_unsigned( ADDI1_OPCODE_i ,OP_CODE_SIZE));
  constant SUBI1_OPCODE  : std_logic_vector(OP_CODE_SIZE-1 downto 0) := std_logic_vector(to_unsigned( SUBI1_OPCODE_i ,OP_CODE_SIZE));
  constant ANDI1_OPCODE  : std_logic_vector(OP_CODE_SIZE-1 downto 0) := std_logic_vector(to_unsigned( ANDI1_OPCODE_i ,OP_CODE_SIZE));
  constant ORI1_OPCODE   : std_logic_vector(OP_CODE_SIZE-1 downto 0) := std_logic_vector(to_unsigned( ORI1_OPCODE_i  ,OP_CODE_SIZE)); 
  constant ADDI2_OPCODE  : std_logic_vector(OP_CODE_SIZE-1 downto 0) := std_logic_vector(to_unsigned( ADDI2_OPCODE_i ,OP_CODE_SIZE));  
  constant SUBI2_OPCODE  : std_logic_vector(OP_CODE_SIZE-1 downto 0) := std_logic_vector(to_unsigned( SUBI2_OPCODE_i ,OP_CODE_SIZE));  
  constant ANDI2_OPCODE  : std_logic_vector(OP_CODE_SIZE-1 downto 0) := std_logic_vector(to_unsigned( ANDI2_OPCODE_i ,OP_CODE_SIZE));  
  constant ORI2_OPCODE   : std_logic_vector(OP_CODE_SIZE-1 downto 0) := std_logic_vector(to_unsigned( ORI2_OPCODE_i  ,OP_CODE_SIZE));   
  constant MOV_OPCODE    : std_logic_vector(OP_CODE_SIZE-1 downto 0) := std_logic_vector(to_unsigned( MOV_OPCODE_i  ,OP_CODE_SIZE));    
  constant S_REG1_OPCODE : std_logic_vector(OP_CODE_SIZE-1 downto 0) := std_logic_vector(to_unsigned( S_REG1_OPCODE_i,OP_CODE_SIZE)); 
  constant S_REG2_OPCODE : std_logic_vector(OP_CODE_SIZE-1 downto 0) := std_logic_vector(to_unsigned( S_REG2_OPCODE_i,OP_CODE_SIZE)); 
  constant S_MEM2_OPCODE : std_logic_vector(OP_CODE_SIZE-1 downto 0) := std_logic_vector(to_unsigned( S_MEM2_OPCODE_i,OP_CODE_SIZE)); 
  constant L_MEM1_OPCODE : std_logic_vector(OP_CODE_SIZE-1 downto 0) := std_logic_vector(to_unsigned( L_MEM1_OPCODE_i,OP_CODE_SIZE)); 
  constant L_MEM2_OPCODE : std_logic_vector(OP_CODE_SIZE-1 downto 0) := std_logic_vector(to_unsigned( L_MEM2_OPCODE_i,OP_CODE_SIZE)); 

  -- FUNC in std_logic_vector form
  constant ADD_FUNC : std_logic_vector(FUNC_SIZE-1 downto 0) := std_logic_vector(to_unsigned(ADD_FUNC_i,FUNC_SIZE)); 
  constant SUB_FUNC : std_logic_vector(FUNC_SIZE-1 downto 0) := std_logic_vector(to_unsigned(SUB_FUNC_i,FUNC_SIZE)); 
  constant AND_FUNC : std_logic_vector(FUNC_SIZE-1 downto 0) := std_logic_vector(to_unsigned(AND_FUNC_i,FUNC_SIZE)); 
  constant OR_FUNC  : std_logic_vector(FUNC_SIZE-1 downto 0) := std_logic_vector(to_unsigned(OR_FUNC_i ,FUNC_SIZE)); 

end COMM_PKG;
