--------------------------------------------------------------------------------
-- Engineer: Simone Ruffini [simone.ruffini@studenti.polito.it,simone.ruffini@tutanota.com]
--           Matteo Bonora  [matteo.bonora@studenti.polito.it]
--
-- Create Date:     Sat 23 16:09:34 PM CEST 2022
-- Module Name:     DATAPATH
-- Project Name:    DLX
-- Description:     DLX datapath
--
-- Revision:
-- Revision 00 - Matteo Bonora
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

entity DATAPATH is
  port (
    CLK             : in    std_logic;                                     -- Clock Signal (rising-edge trigger)
    RST_AN          : in    std_logic;                                     -- Reset Signal: Asyncronous Active Low (Negative)
    CTRL_WRD        : in    cntrl_wrd_t;                                   -- Control Word from CU
    PC_PLS_4        : out   std_logic_vector(C_ARCH_WORD_W - 1 downto 0);  -- Program Counter plus 4
    INSTR           : in    std_logic_vector(C_ARCH_WORD_W - 1 downto 0);  -- Instruction Word from Instr.MEM
    DMEM_ADDR       : out   std_logic_vector(C_ARCH_WORD_W - 1 downto 0);  -- Data Memory address
    DMEM_DOUT       : in    std_logic_vector(C_ARCH_WORD_W - 1 downto 0)   -- Data Memory data output
  );
end entity DATAPATH;

------------------------------------------------------------- ARCHITECTURE

architecture BEHAVIORAL of DATAPATH is

  ----------------------------------------------------------- CONSTANTS 1
  constant C_REG_INIT_VAL : integer := 0;

  ----------------------------------------------------------- TYPES

  ----------------------------------------------------------- FUNCTIONS

  ----------------------------------------------------------- CONSTANTS 2

  ----------------------------------------------------------- SIGNALS

  -- Fetch Stage Signals (_f)

  -- Decode Stage Signals (_d)

  -- Execute Stage Signals (_e)
  signal rs2_e            : std_logic_vector(C_INSTR_RS2_W - 1 downto 0);
  signal rs3_e            : std_logic_vector(C_INSTR_RS3_W - 1 downto 0);

  signal pc_pls_4_e       : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal rf_dout1_e       : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal rf_dout2_e       : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal rf_waddr_e       : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal imm_e            : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal dmem_dout_e      : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);

  signal alu_a_e          : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal alu_b_e          : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal alu_out_e        : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);

  -- Memory Stage Signals (_m)
  signal alu_out_m        : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal dmem_dout_m      : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal rf_waddr_e       : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);

  -- Write Back Stage Signals (_wb)
  signal alu_out_m        : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);

begin
  --*************************************************************************** FETCH STAGE
  --*********************************************************************************************

  ----------------------------------------------------------- ENTITY DEFINITION

  ----------------------------------------------------------- COMBINATORIAL

  ----------------------------------------------------------- PROCESSES

  --*************************************************************************** DECODE STAGE
  --*********************************************************************************************

  ----------------------------------------------------------- ENTITY DEFINITION

  ----------------------------------------------------------- COMBINATORIAL

  ----------------------------------------------------------- PROCESSES

  --*************************************************************************** EXECUTE STAGE
  --*****************************************************************************************

  ----------------------------------------------------------- ENTITY DEFINITION
  U_ALU : entity work.alu("Behavioural")
    generic map (
      DATA_W => C_ARCH_WORD_W
    )
    port map (
      FUNC => CTRL_WRD.alu_func,
      A    => alu_a_e,
      B    => alu_b_e,
      RES  => alu_out_e
    );

  -- TODO: rethink this design it gets busier the more registers we need maybe use a generate block
  U_REG_ALU_OUT_E : entity work.reg_pipo("BEHAV_WITH_EN_INIT")
    generic map (
      DATA_W => alu_out_e'length, INIT_VAL => C_REG_INIT_VAL
    )
    port map (
      CLK    => CLK,
      RST_AN => RST_AN,
      EN_N   => '0',
      INIT   => '0',
      DIN    => alu_out_e,
      DOUT   => alu_out_m
    );

  U_REG_DMEM_DOUT_E : entity work.reg_pipo("BEHAV_WITH_EN_INIT")
    generic map (
      DATA_W => dmem_dout_e'length, INIT_VAL => C_REG_INIT_VAL
    )
    port map (
      CLK    => CLK,
      RST_AN => RST_AN,
      EN_N   => '0',
      INIT   => '0',
      DIN    => dmem_dout_e,
      DOUT   => dmem_dout_m
    );

  U_REG_RF_WADDR_E : entity work.reg_pipo("BEHAV_WITH_EN_INIT")
    generic map (
      DATA_W => rf_waddr_e'length, INIT_VAL => C_REG_INIT_VAL
    )
    port map (
      CLK    => CLK,
      RST_AN => RST_AN,
      EN_N   => '0',
      INIT   => '0',
      DIN    => rf_waddr_e,
      DOUT   => rf_waddr_m
    );

  ----------------------------------------------------------- COMBINATORIAL

  -- MUX ALU A
  alu_a_e <= pc_pls_4_e when CTRL_WRD.pc_pls_4_sel = '1' else
             rf_dout1_e;

  -- MUX ALU B
  alu_b_e <= imm_e when CTRL_WRD.imm_sel = '1' else
             rf_dout2_e;

  -- MUX RF WADDR
  rf_waddr_e  <= rs3_e when CTRL_WRD.r_type_sel = '1' else
                 rs2_e;

  dmem_dout_e <= rf_doutb_e;

  ----------------------------------------------------------- PROCESSES

  --*************************************************************************** MEMORY STAGE
  --*********************************************************************************************

  ----------------------------------------------------------- ENTITY DEFINITION

  ----------------------------------------------------------- COMBINATORIAL

  ----------------------------------------------------------- PROCESSES

  
  --*************************************************************************** WRITE BACK STAGE
  --*********************************************************************************************

  ----------------------------------------------------------- ENTITY DEFINITION

  ----------------------------------------------------------- COMBINATORIAL

  ----------------------------------------------------------- PROCESSES

end architecture BEHAVIORAL;

-- configuration CFG_DATAPATH_BEHAVIORAL of DATAPATH is
--  for BEHAVIORAL
--  end for;
-- end CFG_DATAPATH_BEHAVIORAL;
