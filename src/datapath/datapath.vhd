--------------------------------------------------------------------------------
-- Engineer: Simone Ruffini [simone.ruffini@studenti.polito.it,simone.ruffini@tutanota.com]
--           Matteo Bonora  [matteo.bonora@studenti.polito.it]
--
-- Create Date:     Sat 23 16:09:34 PM CEST 2022
-- Design Name:     datapath
-- Module Name:     datapath.vhd
-- Project Name:    DLX
-- Description:     DLX datapath
--
-- Revision:
-- Revision 00 - Matteo Bonora
--  * Created
-- Additional Comments:
--
--------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;

library work;
  use work.comm_pkg.all;

entity datapath is
  generic (
    addr_w : integer := 32;
    data_w : integer := 32
  );
  port (
    instruction  : in    std_logic_vector(data_w - 1 downto 0);
    ctrl_word    : in    controlword_t(CW_SIZE - 1 downto 0);
    datapath_out : out   std_logic_vector(data_w - 1 downto 0)
  );
end entity datapath;

architecture BEHAVIORAL of datapath is

begin

end architecture BEHAVIORAL;

configuration CFG_DATAPATH_BEHAVIORAL of datapath is
  for BEHAVIORAL
  end for;
end CFG_DATAPATH_BEHAVIORAL;
