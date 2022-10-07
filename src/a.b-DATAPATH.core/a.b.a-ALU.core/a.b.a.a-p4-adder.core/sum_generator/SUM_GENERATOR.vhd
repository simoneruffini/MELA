--------------------------------------------------------------------------------
-- Engineer: Matteo Bonora  [matteo.bonora@studenti.polito.it]
--           Simone Ruffini [simone.ruffini@studenti.polito.it]
-- 
-- Create Date:     Mon Mar 21 17:00:00 CET 2022
-- Design Name:     Sum Generator
-- Module Name:     sum_generator.vhd
-- Project Name:    P4 adder
-- Description:     Carry Select-like sum generator
--                  
--
-- Revision:
-- Revision 00 - Matteo Bonora
--  * File Created
-- Revision 01 - Simone Ruffini
--  * Fix carry in and carry out
-- Additional Comments:
-- 
--------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY SUM_GENERATOR IS
  GENERIC (
    NBIT_PER_BLOCK : INTEGER := 4;
    NBLOCKS        : INTEGER := 8
  );
  PORT (
    A  : IN STD_LOGIC_VECTOR(NBIT_PER_BLOCK * NBLOCKS - 1 DOWNTO 0);
    B  : IN STD_LOGIC_VECTOR(NBIT_PER_BLOCK * NBLOCKS - 1 DOWNTO 0);
    Ci : IN STD_LOGIC_VECTOR(NBLOCKS - 1 DOWNTO 0);
    S  : OUT STD_LOGIC_VECTOR(NBIT_PER_BLOCK * NBLOCKS - 1 DOWNTO 0)
  );
END ENTITY;

ARCHITECTURE BEHAVIORAL OF SUM_GENERATOR IS


  COMPONENT CSB
    GENERIC (
      NBIT : INTEGER 
    );
    PORT (
      A   : IN STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
      B   : IN STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
      Cin : IN STD_LOGIC;
      S   : OUT STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
      Co  : OUT STD_LOGIC
    );
  END COMPONENT;

BEGIN

  GEN_CSB : FOR I IN 1 TO NBLOCKS GENERATE
    U_CSB : CSB
      GENERIC MAP (NBIT => NBIT_PER_BLOCK)
      PORT MAP(
        A   => A((I * NBIT_PER_BLOCK)-1 DOWNTO (I - 1) * NBIT_PER_BLOCK), 
        B   => B((I * NBIT_PER_BLOCK)-1 DOWNTO (I - 1) * NBIT_PER_BLOCK), 
        Cin => Ci(I - 1), 
        S   => S((I * NBIT_PER_BLOCK)-1 DOWNTO (I - 1) * NBIT_PER_BLOCK), 
        Co  => open
      );
  END GENERATE;

END BEHAVIORAL;

CONFIGURATION CFG_SUM_GENERATOR_STRUCTURAL OF SUM_GENERATOR IS
  FOR BEHAVIORAL
    FOR GEN_CSB
      FOR ALL : CSB
        USE CONFIGURATION WORK.CFG_CSB_BEHAVIORAL;
      END FOR;
    END FOR;
  END FOR;
END CFG_SUM_GENERATOR_STRUCTURAL;
