--------------------------------------------------------------------------------
-- Engineer: Simone Ruffini [simone.ruffini@studenti.polito.it]
--
-- Create Date:     Wed Mar 30 10:56:52 PM CEST 2022
-- Design Name:     GG
-- Module Name:     GG.vhd
-- Project Name:    P4 adder
-- Description:     Group Generate Unit
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

entity GG is
  port (
    G_CURRENT   : in    std_logic;
    P_CURRENT   : in    std_logic;
    G_PREV      : in    std_logic;
    G           : out   std_logic
  );
end entity GG;

------------------------------------------------------------- ARCHITECTURE

architecture BEHAVIOURAL of GG is

----------------------------------------------------------- CONSTANTS 1

----------------------------------------------------------- TYPES

----------------------------------------------------------- FUNCTIONS

----------------------------------------------------------- CONSTANTS 2

----------------------------------------------------------- SIGNALS

begin

  G <= (G_CURRENT or (P_CURRENT and G_PREV));

end architecture BEHAVIOURAL;

CONFIGURATION CFG_GG_BEHAVIOURAL OF GG IS
 FOR BEHAVIOURAL
 END FOR;
END CFG_GG_BEHAVIOURAL;
