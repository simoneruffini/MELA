--------------------------------------------------------------------------------
-- Engineer: Simone Ruffini [simone.ruffini@tutanota.com]
-- 
-- Create Date:     Wed Apr  6 10:53:55 CEST 2022
-- Design Name:     RCA
-- Module Name:     rca.vhd
-- Project Name:    
-- Description:     
--                  
--
-- Revision:
-- Revision 00 - Simone Ruffini
--  * File Created
-- Additional Comments:
--
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;
--USE work.constants.ALL;

ENTITY RCA IS
  GENERIC (
    NBIT : INTEGER := 32 -- NumBit
  );
  PORT (
    A : IN STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
    B : IN STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
    Ci : IN STD_LOGIC;
    S : OUT STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
    Co : OUT STD_LOGIC
  );
END RCA;

ARCHITECTURE BEHAVIORAL OF RCA IS
  SIGNAL num1 : unsigned(A'length - 1 DOWNTO 0);
  SIGNAL num2 : unsigned(B'length - 1 DOWNTO 0);
  SIGNAL res : unsigned(S'length DOWNTO 0); -- one extra bit
BEGIN
  num1 <= unsigned(A);
  num2 <= unsigned(B);
  res <= ('0' & num1) + ('0' & num2) + resize('0' & Ci, res'length);

  Co <= res(res'length - 1);
  S <= STD_LOGIC_VECTOR(res(NBIT - 1 DOWNTO 0));

  --  S <= (A + B) after DRCAS;

END BEHAVIORAL;

CONFIGURATION CFG_RCA_BEHAVIORAL OF RCA IS
  FOR BEHAVIORAL
  END FOR;
END CFG_RCA_BEHAVIORAL;
