--------------------------------------------------------------------------------
-- Engineer: Simone Ruffini [simone.ruffini@studenti.polito.it,simone.ruffini@tutanota.com]
--           Matteo Bonora  [matteo.bonora@studenti.polito.it]
--
-- Create Date:     Mon Sep 26 03:57:07 PM CEST 2022
-- Module Name:     DMEM
-- Project Name:    DLX
-- Description:     Data Memory
--
-- Revision:
-- Revision 00 - Simone Ruffini
--  * Created
-- Additional Comments:
--  1 shared read write port, 1 data in port, asynchronous, word adressed
--  NOTE: may not work correctly if ADDR_W >= 32
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

entity DMEM is
  generic (
    ADDR_W : integer; -- Data memory addres port bit width
    DATA_W : integer  -- Data memory data port bit width
  );
  port (
    RST_AN : in    std_logic;                             -- Reset Signal: Asyncronous Active Low (Negative)
    RWADDR : in    std_logic_vector(ADDR_W - 1 downto 0); -- Read Write Address Port
    WEN    : in    std_logic;                             -- Write Enable port, active high
    DIN    : in    std_logic_vector(DATA_W - 1 downto 0); -- Data Input Port (used in writes)
    DOUT   : out   std_logic_vector(DATA_W - 1 downto 0)  -- Data Output Port (output of a read)
  );
end entity DMEM;

------------------------------------------------------------- ARCHITECTURE

architecture BEHAVIOURAL of DMEM is

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

  signal mem              : mem_type := initramfromfile("../src/00-common.core/004-DMEM_INIT_FILE.txt");

  signal truncated_rwaddr : std_logic_vector((ADDR_W - 2) - 1 downto 0); -- Word-addressed read address

begin

  ----------------------------------------------------------- ENTITY DEFINITION

  ----------------------------------------------------------- COMBINATORIAL
  -- this memory doesn't have byte adressing
  truncated_rwaddr <= RWADDR(RWADDR'length-1 downto 2);

  P_WRITE_AND_READ : process (RST_AN, DIN, truncated_rwaddr, WEN) is
  begin

    if (RST_AN = '0') then
      DOUT <= (others => '0');
    else
      DOUT <= mem(to_integer(unsigned(truncated_rwaddr)));

      if (WEN = '1') then
        mem(to_integer(unsigned(truncated_rwaddr))) <= DIN;
        DOUT                                        <= DIN; -- do not infer latch just propagate input
      end if;
    end if;

  end process P_WRITE_AND_READ;

----------------------------------------------------------- SEQUENTIAL

end architecture BEHAVIOURAL;
