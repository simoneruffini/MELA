--------------------------------------------------------------------------------
-- Engineer: Simone Ruffini [simone.ruffini@studenti.polito.it]
-- 
-- Create Date:     Thu Mar 24 09:23:06 CET 2022
-- Design Name:     PG_PRIM
-- Module Name:     PG_PRIM.vhd
-- Project Name:    
-- Description:     pg primitive to create the pg network
--                  
--
-- Revision:
-- Revision 00 - Simone Ruffini
--  * Created
-- Additional Comments:
--
--------------------------------------------------------------------------------
LIBRARY ieee;
    USE ieee.std_logic_1164.ALL;
    USE ieee.numeric_std.ALL;

ENTITY PG_PRIM IS
  PORT (
    A       : IN STD_LOGIC;
    B       : IN STD_LOGIC;
    g       : OUT STD_LOGIC;
    p       : OUT STD_LOGIC
  );
END PG_PRIM;

ARCHITECTURE BEHAVIORAL OF PG_PRIM IS
BEGIN

    g <= A AND B;
    p <= A XOR B;

END BEHAVIORAL;

ARCHITECTURE BEHAVIORAL2 OF PG_PRIM IS
BEGIN

    g <= A AND B;
    p <= A OR B;

END BEHAVIORAL2;

CONFIGURATION CFG_PG_PRIM_BEHAVIORAL_XOR OF PG_PRIM IS
  FOR BEHAVIORAL
  END FOR;
END CFG_PG_PRIM_BEHAVIORAL_XOR;

CONFIGURATION CFG_PG_PRIM_BEHAVIORAL_OR OF PG_PRIM IS
  FOR BEHAVIORAL2
  END FOR;
END CFG_PG_PRIM_BEHAVIORAL_OR;
