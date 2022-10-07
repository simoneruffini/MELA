--------------------------------------------------------------------------------
-- Engineer:  Simone Ruffini [simone.ruffini@studenti.unitn.it]
--
--
-- Create Date:     Fri Apr 22 07:21:29 PM CEST 2022
-- Design Name:     RF_PKG
-- Module Name:     RF_PKG.vhd
-- Project Name:    Windowed Register File
-- Description:     Common Package for the windowed register file
--
-- Revision:
-- Revision 00 - Simone Ruffini
--  * File Created
-- Additional Comments:
--
--------------------------------------------------------------------------------
library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use IEEE.NUMERIC_STD.all;
  use IEEE.MATH_REAL.all;

package RF_PKG is

  type wrf_state is (
    INACTIVE_s,       -- The Windowed Register File is inactive
    READY_s,          -- The Windowed Register File is ready for requests
    FILL_s,           -- The Windowed Register File is busy retriving data from memory
    SPILL_s           -- The Windowed Register File is busy pushing data to memory
  );
  type wrf_op is (
    WRF_NO_OP,       -- no operation
    WRF_OPN_CTX,     -- Open New Context (Subrutine Call)
    WRF_CLS_CTX      -- Close Current Context (Subrutine Return)
  );

  function addr_w_virt(
    N_WIN         : integer;   -- Number of windows
    N_REG_PER_WIN : INTEGER;  -- Nubmer of register per window
    N_GLOBAL_REG  : INTEGER  -- Number of register in the global "window"
  ) return natural;

  function addr_w_phys(
    N_WIN         : integer;   -- Number of windows
    N_REG_PER_WIN : INTEGER;  -- Nubmer of register per window
    N_GLOBAL_REG  : INTEGER  -- Number of register in the global "window"
  ) return natural;


end package;

package body RF_PKG is
  function addr_w_virt(
    N_WIN         : integer;   -- Number of windows
    N_REG_PER_WIN : INTEGER;  -- Nubmer of register per window
    N_GLOBAL_REG  : INTEGER  -- Number of register in the global "window"
  ) return natural is   
  begin
    return integer(
            ceil(log2(real( 3*N_REG_PER_WIN + N_GLOBAL_REG )))  -- address space of virtual address (3 blocks IN/LOCAL/OUT create a full window)
           );
  end function;

  function addr_w_phys(
    N_WIN         : integer;   -- Number of windows
    N_REG_PER_WIN : INTEGER;  -- Nubmer of register per window
    N_GLOBAL_REG  : INTEGER  -- Number of register in the global "window"
  ) return natural is   
  begin
    return integer(
            ceil(log2(real( 2*N_WIN*N_REG_PER_WIN + N_GLOBAL_REG )))  -- RF size
           );
  end function;


end RF_PKG;

