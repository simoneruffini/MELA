--------------------------------------------------------------------------------
-- Engineer: Simone Ruffini [simone.ruffini@studenti.polito.it]
--
-- Create Date:     Wed Mar 30 10:56:52 PM CEST 2022
-- Design Name:     GP
-- Module Name:     GP.vhd
-- Project Name:    P4 adder
-- Description:     Group Propagate Unit
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

entity GP is
  port (
    P_CURRENT   : in    std_logic;
    P_PREV      : in    std_logic;
    P           : out   std_logic
  );
end entity GP;

------------------------------------------------------------- ARCHITECTURE

architecture BEHAVIORAL of GP is

----------------------------------------------------------- CONSTANTS 1

----------------------------------------------------------- TYPES

----------------------------------------------------------- FUNCTIONS

----------------------------------------------------------- CONSTANTS 2

----------------------------------------------------------- SIGNALS

begin

  P <= P_CURRENT and P_PREV;

end architecture BEHAVIORAL;

CONFIGURATION CFG_GP_BEHAVIORAL OF GP IS
 FOR BEHAVIORAL
 END FOR;
END CFG_GP_BEHAVIORAL;

