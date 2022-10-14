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

------------------------------------------------------------- PACKAGES/LIBRARIES

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

------------------------------------------------------------- ENTITY

entity PG_PRIM is
  port (
    A       : in    std_logic;
    B       : in    std_logic;
    G       : out   std_logic;
    P       : out   std_logic
  );
end entity PG_PRIM;

------------------------------------------------------------- ARCHITECTURE

architecture BEHAVIORAL of PG_PRIM is

----------------------------------------------------------- CONSTANTS 1

----------------------------------------------------------- TYPES

----------------------------------------------------------- FUNCTIONS

----------------------------------------------------------- CONSTANTS 2

----------------------------------------------------------- SIGNALS

begin

  G <= A and B;
  P <= A xor B;

end architecture BEHAVIORAL;

architecture BEHAVIORAL2 of PG_PRIM is

begin

  G <= A and B;
  P <= A or B;

end architecture BEHAVIORAL2;

CONFIGURATION CFG_PG_PRIM_BEHAVIORAL_XOR OF PG_PRIM IS
 FOR BEHAVIORAL
 END FOR;
END CFG_PG_PRIM_BEHAVIORAL_XOR;

CONFIGURATION CFG_PG_PRIM_BEHAVIORAL_OR OF PG_PRIM IS
 FOR BEHAVIORAL2
 END FOR;
END CFG_PG_PRIM_BEHAVIORAL_OR;
