--------------------------------------------------------------------------------
-- Engineer: Simone Ruffini [simone.ruffini@studenti.polito.it,simone.ruffini@tutanota.com]
--           Matteo Bonora  [matteo.bonora@studenti.polito.it]
--
-- Create Date:     Sat 23 16:09:34 PM CEST 2022
-- Design Name:     fetch
-- Module Name:     fetch.vhd
-- Project Name:    DLX
-- Description:     Fetch pipeline stage
--
-- Revision:
-- Revision 00 - Matteo Bonora
--  * Created
-- Additional Comments:
--
--------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.comm_pkg.all;

entity fetch is
  generic (
    addr_w : integer := 32;
    data_w : integer := 32
  );
  port (
    ck        : in    std_logic;
    ctrl_word : in    controlword_t(CW_SIZE - 1 downto 0);
    -- Inputs
    pci         : in    std_logic_vector(addr_w - 1 downto 0);
    instruction : in    std_logic_vector(data_w - 1 downto 0);
    -- Outputs
    pco : out   std_logic_vector(addr_w - 1 downto 0);
    ir  : out   std_logic_vector(data_w - 1 downto 0)
  );
end entity fetch;

architecture behavioural of fetch is

begin

  -- Instruction passthrough
  ir_reg : process (ck, instruction) is
  begin

    if (rising_edge (ck)) then
      ir <= instruction;
    end if;

  end process ir_reg;

  -- Increase program counter
  pc_increase : process (ck, pci) is
  begin

    if (rising_edge(ck)) then
      pco <= std_logic_vector(unsigned(pci) + 4);
    end if;

  end process pc_increase;

end architecture behavioural;
