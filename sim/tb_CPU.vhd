--------------------------------------------------------------------------------
-- Engineer: Simone Ruffini [simone.ruffini@studenti.polito.it,simone.ruffini@tutanota.com]
--
-- Create Date:     Thu Oct 13 10:06:06 PM CEST 2022
-- Module Name:     TB_CPU
-- Project Name:    DLX
-- Description:     testbench for Datapath
--
-- Revision:
-- Revision 00 - Simone Ruffini
--  * Created
-- Additional Comments:
--
--------------------------------------------------------------------------------

------------------------------------------------------------- PACKAGES/LIBRARIES

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.dlx_pkg.all;
  use work.alu_pkg.all;
  use work.dlx_isa_enc_pkg.all;

library std;
  use std.env.finish;
------------------------------------------------------------- ENTITY

entity TB_CPU is
-- port (
--);
end entity TB_CPU;

------------------------------------------------------------- ARCHITECTURE

architecture BEHAVIOURAL of TB_CPU is

  ----------------------------------------------------------- CONSTANTS 1
  constant C_CLK_FREQ_HZ            : natural := 1000000; -- 1MHz
  constant C_CLK_PERIOD_NS          : time := 1e09 / C_CLK_FREQ_HZ * 1 ns;
  constant C_0S                     : std_logic_vector(C_ARCH_WORD_W - 1 downto 0) := (others => '0');

  ----------------------------------------------------------- TYPES
  

  ----------------------------------------------------------- FUNCTIONS
  
  ----------------------------------------------------------- CONSTANTS 2

  ----------------------------------------------------------- SIGNALS

  signal clk                        : std_logic;
  signal rst_an                     : std_logic;
  signal instr                      : std_logic_vector(C_ARCH_WORD_W-1 downto 0);
  signal fetch : instr_t;
  signal decode: instr_t;
  signal execute: instr_t;
  signal memory: instr_t;
  signal writeback: instr_t;

  -- this needs to be in the top level
  signal assertion_test_output      : natural := dlx_pkg_check_assertions;


begin

  ----------------------------------------------------------- ENTITY DEFINITION
  U_CLKGEN : entity work.clkgen
    generic map (
      CLK_HZ => C_CLK_FREQ_HZ
    )
    port map (
      CLK => clk
    );

  U_CPU : entity work.cpu(BEHAVIOURAL)
    port map (
      CLK    => clk,
      RST_AN => rst_an,
      -- DEBUG
      INSTR => instr
    );

  ----------------------------------------------------------- COMBINATORIAL

  ----------------------------------------------------------- PROCESSES
  P_FETCH : process(instr) is 
  begin
      fetch <= print_instr(instr);
  end process P_FETCH;

  P_PIPELINE_STAGE_PRINT: process (CLK,RST_AN) is 
  begin
    if(RST_AN = '0') then
        decode    <= INSTR_NOT_FOUNDx;
        execute   <= INSTR_NOT_FOUNDx;
        memory    <= INSTR_NOT_FOUNDx;
        writeback <= INSTR_NOT_FOUNDx;
    elsif(rising_edge(CLK)) then
        decode <= fetch;
        execute <= decode;
        memory <= execute;
        writeback <= memory;
    end if;
  end process;

  -- simulation process
  P_SIM : process is
  begin

    rst_an <= '0';
    wait for 5 * C_CLK_PERIOD_NS;
    rst_an <= '1';

    wait;

  end process P_SIM;

end architecture BEHAVIOURAL;
