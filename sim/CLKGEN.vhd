--------------------------------------------------------------------------------
-- Engineer: Simone Ruffini [simone.ruffini@tutanota.com]
--
-- Create Date:   Mon Jun 07 18:38 2021
-- Design Name:   CLKGEN
-- Module Name:   CLKGEN.vhd - BEHAVIOURAL
-- Project Name:  COMMON
-- Description:   Gneration of a clk signal, used for testbench purposes
--
-- Revision:
-- Revision 00 - Simone Ruffini
-- * File Created
-- Additional Comments:
--  The time base is internally expressed in ns
--------------------------------------------------------------------------------

----------------------------- PACKAGES/LIBRARIES -------------------------------

library IEEE;
  use IEEE.std_logic_1164.all;

----------------------------- ENTITY -------------------------------------------

entity CLKGEN is
  generic (
    CLK_HZ        : natural := 100000000
  );
  port (
    CLK        : out   std_logic
  );
end entity CLKGEN;

----------------------------- ARCHITECTURE -------------------------------------

architecture BEHAVIOURAL of CLKGEN is

  --########################### CONSTANTS ######################################
  constant C_CLOCK_PERIOD_NS : time := (1e9 / CLK_HZ) * 1 ns;

  --########################### SIGNALS ########################################
  signal clk_s               : std_logic := '0';

  --########################### ARCHITECTURE BEGIN #############################

begin

  --########################## PROCESSES #######################################

  -- Clock generator (50% duty cycle)
  P_CLK_GEN : process is
  begin

    clk_s <= '0';
    wait for C_CLOCK_PERIOD_NS / 2;
    clk_s <= '1';
    wait for C_CLOCK_PERIOD_NS / 2;

  end process P_CLK_GEN;

  CLK <= clk_s;

end architecture BEHAVIOURAL;

