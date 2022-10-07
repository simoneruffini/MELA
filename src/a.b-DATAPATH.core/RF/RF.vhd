--------------------------------------------------------------------------------
-- Engineer: Lorenzo Latella [lorenzo.latella@studenti.polito.it]
--           Matteo Bonora  [matteo.bonora@studenti.polito.it]
--           Simone Ruffini [simone.ruffini@studenti.polito.it]
--
-- Create Date:     Thu Apr 21 11:08:45 CEST 2022
-- Design Name:     Register File
-- Module Name:     RF.vhd
-- Project Name:    Register File
-- Description:     Register File base memory
--
--
-- Revision:
-- Revision 00 - Lorenzo Latella
-- first implementation
-- Additional Comments:
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

library WORK;
use WORK.all;

entity RF is
 GENERIC(
    ADDR_W : INTEGER := integer(log2(32.0)); -- address signal width
    DATA_W : INTEGER := 64                   -- data input/output signal width
 );
 port ( 
   CLK     : IN std_logic;
   RESET   : IN std_logic;
   ENABLE  : IN std_logic;
   RD1     : IN std_logic;
   RD2     : IN std_logic;
   WR      : IN std_logic;
   ADD_WR  : IN std_logic_vector(ADDR_W - 1 downto 0);
   ADD_RD1 : IN std_logic_vector(ADDR_W - 1 downto 0);
   ADD_RD2 : IN std_logic_vector(ADDR_W - 1 downto 0);
   DATAIN  : IN std_logic_vector(DATA_W - 1 downto 0);
   OUT1    : OUT std_logic_vector(DATA_W - 1 downto 0);
   OUT2    : OUT std_logic_vector(DATA_W - 1 downto 0)
 );
end RF;

architecture Behavioural of RF is

  -- suggested structures
  subtype REG_ADDR is natural range 0 to ((2 ** ADDR_W) - 1) ; -- using natural type
    type REG_ARRAY is array(REG_ADDR) of std_logic_vector(DATA_W - 1 downto 0); 
    signal REGISTERS : REG_ARRAY; 
    
begin 
  -- write your RF code 

    Reg: PROCESS(CLK)
    BEGIN
        IF CLK'EVENT AND CLK= '1' THEN
            IF RESET = '1' THEN
                --reset signals
                FOR i IN REG_ARRAY'RANGE LOOP 
                    REGISTERS(i) <= (OTHERS => '0');
                END LOOP; 
            ELSIF ENABLE = '1' THEN 
                --writing 
                IF WR = '1' THEN
                    REGISTERS(to_integer(unsigned(ADD_WR))) <= DATAIN;
                END IF;
                --reading out2
                IF RD2 = '1' THEN
                END IF;	 
            END IF;	 
        END IF;
    END PROCESS Reg;

    Read: PROCESS(RD1, RD2)
    BEGIN
        IF RD1 = '1' AND ENABLE = '1' THEN
            IF unsigned(ADD_RD1) = '0' THEN
                OUT1 <= (others => 0);
            END IF;
            OUT1 <= REGISTERS(to_integer(unsigned(ADD_RD1)));
        END IF;

        IF RD2 = '1' AND ENABLE = '1' THEN
            IF unsigned(ADD_RD2) = '0' THEN
                OUT2 <= (others => 0);
            END IF;
            OUT2 <= REGISTERS(to_integer(unsigned(ADD_RD2)));
        END IF;
    END PROCESS Read;

end Behavioural;

----

configuration CFG_RF_BEHAVIOURAL of RF is
  for Behavioural
  end for;
end configuration;
