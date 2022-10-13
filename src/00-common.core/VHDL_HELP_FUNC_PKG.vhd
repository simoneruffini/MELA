--------------------------------------------------------------------------------
-- Engineer: Simone Ruffini  [simone.ruffini@studenti.polito.it]
--
-- Create Date:     Thu Oct 13 06:42:01 PM CEST 2022
-- Module Name:     VHDL_HELP_FUNC_PKG (VHFP prefix)
-- Project Name:    -
-- Description:     VHDL helper functions package
--
-- Revision:
-- Revision 00 - Simone Ruffini
--  * file created
-- Additional Comments:
--
--------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

package VHDL_HELP_FUNC_PKG is

  -- ilog2 returs always the ceiling of the log2 of x

  function vhfp_ilog2 (x: natural) return natural;

end package VHDL_HELP_FUNC_PKG;

package body VHDL_HELP_FUNC_PKG is

  function vhfp_ilog2 (x:natural) return natural is
  begin

    return natural(ceil(log2(real(x))));

  end function;

end package body VHDL_HELP_FUNC_PKG;
