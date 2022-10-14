--------------------------------------------------------------------------------
-- Engineer:  Simone Ruffini [simone.ruffini@studenti.unitn.it]
--
--
-- Create Date:     Thu Mar 24 10:35:58 CET 2022
-- Design Name:     CARRY_GENERATOR_PKG
-- Module Name:     CARRY_GENERATOR_PKG.vhd
-- Project Name:    P4 adder
-- Description:     Common Package for the P4 Adder
--
-- Revision:
-- Revision 00 - Simone Ruffini
--  * File Created
-- Revision 01 - Simone Ruffini Fri Jul 22 02:21:11 PM CEST 2022
--  * ranamed file COMM_PKG -> CARRY_GENERATOR_PKG
-- Revision 02 - Simone Ruffini Fri Oct 14 06:48:12 PM CEST 2022
--  * converted procedure assert_bits to function
-- Additional Comments:
--
--------------------------------------------------------------------------------

------------------------------------------------------------- PACKAGES/LIBRARIES

library IEEE;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

------------------------------------------------------------- PACKAGE
package CARRY_GENERATOR_PKG is

  ----------------------------------------------------------- CONSTANTS 1

  -- G index
  constant G_IDX : natural := 0;
  -- P index
  constant P_IDX : natural := 1;

  ----------------------------------------------------------- TYPES

  type crossbar_t is array (natural range <>, natural range <>) of std_logic_vector(1 downto 0);

  ----------------------------------------------------------- FUNCTIONS

  function assert_bits (
    BIT_WIDTH   : natural;
    CARRY_STEP  : natural
  ) return natural;

  ----------------------------------------------------------- CONSTANTS 2

  ----------------------------------------------------------- SIGNALS


end package CARRY_GENERATOR_PKG;

------------------------------------------------------------- PACKAGE BODY

package body CARRY_GENERATOR_PKG is

  function assert_bits (
    BIT_WIDTH   : natural;
    CARRY_STEP  : natural
  ) return natural is
  begin

    assert (BIT_WIDTH >= CARRY_STEP)
      report "ERROR: The adder carry bit step (" & integer'image(CARRY_STEP) & ") is greater then the bit width of the adder (" & integer'image(BIT_WIDTH) & ")"
      severity failure;

    assert ((LOG2(real(BIT_WIDTH)) - real(integer(LOG2(real(BIT_WIDTH))))) = 0.0)
      report "ERROR: The bit size of the adder(" & integer'image(BIT_WIDTH) & ") is not supported, it must be a power of 2"
      severity failure;

    assert ((LOG2(real(CARRY_STEP)) - real(integer(LOG2(real(CARRY_STEP))))) = 0.0)
      report "ERROR: The carry bit step of the adder (" & integer'image(CARRY_STEP) & ") is not supported, it must be a power of 2"
      severity failure;

    report "CARRY_GENGERATOR asserts: OK";

    return 0;

  end function;

end package body CARRY_GENERATOR_PKG;

