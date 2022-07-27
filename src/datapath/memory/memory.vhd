--------------------------------------------------------------------------------
-- Engineer: Simone Ruffini [simone.ruffini@studenti.polito.it,simone.ruffini@tutanota.com]
--           Matteo Bonora  [matteo.bonora@studenti.polito.it]
--
-- Create Date:     Sat 24 09:54:43 PM CEST 2022
-- Design Name:     Memory access
-- Module Name:     memory.vhd
-- Project Name:    DLX
-- Description:     Memory access pipeline stage
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

entity memory is
  generic (
    addr_w : integer := 32;
    data_w : integer := 32
  );
  port (
    ck        : in    std_logic;
    ctrl_word    : in    controlword_t(cw_signals_type'POS(CW_SIZE) - 1 downto 0);
    -- Inputs
    pci     : in    std_logic_vector(addr_w - 1 downto 0);
    cond    : in    std_logic;
    alu_out : in    std_logic_vector(data_w - 1 downto 0);
    me      : in    std_logic_vector(data_w - 1 downto 0);
    -- Outputs
    pco : out   std_logic_vector(addr_w - 1 downto 0);
    lmd : out   std_logic_vector(data_w - 1 downto 0)
  );
end entity memory;

architecture BEHAVIORAL of memory is

begin

end architecture BEHAVIORAL;

configuration CFG_MEMORY_BEHAVIORAL of memory is
  for BEHAVIORAL
  end for;
end CFG_MEMORY_BEHAVIORAL;
