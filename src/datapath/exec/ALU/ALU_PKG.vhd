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

package ALU_PKG is
  type TYPE_OP is (
    ADD,    -- 0000
    SUB,    -- 0001
    MULT,   -- 0010
    BITAND, -- 0011
    BITOR,  -- 0100
    BITXOR, -- 0101
    FUNCLSL,-- 0110
    FUNCLSR,-- 0111
    -- TODO: add arithmetic shifts
    FUNCRL, -- 1000
    FUNCRR  -- 1001
  );
end ALU_PKG;
