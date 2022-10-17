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
-- Revision 01 - Simone Ruffini
--  * Overhaul for DLX
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
    CLK              : in    std_logic;                                     -- Clock Signal (rising-edge trigger)
    RST_AN           : in    std_logic;                                     -- Reset Signal: Asyncronous Active Low (Negative)
    CTRL_WORD        : in    ctrl_word_t;                                   -- Control Word from CU
    INSTR            : in    std_logic_vector(C_ARCH_WORD_W - 1 downto 0);  -- Instruction Word from Instr.MEM
    IMEM_ADDR        : out   std_logic_vector(C_IMEM_ADDR_W - 1 downto 0);  -- Instructin Memory read address
    IMEM_DOUT        : in    std_logic_vector(C_ARCH_WORD_W - 1 downto 0);  -- Instructino Memory data output
    DMEM_RWADDR      : out   std_logic_vector(C_DMEM_ADDR_W - 1 downto 0);  -- Data Memory read/write address
    DMEM_DIN         : out   std_logic_vector(C_ARCH_WORD_W - 1 downto 0);  -- Data Memory data input
    DMEM_DOUT        : in    std_logic_vector(C_ARCH_WORD_W - 1 downto 0)   -- Data Memory data output
  );
end entity DATAPATH;

------------------------------------------------------------- ARCHITECTURE

architecture BEHAVIORAL of DATAPATH is

  ----------------------------------------------------------- CONSTANTS 1
  constant C_REG_INIT_VAL   : integer := 0;

  ----------------------------------------------------------- TYPES

  ----------------------------------------------------------- FUNCTIONS

  ----------------------------------------------------------- CONSTANTS 2

  ----------------------------------------------------------- SIGNALS

  -- Fetch Stage Signals (_f)

  signal npc_sel_f          : std_logic;
  signal npc_f              : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);        -- new program counter
  signal pc_f               : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);        -- program counter
  signal pc_pls_4_f         : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);        -- program counter plus 4
  signal instr_f            : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);        -- instruction word

  -- Decode Stage Signals (_d)

  signal pc_pls_4_d         : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);        -- see in fetch stage
  signal instr_d            : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);        -- see in fetch stage
  signal rs1_d              : std_logic_vector(C_INSTR_RS2_W - 1 downto 0);
  signal rs2_d              : std_logic_vector(C_INSTR_RS2_W - 1 downto 0);
  signal rs3_d              : std_logic_vector(C_INSTR_RS3_W - 1 downto 0);
  signal imm_i_type_d       : std_logic_vector(C_INSTR_I_TYPE_IMM_W - 1 downto 0); -- immediate field of I type instructions
  signal imm_j_type_d       : std_logic_vector(C_INSTR_J_TYPE_IMM_W - 1 downto 0); -- immediate field of J type instructions
  signal imm_i_type_ext_d   : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);        -- immediate field of I type instructions EXTENDED
  signal imm_j_type_ext_d   : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);        -- immediate field of J type instructions EXTENDED
  signal imm_d              : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);        -- immediate field going to executed stage
  signal rf_waddr_d         : std_logic_vector(C_RF_ADDR_W - 1 downto 0);
  signal rf_din_d           : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal rf_dout1_d         : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal rf_dout2_d         : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);

  -- Execute Stage Signals (_e)
  signal rs2_e              : std_logic_vector(C_INSTR_RS2_W - 1 downto 0);
  signal rs3_e              : std_logic_vector(C_INSTR_RS3_W - 1 downto 0);

  signal pc_pls_4_e         : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal rf_dout1_e         : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal rf_dout2_e         : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal rf_waddr_e         : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal imm_e              : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal dmem_din_e         : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);

  signal alu_a_e            : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal alu_b_e            : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal alu_out_e          : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);

  signal is_0_e             : std_logic;

  -- Memory Stage Signals (_m)
  signal alu_out_m          : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal dmem_din_m         : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal dmem_dout_m        : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal rf_waddr_m         : std_logic_vector(C_RF_ADDR_W - 1 downto 0);

  signal is_0_m             : std_logic;

  -- Write Back Stage Signals (_wb)
  signal alu_out_wb         : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal dmem_dout_wb       : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal rf_waddr_wb        : std_logic_vector(C_RF_ADDR_W - 1 downto 0);
  signal rf_din_wb          : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);

begin

  --*************************************************************************** FETCH STAGE
  --*********************************************************************************************

  ----------------------------------------------------------- ENTITY DEFINITION
  U_PC_REG : entity work.reg_pipo(BEHAV_WITH_EN_INIT)
    generic map (
      DATA_W => pc_f'length, INIT_VAL => C_REG_INIT_VAL
    )
    port map (
      CLK    => CLK,
      RST_AN => RST_AN,
      EN_N   => '0',
      INIT   => '0',
      DIN    => npc_f,
      DOUT   => pc_f
    );

  -- U_IMEM : entity work.imem(Behavioural)
  --  generic map (
  --    ADDR_W => C_IMEM_ADDR_W,
  --    DATA_W => C_ARCH_WORD_W
  --  )
  --  port map (
  --    CLK    => CLK,
  --    RST_AN => RST_AN,
  --    RADDR  => pc_pls_4_f,
  --    DOUT   => instr_f
  --  );

  ----------------------------------------------------------- COMBINATORIAL

  -- Instruction Memory signals
  -- NOTE: the pc_f signal is truncated if the memory address space is smaller
  -- then the DLX architecture word width
  IMEM_ADDR <= std_logic_vector(resize(unsigned(pc_f), IMEM_ADDR'length));

  instr_f <= IMEM_DOUT;

  -- PC + 4 adder
  pc_pls_4_f <= std_logic_vector(to_unsigned(to_integer(unsigned(pc_f)) + 4, pc_pls_4_f'length));

  -- NPC MUX select signal logic
  npc_sel_f <= (is_0_m xor CTRL_WORD.comp_0_invert) when CTRL_WORD.branch_en = '1' else
               '1' when CTRL_WORD.jump_en else
               '0';

  -- NPC MUX
  npc_f <= alu_out_m when npc_sel_f = '1' else
           pc_pls_4_f;

  ----------------------------------------------------------- PIPELINE REGISTERS

  U_PC_PLS_4_REG : entity work.reg_pipo(BEHAV_WITH_EN_INIT)
    generic map (
      DATA_W => pc_pls_4_f'length, INIT_VAL => C_REG_INIT_VAL
    )
    port map (
      CLK    => CLK,
      RST_AN => RST_AN,
      EN_N   => '0',
      INIT   => '0',
      DIN    => pc_pls_4_f,
      DOUT   => pc_pls_4_d
    );

  U_INSTR_REG : entity work.reg_pipo(BEHAV_WITH_EN_INIT)
    generic map (
      DATA_W => instr_f'length, INIT_VAL => C_REG_INIT_VAL
    )
    port map (
      CLK    => CLK,
      RST_AN => RST_AN,
      EN_N   => '0',
      INIT   => '0',
      DIN    => instr_f,
      DOUT   => instr_d
    );

  --*************************************************************************** DECODE STAGE
  --*********************************************************************************************

  ----------------------------------------------------------- ENTITY DEFINITION

  U_RF : entity work.rf(Behavioural)
    generic map (
      ADDR_W => C_RF_ADDR_W,
      DATA_W => C_ARCH_WORD_W
    )
    port map (
      CLK     => CLK,
      RST_AN  => RST_AN,
      ENABLE  => '1',
      RD1     => '1',
      RD2     => '1',
      WR      => CTRL_WORD.rf_wen,
      ADD_WR  => rf_waddr_d,
      ADD_RD1 => rs1_d,
      ADD_RD2 => rs2_d,
      DATAIN  => rf_din_d,
      OUT1    => rf_dout1_d,
      OUT2    => rf_dout2_d
    );

  U_RF_DOUT1_REG : entity work.reg_pipo(BEHAV_WITH_EN_INIT)
    generic map (
      DATA_W => rf_dout1_d'length, INIT_VAL => C_REG_INIT_VAL
    )
    port map (
      CLK    => CLK,
      RST_AN => RST_AN,
      EN_N   => '0',
      INIT   => '0',
      DIN    => rf_dout1_d,
      DOUT   => rf_dout1_e
    );

  ----------------------------------------------------------- COMBINATORIAL

  rs1_d <= instr_d((C_INSTR_RS1_START_POS_BIT + C_INSTR_RS1_W) - 1 downto C_INSTR_RS1_START_POS_BIT);
  rs2_d <= instr_d((C_INSTR_RS2_START_POS_BIT + C_INSTR_RS2_W) - 1 downto C_INSTR_RS2_START_POS_BIT);
  rs3_d <= instr_d((C_INSTR_RS3_START_POS_BIT + C_INSTR_RS3_W) - 1 downto C_INSTR_RS3_START_POS_BIT);

  imm_i_type_d <= instr_d((C_INSTR_I_TYPE_IMM_START_POS_BIT + C_INSTR_I_TYPE_IMM_W) - 1 downto C_INSTR_I_TYPE_IMM_START_POS_BIT);
  imm_j_type_d <= instr_d((C_INSTR_J_TYPE_IMM_START_POS_BIT + C_INSTR_J_TYPE_IMM_W) - 1 downto C_INSTR_J_TYPE_IMM_START_POS_BIT);

  -- SIGN EXTEND on immediate for I-type instructions
  imm_i_type_ext_d <= std_logic_vector(resize(signed(imm_i_type_d), C_ARCH_WORD_W));

  -- SIGN EXTEND on immediate for J-type instructions
  imm_j_type_ext_d <= std_logic_vector(resize(signed(imm_j_type_d), C_ARCH_WORD_W));

  -- RF_WADDR MUX
  rf_waddr_d <= std_logic_vector(to_unsigned(C_JAL_RET_ADDR_REG, rf_waddr_d'length)) when CTRL_WORD.jal_en = '1' else
                rf_waddr_wb;

  -- RF_DIN MUX
  rf_din_d <= pc_pls_4_d when CTRL_WORD.jal_en = '1' else
              rf_din_wb;

  -- IMMEDIATE FROM JTYPE MUX
  imm_d <= imm_j_type_ext_d when CTRL_WORD.j_type_imm_sel = '1' else
           imm_i_type_ext_d;

  ----------------------------------------------------------- PIPELINE REGISTERS
  U_RF_DOUT2_REG : entity work.reg_pipo(BEHAV_WITH_EN_INIT)
    generic map (
      DATA_W => rf_dout2_d'length, INIT_VAL => C_REG_INIT_VAL
    )
    port map (
      CLK    => CLK,
      RST_AN => RST_AN,
      EN_N   => '0',
      INIT   => '0',
      DIN    => rf_dout2_d,
      DOUT   => rf_dout2_e
    );

  U_IMM_REG : entity work.reg_pipo(BEHAV_WITH_EN_INIT)
    generic map (
      DATA_W => imm_d'length, INIT_VAL => C_REG_INIT_VAL
    )
    port map (
      CLK    => CLK,
      RST_AN => RST_AN,
      EN_N   => '0',
      INIT   => '0',
      DIN    => imm_d,
      DOUT   => imm_e
    );

  U_RS2_REG : entity work.reg_pipo(BEHAV_WITH_EN_INIT)
    generic map (
      DATA_W => rs2_d'length, INIT_VAL => C_REG_INIT_VAL
    )
    port map (
      CLK    => CLK,
      RST_AN => RST_AN,
      EN_N   => '0',
      INIT   => '0',
      DIN    => rs2_d,
      DOUT   => rs2_e
    );

  U_RS3_REG : entity work.reg_pipo(BEHAV_WITH_EN_INIT)
    generic map (
      DATA_W => rs3_d'length, INIT_VAL => C_REG_INIT_VAL
    )
    port map (
      CLK    => CLK,
      RST_AN => RST_AN,
      EN_N   => '0',
      INIT   => '0',
      DIN    => rs3_d,
      DOUT   => rs3_e
    );

  --*************************************************************************** EXECUTE STAGE
  --*****************************************************************************************

  ----------------------------------------------------------- ENTITY DEFINITION
  U_ALU : entity work.alu(BEHAVIOURAL)
    generic map (
      DATA_W => C_ARCH_WORD_W
    )
    port map (
      FUNC => CTRL_WORD.alu_func,
      A    => alu_a_e,
      B    => alu_b_e,
      RES  => alu_out_e
    );

  ----------------------------------------------------------- COMBINATORIAL

  -- MUX ALU A
  alu_a_e <= pc_pls_4_e when CTRL_WORD.pc_pls_4_sel = '1' else
             rf_dout1_e;

  -- MUX ALU B
  alu_b_e <= imm_e when CTRL_WORD.imm_sel = '1' else
             rf_dout2_e;

  -- MUX RF WADDR
  rf_waddr_e <= rs3_e when CTRL_WORD.r_type_sel = '1' else
                rs2_e;

  -- ZERO detector
  is_0_e <= '1' when unsigned(rf_dout1_e) = 0 else
            '0';

  -- Alias Signals for naming purposes
  dmem_din_e <= rf_dout2_e;

  ----------------------------------------------------------- PIPELINE REGISTERS

  -- TODO: rethink this design it gets busier the more registers we need maybe use a generate block
  U_REG_ALU_OUT_E : entity work.reg_pipo(BEHAV_WITH_EN_INIT)
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

  U_REG_DMEM_DOUT_E : entity work.reg_pipo(BEHAV_WITH_EN_INIT)
    generic map (
      DATA_W => dmem_din_e'length, INIT_VAL => C_REG_INIT_VAL
    )
    port map (
      CLK    => CLK,
      RST_AN => RST_AN,
      EN_N   => '0',
      INIT   => '0',
      DIN    => dmem_din_e,
      DOUT   => dmem_din_m
    );

  U_REG_RF_WADDR_E : entity work.reg_pipo(BEHAV_WITH_EN_INIT)
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

  U_REG_IS_0_E : entity work.reg_pipo(BEHAV_WITH_EN_INIT)
    generic map (
      DATA_W => 1, INIT_VAL => C_REG_INIT_VAL
    )
    port map (
      CLK     => CLK,
      RST_AN  => RST_AN,
      EN_N    => '0',
      INIT    => '0',
      DIN(0)  => is_0_e,
      DOUT(0) => is_0_m
    );

  --*************************************************************************** MEMORY STAGE
  --*********************************************************************************************

  ----------------------------------------------------------- ENTITY DEFINITION
  -- U_DMEM : entity work.dmem(Behavioural)
  --  generic map (
  --    ADDR_W => C_DMEM_ADDR_W,
  --    DATA_W => C_ARCH_WORD_W
  --  )
  --  port map (
  --    CLK    => CLK,
  --    RST_AN => RST_AN,
  --    RWADDR => alu_out_m,
  --    WEN    => CTRL_WORD.dmem_we,
  --    DIN    => dmem_din_m,
  --    DOUT   => dmem_dout_m,
  --  );

  ----------------------------------------------------------- COMBINATORIAL

  -- Data Memory Signals
  -- NOTE: the alu_out_m signal is truncated if the memory address space is smaller
  -- then the DLX architecture word width
  DMEM_RWADDR <= std_logic_vector(resize(unsigned(alu_out_m), DMEM_RWADDR'length));
  DMEM_DIN    <= dmem_din_m;
  dmem_dout_m <= DMEM_DOUT;

  ----------------------------------------------------------- PIPELINE REGISTERS
  U_REG_ALU_OUT_M : entity work.reg_pipo(BEHAV_WITH_EN_INIT)
    generic map (
      DATA_W => alu_out_m'length, INIT_VAL => C_REG_INIT_VAL
    )
    port map (
      CLK    => CLK,
      RST_AN => RST_AN,
      EN_N   => '0',
      INIT   => '0',
      DIN    => alu_out_m,
      DOUT   => alu_out_wb
    );

  U_REG_DMEM_DOUT_M : entity work.reg_pipo(BEHAV_WITH_EN_INIT)
    generic map (
      DATA_W => dmem_dout_m'length, INIT_VAL => C_REG_INIT_VAL
    )
    port map (
      CLK    => CLK,
      RST_AN => RST_AN,
      EN_N   => '0',
      INIT   => '0',
      DIN    => dmem_dout_m,
      DOUT   => dmem_dout_wb
    );

  U_REG_RF_WADDR_M : entity work.reg_pipo(BEHAV_WITH_EN_INIT)
    generic map (
      DATA_W => rf_waddr_m'length, INIT_VAL => C_REG_INIT_VAL
    )
    port map (
      CLK    => CLK,
      RST_AN => RST_AN,
      EN_N   => '0',
      INIT   => '0',
      DIN    => rf_waddr_m,
      DOUT   => rf_waddr_wb
    );

  --*************************************************************************** WRITE BACK STAGE
  --*********************************************************************************************

  ----------------------------------------------------------- ENTITY DEFINITION

  ----------------------------------------------------------- COMBINATORIAL
  rf_din_wb <= dmem_dout_wb when CTRL_WORD.rf_wb_dmem_dout_sel = '1' else
               alu_out_wb;

end architecture BEHAVIORAL;

-- configuration CFG_DATAPATH_BEHAVIORAL of DATAPATH is
--  for BEHAVIORAL
--  end for;
-- end CFG_DATAPATH_BEHAVIORAL;
