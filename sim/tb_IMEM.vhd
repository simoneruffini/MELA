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
  use ieee.std_logic_textio.all; -- synopsis

library std;
  use std.textio.all;

entity IMEM_TB is
end entity IMEM_TB;

architecture TEST of IMEM_TB is

  signal clk   : std_logic := '0';
  signal rst   : std_logic := '1';
  signal raddr : std_logic_vector(8 - 1 downto 0) := "10101010";
  signal dout  : std_logic_vector(32 - 1 downto 0);

begin

  DIOCA : entity work.imem
    generic map (
      ADDR_W => 8,
      DATA_W => 32
    )
    port map (
    clk,
    rst,
    raddr,
    dout
    );

end architecture TEST;
