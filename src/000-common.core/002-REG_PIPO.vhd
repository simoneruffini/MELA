--------------------------------------------------------------------------------
-- Engineer: Simone Ruffini [simone.ruffini@studenti.polito.it,
--                           simone.ruffini@tutanota.com]
--           Matteo Bonora  [matteo.bonora@studenti.polito.it]
--
-- Create Date:   Tue Sep 27 12:40:53 PM CEST 2022
-- Module Name:   REG_PIPO
-- Project Name:  MELA
-- Description:   Generic Register Parallell In Parallel Out
--
-- Revision:
-- Revision 00 - Simone Ruffini
--  * Created
-- Additional Comments:
--  If the register can be initialized by the INIT active high signal, in such case
--  the register will take the value defined in INIT_VAL.
--  The initialization function is overridden by the EN signal, if EN is on the
--  NOTE: generics are unconstrained because of limitation of the syntehsis tool
--        their size is DATA_W bit
--------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

------------------------------------------------------------- ENTITY

entity REG_PIPO is
  generic (
    DATA_W       : integer;            -- Data width of the register
    INIT_VAL     : std_logic_vector;   -- init value synchcronous (DATA_W - 1 downto 0);
    RST_INIT_VAL : std_logic_vector    -- value at reset          (DATA_W - 1 downto 0)
  );
  port (
    CLK    : in    std_logic;                             -- Clock Signal (rising-edge trigger)
    RST_AN : in    std_logic;                             -- Reset Signal: Asyncronous Active Low (Negative)

    EN     : in    std_logic;                             -- Enable signal, active low, synch, priority on INIT
    INIT   : in    std_logic;                             -- Initialize signal, acitve high, synch
    DIN    : in    std_logic_vector(DATA_W - 1 downto 0); -- Data Input signal
    DOUT   : out   std_logic_vector(DATA_W - 1 downto 0)  -- Data Output Signal
  );
end entity REG_PIPO;

------------------------------------------------------------- ARCHITECTURE: BEHAV_WITH_EN
-- THE INIT SIGNAL IS NOT USED
--

architecture BEHAV_WITH_EN of REG_PIPO is

  ----------------------------------------------------------- CONSTANTS 1

  ----------------------------------------------------------- TYPES

  ----------------------------------------------------------- FUNCTIONS

  ----------------------------------------------------------- CONSTANTS 2

  ----------------------------------------------------------- SIGNALS

  signal reg_mem : std_logic_vector(DATA_W - 1 downto 0);

begin

  ----------------------------------------------------------- ENTITY DEFINITION

  ----------------------------------------------------------- COMBINATORIAL

  DOUT <= reg_mem;
  ----------------------------------------------------------- PROCESSES
  P_MEM : process (CLK, RST_AN) is
  begin

    if (RST_AN = '0') then
      reg_mem <= (others => '0');
    elsif (CLK'event and CLK = '1') then
      reg_mem <= reg_mem; -- Inference a memory

      if (EN = '1') then
        reg_mem <= DIN;   -- Update the value with the one on the rising edge
      end if;
    end if;

  end process P_MEM;

end architecture BEHAV_WITH_EN;

------------------------------------------------------------- ARCHITECTURE: BEHAV_WITH_EN_RSTINIT
-- THE INIT SIGNAL IS NOT USED
--

architecture BEHAV_WITH_EN_RSTINIT of REG_PIPO is

  ----------------------------------------------------------- CONSTANTS 1

  ----------------------------------------------------------- TYPES

  ----------------------------------------------------------- FUNCTIONS

  ----------------------------------------------------------- CONSTANTS 2

  ----------------------------------------------------------- SIGNALS

  signal reg_mem : std_logic_vector(DATA_W - 1 downto 0);

begin

  ----------------------------------------------------------- ENTITY DEFINITION

  ----------------------------------------------------------- COMBINATORIAL

  DOUT <= reg_mem;
  ----------------------------------------------------------- PROCESSES
  P_MEM : process (CLK, RST_AN) is
  begin

    if (RST_AN = '0') then
      reg_mem <= RST_INIT_VAL;
    elsif (CLK'event and CLK = '1') then
      reg_mem <= reg_mem; -- Inference a memory

      if (EN = '1') then
        reg_mem <= DIN;   -- Update the value with the one on the rising edge
      end if;
    end if;

  end process P_MEM;

end architecture BEHAV_WITH_EN_RSTINIT;

------------------------------------------------------------- ARCHITECTURE: BEHAV_WITH_EN_INIT
-- THE INIT SIGNAL IS USED SYNCH.
--

architecture BEHAV_WITH_EN_INIT of REG_PIPO is

  ----------------------------------------------------------- CONSTANTS 1

  ----------------------------------------------------------- TYPES

  ----------------------------------------------------------- FUNCTIONS

  ----------------------------------------------------------- CONSTANTS 2

  ----------------------------------------------------------- SIGNALS

  signal reg_mem : std_logic_vector(DATA_W - 1 downto 0);

begin

  ----------------------------------------------------------- ENTITY DEFINITION

  ----------------------------------------------------------- COMBINATORIAL

  DOUT <= reg_mem;
  ----------------------------------------------------------- PROCESSES
  P_MEM : process (CLK, RST_AN) is
  begin

    if (RST_AN = '0') then
      reg_mem <= (others => '0');
    elsif (CLK'event and CLK = '1') then
      reg_mem <= reg_mem; -- Inference a memory

      if (EN = '1') then
        reg_mem <= DIN;   -- Update the value with the one on the rising edge

        -- If init is on then overwrite the value saved in memory and hence the output
        if (INIT = '1') then
          reg_mem <= INIT_VAL;
        end if;
      end if;
    end if;

  end process P_MEM;

end architecture BEHAV_WITH_EN_INIT;

------------------------------------------------------------- ARCHITECTURE: BEHAV_WITH_EN_RSTINIT
-- THE INIT SIGNAL IS USED SYNCH.
--

architecture BEHAV_WITH_EN_INIT_RSTINIT of REG_PIPO is

  ----------------------------------------------------------- CONSTANTS 1

  ----------------------------------------------------------- TYPES

  ----------------------------------------------------------- FUNCTIONS

  ----------------------------------------------------------- CONSTANTS 2

  ----------------------------------------------------------- SIGNALS

  signal reg_mem : std_logic_vector(DATA_W - 1 downto 0);

begin

  ----------------------------------------------------------- ENTITY DEFINITION

  ----------------------------------------------------------- COMBINATORIAL

  DOUT <= reg_mem;
  ----------------------------------------------------------- PROCESSES
  P_MEM : process (CLK, RST_AN) is
  begin

    if (RST_AN = '0') then
      reg_mem <= RST_INIT_VAL;
    elsif (CLK'event and CLK = '1') then
      reg_mem <= reg_mem; -- Inference a memory

      if (EN = '1') then
        reg_mem <= DIN;   -- Update the value with the one on the rising edge

        -- If init is on then overwrite the value saved in memory and hence the output
        if (INIT = '1') then
          reg_mem <= INIT_VAL;
        end if;
      end if;
    end if;

  end process P_MEM;

end architecture BEHAV_WITH_EN_INIT_RSTINIT;

configuration CFG_REG_PIPO_BEHAV_WITH_EN of REG_PIPO is
 for BEHAV_WITH_EN
 end for;
end CFG_REG_PIPO_BEHAV_WITH_EN;

configuration CFG_REG_PIPO_BEHAV_WITH_EN_RSTINIT of REG_PIPO is
  for BEHAV_WITH_EN_RSTINIT 
  end for;
end configuration CFG_REG_PIPO_BEHAV_WITH_EN_RSTINIT;

configuration CFG_REG_PIPO_BEHAV_WITH_EN_INIT of REG_PIPO is
  for BEHAV_WITH_EN_INIT
  end for;
end configuration CFG_REG_PIPO_BEHAV_WITH_EN_INIT;

configuration CFG_REG_PIPO_BEHAV_WITH_EN_INIT_RSTINIT of REG_PIPO is
  for BEHAV_WITH_EN_INIT_RSTINIT
  end for;
end configuration CFG_REG_PIPO_BEHAV_WITH_EN_INIT_RSTINIT;

