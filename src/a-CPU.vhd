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
  use work.dlx_isa_enc_pkg.all;

------------------------------------------------------------- ENTITY

entity CPU is
  port (
    CLK              : in    std_logic;                                   -- Clock Signal (rising-edge trigger)
    RST_AN           : in    std_logic                                    -- Reset Signal: Asyncronous Active Low (Negative)
  );
end entity CPU;

------------------------------------------------------------- ARCHITECTURE

architecture BEHAVIOURAL of CPU is

  ----------------------------------------------------------- CONSTANTS 1

  ----------------------------------------------------------- TYPES

  ----------------------------------------------------------- FUNCTIONS

  ----------------------------------------------------------- CONSTANTS 2

  ----------------------------------------------------------- SIGNALS

  signal ctrl_word                  : ctrl_word_t;
  signal instr_cu                   : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal imem_addr                  : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal imem_addr_trunc            : std_logic_vector(C_IMEM_ADDR_W - 1 downto 0);
  signal imem_dout                  : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal dmem_rwaddr                : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal dmem_rwaddr_trunc          : std_logic_vector(C_DMEM_ADDR_W - 1 downto 0);
  signal dmem_din                   : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal dmem_dout                  : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal dp_sig                     : dp_sig_t;
  signal hzrd_sig                   : hzrd_sig_t;

  -- this needs to be in the top level
  signal assertion_test_output      : natural := dlx_pkg_check_assertions;

  -- DEBUG
  signal dbg_fetch                  : instr_t;
  signal dbg_decode                 : instr_t;
  signal dbg_execute                : instr_t;
  signal dbg_memory                 : instr_t;
  signal dbg_writeback              : instr_t;

begin

  ----------------------------------------------------------- ENTITY DEFINITION

  U_CU : entity work.cu(BEHAVIOURAL)
    port map (
      CLK       => CLK,
      RST_AN    => RST_AN,
      INSTR     => instr_cu,
      HZRD_SIG  => hzrd_sig,
      CTRL_WORD => ctrl_word
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

  U_DATAPATH : entity work.datapath(BEHAVIOURAL)
    port map (
      CLK         => CLK,
      RST_AN      => RST_AN,
      CTRL_WORD   => ctrl_word,
      INSTR_CU    => instr_cu,
      HZRD_SIG    => hzrd_sig,
      DP_SIG      => dp_sig,
      IMEM_ADDR   => imem_addr,
      IMEM_DOUT   => imem_dout,
      DMEM_RWADDR => dmem_rwaddr,
      DMEM_DIN    => dmem_din,
      DMEM_DOUT   => dmem_dout
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
      WEN    => ctrl_word.dmem_wen,
      DIN    => dmem_din,
      DOUT   => dmem_dout
    );

  U_HU : entity work.hu(BEHAVIOURAL)
    port map (
      CLK      => CLK,
      RST_AN   => RST_AN,
      DP_SIG   => dp_sig,
      HZRD_SIG => hzrd_sig
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


  -- DEBUG: will not be synthesized
  P_DBG_FETCH : process (instr_cu) is
  begin

    dbg_fetch <= print_instr(instr_cu);

  end process P_DBG_FETCH;

  ----------------------------------------------------------- SEQUENTIAL

  P_DBG_PIPELINE_STAGE_PRINT : process (CLK, RST_AN) is
  begin

    if (RST_AN = '0') then
      dbg_decode    <= INSTR_NOT_FOUNDx;
      dbg_execute   <= INSTR_NOT_FOUNDx;
      dbg_memory    <= INSTR_NOT_FOUNDx;
      dbg_writeback <= INSTR_NOT_FOUNDx;
    elsif (CLK'event and CLK = '1') then
      dbg_decode <= dbg_fetch;
      if (hzrd_sig.flush_fd = '1') then
        dbg_decode <= INSTR_NOT_FOUNDx;
      end if;

      dbg_execute <= dbg_decode;
      if (hzrd_sig.flush_de = '1') then
        dbg_execute <= INSTR_NOT_FOUNDx;
      end if;

      dbg_memory <= dbg_execute;
      if (hzrd_sig.flush_em = '1') then
        dbg_memory <= INSTR_NOT_FOUNDx;
      end if;

      dbg_writeback <= dbg_memory;
      if (hzrd_sig.flush_mwb = '1') then
        dbg_memory <= INSTR_NOT_FOUNDx;
      end if;
    end if;

  end process P_DBG_PIPELINE_STAGE_PRINT;

end architecture BEHAVIOURAL;

-- configuration CFG_CPU_BEHAVIOURAL of CPU is
--  for BEHAVIOURAL
--  end for;
-- end CFG_CPU_BEHAVIOURAL;
