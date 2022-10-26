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
    CLK              : in    std_logic;                                       -- Clock Signal (rising-edge trigger)
    RST_AN           : in    std_logic;                                       -- Reset Signal: Asyncronous Active Low (Negative)
    -- xMEM ports
    IMEM_ADDR        : out   std_logic_vector(C_ARCH_WORD_W - 1 downto 0);    -- Instructin Memory read address
    IMEM_DOUT        : in    std_logic_vector(C_ARCH_WORD_W - 1 downto 0);    -- Instructino Memory data output
    DMEM_RWADDR      : out   std_logic_vector(C_ARCH_WORD_W - 1 downto 0);    -- Data Memory read/write address
    DMEM_WEN         : out   std_logic;                                       -- Data Memory Write Enable
    DMEM_DIN         : out   std_logic_vector(C_ARCH_WORD_W - 1 downto 0);    -- Data Memory data input
    DMEM_DOUT        : in    std_logic_vector(C_ARCH_WORD_W - 1 downto 0)     -- Data Memory data output
  );
end entity CPU;

------------------------------------------------------------- ARCHITECTURE

architecture BEHAVIOURAL of CPU is

  ----------------------------------------------------------- COMPONENTS
  component CU is
    port (
      CLK              : in    std_logic;
      RST_AN           : in    std_logic;
      INSTR            : in    std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
      HZRD_SIG         : in    hzrd_sig_t;
      CTRL_WORD        : out   ctrl_word_t
    );
  end component;

  component DATAPATH is
    port (
      CLK              : in    std_logic;
      RST_AN           : in    std_logic;
      CTRL_WORD        : in    ctrl_word_t;
      INSTR_CU         : out   std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
      HZRD_SIG         : in    hzrd_sig_t;
      DP_SIG           : out   dp_sig_t;
      IMEM_ADDR        : out   std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
      IMEM_DOUT        : in    std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
      DMEM_RWADDR      : out   std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
      DMEM_DIN         : out   std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
      DMEM_DOUT        : in    std_logic_vector(C_ARCH_WORD_W - 1 downto 0)
    );
  end component;

  component HU is
    port (
      CLK              : in    std_logic;
      RST_AN           : in    std_logic;
      DP_SIG           : in    dp_sig_t;
      HZRD_SIG         : out   hzrd_sig_t
    );
  end component;

  ----------------------------------------------------------- CONSTANTS 1

  ----------------------------------------------------------- TYPES

  ----------------------------------------------------------- FUNCTIONS

  ----------------------------------------------------------- CONSTANTS 2

  ----------------------------------------------------------- SIGNALS

  signal ctrl_word                  : ctrl_word_t;
  signal instr_cu                   : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal dp_sig                     : dp_sig_t;
  signal hzrd_sig                   : hzrd_sig_t;

  -- this needs to be in the top level
  signal assertion_test_output      : natural := dlx_pkg_check_assertions;

  -- DEBUG signals (will be left out of synthesis)
  signal dbg_fetch                  : instr_t;
  signal dbg_decode                 : instr_t;
  signal dbg_execute                : instr_t;
  signal dbg_memory                 : instr_t;
  signal dbg_writeback              : instr_t;

begin

  ----------------------------------------------------------- ENTITY DEFINITION

  U_CU : CU
    port map (
      CLK       => CLK,
      RST_AN    => RST_AN,
      INSTR     => instr_cu,
      HZRD_SIG  => hzrd_sig,
      CTRL_WORD => ctrl_word
    );

  U_DATAPATH : DATAPATH
    port map (
      CLK         => CLK,
      RST_AN      => RST_AN,
      CTRL_WORD   => ctrl_word,
      INSTR_CU    => instr_cu,
      HZRD_SIG    => hzrd_sig,
      DP_SIG      => dp_sig,
      IMEM_ADDR   => IMEM_ADDR,
      IMEM_DOUT   => IMEM_DOUT,
      DMEM_RWADDR => DMEM_RWADDR,
      DMEM_DIN    => DMEM_DIN,
      DMEM_DOUT   => DMEM_DOUT
    );

  U_HU : HU
    port map (
      CLK      => CLK,
      RST_AN   => RST_AN,
      DP_SIG   => dp_sig,
      HZRD_SIG => hzrd_sig
    );

  ----------------------------------------------------------- COMBINATORIAL

  DMEM_WEN <= CTRL_WORD.dmem_wen;

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

----------------------------------------------------------- CONFIGURATIONS

configuration CFG_CPU_BEHAV of CPU is
  for BEHAVIOURAL
    for all: CU
      use configuration work.CFG_CU_BEHAV;
    end for;
    for all: DATAPATH
      use configuration work.CFG_DATAPATH_BEHAV;
    end for;
    for all: HU 
      use configuration work.CFG_HU_BEHAV;
    end for;
  end for;
end configuration;

configuration CFG_CPU_BEHAV_ALU_P4ADDER of CPU is
  for BEHAVIOURAL
    for all: CU
      use configuration work.CFG_CU_BEHAV;
    end for;
    for all: DATAPATH
      use configuration work.CFG_DATAPATH_BEHAV_ALU_P4ADDER;
    end for;
    for all: HU 
      use configuration work.CFG_HU_BEHAV;
    end for;
  end for;
end configuration;

configuration CFG_CPU_BEHAV_ALU_T2LOGIC of CPU is
  for BEHAVIOURAL
    for all: CU
      use configuration work.CFG_CU_BEHAV;
    end for;
    for all: DATAPATH
      use configuration work.CFG_DATAPATH_BEHAV_ALU_T2LOGIC;
    end for;
    for all: HU 
      use configuration work.CFG_HU_BEHAV;
    end for;
  end for;
end configuration;

configuration CFG_CPU_BEHAV_ALU_T2SHIFTER of CPU is
  for BEHAVIOURAL
    for all: CU
      use configuration work.CFG_CU_BEHAV;
    end for;
    for all: DATAPATH
      use configuration work.CFG_DATAPATH_BEHAV_ALU_T2SHIFTER;
    end for;
    for all: HU 
      use configuration work.CFG_HU_BEHAV;
    end for;
  end for;
end configuration;

configuration CFG_CPU_BEHAV_ALU_STRUCT of CPU is
  for BEHAVIOURAL
    for all: CU
      use configuration work.CFG_CU_BEHAV;
    end for;
    for all: DATAPATH
      use configuration work.CFG_DATAPATH_BEHAV_ALU_STRUCT;
    end for;
    for all: HU 
      use configuration work.CFG_HU_BEHAV;
    end for;
  end for;
end configuration;
