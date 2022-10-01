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
    ADDR_W : integer; -- Instruction memory addres port bit width
    DATA_W : integer  -- Instruction memory data port bit width
  );
  port (
    CLK    : in    std_logic;                             -- Clock Signal (rising-edge trigger)
    RST_AN : in    std_logic;                             -- Reset Signal: Asyncronous Active Low (Negative)
    RADDR  : in    std_logic_vector(ADDR_W - 1 downto 0); -- Read Address Port
    DOUT   : out   std_logic_vector(DATA_W - 1 downto 0)  -- Data Output Port
  );
end entity IMEM;

architecture BEHAVIOURAL of IMEM is

  type mem_type is array ((2 ** ADDR_W) - 1 downto 0) of std_logic_vector(DATA_W - 1 downto 0);

  signal mem   : mem_type;
  signal d_out : std_logic_vector(DATA_W - 1 downto 0);

begin

  DOUT <= d_out;

  P_READ : process (CLK) is
  begin

    if (CLK = '1' and CLK'event) then
      d_out <= mem(to_integer(unsigned(RADDR)));
    end if;

  end process P_READ;

  P_RESET : process (RST_AN) is
  begin

    if (RST_AN = '1') then
      d_out <= (others => 'Z');
    end if;

  end process P_RESET;

end architecture BEHAVIOURAL;
