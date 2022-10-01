--------------------------------------------------------------------------------
-- Engineer: Simone Ruffini [simone.ruffini@studenti.polito.it,simone.ruffini@tutanota.com]
--           Matteo Bonora  [matteo.bonora@studenti.polito.it]
--
-- Create Date:     Mon Sep 26 03:57:07 PM CEST 2022
-- Module Name:     DMEM
-- Project Name:    DLX
-- Description:     Data Memory, 1 shared read write port, 1 data in port
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

entity DMEM is
  generic (
    ADDR_W : integer; -- Data memory addres port bit width
    DATA_W : integer  -- Data memory data port bit width
  );
  port (
    CLK    : in    std_logic;                             -- Clock Signal (rising-edge trigger)
    RST_AN : in    std_logic;                             -- Reset Signal: Asyncronous Active Low (Negative)
    RWADDR : in    std_logic_vector(ADDR_W - 1 downto 0); -- Read Write Address Port
    WEN    : in    std_logic;                             -- Write Enable port, active high
    DIN    : in    std_logic_vector(DATA_W - 1 downto 0); -- Data Input Port (used in writes)
    DOUT   : out   std_logic_vector(DATA_W - 1 downto 0)  -- Data Output Port (output of a read)
  );
end entity DMEM;

architecture BEHAVIOURAL of DMEM is

  type mem_type is array ((2 ** ADDR_W) - 1 downto 0) of std_logic_vector(DATA_W - 1 downto 0);

  signal mem : mem_type;

begin

  P_READ : process (CLK, RST_AN) is
  begin

    if (RST_AN = '1') then
      if (CLK = '1' and CLK'event) then
        DOUT <= mem(to_integer(unsigned(RWADDR)));
      end if;
    else
      DOUT <= (others => '0');
    end if;

  end process P_READ;

  P_WRITE : process (CLK) is
  begin

    if (WEN = '1' and CLK = '1' and CLK'event) then
      mem(to_integer(unsigned(RWADDR))) <= DIN;
    end if;

  end process P_WRITE;

end architecture BEHAVIOURAL;
