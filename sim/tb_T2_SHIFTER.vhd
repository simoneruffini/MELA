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
-- Revision 00 - Bonora Matteo
--  * Created
-- Additional Comments:
--
--------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library std;

entity T2_SHIFTER_TB is
end entity T2_SHIFTER_TB;

architecture TEST of T2_SHIFTER_TB is

  signal a : std_logic_vector(31 downto 0) := x"00000000";
  signal amount : std_logic_vector(5 downto 0) := "100000";
  signal op : std_logic_vector(1 downto 0):= "10";
  signal s  : std_logic_vector(31 downto 0);

begin

  SHIFTER : entity work.t2_shifter
    generic map (
      DATA_W => 32
    )
    port map (
    a,
    amount,
    op,
    s
    );

-- TEST: process() is

-- end process TEST;

end architecture TEST;
