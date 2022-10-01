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
  use ieee.std_logic_textio.all; -- synopsis

library work;
  use work.dlx_pkg.all;
  use std.textio.all;

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

  -- Takes 32 hexadecimal values from RamFileName  and returns an array of them
  -- NOTE: values must be 32bit hex

  impure function initramfromfile (RamFileName : in string) return mem_type is

    file     RamFile     : text is in RamFileName;
    variable ramfileline : line;
    variable tmpword     : std_logic_vector(31 downto 0);
    variable ram         : mem_type;

  begin

    for I in 0 to (2 ** ADDR_W) - 1 loop

      readline (RamFile, ramfileline);
      hread(ramfileline, tmpword);
      ram(i) := std_logic_vector(resize(unsigned(tmpword), DATA_W));

    end loop;

    return ram;

  end function;

  signal mem   : mem_type;

begin

  P_READ : process (CLK) is
  begin

    if (RST_AN = '1') then
      if (CLK = '1' and CLK'event) then
        DOUT <= mem(to_integer(unsigned(RADDR)));
      end if;
    else
      DOUT <= (others => '0');
    end if;

  end process P_READ;

end architecture BEHAVIOURAL;
