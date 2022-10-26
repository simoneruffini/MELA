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
--  2 read ports, 1 write port, Synchronous falling edge write, asynchronous read
--  NOTE: may not work correctly if ADDR_W >= 32
--------------------------------------------------------------------------------

------------------------------------------------------------- PACKAGES/LIBRARIES

library IEEE;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

------------------------------------------------------------- ENTITY

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

------------------------------------------------------------- ARCHITECTURE

architecture BEHAVIOURAL of RF is

  ----------------------------------------------------------- CONSTANTS 1

  ----------------------------------------------------------- TYPES

  -- NOTE: this subtipe is dangerous if ADDR_W >= 32, we have overflow and the
  --       range doesn't work, this is a VHDL limitation and no betters
  --       solutions are available
  subtype reg_addr_range is natural range 0 to ((2 ** ADDR_W) - 1); -- using natural type

  type reg_array is array (reg_addr_range) of std_logic_vector(DATA_W - 1 downto 0);

  ----------------------------------------------------------- FUNCTIONS

  -- Initialize register file
  -- NOTE reg(0) is always 0 therefore start_number will be assigned to reg(1)

  function init_reg (start_number: integer; step: integer) return reg_array is

    variable ret : reg_array;
    variable cnt : integer := start_number;
    variable i   : integer := 1;

  begin

    ret(0) := (others => '0');

    while i < 2 ** ADDR_W loop

      ret(i) := std_logic_vector(to_unsigned(cnt, DATA_W));
      cnt    := cnt + step;
      i      := i + 1;

    end loop;

    return ret;

  end function init_reg;

  ----------------------------------------------------------- CONSTANTS 2

  ----------------------------------------------------------- SIGNALS

  signal registers : reg_array;

begin

  ----------------------------------------------------------- ENTITY DEFINITION

  ----------------------------------------------------------- COMBINATORIAL

  ----------------------------------------------------------- PROCESSES

  -- write your RF code

  P_WRITE : process (RST_AN, CLK) is
  begin

    if (RST_AN = '0') then
      -- reset signals
      for i in reg_array'range loop

        registers(i) <= (OTHERS => '0');

      end loop;

    elsif (CLK'EVENT and CLK = '1') then -- faling edge
      if (ENABLE = '1') then
        -- writing
        if (WR = '1') then
          registers(to_integer(unsigned(ADD_WR))) <= DATAIN;
        end if;
      end if;
    end if;

  end process P_WRITE;

  P_READ : process (ENABLE, ADD_RD1, ADD_RD2, RD1, RD2) is
  begin

    if (RD1 = '1' and ENABLE = '1') then
      OUT1 <= registers(to_integer(unsigned(ADD_RD1)));
      if (unsigned(ADD_RD1) = 0) then
        OUT1 <= (others => '0');
      end if;
    end if;

    if (RD2 = '1' and ENABLE = '1') then
      OUT2 <= registers(to_integer(unsigned(ADD_RD2)));
      if (unsigned(ADD_RD2) = 0) then
        OUT2 <= (others => '0');
      end if;
    end if;

  end process P_READ;

end architecture BEHAVIOURAL;

configuration CFG_RF_BEHAV of RF is
  for BEHAVIOURAL
  end for;
end configuration;
