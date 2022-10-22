--------------------------------------------------------------------------------
-- Engineer: Simone Ruffini [simone.ruffini@studenti.polito.it,simone.ruffini@tutanota.com]
--           Matteo Bonora  [matteo.bonora@studenti.polito.it]
--
-- Create Date:     Mon Sep 26 03:57:07 PM CEST 2022
-- Module Name:     IMEM
-- Project Name:    DLX
-- Description:     Instruction Memory
--
-- Revision:
-- Revision 00 - Bonora Matteo
--  * Created
-- Additional Comments:
-- 1 read port 1 out port, asynchronous, word adressed
--------------------------------------------------------------------------------

------------------------------------------------------------- PACKAGES/LIBRARIES

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.std_logic_textio.all; -- synopsis

library work;
  use work.vhdl_help_func_pkg.all;

library std;
  use std.textio.all;

------------------------------------------------------------- ENTITY

entity IMEM is
  generic (
    ADDR_W : integer; -- Instruction memory addres port bit width
    DATA_W : integer  -- Instruction memory data port bit width
  );
  port (
    RST_AN : in    std_logic;                             -- Reset Signal: Asyncronous Active Low (Negative)
    RADDR  : in    std_logic_vector(ADDR_W - 1 downto 0); -- Read Address Port
    DOUT   : out   std_logic_vector(DATA_W - 1 downto 0)  -- Data Output Port
  );
end entity IMEM;

------------------------------------------------------------- ARCHITECTURE

architecture BEHAVIOURAL of IMEM is

  ----------------------------------------------------------- CONSTANTS 1

  ----------------------------------------------------------- TYPES

  -- NOTE: this subtipe is dangerous if ADDR_W >= 32, we have overflow and the
  --       range doesn't work, this is a VHDL limitation and no betters
  --       solutions are available

  type mem_type is array ((2 ** ADDR_W) - 1 downto 0) of std_logic_vector(DATA_W - 1 downto 0);

  ----------------------------------------------------------- FUNCTIONS

  -- Takes 32 hexadecimal values from RamFileName  and returns an array of them
  -- NOTE: values must be 32bit hex

  impure function initramfromfile (RamFileName : in string) return mem_type is

    file     RamFile     : text open read_mode is RamFileName;
    variable ramfileline : line;
    variable tmpword     : std_logic_vector(31 downto 0);
    variable ram         : mem_type;
    variable i           : natural := 0;

  begin

    if (vhfp_file_exists(RamFileName)) then

      while not endfile(RamFile) loop

        assert i < (2 ** ADDR_W)
          report "Input file size exceeds memory size"
          severity failure;

        readline (RamFile, ramfileline);
        hread(ramfileline, tmpword);
        ram(i) := std_logic_vector(resize(unsigned(tmpword), DATA_W));

        i := i + 1;

      end loop;

      -- fill remaining with 0s
      while i < mem_type'length loop

        ram(i) := (others => '0');
        i      := i + 1;

      end loop;

    else

      for i in  mem_type'range loop

        ram(i) := (others => '0');

      end loop;

    end if;

    return ram;

  end function;

  ----------------------------------------------------------- CONSTANTS 2

  ----------------------------------------------------------- SIGNALS

  signal mem             : mem_type := initramfromfile("../src/00-common.core/003-IMEM_INIT_FILE.txt");

  signal truncated_raddr : std_logic_vector((ADDR_W - 2) - 1 downto 0); -- Word-addressed read address

begin

  ----------------------------------------------------------- ENTITY DEFINITION

  ----------------------------------------------------------- COMBINATORIAL
  truncated_raddr <= RADDR(RADDR'length-1 downto 2);

  P_READ : process (RST_AN, truncated_raddr) is
  begin

    if (RST_AN = '0') then
      DOUT <= (others => '0');
    else
      DOUT <= mem(to_integer(unsigned(truncated_raddr)));
    end if;

  end process P_READ;

----------------------------------------------------------- SEQUENTIAL

end architecture BEHAVIOURAL;
