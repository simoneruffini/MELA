-- This is a 16 bit Linear Feedback Shift Register
library ieee; 
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity LFSR16 is 
  port( 
    CLK : in std_logic; 
    RESET : in std_logic; 
    LD : in std_logic; 
    EN : in std_logic; 
    DIN : in std_logic_vector (0 to 15); 
    PRN : out std_logic_vector (0 to 15); 
    ZERO_D : out std_logic);
end LFSR16;

architecture RTL of LFSR16 is 
  signal t_prn : std_logic_vector(0 to 15);
begin
-- Continuous assignments :
  PRN <= t_prn;
  ZERO_D <= '1' when (t_prn = "0000000000000000") else '0';
-- LFSR process : 
  process(CLK,RESET) 
  begin 
    if RESET='1' then 
      t_prn <= "0000000000000001"; -- load 1 at reset 
    elsif rising_edge (CLK) then 
      if (LD = '1') then -- load a new seed when ld is active 
        t_prn <= DIN; 
      elsif (EN = '1') then -- shift when enabled 
        t_prn(0) <= t_prn(15) xor t_prn(4) xor t_prn(2) xor t_prn(1);
        t_prn(1 to 15) <= t_prn(0 to 14); 
      end if; 
    end if;
  end process;
end RTL;


