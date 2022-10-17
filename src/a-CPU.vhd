--------------------------------------------------------------------------------
-- Engineer: Simone Ruffini [simone.ruffini@studenti.polito.it,simone.ruffini@tutanota.com]
--           Matteo Bonora  [matteo.bonora@studenti.polito.it]
--
-- Create Date:     Fri Oct 14 05:59:30 PM CEST 2022
-- Module Name:     CPU
-- Project Name:    DLX
-- Description:     Central Processing Unit implementing DLX isa
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

------------------------------------------------------------- ENTITY

entity CPU is
  port (
    CLK              : in    std_logic; -- Clock Signal (rising-edge trigger)
    RST_AN           : in    std_logic  -- Reset Signal: Asyncronous Active Low (Negative)
  );
end entity CPU;

------------------------------------------------------------- ARCHITECTURE

architecture BEHAVIOURAL of CPU is

  ----------------------------------------------------------- CONSTANTS 1

  ----------------------------------------------------------- TYPES

  ----------------------------------------------------------- FUNCTIONS

  ----------------------------------------------------------- CONSTANTS 2

  ----------------------------------------------------------- SIGNALS

  signal instr            : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal ctrl_word        : ctrl_word_t;
  signal imem_addr        : std_logic_vector(C_IMEM_ADDR_W - 1 downto 0);
  signal imem_dout        : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal dmem_rwaddr      : std_logic_vector(C_DMEM_ADDR_W - 1 downto 0);
  signal dmem_din         : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal dmem_dout        : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);

begin

  ----------------------------------------------------------- ENTITY DEFINITION

  U_CU : entity work.cu(Behavioural)
    port map (
      CLK       => CLK,
      RST_AN    => RST_AN,
      INSTR     => instr,
      CTRL_WORD => ctrl_word
    );

  U_IMEM : entity work.imem(Behavioural)
    generic map (
      ADDR_W => C_IMEM_ADDR_W,
      DATA_W => C_ARCH_WORD_W
    )
    port map (
      CLK    => CLK,
      RST_AN => RST_AN,
      RADDR  => imem_addr,
      DOUT   => instr
    );

  U_DATAPATH : entity work.datapath(Behavioural)
    port map (
      CLK         => CLK,
      RST_AN      => RST_AN,
      CTRL_WORD   => ctrl_word,
      INSTR       => instr,
      IMEM_ADDR   => imem_addr,
      IMEM_DOUT   => imem_dout,
      DMEM_RWADDR => dmem_rwaddr,
      DMEM_DIN    => dmem_din,
      DMEM_DOUT   => dmem_dout
    );

  U_DMEM : entity work.dmem(Behavioural)
    generic map (
      ADDR_W => C_DMEM_ADDR_W,
      DATA_W => C_ARCH_WORD_W
    )
    port map (
      CLK    => CLK,
      RST_AN => RST_AN,
      RWADDR => dmem_rwaddr,
      WEN    => ctrl_word.dmem_wen,
      DIN    => dmem_din,
      DOUT   => dmem_dout
    );

----------------------------------------------------------- COMBINATORIAL

----------------------------------------------------------- PROCESSES

end architecture BEHAVIOURAL;

-- configuration CFG_CPU_BEHAVIOURAL of CPU is
--  for BEHAVIOURAL
--  end for;
-- end CFG_CPU_BEHAVIOURAL;
