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
  use work.dlx_isa_enc_pkg.all;

------------------------------------------------------------- ENTITY

entity DATAPATH is
  port (
    CLK              : in    std_logic;                                       -- Clock Signal (rising-edge trigger)
    RST_AN           : in    std_logic;                                       -- Reset Signal: Asyncronous Active Low (Negative)
    -- CU ports
    CTRL_WORD        : in    ctrl_word_t;                                     -- Control Word from CU
    INSTR_CU         : out   std_logic_vector(C_ARCH_WORD_W - 1 downto 0);    -- instruction word to CU at fetch stage
    -- HU ports
    HZRD_SIG         : in    hzrd_sig_t;                                      -- hazard signals from HU
    DP_SIG           : out   dp_sig_t;                                        -- some datapath signals used by HU
    -- xMEM ports
    IMEM_ADDR        : out   std_logic_vector(C_ARCH_WORD_W - 1 downto 0);    -- Instructin Memory read address
    IMEM_DOUT        : in    std_logic_vector(C_ARCH_WORD_W - 1 downto 0);    -- Instructino Memory data output
    DMEM_RWADDR      : out   std_logic_vector(C_ARCH_WORD_W - 1 downto 0);    -- Data Memory read/write address
    DMEM_DIN         : out   std_logic_vector(C_ARCH_WORD_W - 1 downto 0);    -- Data Memory data input
    DMEM_DOUT        : in    std_logic_vector(C_ARCH_WORD_W - 1 downto 0)     -- Data Memory data output
  );
end entity DATAPATH;

------------------------------------------------------------- ARCHITECTURE

architecture BEHAVIOURAL of DATAPATH is

  ----------------------------------------------------------- CONSTANTS 1
  constant C_REG_INIT_VAL   : integer := 0;
  -- TODO fix this costant
  constant C_PC_INIT_VAL    : std_logic_vector(C_ARCH_WORD_W - 1 downto 0) := (1=>'0', 0=>'0', others => '1');
  ----------------------------------------------------------- TYPES

  ----------------------------------------------------------- FUNCTIONS

  ----------------------------------------------------------- CONSTANTS 2

  ----------------------------------------------------------- SIGNALS
  signal pc_init            : std_logic;

  -- Fetch Stage Signals (_f)

  signal npc_sel_f          : std_logic;
  signal npc_f              : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);        -- new program counter
  signal pc_f               : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);        -- program counter
  signal pc_pls_4_f         : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);        -- program counter plus 4
  signal instr_f            : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);        -- instruction word

  -- Decode Stage Signals (_d)

  signal pc_pls_4_d         : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);        -- see in fetch stage
  signal instr_d            : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);        -- see in fetch stage
  signal instr_opcode_d     : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0);     -- extracted opcode from instruction
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
  signal instr_opcode_e     : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0);     -- see in decode stage

  signal rs2_e              : std_logic_vector(C_INSTR_RS2_W - 1 downto 0);
  signal rs3_e              : std_logic_vector(C_INSTR_RS3_W - 1 downto 0);

  signal pc_pls_4_e         : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal rf_dout1_e         : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal rf_dout2_e         : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal rf_waddr_e         : std_logic_vector(C_RF_ADDR_W - 1 downto 0);
  signal imm_e              : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal dmem_din_e         : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);

  signal alu_a_e            : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal alu_b_e            : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal alu_out_e          : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);

  signal is_0_e             : std_logic;

  -- Memory Stage Signals (_m)
  signal instr_opcode_m     : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0);     -- see in execute stage

  signal pc_pls_4_m         : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);

  signal alu_out_m          : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal dmem_din_m         : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal dmem_dout_m        : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal rf_waddr_m         : std_logic_vector(C_RF_ADDR_W - 1 downto 0);

  signal is_0_m             : std_logic;

  -- Write Back Stage Signals (_wb)
  signal pc_pls_4_wb        : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal alu_out_wb         : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal dmem_dout_wb       : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);
  signal rf_waddr_wb        : std_logic_vector(C_RF_ADDR_W - 1 downto 0);
  signal rf_din_wb          : std_logic_vector(C_ARCH_WORD_W - 1 downto 0);

begin

  --*************************************************************************** PROGRAM COUNTER
  --*********************************************************************************************
  -- the program counter is a CLK cycle on it's own so it is not directly part of the FETCH stage

  U_PC_REG : entity work.reg_pipo(BEHAV_WITH_EN_RSTINIT)
    generic map (
      DATA_W => pc_f'length, INIT_VAL => C_PC_INIT_VAL, RST_INIT_VAL => C_PC_INIT_VAL
    )
    port map (
      CLK    => CLK,
      RST_AN => RST_AN,
      EN     => '1',
      INIT   => pc_init,
      DIN    => npc_f,
      DOUT   => pc_f
    );

  -- **** THIS CODE CAN BE ADDED IF THERE ARE BUGS (AT PHYSICAL LEVEL) ****
  -- It solves glitches at program start inserting one extra NOP instruction
  --
  -- HOWTO:
  -- 1) comment the below assignment
  -- 2) UNcomment U_INIT_PC process
  -- 3) change U_PC_REG instantiation to use BEHAV_WITH_EN_INIT_RSTINIT architecture

  pc_init <= '0';

  -- This process initializes synchronously the PC so that its value is 0 for
  -- the first CLK cycle
  -- NOTE: the reset signal is used "inproperly" i.e. synchronously
  --       therefore RST_AN is not in the sensitivity list
  -- U_INIT_PC : process (CLK) is
  -- begin

  --  if (CLK'event and CLK = '1') then
  --    pc_init <= '0';
  --    if(RST_AN = '0') then
  --      pc_init <= '1';
  --    end if;
  --  end if;

  -- end process U_INIT_PC;

  --*************************************************************************** FETCH STAGE
  --*********************************************************************************************

  ----------------------------------------------------------- ENTITY DEFINITION

  ----------------------------------------------------------- COMBINATORIAL

  -- Instruction Memory signals
  -- NOTE: IMEM is word addressed, trucante addresses (bit0,1 removed)
  -- NOTE: the pc_f signal is truncated if the memory address space is smaller
  -- then the DLX architecture word width
  --IMEM_ADDR <= std_logic_vector( resize(unsigned(pc_f(pc_f'length-1 downto 2), IMEM_ADDR'length));
  IMEM_ADDR <= pc_f;

  instr_f <= IMEM_DOUT;

  INSTR_CU <= instr_f;

  -- PC + 4 adder
  pc_pls_4_f <= std_logic_vector(to_unsigned(to_integer(unsigned(pc_f)) + 4, pc_pls_4_f'length));

  -- NPC MUX select signal logic
  npc_sel_f <= (is_0_m xor CTRL_WORD.comp_0_invert) when CTRL_WORD.branch_en = '1' else
               '1' when CTRL_WORD.jump_en else
               '0';

  -- NPC MUX
  npc_f <= alu_out_m when npc_sel_f = '1' else
           pc_pls_4_f;

  -----------------------------------------------------------------------------------------------

  --*********************************************************** PIPELINE REGISTERS FETCH/DECODE
  --*********************************************************************************************

  -- TODO: rethink this design it gets busier the more registers we need maybe use a generate block

  U_PC_PLS_4_REG_FD : entity work.reg_pipo(BEHAV_WITH_EN_INIT)
    generic map (
      DATA_W => pc_pls_4_f'length, INIT_VAL => std_logic_vector(to_unsigned(C_REG_INIT_VAL,pc_pls_4_f'length))
    )
    port map (
      CLK    => CLK,
      RST_AN => RST_AN,
      EN     => '1',
      INIT   => HZRD_SIG.flush_fd,
      DIN    => pc_pls_4_f,
      DOUT   => pc_pls_4_d
    );

  U_INSTR_REG_FD : entity work.reg_pipo(BEHAV_WITH_EN_INIT)
    generic map (
      DATA_W => instr_f'length, INIT_VAL => std_logic_vector(to_unsigned(C_REG_INIT_VAL,instr_f'length))
    )
    port map (
      CLK    => CLK,
      RST_AN => RST_AN,
      EN     => '1',
      INIT   => HZRD_SIG.flush_fd,
      DIN    => instr_f,
      DOUT   => instr_d
    );

  -----------------------------------------------------------------------------------------------

  --*************************************************************************** DECODE STAGE
  --*********************************************************************************************

  ----------------------------------------------------------- ENTITY DEFINITION

  U_RF : entity work.rf(BEHAVIOURAL)
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

  ----------------------------------------------------------- COMBINATORIAL

  P_EXTRACT_FROM_INSTR : process (instr_d) is
  begin

    instr_opcode_d <= get_opcode(instr_d);

    rs1_d <= get_rs1(instr_d);
    rs2_d <= get_rs2(instr_d);
    rs3_d <= get_rs3(instr_d);

    imm_i_type_d <= get_i_type_imm(instr_d);
    imm_j_type_d <= get_j_type_imm(instr_d);

  end process P_EXTRACT_FROM_INSTR;

  -- SIGN EXTEND on immediate for I-type instructions
  imm_i_type_ext_d <= std_logic_vector(resize(signed(imm_i_type_d), C_ARCH_WORD_W));

  -- SIGN EXTEND on immediate for J-type instructions
  imm_j_type_ext_d <= std_logic_vector(resize(signed(imm_j_type_d), C_ARCH_WORD_W));

  -- RF_WADDR MUX
  rf_waddr_d <= std_logic_vector(to_unsigned(C_JAL_RET_ADDR_REG, rf_waddr_d'length)) when CTRL_WORD.jal_en = '1' else
                rf_waddr_wb;

  -- RF_DIN 
  rf_din_d <= rf_din_wb;

  -- IMMEDIATE FROM JTYPE MUX
  imm_d <= imm_j_type_ext_d when CTRL_WORD.j_type_imm_sel = '1' else
           imm_i_type_ext_d;

  -----------------------------------------------------------------------------------------------

  --*********************************************************** PIPELINE REGISTERS DECODE/EXECUTE
  --*********************************************************************************************

  U_INSTR_OPCODE_REG_DE : entity work.reg_pipo(BEHAV_WITH_EN_INIT)
    generic map (
      DATA_W => instr_opcode_d'length, INIT_VAL => std_logic_vector(to_unsigned(C_REG_INIT_VAL,instr_opcode_d'length))
    )
    port map (
      CLK    => CLK,
      RST_AN => RST_AN,
      EN     => '1',
      INIT   => HZRD_SIG.flush_de,
      DIN    => instr_opcode_d,
      DOUT   => instr_opcode_e
    );

  U_PC_PLS_4_REG_DE : entity work.reg_pipo(BEHAV_WITH_EN_INIT)
    generic map (
      DATA_W => pc_pls_4_d'length, INIT_VAL => std_logic_vector(to_unsigned(C_REG_INIT_VAL,pc_pls_4_d'length))
    )
    port map (
      CLK    => CLK,
      RST_AN => RST_AN,
      EN     => '1',
      INIT   => HZRD_SIG.flush_de,
      DIN    => pc_pls_4_d,
      DOUT   => pc_pls_4_e
    );

  U_RF_DOUT1_REG_DE : entity work.reg_pipo(BEHAV_WITH_EN_INIT)
    generic map (
      DATA_W => rf_dout1_d'length, INIT_VAL => std_logic_vector(to_unsigned(C_REG_INIT_VAL,rf_dout1_d'length))
    )
    port map (
      CLK    => CLK,
      RST_AN => RST_AN,
      EN     => '1',
      INIT   => HZRD_SIG.flush_de,
      DIN    => rf_dout1_d,
      DOUT   => rf_dout1_e
    );

  U_RF_DOUT2_REG_DE : entity work.reg_pipo(BEHAV_WITH_EN_INIT)
    generic map (
      DATA_W => rf_dout2_d'length, INIT_VAL => std_logic_vector(to_unsigned(C_REG_INIT_VAL,rf_dout2_d'length))
    )
    port map (
      CLK    => CLK,
      RST_AN => RST_AN,
      EN     => '1',
      INIT   => HZRD_SIG.flush_de,
      DIN    => rf_dout2_d,
      DOUT   => rf_dout2_e
    );

  U_IMM_REG_DE : entity work.reg_pipo(BEHAV_WITH_EN_INIT)
    generic map (
      DATA_W => imm_d'length, INIT_VAL => std_logic_vector(to_unsigned(C_REG_INIT_VAL,imm_d'length))
    )
    port map (
      CLK    => CLK,
      RST_AN => RST_AN,
      EN     => '1',
      INIT   => HZRD_SIG.flush_de,
      DIN    => imm_d,
      DOUT   => imm_e
    );

  U_RS2_REG_DE : entity work.reg_pipo(BEHAV_WITH_EN_INIT)
    generic map (
      DATA_W => rs2_d'length, INIT_VAL => std_logic_vector(to_unsigned(C_REG_INIT_VAL,rs2_d'length))
    )
    port map (
      CLK    => CLK,
      RST_AN => RST_AN,
      EN     => '1',
      INIT   => HZRD_SIG.flush_de,
      DIN    => rs2_d,
      DOUT   => rs2_e
    );

  U_RS3_REG_DE : entity work.reg_pipo(BEHAV_WITH_EN_INIT)
    generic map (
      DATA_W => rs3_d'length, INIT_VAL => std_logic_vector(to_unsigned(C_REG_INIT_VAL,rs3_d'length))
    )
    port map (
      CLK    => CLK,
      RST_AN => RST_AN,
      EN     => '1',
      INIT   => HZRD_SIG.flush_de,
      DIN    => rs3_d,
      DOUT   => rs3_e
    );

  -----------------------------------------------------------------------------------------------

  --*************************************************************************** EXECUTE STAGE
  --*****************************************************************************************

  ----------------------------------------------------------- ENTITY DEFINITION
  U_ALU : entity work.alu(BEHAVIOURAL)
  --U_ALU : entity work.alu(STRUCTURAL)
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

  -----------------------------------------------------------------------------------------------

  --*********************************************************** PIPELINE REGISTERS EXECUTE/MEMORY
  --*********************************************************************************************

  U_INSTR_OPCODE_REG_EM : entity work.reg_pipo(BEHAV_WITH_EN_INIT)
    generic map (
      DATA_W => instr_opcode_e'length, INIT_VAL => std_logic_vector(to_unsigned(C_REG_INIT_VAL,instr_opcode_e'length))
    )
    port map (
      CLK    => CLK,
      RST_AN => RST_AN,
      EN     => '1',
      INIT   => HZRD_SIG.flush_em,
      DIN    => instr_opcode_e,
      DOUT   => instr_opcode_m
    );

  U_PC_PLS_4_REG_EM : entity work.reg_pipo(BEHAV_WITH_EN_INIT)
    generic map (
      DATA_W => pc_pls_4_e'length, INIT_VAL => std_logic_vector(to_unsigned(C_REG_INIT_VAL,pc_pls_4_e'length))
    )
    port map (
      CLK    => CLK,
      RST_AN => RST_AN,
      EN     => '1',
      INIT   => HZRD_SIG.flush_em,
      DIN    => pc_pls_4_e,
      DOUT   => pc_pls_4_m
    );

  U_ALU_OUT_REG_EM : entity work.reg_pipo(BEHAV_WITH_EN_INIT)
    generic map (
      DATA_W => alu_out_e'length, INIT_VAL => std_logic_vector(to_unsigned(C_REG_INIT_VAL,alu_out_e'length))
    )
    port map (
      CLK    => CLK,
      RST_AN => RST_AN,
      EN     => '1',
      INIT   => HZRD_SIG.flush_em,
      DIN    => alu_out_e,
      DOUT   => alu_out_m
    );

  U_DMEM_DOUT_REG_EM : entity work.reg_pipo(BEHAV_WITH_EN_INIT)
    generic map (
      DATA_W => dmem_din_e'length, INIT_VAL => std_logic_vector(to_unsigned(C_REG_INIT_VAL,dmem_din_e'length))
    )
    port map (
      CLK    => CLK,
      RST_AN => RST_AN,
      EN     => '1',
      INIT   => HZRD_SIG.flush_em,
      DIN    => dmem_din_e,
      DOUT   => dmem_din_m
    );

  U_RF_WADDR_REG_EM : entity work.reg_pipo(BEHAV_WITH_EN_INIT)
    generic map (
      DATA_W => rf_waddr_e'length, INIT_VAL => std_logic_vector(to_unsigned(C_REG_INIT_VAL,rf_waddr_e'length))
    )
    port map (
      CLK    => CLK,
      RST_AN => RST_AN,
      EN     => '1',
      INIT   => HZRD_SIG.flush_em,
      DIN    => rf_waddr_e,
      DOUT   => rf_waddr_m
    );

  U_IS_0_REG_EM : entity work.reg_pipo(BEHAV_WITH_EN_INIT)
    generic map (
      DATA_W => 1, INIT_VAL => std_logic_vector(to_unsigned(C_REG_INIT_VAL,1))
    )
    port map (
      CLK     => CLK,
      RST_AN  => RST_AN,
      EN      => '1',
      INIT    => HZRD_SIG.flush_em,
      DIN(0)  => is_0_e,
      DOUT(0) => is_0_m
    );

  -----------------------------------------------------------------------------------------------

  --*************************************************************************** MEMORY STAGE
  --*********************************************************************************************

  ----------------------------------------------------------- ENTITY DEFINITION

  ----------------------------------------------------------- COMBINATORIAL

  -- Data Memory Signals
  -- NOTE: the alu_out_m signal is truncated if the memory address space is smaller
  -- then the DLX architecture word width
  --DMEM_RWADDR <= std_logic_vector(resize(unsigned(alu_out_m), DMEM_RWADDR'length));
  DMEM_RWADDR <= alu_out_m;
  DMEM_DIN    <= dmem_din_m;
  dmem_dout_m <= DMEM_DOUT;

  DP_SIG.cmpr_0_is_0_m  <= is_0_m;
  DP_SIG.instr_opcode_m <= instr_opcode_m;

  -----------------------------------------------------------------------------------------------

  --********************************************************* PIPELINE REGISTERS MEMORY/WRITEBACK
  --*********************************************************************************************

  U_PC_PLS_4_REG_MWB : entity work.reg_pipo(BEHAV_WITH_EN_INIT)
    generic map (
      DATA_W => pc_pls_4_m'length, INIT_VAL => std_logic_vector(to_unsigned(C_REG_INIT_VAL,pc_pls_4_m'length))
    )
    port map (
      CLK    => CLK,
      RST_AN => RST_AN,
      EN     => '1',
      INIT   => HZRD_SIG.flush_mwb,
      DIN    => pc_pls_4_m,
      DOUT   => pc_pls_4_wb
    );

  U_ALU_OUT_REG_MWB : entity work.reg_pipo(BEHAV_WITH_EN_INIT)
    generic map (
      DATA_W => alu_out_m'length, INIT_VAL => std_logic_vector(to_unsigned(C_REG_INIT_VAL,alu_out_m'length))
    )
    port map (
      CLK    => CLK,
      RST_AN => RST_AN,
      EN     => '1',
      INIT   => HZRD_SIG.flush_mwb,
      DIN    => alu_out_m,
      DOUT   => alu_out_wb
    );

  U_DMEM_DOUT_REG_MWB : entity work.reg_pipo(BEHAV_WITH_EN_INIT)
    generic map (
      DATA_W => dmem_dout_m'length, INIT_VAL => std_logic_vector(to_unsigned(C_REG_INIT_VAL,dmem_dout_m'length))
    )
    port map (
      CLK    => CLK,
      RST_AN => RST_AN,
      EN     => '1',
      INIT   => HZRD_SIG.flush_mwb,
      DIN    => dmem_dout_m,
      DOUT   => dmem_dout_wb
    );

  U_RF_WADDR_REG_MWB : entity work.reg_pipo(BEHAV_WITH_EN_INIT)
    generic map (
      DATA_W => rf_waddr_m'length, INIT_VAL => std_logic_vector(to_unsigned(C_REG_INIT_VAL,rf_waddr_m'length))
    )
    port map (
      CLK    => CLK,
      RST_AN => RST_AN,
      EN     => '1',
      INIT   => HZRD_SIG.flush_mwb,
      DIN    => rf_waddr_m,
      DOUT   => rf_waddr_wb
    );

  -----------------------------------------------------------------------------------------------

  --*************************************************************************** WRITE BACK STAGE
  --*********************************************************************************************

  ----------------------------------------------------------- ENTITY DEFINITION

  ----------------------------------------------------------- COMBINATORIAL
  rf_din_wb <= dmem_dout_wb when CTRL_WORD.rf_wb_dmem_dout_sel = '1' else
               pc_pls_4_wb  when CTRL_WORD.jal_en = '1' else
               alu_out_wb;

end architecture BEHAVIOURAL;

-- configuration CFG_DATAPATH_BEHAVIOURAL of DATAPATH is
--  for BEHAVIOURAL
--  end for;
-- end CFG_DATAPATH_BEHAVIOURAL;
