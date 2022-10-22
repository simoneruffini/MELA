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
--  VHDL2008 or higher
--------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;
  use std.textio.all;

library std;
  use std.textio.all;

package VHDL_HELP_FUNC_PKG is

  -- ilog2 returs always the ceiling of the log2 of x

  function vhfp_ilog2 (x: natural) return natural;

  -- check if filename exists before working on it

  impure function vhfp_file_exists (filename : in string) return boolean;

end package VHDL_HELP_FUNC_PKG;

package body VHDL_HELP_FUNC_PKG is

  function vhfp_ilog2 (x:natural) return natural is
  begin

    return natural(ceil(log2(real(x))));

  end function;

  impure function vhfp_file_exists (filename : in string) return boolean is

    variable open_status : FILE_OPEN_STATUS;
    file     infile      :text;

  begin

    file_open(open_status, infile, filename, read_mode);

    if (open_status /= open_ok) then
      return false;
    else
      file_close(infile);
      return true;
    end if;

  end function;

end package body VHDL_HELP_FUNC_PKG;
