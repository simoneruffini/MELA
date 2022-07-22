--------------------------------------------------------------------------------
-- Engineer: Matteo Bonora  [matteo.bonora@studenti.polito.it]
--           Simone Ruffini [simone.ruffini@studenti.polito.it]
-- 
-- Create Date:     Mon Mar 22 11:01:00 CET 2022
-- Design Name:     Carry Select Block
-- Module Name:     csb.vhd
-- Project Name:    P4 adder
-- Description:     carry-select block NBIT-adder
--                  
--
-- Revision:
-- Revision 00 - Matteo Bonora
--  * Created
-- Revision 01 - Simone Ruffini
--  * Typos and refactor
-- Additional Comments:
--
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

ENTITY CSB IS
  GENERIC (
    NBIT : INTEGER := 4
  );
  PORT (
    A   : IN STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
    B   : IN STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
    Cin : IN STD_LOGIC;
    S   : OUT STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
    Co  : OUT STD_LOGIC
  );
END CSB;

ARCHITECTURE BEHAVIOURAL OF CSB IS

  COMPONENT RCA IS
    GENERIC (
      NBIT : INTEGER
    );
    PORT (
      A  : IN STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
      B  : IN STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
      Ci : IN STD_LOGIC;
      S  : OUT STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
      Co : OUT STD_LOGIC
    );
  END COMPONENT;
  SIGNAL Co0 : STD_LOGIC;
  SIGNAL Co1 : STD_LOGIC;
  SIGNAL S0 : STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
  SIGNAL S1 : STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
BEGIN

  U_RCA0 : RCA
  GENERIC MAP(NBIT => NBIT)
  PORT MAP(A => A, B => B, Ci => '0', S => S0, Co => Co0);

  U_RCA1 : RCA
  GENERIC MAP(NBIT => NBIT)
  PORT MAP(A => A, B => B, Ci => '1', S => S1, Co => Co1);

  U_MUX : PROCESS (Co0, Co1, Cin, S0, S1)
  BEGIN
    IF (Cin = '1') THEN
      Co <= Co1;
      S <= S1;
    ELSE
      Co <= Co0;
      S <= S0;
    END IF;
  END PROCESS;

END BEHAVIOURAL;

CONFIGURATION CFG_CSB_BEHAVIOURAL OF CSB IS
  FOR BEHAVIOURAL
    FOR ALL : RCA
      USE CONFIGURATION WORK.CFG_RCA_BEHAVIORAL;
    END FOR;
  END FOR;
END CFG_CSB_BEHAVIOURAL;
