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
  use work.COMM_PKG.all;

entity datapath is
  generic (
    ADDR_W : integer := 32;
    DATA_W : integer := 32
  );
  port (
    CTRL_WORD : in controlword_t(CW_SIZE-1 downto 0)
  );
end entity datapath;

architecture behavioural of datapath is

begin

end architecture behavioural;
