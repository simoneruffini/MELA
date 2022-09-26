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

package alu_pkg is

  type alu_func_t is (
    ADD,    -- Addition              RES = A + B
    SUB,    -- Subtraction           RES = A - B
    BITAND, -- Bitwise and           RES = A AND B
    BITOR,  -- Bitwise or            RES = A OR B
    BITXOR, -- Bitwise xor           RES = A XOR B
    LSL,    -- Logical shift left    RES = A << B
    LSR,    -- Logical shift right   RES = A >> B
    RL,     -- rotate left           RES = A rl(B)
    RR,     -- rotate right          RES = A rr(B)
    GEQ,    -- greater then equal    RES = A >= B
    LEQ,    -- less then equal       RES = A <= B
    NEQ     -- not equal             RES = A != B
  );

end package alu_pkg;
