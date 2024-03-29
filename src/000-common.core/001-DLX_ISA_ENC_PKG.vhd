--------------------------------------------------------------------------------
-- Engineer: Simone Ruffini   [simone.ruffini@studenti.polito.it]
--           Matteo Bonora    [matteo.bonora@studenti.polito.it]
--
-- Create Date:     Tue Oct 11 05:15:07 PM CEST 2022
-- Module Name:     DLX_ISA_ENC_PKG
-- Project Name:    MELA
-- Description:     DLX Instruction Set Architecture Encodings Package
--
-- Revision:
-- Revision 00 - Simone Ruffini
--  * Created
-- Additional Comments:
--  These ecodins follow the output of the assembler found at
--  ${root_prj}/scripts/assembler/assembler.sh
--------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.dlx_pkg.all;

package DLX_ISA_ENC_PKG is

  ----------------------------------------------------------- CONSTANTS 1

  ----------------------------------------------------------- TYPES
  -- Instruction enum used only for simulation

  type instr_t is (
    RTYPx,
    SLLx,
    SRLx,
    SRAx,
    ADDx,
    SUBx,
    ANDx,
    ORx,
    XORx,
    SNEx,
    SLEx,
    SGEx,
    Jx,
    JALx,
    BEQZx,
    BNEZx,
    ADDIx,
    SUBIx,
    ANDIx,
    ORIx,
    XORIx,
    SLLIx,
    NOPx,
    SRLIx,
    SRAIx,
    SNEIx,
    SLEIx,
    SGEIx,
    LWx,
    SWx,
    INSTR_NOT_FOUNDx
  );

  ----------------------------------------------------------- FUNCTIONS

  function print_instr_op (opcode: std_logic_vector) return instr_t;

  function print_instr (instr: std_logic_vector) return instr_t;

  function print_instr (opcode: std_logic_vector; func: std_logic_vector) return instr_t;

  ----------------------------------------------------------- CONSTANTS 2

  -- vsg_off constant_015 constant_004 : vsg checking that constant have C_ prefix

  constant RTYPE_OPCODE_i : natural := 16#00#;

  -- opcodes in integer form
  -- the encoding of the opcodes can be changed to optimize the resulting design
  --
  --       OPCODE NAME   |         OPCODE VALUE      |
  constant SLL_OPCODE_i  : natural := RTYPE_OPCODE_i;
  constant SRL_OPCODE_i  : natural := RTYPE_OPCODE_i;
  constant SRA_OPCODE_i  : natural := RTYPE_OPCODE_i;
  constant ADD_OPCODE_i  : natural := RTYPE_OPCODE_i;
  constant SUB_OPCODE_i  : natural := RTYPE_OPCODE_i;
  constant AND_OPCODE_i  : natural := RTYPE_OPCODE_i;
  constant OR_OPCODE_i   : natural := RTYPE_OPCODE_i;
  constant XOR_OPCODE_i  : natural := RTYPE_OPCODE_i;
  constant SNE_OPCODE_i  : natural := RTYPE_OPCODE_i;
  constant SLE_OPCODE_i  : natural := RTYPE_OPCODE_i;
  constant SGE_OPCODE_i  : natural := RTYPE_OPCODE_i;
  constant J_OPCODE_i    : natural := 16#02#;
  constant JAL_OPCODE_i  : natural := 16#03#;
  constant BEQZ_OPCODE_i : natural := 16#04#;
  constant BNEZ_OPCODE_i : natural := 16#05#;
  constant ADDI_OPCODE_i : natural := 16#08#;
  constant SUBI_OPCODE_i : natural := 16#0a#;
  constant ANDI_OPCODE_i : natural := 16#0c#;
  constant ORI_OPCODE_i  : natural := 16#0d#;
  constant XORI_OPCODE_i : natural := 16#0e#;
  constant SLLI_OPCODE_i : natural := 16#14#;
  constant NOP_OPCODE_i  : natural := 16#15#;
  constant SRLI_OPCODE_i : natural := 16#16#;
  constant SRAI_OPCODE_i : natural := 16#17#;
  constant SNEI_OPCODE_i : natural := 16#19#;
  constant SLEI_OPCODE_i : natural := 16#1c#;
  constant SGEI_OPCODE_i : natural := 16#1d#;
  constant LW_OPCODE_i   : natural := 16#23#;
  constant SW_OPCODE_i   : natural := 16#2b#;

  -- FUNC for R-Type instructions in integer form
  -- the encoding of functions can be changed to optimize the resulting design
  --
  --       FUNC NAME     |   OPCODE VALUE   |
  constant SLL_FUNC_i : natural := 16#04#;
  constant SRL_FUNC_i : natural := 16#06#;
  constant SRA_FUNC_i : natural := 16#07#;
  constant ADD_FUNC_i : natural := 16#20#;
  constant SUB_FUNC_i : natural := 16#22#;
  constant AND_FUNC_i : natural := 16#24#;
  constant OR_FUNC_i  : natural := 16#25#;
  constant XOR_FUNC_i : natural := 16#26#;
  constant SNE_FUNC_i : natural := 16#29#;
  constant SLE_FUNC_i : natural := 16#2C#;
  constant SGE_FUNC_i : natural := 16#2D#;

  -- BORING CONVERSIONS --
  -- opcodes in std_logic_vector form
  constant RTYPE_OPCODE : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0) := std_logic_vector(to_unsigned(RTYPE_OPCODE_i, C_INSTR_OPCODE_W));
  constant SLL_OPCODE   : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0) := std_logic_vector(to_unsigned(SLL_OPCODE_i, C_INSTR_OPCODE_W));
  constant SRL_OPCODE   : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0) := std_logic_vector(to_unsigned(SRL_OPCODE_i, C_INSTR_OPCODE_W));
  constant SRA_OPCODE   : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0) := std_logic_vector(to_unsigned(SRA_OPCODE_i, C_INSTR_OPCODE_W));
  constant ADD_OPCODE   : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0) := std_logic_vector(to_unsigned(ADD_OPCODE_i, C_INSTR_OPCODE_W));
  constant SUB_OPCODE   : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0) := std_logic_vector(to_unsigned(SUB_OPCODE_i, C_INSTR_OPCODE_W));
  constant AND_OPCODE   : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0) := std_logic_vector(to_unsigned(AND_OPCODE_i, C_INSTR_OPCODE_W));
  constant OR_OPCODE    : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0) := std_logic_vector(to_unsigned(OR_OPCODE_i, C_INSTR_OPCODE_W));
  constant XOR_OPCODE   : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0) := std_logic_vector(to_unsigned(XOR_OPCODE_i, C_INSTR_OPCODE_W));
  constant SNE_OPCODE   : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0) := std_logic_vector(to_unsigned(SNE_OPCODE_i, C_INSTR_OPCODE_W));
  constant SLE_OPCODE   : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0) := std_logic_vector(to_unsigned(SLE_OPCODE_i, C_INSTR_OPCODE_W));
  constant SGE_OPCODE   : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0) := std_logic_vector(to_unsigned(SGE_OPCODE_i, C_INSTR_OPCODE_W));
  constant J_OPCODE     : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0) := std_logic_vector(to_unsigned(J_OPCODE_i, C_INSTR_OPCODE_W));
  constant JAL_OPCODE   : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0) := std_logic_vector(to_unsigned(JAL_OPCODE_i, C_INSTR_OPCODE_W));
  constant BEQZ_OPCODE  : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0) := std_logic_vector(to_unsigned(BEQZ_OPCODE_i, C_INSTR_OPCODE_W));
  constant BNEZ_OPCODE  : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0) := std_logic_vector(to_unsigned(BNEZ_OPCODE_i, C_INSTR_OPCODE_W));
  constant ADDI_OPCODE  : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0) := std_logic_vector(to_unsigned(ADDI_OPCODE_i, C_INSTR_OPCODE_W));
  constant SUBI_OPCODE  : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0) := std_logic_vector(to_unsigned(SUBI_OPCODE_i, C_INSTR_OPCODE_W));
  constant ANDI_OPCODE  : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0) := std_logic_vector(to_unsigned(ANDI_OPCODE_i, C_INSTR_OPCODE_W));
  constant ORI_OPCODE   : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0) := std_logic_vector(to_unsigned(ORI_OPCODE_i, C_INSTR_OPCODE_W));
  constant XORI_OPCODE  : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0) := std_logic_vector(to_unsigned(XORI_OPCODE_i, C_INSTR_OPCODE_W));
  constant SLLI_OPCODE  : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0) := std_logic_vector(to_unsigned(SLLI_OPCODE_i, C_INSTR_OPCODE_W));
  constant NOP_OPCODE   : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0) := std_logic_vector(to_unsigned(NOP_OPCODE_i, C_INSTR_OPCODE_W));
  constant SRLI_OPCODE  : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0) := std_logic_vector(to_unsigned(SRLI_OPCODE_i, C_INSTR_OPCODE_W));
  constant SRAI_OPCODE  : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0) := std_logic_vector(to_unsigned(SRAI_OPCODE_i, C_INSTR_OPCODE_W));
  constant SNEI_OPCODE  : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0) := std_logic_vector(to_unsigned(SNEI_OPCODE_i, C_INSTR_OPCODE_W));
  constant SLEI_OPCODE  : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0) := std_logic_vector(to_unsigned(SLEI_OPCODE_i, C_INSTR_OPCODE_W));
  constant SGEI_OPCODE  : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0) := std_logic_vector(to_unsigned(SGEI_OPCODE_i, C_INSTR_OPCODE_W));
  constant LW_OPCODE    : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0) := std_logic_vector(to_unsigned(LW_OPCODE_i, C_INSTR_OPCODE_W));
  constant SW_OPCODE    : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0) := std_logic_vector(to_unsigned(SW_OPCODE_i, C_INSTR_OPCODE_W));

  -- FUNC in std_logic_vector form
  constant SLL_FUNC : std_logic_vector(C_INSTR_FUNC_W - 1 downto 0) := std_logic_vector(to_unsigned(SLL_FUNC_i, C_INSTR_FUNC_W));
  constant SRL_FUNC : std_logic_vector(C_INSTR_FUNC_W - 1 downto 0) := std_logic_vector(to_unsigned(SRL_FUNC_i, C_INSTR_FUNC_W));
  constant SRA_FUNC : std_logic_vector(C_INSTR_FUNC_W - 1 downto 0) := std_logic_vector(to_unsigned(SRA_FUNC_i, C_INSTR_FUNC_W));
  constant ADD_FUNC : std_logic_vector(C_INSTR_FUNC_W - 1 downto 0) := std_logic_vector(to_unsigned(ADD_FUNC_i, C_INSTR_FUNC_W));
  constant SUB_FUNC : std_logic_vector(C_INSTR_FUNC_W - 1 downto 0) := std_logic_vector(to_unsigned(SUB_FUNC_i, C_INSTR_FUNC_W));
  constant AND_FUNC : std_logic_vector(C_INSTR_FUNC_W - 1 downto 0) := std_logic_vector(to_unsigned(AND_FUNC_i, C_INSTR_FUNC_W));
  constant OR_FUNC  : std_logic_vector(C_INSTR_FUNC_W - 1 downto 0) := std_logic_vector(to_unsigned(OR_FUNC_i, C_INSTR_FUNC_W));
  constant XOR_FUNC : std_logic_vector(C_INSTR_FUNC_W - 1 downto 0) := std_logic_vector(to_unsigned(XOR_FUNC_i, C_INSTR_FUNC_W));
  constant SNE_FUNC : std_logic_vector(C_INSTR_FUNC_W - 1 downto 0) := std_logic_vector(to_unsigned(SNE_FUNC_i, C_INSTR_FUNC_W));
  constant SLE_FUNC : std_logic_vector(C_INSTR_FUNC_W - 1 downto 0) := std_logic_vector(to_unsigned(SLE_FUNC_i, C_INSTR_FUNC_W));
  constant SGE_FUNC : std_logic_vector(C_INSTR_FUNC_W - 1 downto 0) := std_logic_vector(to_unsigned(SGE_FUNC_i, C_INSTR_FUNC_W));

end package DLX_ISA_ENC_PKG;

package body DLX_ISA_ENC_PKG is

  function print_instr_op (opcode: std_logic_vector) return instr_t is
  begin

    if (opcode = RTYPE_OPCODE) then
      return RTYPx;
    elsif (opcode = J_OPCODE) then
      return Jx;
    elsif (opcode = JAL_OPCODE) then
      return JALx;
    elsif (opcode = BEQZ_OPCODE) then
      return BEQZx;
    elsif (opcode = BNEZ_OPCODE) then
      return BNEZx;
    elsif (opcode = ADDI_OPCODE) then
      return ADDIx;
    elsif (opcode = SUBI_OPCODE) then
      return SUBIx;
    elsif (opcode = ANDI_OPCODE) then
      return ANDIx;
    elsif (opcode = ORI_OPCODE) then
      return ORIx;
    elsif (opcode = XORI_OPCODE) then
      return XORIx;
    elsif (opcode = SLLI_OPCODE) then
      return SLLIx;
    elsif (opcode = NOP_OPCODE) then
      return NOPx;
    elsif (opcode = SRLI_OPCODE) then
      return SRLIx;
    elsif (opcode = SRAI_OPCODE) then
      return SRAIx;
    elsif (opcode = SNEI_OPCODE) then
      return SNEIx;
    elsif (opcode = SLEI_OPCODE) then
      return SLEIx;
    elsif (opcode = SGEI_OPCODE) then
      return SGEIx;
    elsif (opcode = LW_OPCODE) then
      return LWx;
    elsif (opcode = SW_OPCODE) then
      return SWx;
    else
      return INSTR_NOT_FOUNDx;
    end if;

  end function print_instr_op;

  function print_instr (opcode: std_logic_vector;func: std_logic_vector) return instr_t is

    variable ret : instr_t;

  begin

    ret := print_instr_op(opcode);

    if (ret = RTYPx) then
      if (func = SLL_FUNC) then
        ret := SLLx;
      elsif (func = SRL_FUNC) then
        ret := SRLx;
      elsif (func = SRA_FUNC) then
        ret := SRAx;
      elsif (func = ADD_FUNC) then
        ret := ADDx;
      elsif (func = SUB_FUNC) then
        ret := SUBx;
      elsif (func = AND_FUNC) then
        ret := ANDx;
      elsif (func = OR_FUNC) then
        ret := ORx;
      elsif (func = XOR_FUNC) then
        ret := XORx;
      elsif (func = SNE_FUNC) then
        ret := SNEx;
      elsif (func = SLE_FUNC) then
        ret := SLEx;
      elsif (func = SGE_FUNC) then
        ret := SGEx;
      else
        ret := INSTR_NOT_FOUNDx;
      end if;
    end if;

    return ret;

  end function print_instr;

  -- Prints the enum instruction rappresentation of instr

  function print_instr (instr: std_logic_vector) return instr_t is

    variable opcode : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0);
    variable func   : std_logic_vector(C_INSTR_FUNC_W - 1 downto 0);
    variable ret    : instr_t;

  begin

    opcode := get_opcode(instr);
    func   := get_func(instr);
    ret    := print_instr(opcode, func);
    return ret;

  end function print_instr;

end package body DLX_ISA_ENC_PKG;
