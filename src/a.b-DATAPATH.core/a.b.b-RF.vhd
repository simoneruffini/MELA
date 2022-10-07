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
--  first implementation
-- Revision 01 - Simone Ruffini
--  changed behavioural architecture with asynchronoud active low reset
-- Additional Comments:
--
--------------------------------------------------------------------------------

library IEEE;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

entity RF is
  generic (
    ADDR_W : integer := integer(log2(32.0)); -- address signal width
    DATA_W : integer := 64                   -- data input/output signal width
  );
  port (
    CLK     : in    std_logic;
    RST_AN  : in    std_logic;
    ENABLE  : in    std_logic;
    RD1     : in    std_logic;
    RD2     : in    std_logic;
    WR      : in    std_logic;
    ADD_WR  : in    std_logic_vector(ADDR_W - 1 downto 0);
    ADD_RD1 : in    std_logic_vector(ADDR_W - 1 downto 0);
    ADD_RD2 : in    std_logic_vector(ADDR_W - 1 downto 0);
    DATAIN  : in    std_logic_vector(DATA_W - 1 downto 0);
    OUT1    : out   std_logic_vector(DATA_W - 1 downto 0);
    OUT2    : out   std_logic_vector(DATA_W - 1 downto 0)
  );
end entity RF;

architecture BEHAVIOURAL of RF is

  subtype reg_addr_range is natural range 0 to ((2 ** ADDR_W) - 1); -- using natural type

  type reg_array is array (reg_addr_range) of std_logic_vector(DATA_W - 1 downto 0);

  signal registers : reg_array;

begin

  -- write your RF code

  REG : process (RST_AN, CLK) is
  begin

    if (RST_AN = '1') then
      -- reset signals
      for i IN reg_array'range loop

        registers(i) <= (OTHERS => '0');

      end loop;

    elsif (CLK'EVENT and CLK= '1') then
      if (ENABLE = '1') then
        -- writing
        if (WR = '1') then
          registers(to_integer(unsigned(ADD_WR))) <= DATAIN;
        end if;
        -- reading out2
        if (RD2 = '1') then
        end if;
      end if;
    end if;

  end process REG;

  READ : process (RD1, RD2) is
  begin

    if (RD1 = '1' and ENABLE = '1') then
      if (unsigned(ADD_RD1) = '0') then
        OUT1 <= (others => 0);
      end if;
      OUT1 <= registers(to_integer(unsigned(ADD_RD1)));
    end if;

    if (RD2 = '1' and ENABLE = '1') then
      if (unsigned(ADD_RD2) = '0') then
        OUT2 <= (others => 0);
      end if;
      OUT2 <= registers(to_integer(unsigned(ADD_RD2)));
    end if;

  end process READ;

end architecture BEHAVIOURAL;

-- configuration CFG_RF_BEHAVIOURAL of RF is
--  for Behavioural
--  end for;
-- end configuration;
