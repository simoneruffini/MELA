--------------------------------------------------------------------------------
-- Engineer:  Simone Ruffini [simone.ruffini@studenti.unitn.it]
--
--
-- Create Date:     Fri Jul 22 03:14:41 PM CEST 2022
-- Design Name:     ALU_PKG
-- Module Name:     ALU_PKG.vhd
-- Project Name:    ALU
-- Description:     Package for ALU
--
-- Revision:
-- Revision 00 - Simone Ruffini
--  * File Created
-- Additional Comments:
--
--------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

package ALU_PKG is

  type alu_func_t is (
    ADD,    -- Addition               RES = A + B
    SUB,    -- Subtraction            RES = A - B
    BITAND, -- Bitwise and            RES = A AND B
    BITOR,  -- Bitwise or             RES = A OR B
    BITXOR, -- Bitwise xor            RES = A XOR B
    LSL,    -- Logical shift left     RES = A << B
    LSR,    -- Logical shift right    RES = A >> B
    ASR,    -- Arithmetic shift right RES = A a>> B
    GEQ,    -- greater then equal     RES = A >= B
    LEQ,    -- less then equal        RES = A <= B
    NEQ,    -- not equal              RES = A != B
    NOP     -- no operation
  );

  constant C_T2_LOGIC_OP_AND  : std_logic_vector(3 downto 0) := "0001";
  constant C_T2_LOGIC_OP_NAND : std_logic_vector(3 downto 0) := "1110";
  constant C_T2_LOGIC_OP_OR   : std_logic_vector(3 downto 0) := "0111";
  constant C_T2_LOGIC_OP_NOR  : std_logic_vector(3 downto 0) := "1000";
  constant C_T2_LOGIC_OP_XOR  : std_logic_vector(3 downto 0) := "0110";

  constant C_T2_SHIFTER_OP_SLL : std_logic_vector(1 downto 0) := "00";
  constant C_T2_SHIFTER_OP_SRL : std_logic_vector(1 downto 0) := "01";
  constant C_T2_SHIFTER_OP_SRA : std_logic_vector(1 downto 0) := "10";

end package ALU_PKG;
