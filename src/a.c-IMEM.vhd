--------------------------------------------------------------------------------
-- Engineer: Simone Ruffini [simone.ruffini@studenti.polito.it,simone.ruffini@tutanota.com]
--           Matteo Bonora  [matteo.bonora@studenti.polito.it]
--
-- Create Date:     Mon Sep 26 03:57:07 PM CEST 2022
-- Module Name:     IMEM
-- Project Name:    DLX
-- Description:     Instruction Memory, 1 read port
--
-- Revision:
-- Revision 00 - Simone Ruffini
--  * Created
-- Additional Comments:
--
--------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.dlx_pkg.all;

entity IMEM is
  generic (
    ADDR_W  : integer; -- Instruction memory addres port bit width
    DATA_W  : integer  -- Instruction memory data port bit width
  );
  port (
    CLK             : in    std_logic;                             -- Clock Signal (rising-edge trigger)
    RST_AN          : in    std_logic;                             -- Reset Signal: Asyncronous Active Low (Negative)
    RADDR           : in    std_logic_vector(ADDR_W - 1 downto 0); -- Read Address Port
    DOUT            : out   std_logic_vector(DATA_W - 1 downto 0)  -- Data Output Port
  );
end entity IMEM;

architecture BEHAVIOURAL of IMEM is

begin

end architecture BEHAVIOURAL;
