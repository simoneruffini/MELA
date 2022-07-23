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
    ADD, 
    SUB,
    MULT,
    BITAND,
    BITOR,
    BITXOR,
    FUNCLSL,
    FUNCLSR,
    FUNCRL,
    FUNCRR
  );
end ALU_PKG;
