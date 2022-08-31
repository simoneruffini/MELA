--------------------------------------------------------------------------------
-- Engineer: Simone Ruffini  [simone.ruffini@studenti.polito.it]
--           Lorenzo Latella [s292653@studenti.polito.it]
--           Matteo Bonora   [matteo.bonora@studenti.polito.it]
--
-- Create Date:     Wed May  4 16:45:33 CEST 2022
-- Design Name:     Control Unit Hardwired
-- Module Name:     CU.vhd
-- Project Name:    DLX control unit
-- Description:     Control unit for the DLX datapath
--
--
-- Revision:
-- Revision 00 - Simone Ruffini
--  * first implementation
-- Revision 01 - Simone Ruffini Fri Jul 22 03:37:10 PM CEST 2022
--  * rename CU_HW -> CU
-- Additional Comments: 
--
--------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.DLX_PKG.all;

entity CU is
  port (
    -- INPUTS
    CLK    : in std_logic;
    RSTn   : in std_logic;                -- Active Low
    OPCODE : in  std_logic_vector(OP_CODE_SIZE - 1 downto 0);
    FUNC   : in  std_logic_vector(FUNC_SIZE - 1 downto 0);
    CTRL_WORD : out    controlword_t(cw_signals_type'POS(CW_SIZE) - 1 downto 0)
  );
end CU;

architecture BEHAVIORAL of CU is

  type op_lut_t is array (integer range <>) of std_logic_vector(CW_SIZE - 1 downto 0);
  type func_lut_t is array (integer range <>) of std_logic_vector(ALU_CW_SIZE - 1 downto 0);

  constant LUT_SIZE : integer := 2 ** (OP_CODE_SIZE); 

  -- Lut Memory containing the control words for each OPCODE. 
  -- The OPCODE indexes the LUT.
  -- 
  -- cw = cw_lut(opcode)
  --
  -- NOTE:
  -- R-type instruction share the same control world a part from the ALU part: 
  -- ALU1, ALU2 signals. Therefore all R-type instructions are mapped to the same 
  -- control word (RTYPE_CW) and the ALU part will be handled by a different LUT
  --
  signal cw_lut : op_lut_t(2 ** (OP_CODE_SIZE) -1 downto 0) :=(
    RTYPE_OPCODE_i  => RTYPE_CW       ,
    ADDI1_OPCODE_i  => ITYPE_ADDI1_CW ,
    SUBI1_OPCODE_i  => ITYPE_SUBI1_CW ,
    ANDI1_OPCODE_i  => ITYPE_ANDI1_CW ,
    ORI1_OPCODE_i   => ITYPE_ORI1_CW  ,
    ADDI2_OPCODE_i  => ITYPE_ADDI2_CW ,
    SUBI2_OPCODE_i  => ITYPE_SUBI2_CW ,
    ANDI2_OPCODE_i  => ITYPE_ANDI2_CW ,
    ORI2_OPCODE_i   => ITYPE_ORI2_CW  ,
    MOV_OPCODE_i    => ITYPE_MOV_CW   ,
    S_REG1_OPCODE_i => ITYPE_S_REG1_CW,
    S_REG2_OPCODE_i => ITYPE_S_REG2_CW,
    S_MEM2_OPCODE_i => ITYPE_S_MEM2_CW,
    L_MEM1_OPCODE_i => ITYPE_L_MEM1_CW,
    L_MEM2_OPCODE_i => ITYPE_L_MEM2_CW,
    others          => (others => '0') -- this disables all enable signals so nothing would work
  );

  -- Lut Memory containing the ALU control words for each FUNC of and R-type instruction.
  -- The FUNC indexes the LUT.
  -- 
  -- alu_cw = alu_cw_lut(FUNC)
  --
  -- The ALU control words will drive directly ALU1 and ALU2 signals when the 
  -- opcode is of an r-type instruction
  --
  signal alu_cw_lut : func_lut_t(2 ** (FUNC_SIZE) -1 downto 0) :=(
    ADD_FUNC_i  => ALU_ADD_CW,
    SUB_FUNC_i  => ALU_SUB_CW, 
    AND_FUNC_i  => ALU_AND_CW,
    OR_FUNC_i   => ALU_OR_CW ,
    others      => (others => '0')
  );


  signal cw  : std_logic_vector(CW_SIZE -1 downto 0); -- full control word read from cw_lut
  signal cw1 : std_logic_vector(CW_SIZE -1 downto 0); -- cw 1 clk delay stage 
  signal cw2 : std_logic_vector(CW_SIZE -1 downto 0); -- cw 2 clk delay stage

  signal alu_cw: std_logic_vector(ALU_CW_SIZE-1 downto 0);  -- alu control word read from alu_cw_lut
  signal alu_cw1: std_logic_vector(ALU_CW_SIZE-1 downto 0); -- alu_cw 1 clk delay stage
 
begin

  -- LUT operations
  cw     <= cw_lut(to_integer(unsigned(OPCODE)));
  alu_cw <= alu_cw_lut(to_integer(unsigned(FUNC)));

  -- stage one control signals
  EN1 <= cw(PEN1);
  RF1 <= cw(PRF1);
  RF2 <= cw(PRF2);
  WF1 <= cw(PWF1);

  -- stage two control signals
  EN2  <= cw1(PEN2);
  S1   <= cw1(PS1);
  S2   <= cw1(PS2);
  -- ALU1,ALU2 are redirected to the output of alu_cw_lut when the opcode is of an R-type instruction
  ALU1 <= cw1(PALU1) when OPCODE /= RTYPE_OPCODE else alu_cw1(1); 
  ALU2 <= cw1(PALU2) when OPCODE /= RTYPE_OPCODE else alu_cw1(0);
  
  -- stage three control signals
  EN3 <= cw2(PEN3);
  RM  <= cw2(PRM );
  WM  <= cw2(PWM );
  S3  <= cw2(PS3 );

  -- process to pipeline control words
  DELAYS: process (CLK, RSTn)
  begin  -- process CLK
    if RSTn = '0' then                   -- asynchronous reset (active low)
      cw1 <= (others => '0');
      cw2 <= (others => '0');
      alu_cw1 <= (others => '0');

    elsif CLK'event and CLK = '1' then  -- rising clock edge
      cw1 <= cw;
      cw2 <= cw1;

      alu_cw1 <= alu_cw;
    end if;
  end process DELAYS;

end BEHAVIORAL;

configuration CFG_CU_BEHAVIORAL of CU is
  for BEHAVIORAL
  end for;
end configuration;

