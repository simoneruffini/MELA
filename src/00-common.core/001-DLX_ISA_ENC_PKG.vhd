--------------------------------------------------------------------------------
-- Engineer: Simone Ruffini   [simone.ruffini@studenti.polito.it]
--           Matteo Bonora    [matteo.bonora@studenti.polito.it]
--
-- Create Date:     Tue Oct 11 05:15:07 PM CEST 2022
-- Module Name:     DLX_ISA_ENC_PKG
-- Project Name:    DLX
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

  -- vsg_off constant_015 : vsg checking that constant have C_ prefix

  constant RTYPE_OPCODE_i : natural := 16#00#;

  -- opcodes in integer form
  -- the encoding of the opcodes can be changed to optimize the resulting design
  --
  --       OPCODE NAME     |         OPCODE VALUE      |
  constant SLL_OPCODE_i  : natural := RTYPE_OPCODE_i;
  constant SRL_OPCODE_i  : natural := RTYPE_OPCODE_i;
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
  constant SNEI_OPCODE  : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0) := std_logic_vector(to_unsigned(SNEI_OPCODE_i, C_INSTR_OPCODE_W));
  constant SLEI_OPCODE  : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0) := std_logic_vector(to_unsigned(SLEI_OPCODE_i, C_INSTR_OPCODE_W));
  constant SGEI_OPCODE  : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0) := std_logic_vector(to_unsigned(SGEI_OPCODE_i, C_INSTR_OPCODE_W));
  constant LW_OPCODE    : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0) := std_logic_vector(to_unsigned(LW_OPCODE_i, C_INSTR_OPCODE_W));
  constant SW_OPCODE    : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0) := std_logic_vector(to_unsigned(SW_OPCODE_i, C_INSTR_OPCODE_W));

  -- FUNC in std_logic_vector form
  constant SLL_FUNC : std_logic_vector(C_INSTR_FUNC_W - 1 downto 0) := std_logic_vector(to_unsigned(SLL_FUNC_i, C_INSTR_FUNC_W));
  constant SRL_FUNC : std_logic_vector(C_INSTR_FUNC_W - 1 downto 0) := std_logic_vector(to_unsigned(SRL_FUNC_i, C_INSTR_FUNC_W));
  constant ADD_FUNC : std_logic_vector(C_INSTR_FUNC_W - 1 downto 0) := std_logic_vector(to_unsigned(ADD_FUNC_i, C_INSTR_FUNC_W));
  constant SUB_FUNC : std_logic_vector(C_INSTR_FUNC_W - 1 downto 0) := std_logic_vector(to_unsigned(SUB_FUNC_i, C_INSTR_FUNC_W));
  constant AND_FUNC : std_logic_vector(C_INSTR_FUNC_W - 1 downto 0) := std_logic_vector(to_unsigned(AND_FUNC_i, C_INSTR_FUNC_W));
  constant OR_FUNC  : std_logic_vector(C_INSTR_FUNC_W - 1 downto 0) := std_logic_vector(to_unsigned(OR_FUNC_i, C_INSTR_FUNC_W));
  constant XOR_FUNC : std_logic_vector(C_INSTR_FUNC_W - 1 downto 0) := std_logic_vector(to_unsigned(XOR_FUNC_i, C_INSTR_FUNC_W));
  constant SNE_FUNC : std_logic_vector(C_INSTR_FUNC_W - 1 downto 0) := std_logic_vector(to_unsigned(SNE_FUNC_i, C_INSTR_FUNC_W));
  constant SLE_FUNC : std_logic_vector(C_INSTR_FUNC_W - 1 downto 0) := std_logic_vector(to_unsigned(SLE_FUNC_i, C_INSTR_FUNC_W));
  constant SGE_FUNC : std_logic_vector(C_INSTR_FUNC_W - 1 downto 0) := std_logic_vector(to_unsigned(SGE_FUNC_i, C_INSTR_FUNC_W));

end package DLX_ISA_ENC_PKG;
