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
LIBRARY ieee;
    USE ieee.std_logic_1164.ALL;
    USE ieee.numeric_std.ALL;

entity GG is
  port (
    G_current   : IN STD_LOGIC; 
    P_current   : IN STD_LOGIC; 
    G_prev      : IN STD_LOGIC; 
    G           : OUT STD_LOGIC
  );
end GG;

ARCHITECTURE BEHAVIORAL OF GG is 
BEGIN

  G <= ( G_current OR (P_current AND G_prev) );

END ARCHITECTURE BEHAVIORAL;

CONFIGURATION CFG_GG_BEHAVIORAL OF GG IS
  FOR BEHAVIORAL
  END FOR;
END CFG_GG_BEHAVIORAL;
