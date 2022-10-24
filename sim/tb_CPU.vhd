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

  signal imem_addr                  : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal imem_addr_trunc            : std_logic_vector(C_IMEM_ADDR_W - 1 downto 0);
  signal imem_dout                  : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal dmem_rwaddr                : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal dmem_rwaddr_trunc          : std_logic_vector(C_DMEM_ADDR_W - 1 downto 0);
  signal dmem_wen                   : std_logic;                                -- Data Memory Write Enable
  signal dmem_din                   : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal dmem_dout                  : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);



begin

  ----------------------------------------------------------- ENTITY DEFINITION
  U_CLKGEN : entity work.clkgen
    generic map (
      CLK_HZ => C_CLK_FREQ_HZ
    )
    port map (
      CLK => clk
    );

  U_IMEM : entity work.imem(BEHAVIOURAL)
    generic map (
      ADDR_W => C_IMEM_ADDR_W,
      DATA_W => C_ARCH_WORD_W
    )
    port map (
      RST_AN => RST_AN,
      RADDR  => imem_addr_trunc,
      DOUT   => imem_dout
    );

  U_DMEM : entity work.dmem(BEHAVIOURAL)
    generic map (
      ADDR_W => C_DMEM_ADDR_W,
      DATA_W => C_ARCH_WORD_W
    )
    port map (
      CLK    => CLK,
      RST_AN => RST_AN,
      RWADDR => dmem_rwaddr_trunc,
      WEN    => dmem_wen,
      DIN    => dmem_din,
      DOUT   => dmem_dout
    );

  U_CPU : entity work.cpu(BEHAVIOURAL)
    port map (
      CLK    => clk,
      RST_AN => rst_an,
      IMEM_ADDR   => imem_addr,
      IMEM_DOUT   => imem_dout,
      DMEM_RWADDR => dmem_rwaddr,
      DMEM_WEN    => dmem_wen,
      DMEM_DIN    => dmem_din,
      DMEM_DOUT   => dmem_dout
    );

  ----------------------------------------------------------- COMBINATORIAL

  -- NOTE: IMEM is word addressed, trucante addresses (bit0,1 removed)
  -- NOTE: the imem_addr signal is additionaly truncated if the memory address
  --       space (imem size) is smaller then the DLX architecture word width
  imem_addr_trunc <= std_logic_vector(resize(unsigned(imem_addr(imem_addr'length-1 downto 2)), imem_addr_trunc'length));

  -- NOTE: DMEM is word addressed, but dmem_rwaddr is already a word-addressed
  --       address (no first 2 bits trucation)
  -- NOTE: the dmem_rwaddr signal is still truncated if the memory address
  --       space (dmem size) is smaller then the DLX architecture word width
  dmem_rwaddr_trunc <= std_logic_vector(resize(unsigned(dmem_rwaddr), dmem_rwaddr_trunc'length));

  ----------------------------------------------------------- PROCESSES

  -- simulation process
  P_SIM : process is
  begin

    rst_an <= '0';
    wait for 5 * C_CLK_PERIOD_NS;
    rst_an <= '1';

    wait;

  end process P_SIM;

end architecture BEHAVIOURAL;
