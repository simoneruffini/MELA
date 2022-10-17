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

architecture BEHAVIORAL of TB_CPU is

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
  signal instr                      : std_logic_vector(C_ARCH_WORD_W - 1 downto 0) := (others => '0');
  signal ctrl_word                  : ctrl_word_t;

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

  U_CU : entity work.cpu(BEHAVIOURAL)
    port map (
      CLK    => clk,
      RST_AN => rst_an
    );

  ----------------------------------------------------------- COMBINATORIAL

  ----------------------------------------------------------- PROCESSES

  -- simulation process
  P_SIM : process is
  begin

    rst_an <= '0';
    instr  <= (others => '0');
    report "Instr = " & integer'image(to_integer(unsigned(instr)));
    wait for 5 * C_CLK_PERIOD_NS;
    rst_an <= '1';

    wait for 100 * C_CLK_PERIOD_NS;

    instr <= std_logic_vector(shift_left(resize(unsigned(RTYPE_OPCODE), C_ARCH_WORD_W), C_INSTR_OPCODE_START_POS_BIT));
    report "Instr = " & integer'image(to_integer(unsigned(instr)));
    wait for 1 * C_CLK_PERIOD_NS;
    report print_ctrl_wrd (ctrl_word);

    wait for 100 * C_CLK_PERIOD_NS;

    instr <= std_logic_vector(shift_left(resize(unsigned(J_OPCODE), C_ARCH_WORD_W), C_INSTR_OPCODE_START_POS_BIT));
    report "Instr = " & integer'image(to_integer(unsigned(instr)));
    wait for 1 * C_CLK_PERIOD_NS;
    report print_ctrl_wrd (ctrl_word);

    wait for 100 * C_CLK_PERIOD_NS;

    report "Finish simulation";
    finish; -- needs VHDL-2008 and std.env.finish

  end process P_SIM;

end architecture BEHAVIORAL;
