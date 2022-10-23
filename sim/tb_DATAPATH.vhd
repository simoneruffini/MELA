--------------------------------------------------------------------------------
-- Engineer: Simone Ruffini [simone.ruffini@studenti.polito.it,simone.ruffini@tutanota.com]
--
-- Create Date:     Thu Oct 13 10:06:06 PM CEST 2022
-- Module Name:     TB_CU
-- Project Name:    DLX
-- Description:     testbench for Control Unit
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

entity TB_DATAPATH is
-- port (
--);
end entity TB_DATAPATH;

------------------------------------------------------------- ARCHITECTURE

architecture BEHAVIOURAL of TB_DATAPATH is

  ----------------------------------------------------------- CONSTANTS 1
  constant C_CLK_FREQ_HZ            : natural := 1000000; -- 1MHz
  constant C_CLK_PERIOD_NS          : time := 1e09 / C_CLK_FREQ_HZ * 1 ns;
  constant C_0S                     : std_logic_vector(C_ARCH_WORD_W - 1 downto 0) := (others => '0');
  ----------------------------------------------------------- TYPES

  ----------------------------------------------------------- FUNCTIONS

  ----------------------------------------------------------- CONSTANTS 2

  ----------------------------------------------------------- SIGNALS

  signal clk              : std_logic;
  signal rst_an           : std_logic;
  signal ctrl_word        : ctrl_word_t;
  signal IMEM_ADDR        : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);  -- Instructin Memory read address
  signal IMEM_DOUT        : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);  -- Instructino Memory data output
  signal DMEM_RWADDR      : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);  -- Data Memory read/write address
  signal DMEM_DIN         : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);  -- Data Memory data input
  signal DMEM_DOUT        : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);   -- Data Memory data output

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

  U_DATAPATH : entity work.datapath
    port map (
      CLK           => clk,
      RST_AN        => rst_an,
      CTRL_WORD     => ctrl_word,
      HZRD_SIG      => C_HZRD_SIG_0S,
      DP_SIG        => open,
      IMEM_ADDR     => IMEM_ADDR  ,
      IMEM_DOUT     => IMEM_DOUT  ,
      DMEM_RWADDR   => DMEM_RWADDR,
      DMEM_DIN      => DMEM_DIN   ,
      DMEM_DOUT     => DMEM_DOUT  
    );

  ----------------------------------------------------------- COMBINATORIAL

  ----------------------------------------------------------- PROCESSES

  -- simulation process
  P_SIM : process is
  begin

    rst_an <= '0';
    --instr  <= (others => '0');
    --report "Instr = " & integer'image(to_integer(unsigned(instr)));
    wait for 5 * C_CLK_PERIOD_NS;
    rst_an <= '1';

    --wait for 100 * C_CLK_PERIOD_NS;

    ctrl_word <= (
      branch_en           =>'0',
      jump_en             =>'0',
      jal_en              =>'0',
      rf_wen              =>'1',
      j_type_imm_sel      =>'0',
      r_type_sel          =>'1',
      imm_sel             =>'0',
      pc_pls_4_sel        =>'0',
      alu_func            =>ADD,
      comp_0_invert       =>'0',
      dmem_wen            =>'0',
      rf_wb_dmem_dout_sel =>'0'
    );

    wait for 1 * C_CLK_PERIOD_NS;
    report print_ctrl_wrd (ctrl_word);

    wait for 10 * C_CLK_PERIOD_NS;

    ctrl_word <= (
      branch_en           =>'0',
      jump_en             =>'0',
      jal_en              =>'0',
      rf_wen              =>'1',
      j_type_imm_sel      =>'0',
      r_type_sel          =>'0',
      imm_sel             =>'1',
      pc_pls_4_sel        =>'0',
      alu_func            =>ADD,
      comp_0_invert=>'0',
      dmem_wen            =>'0',
      rf_wb_dmem_dout_sel =>'1'
    );
    wait for 1 * C_CLK_PERIOD_NS;
    report print_ctrl_wrd (ctrl_word);

    wait for 10 * C_CLK_PERIOD_NS;

    ctrl_word <=
  (
    branch_en           =>'0',
    jump_en             =>'0',
    jal_en              =>'0',
    rf_wen              =>'1',
    j_type_imm_sel      =>'0',
    r_type_sel          =>'0',
    imm_sel             =>'1',
    pc_pls_4_sel        =>'0',
    alu_func            =>ADD,
    comp_0_invert=>'0',
    dmem_wen            =>'1',
    rf_wb_dmem_dout_sel =>'1'
  );
    wait for 1 * C_CLK_PERIOD_NS;
    report print_ctrl_wrd (ctrl_word);

    wait for 10 * C_CLK_PERIOD_NS;

    ctrl_word<=(
    branch_en           =>'0',
    jump_en             =>'1',
    jal_en              =>'1',
    rf_wen              =>'1',
    j_type_imm_sel      =>'1',
    r_type_sel          =>'0',
    imm_sel             =>'1',
    pc_pls_4_sel        =>'1',
    alu_func            =>ADD,
    comp_0_invert=>'0',
    dmem_wen            =>'0',
    rf_wb_dmem_dout_sel =>'0'
    );
    wait for 1 * C_CLK_PERIOD_NS;
    report print_ctrl_wrd (ctrl_word);

    wait for 100 * C_CLK_PERIOD_NS;

    report "Finish simulation";
    finish; -- needs VHDL-2008 and std.env.finish

  end process P_SIM;

end architecture BEHAVIOURAL;
