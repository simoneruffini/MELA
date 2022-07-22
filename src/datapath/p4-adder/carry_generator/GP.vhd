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
LIBRARY ieee;
    USE ieee.std_logic_1164.ALL;
    USE ieee.numeric_std.ALL;

entity gp is
  port (
    P_current   : IN STD_LOGIC; 
    P_prev      : IN STD_LOGIC; 
    P           : out STD_LOGIC
  );
end gp;

ARCHITECTURE BEHAVIORAL OF GP is 
BEGIN

  P <= P_current AND P_prev;

END ARCHITECTURE BEHAVIORAL;

CONFIGURATION CFG_GP_BEHAVIORAL OF GP IS
  FOR BEHAVIORAL
  END FOR;
END CFG_GP_BEHAVIORAL;

