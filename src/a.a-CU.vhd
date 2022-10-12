--------------------------------------------------------------------------------
-- Engineer: Simone Ruffini  [simone.ruffini@studenti.polito.it]
--           Lorenzo Latella [s292653@studenti.polito.it]
--           Matteo Bonora   [matteo.bonora@studenti.polito.it]
--
-- Create Date:     Wed May  4 16:45:33 CEST 2022
-- Design Name:     Control Unit Hardwired
-- Module Name:     CU.vhd
-- Project Name:    DLX control unit
-- Description:     Control unit for the DLX datapath
--
--
-- Revision:
-- Revision 00 - Simone Ruffini
--  * first implementation
-- Revision 01 - Simone Ruffini - Fri Jul 22 03:37:10 PM CEST 2022
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
-- use work.cu_pkg.all;

------------------------------------------------------------- ENTITY

entity CU is
  port (
    CLK              : in    std_logic;                                     -- Clock Signal (rising-edge trigger)
    RST_AN           : in    std_logic;                                     -- Reset Signal: Asyncronous Active Low (Negative)
    INSTR            : in    std_logic_vector(C_ARCH_WORD_W - 1 downto 0);  -- Instruction Word from Instr.MEM
    CTRL_WORD        : out   cntrl_word_t                                   -- Control Word
  );
end entity CU;

------------------------------------------------------------- ARCHITECTURE

architecture BEHAVIORAL of CU is

  ----------------------------------------------------------- CONSTANTS 1

  -- Look Up Table Size in term of number of entries a.k.a control words
  constant C_LUT_SIZE               : integer := 2 ** (C_INSTR_OPCODE_W);

  ----------------------------------------------------------- TYPES

  type opcode_cw_t is record
    --======================= Fetch
    branch_en : std_logic;
    jump_en   : std_logic;
    --======================= Decode
    jal_en         : std_logic;
    rf_wen         : std_logic;
    j_type_imm_sel : std_logic;
    --======================= Execute
    r_type_sel   : std_logic;
    imm_sel      : std_logic;
    pc_pls_4_sel : std_logic;
    --======================= Memory
    dmem_wen : std_logic;
    --======================= Writeback
    rf_wb_dmem_dout_sel : std_logic;
  end record opcode_cw_t;

  type func_cw_t is record
    alu_func : alu_func_t;
  end record func_cw_t;

  type op_lut_t is array (integer range <>) of opcode_cw_t;

  type func_lut_t is array (integer range <>) of func_cw_t;

  -- BAD code deduplication but I don't know an easier way that keeps things
  -- clean
  -- fetch stage signals record

  type fetch_stage_sig_t is record
    branch_en : std_logic;
    jump_en   : std_logic;
  end record fetch_stage_sig_t;

  -- Decode stage signals record

  type decode_stage_sig_t is record
    jal_en         : std_logic;
    rf_wen         : std_logic;
    j_type_imm_sel : std_logic;
  end record decode_stage_sig_t;

  -- Execute stage signals record

  type execute_stage_sig_t is record
    r_type_sel   : std_logic;
    imm_sel      : std_logic;
    pc_pls_4_sel : std_logic;
    alu_func     : alu_func_t;
  end record execute_stage_sig_t;

  -- Memory stage signals record

  type memory_stage_sig_t is record
    dmem_wen : std_logic;
  end record memory_stage_sig_t;

  -- Writeback stage signals record

  type writeback_stage_sig_t is record
    rf_wb_dmem_dout_sel : std_logic;
  end record writeback_stage_sig_t;

  ----------------------------------------------------------- FUNCTIONS

  ----------------------------------------------------------- CONSTANTS 2

  constant C_FETCH_STAGE_SIG_0S     : fetch_stage_sig_t :=
  (
    branch_en => '0',
    jump_en   => '0'
  );

  constant C_DECODE_STAGE_SIG_0S    : decode_stage_sig_t :=
  (
    jal_en         => '0',
    rf_wen         => '0',
    j_type_imm_sel => '0'
  );
  constant C_EXECUTE_STAGE_SIG_0S   : execute_stage_sig_t :=
  (
    r_type_sel   => '0',
    imm_sel      => '0',
    pc_pls_4_sel => '0',
    alu_func     => ADD
  );
  constant C_MEMORY_STAGE_SIG_0S    : memory_stage_sig_t :=
  (
    dmem_wen => '0'
  );
  constant C_WRITEBACK_STAGE_SIG_0S : writeback_stage_sig_t :=
  (
    rf_wb_dmem_dout_sel => '0'
  );

  constant RTYPE_CW                 : opcode_cw_t :=
  (
    branch_en           =>'1',
    jump_en             =>'1',
    jal_en              =>'1',
    rf_wen              =>'1',
    j_type_imm_sel      =>'1',
    r_type_sel          =>'1',
    imm_sel             =>'1',
    pc_pls_4_sel        =>'1',
    alu_func            =>ADD,
    dmem_wen            =>'1',
    rf_wb_dmem_dout_sel =>'1'
  );
  constant JTYPE_JUMP_CW            : opcode_cw_t :=
  (
    branch_en           =>'1',
    jump_en             =>'1',
    jal_en              =>'1',
    rf_wen              =>'1',
    j_type_imm_sel      =>'1',
    r_type_sel          =>'1',
    imm_sel             =>'1',
    pc_pls_4_sel        =>'1',
    alu_func            =>ADD,
    dmem_wen            =>'1',
    rf_wb_dmem_dout_sel =>'1'
  );
  constant ITYPE_JAL_CW             : opcode_cw_t :=
  (
    branch_en           =>'1',
    jump_en             =>'1',
    jal_en              =>'1',
    rf_wen              =>'1',
    j_type_imm_sel      =>'1',
    r_type_sel          =>'1',
    imm_sel             =>'1',
    pc_pls_4_sel        =>'1',
    alu_func            =>ADD,
    dmem_wen            =>'1',
    rf_wb_dmem_dout_sel =>'1'
  );

  constant ITYPE_BEQZ_CW            : opcode_cw_t :=
  (
    branch_en           =>'1',
    jump_en             =>'1',
    jal_en              =>'1',
    rf_wen              =>'1',
    j_type_imm_sel      =>'1',
    r_type_sel          =>'1',
    imm_sel             =>'1',
    pc_pls_4_sel        =>'1',
    alu_func            =>ADD,
    dmem_wen            =>'1',
    rf_wb_dmem_dout_sel =>'1'
  );

  constant ITYPE_BNEZ_CW            : opcode_cw_t :=
  (
    branch_en           =>'1',
    jump_en             =>'1',
    jal_en              =>'1',
    rf_wen              =>'1',
    j_type_imm_sel      =>'1',
    r_type_sel          =>'1',
    imm_sel             =>'1',
    pc_pls_4_sel        =>'1',
    alu_func            =>ADD,
    dmem_wen            =>'1',
    rf_wb_dmem_dout_sel =>'1'
  );

  constant ITYPE_ADDI_CW            : opcode_cw_t :=
  (
    branch_en           =>'1',
    jump_en             =>'1',
    jal_en              =>'1',
    rf_wen              =>'1',
    j_type_imm_sel      =>'1',
    r_type_sel          =>'1',
    imm_sel             =>'1',
    pc_pls_4_sel        =>'1',
    alu_func            =>ADD,
    dmem_wen            =>'1',
    rf_wb_dmem_dout_sel =>'1'
  );

  constant ITYPE_SUBI_CW            : opcode_cw_t :=
  (
    branch_en           =>'1',
    jump_en             =>'1',
    jal_en              =>'1',
    rf_wen              =>'1',
    j_type_imm_sel      =>'1',
    r_type_sel          =>'1',
    imm_sel             =>'1',
    pc_pls_4_sel        =>'1',
    alu_func            =>ADD,
    dmem_wen            =>'1',
    rf_wb_dmem_dout_sel =>'1'
  );

  constant ITYPE_ANDI_CW            : opcode_cw_t :=
  (
    branch_en           =>'1',
    jump_en             =>'1',
    jal_en              =>'1',
    rf_wen              =>'1',
    j_type_imm_sel      =>'1',
    r_type_sel          =>'1',
    imm_sel             =>'1',
    pc_pls_4_sel        =>'1',
    alu_func            =>ADD,
    dmem_wen            =>'1',
    rf_wb_dmem_dout_sel =>'1'
  );

  constant ITYPE_ORI_CW             : opcode_cw_t :=
  (
    branch_en           =>'1',
    jump_en             =>'1',
    jal_en              =>'1',
    rf_wen              =>'1',
    j_type_imm_sel      =>'1',
    r_type_sel          =>'1',
    imm_sel             =>'1',
    pc_pls_4_sel        =>'1',
    alu_func            =>ADD,
    dmem_wen            =>'1',
    rf_wb_dmem_dout_sel =>'1'
  );

  constant ITYPE_XORI_CW            : opcode_cw_t :=
  (
    branch_en           =>'1',
    jump_en             =>'1',
    jal_en              =>'1',
    rf_wen              =>'1',
    j_type_imm_sel      =>'1',
    r_type_sel          =>'1',
    imm_sel             =>'1',
    pc_pls_4_sel        =>'1',
    alu_func            =>ADD,
    dmem_wen            =>'1',
    rf_wb_dmem_dout_sel =>'1'
  );

  constant ITYPE_SLLI_CW            : opcode_cw_t :=
  (
    branch_en           =>'1',
    jump_en             =>'1',
    jal_en              =>'1',
    rf_wen              =>'1',
    j_type_imm_sel      =>'1',
    r_type_sel          =>'1',
    imm_sel             =>'1',
    pc_pls_4_sel        =>'1',
    alu_func            =>ADD,
    dmem_wen            =>'1',
    rf_wb_dmem_dout_sel =>'1'
  );

  constant NOP_CW                   : opcode_cw_t :=
  (
    branch_en           =>'1',
    jump_en             =>'1',
    jal_en              =>'1',
    rf_wen              =>'1',
    j_type_imm_sel      =>'1',
    r_type_sel          =>'1',
    imm_sel             =>'1',
    pc_pls_4_sel        =>'1',
    alu_func            =>ADD,
    dmem_wen            =>'1',
    rf_wb_dmem_dout_sel =>'1'
  );

  constant ITYPE_SRLI_CW            : opcode_cw_t :=
  (
    branch_en           =>'1',
    jump_en             =>'1',
    jal_en              =>'1',
    rf_wen              =>'1',
    j_type_imm_sel      =>'1',
    r_type_sel          =>'1',
    imm_sel             =>'1',
    pc_pls_4_sel        =>'1',
    alu_func            =>ADD,
    dmem_wen            =>'1',
    rf_wb_dmem_dout_sel =>'1'
  );

  constant ITYPE_SNEI_CW            : opcode_cw_t :=
  (
    branch_en           =>'1',
    jump_en             =>'1',
    jal_en              =>'1',
    rf_wen              =>'1',
    j_type_imm_sel      =>'1',
    r_type_sel          =>'1',
    imm_sel             =>'1',
    pc_pls_4_sel        =>'1',
    alu_func            =>ADD,
    dmem_wen            =>'1',
    rf_wb_dmem_dout_sel =>'1'
  );

  constant ITYPE_SLEI_CW            : opcode_cw_t :=
  (
    branch_en           =>'1',
    jump_en             =>'1',
    jal_en              =>'1',
    rf_wen              =>'1',
    j_type_imm_sel      =>'1',
    r_type_sel          =>'1',
    imm_sel             =>'1',
    pc_pls_4_sel        =>'1',
    alu_func            =>ADD,
    dmem_wen            =>'1',
    rf_wb_dmem_dout_sel =>'1'
  );

  constant ITYPE_SGEI_CW            : opcode_cw_t :=
  (
    branch_en           =>'1',
    jump_en             =>'1',
    jal_en              =>'1',
    rf_wen              =>'1',
    j_type_imm_sel      =>'1',
    r_type_sel          =>'1',
    imm_sel             =>'1',
    pc_pls_4_sel        =>'1',
    alu_func            =>ADD,
    dmem_wen            =>'1',
    rf_wb_dmem_dout_sel =>'1'
  );

  constant LW_CW                    : opcode_cw_t :=
  (
    branch_en           =>'1',
    jump_en             =>'1',
    jal_en              =>'1',
    rf_wen              =>'1',
    j_type_imm_sel      =>'1',
    r_type_sel          =>'1',
    imm_sel             =>'1',
    pc_pls_4_sel        =>'1',
    alu_func            =>ADD,
    dmem_wen            =>'1',
    rf_wb_dmem_dout_sel =>'1'
  );

  constant SW_CW                    : opcode_cw_t :=
  (
    branch_en           =>'1',
    jump_en             =>'1',
    jal_en              =>'1',
    rf_wen              =>'1',
    j_type_imm_sel      =>'1',
    r_type_sel          =>'1',
    imm_sel             =>'1',
    pc_pls_4_sel        =>'1',
    alu_func            =>ADD,
    dmem_wen            =>'1',
    rf_wb_dmem_dout_sel =>'1'
  );

  constant SLL_FUNC_CW              : func_cw_t := (alu_func=>ADD);
  constant SRL_FUNC_CW              : func_cw_t := (alu_func=>ADD);
  constant ADD_FUNC_CW              : func_cw_t := (alu_func=>ADD);
  constant SUB_FUNC_CW              : func_cw_t := (alu_func=>ADD);
  constant AND_FUNC_CW              : func_cw_t := (alu_func=>ADD);
  constant OR_FUNC_CW               : func_cw_t := (alu_func=>ADD);
  constant XOR_FUNC_CW              : func_cw_t := (alu_func=>ADD);
  constant SNE_FUNC_CW              : func_cw_t := (alu_func=>ADD);
  constant SLE_FUNC_CW              : func_cw_t := (alu_func=>ADD);
  constant SGE_FUNC_CW              : func_cw_t := (alu_func=>ADD);

  -- Lut Memory containing the control words for each OPCODE.
  -- The OPCODE indexes the LUT.
  --
  -- cw = cw_lut(opcode)
  --
  -- NOTE:
  -- R-type instruction share the same control world a part from the ALU part:
  -- ALU1, ALU2 signals. Therefore all R-type instructions are mapped to the same
  -- control word (RTYPE_CW) and the ALU part will be handled by a different LUT
  --
  constant OPCODE_LUT               : op_lut_t(2 ** (C_INSTR_OPCODE_W) - 1 downto 0) :=
  (
    SLL_OPCODE_i  => RTYPE_CW,
    SRL_OPCODE_i  => RTYPE_CW,
    ADD_OPCODE_i  => RTYPE_CW,
    SUB_OPCODE_i  => RTYPE_CW,
    AND_OPCODE_i  => RTYPE_CW,
    OR_OPCODE_i   => RTYPE_CW,
    XOR_OPCODE_i  => RTYPE_CW,
    SNE_OPCODE_i  => RTYPE_CW,
    SLE_OPCODE_i  => RTYPE_CW,
    SGE_OPCODE_i  => RTYPE_CW,
    J_OPCODE_i    => JTYPE_JUMP_CW,
    JAL_OPCODE_i  => ITYPE_JAL_CW,
    BEQZ_OPCODE_i => ITYPE_BEQZ_CW,
    BNEZ_OPCODE_i => ITYPE_BNEZ_CW,
    ADDI_OPCODE_i => ITYPE_ADDI_CW,
    SUBI_OPCODE_i => ITYPE_SUBI_CW,
    ANDI_OPCODE_i => ITYPE_ANDI_CW,
    ORI_OPCODE_i  => ITYPE_ORI_CW,
    XORI_OPCODE_i => ITYPE_XORI_CW,
    SLLI_OPCODE_i => ITYPE_SLLI_CW,
    NOP_OPCODE_i  => NOP_CW,
    SRLI_OPCODE_i => ITYPE_SRLI_CW,
    SNEI_OPCODE_i => ITYPE_SNEI_CW,
    SLEI_OPCODE_i => ITYPE_SLEI_CW,
    SGEI_OPCODE_i => ITYPE_SGEI_CW,
    LW_OPCODE_i   => LW_CW,
    SW_OPCODE_i   => SW_CW,
    others        => (others => '0')                                               -- this disables all enable signals so nothing would work
  );

  -- Lut Memory containing the ALU control words for each FUNC of and R-type instruction.
  -- The FUNC indexes the LUT.
  --
  -- alu_cw = alu_cw_lut(FUNC)
  --
  -- The ALU control words will drive directly ALU1 and ALU2 signals when the
  -- opcode is of an r-type instruction
  --
  constant ALU_CW_LUT               : func_lut_t(2 ** (C_INSTR_FUNC_W) - 1 downto 0) :=
  (
    SLL_FUNC_i  => SLL_FUNC_CW,
    SRL_FUNC_i  => SRL_FUNC_CW,
    ADD_FUNC_i  => ADD_FUNC_CW,
    SUB_FUNC_i  => SUB_FUNC_CW,
    AND_FUNC_i  => AND_FUNC_CW,
    OR_FUNC_i   => OR_FUNC_CW,
    XOR_FUNC_i  => XOR_FUNC_CW,
    SNE_FUNC_i  => SNE_FUNC_CW,
    SLE_FUNC_i  => SLE_FUNC_CW,
    SGE_FUNC_i  => SGE_FUNC_CW,
    others      => ADD                                                             -- for other function do and ADD operation
  );

  ----------------------------------------------------------- SIGNALS

  signal opcode                     : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0);
  signal func                       : std_logic_vector(C_INSTR_FUNC_W - 1 downto 0);

  signal cw                         : std_logic_vector(CW_SIZE - 1 downto 0);      -- full control word read from cw_lut
  signal cw1                        : std_logic_vector(CW_SIZE - 1 downto 0);      -- cw 1 clk delay stage
  signal cw2                        : std_logic_vector(CW_SIZE - 1 downto 0);      -- cw 2 clk delay stage

  signal alu_cw                     : std_logic_vector(ALU_CW_SIZE - 1 downto 0);  -- alu control word read from alu_cw_lut
  signal alu_cw1                    : std_logic_vector(ALU_CW_SIZE - 1 downto 0);  -- alu_cw 1 clk delay stage

  -- TODO delete
  -- signal control_word : cntrl_word_t;

  -- Fetch signals
  signal fetch_sig                  : fetch_stage_sig_t;

  -- Decode signals and delays
  signal decode_sig                 : decode_stage_sig_t;
  signal decode_sig_d1              : decode_stage_sig_t;

  -- Execute signals and delays
  signal execute_sig                : execute_stage_sig_t;
  signal execute_sig_d1             : execute_stage_sig_t;
  signal execute_sig_d2             : execute_stage_sig_t;

  -- Memory signals and delays
  signal memory_sig                 : memory_stage_sig_t;
  signal memory_sig_d1              : memory_stage_sig_t;
  signal memory_sig_d2              : memory_stage_sig_t;
  signal memory_sig_d3              : memory_stage_sig_t;

  -- Writeback signals and delays
  signal writeback_sig              : writeback_stage_sig_t;
  signal writeback_sig_d1           : writeback_stage_sig_t;
  signal writeback_sig_d2           : writeback_stage_sig_t;
  signal writeback_sig_d3           : writeback_stage_sig_t;
  signal writeback_sig_d4           : writeback_stage_sig_t;

begin

  ----------------------------------------------------------- ENTITY DEFINITION

  ----------------------------------------------------------- COMBINATORIAL

  -- Extract the opcode and the func from the instruction word
  opcode <= INSTR((C_INSTR_OPCODE_START_POS_BIT + C_INSTR_OPCODE_W) - 1 downto C_INSTR_OPCODE_START_POS_BIT);
  func   <= INSTR((C_INSTR_FUNC_START_POS_BIT + C_INSTR_FUNC_W) - 1 downto C_INSTR_FUNC_START_POS_BIT);

  -- control_word <= (
  --  branch_en <=OPCODE_LUT(opcode).branch_en ,
  --  jump_en   <=OPCODE_LUT(opcode).jump_en,
  --  jal_en <=OPCODE_LUT(opcode).jal_en,
  --  rf_wen         <=OPCODE_LUT(opcode).rf_wen,
  --  j_type_imm_sel <=OPCODE_LUT(opcode).j_type_imm_sel,
  --  r_type_sel   <=OPCODE_LUT(opcode).r_type_sel,
  --  imm_sel      <=OPCODE_LUT(opcode).imm_sel,
  --  pc_pls_4_sel <=OPCODE_LUT(opcode).pc_pls_4_sel,
  --  alu_func     <=ALU_LUT(func).alu_func,
  --  dmem_wen <=OPCODE_LUT(opcode).dmem_wen,
  --  rf_wb_dmem_dout_sel <=OPCODE_LUT(opcode).rf_wb_dmem_dout_sel
  --);

  -- Extract the signals from the control word in the helpers for the pipeline
  fetch_sig   <= (
                  branch_en =>OPCODE_LUT(opcode).branch_en,
                  jump_en   =>OPCODE_LUT(opcode).jump_en
                );
  decode_sig  <= (
                  jal_en         =>OPCODE_LUT(opcode).jal_en,
                  rf_wen         =>OPCODE_LUT(opcode).rf_wen,
                  j_type_imm_sel =>OPCODE_LUT(opcode).j_type_imm_sel
                );
  execute_sig <= (
                  r_type_sel   =>OPCODE_LUT(opcode).r_type_sel,
                  imm_sel      =>OPCODE_LUT(opcode).imm_sel,
                  pc_pls_4_sel =>OPCODE_LUT(opcode).pc_pls_4_sel,
                  alu_func     =>ALU_LUT(func).alu_func
                );

  memory_sig <= (
                 dmem_wen =>OPCODE_LUT(opcode).dmem_wen
               );

  writeback_sig <= (
                    rf_wb_dmem_dout_sel =>OPCODE_LUT(opcode).rf_wb_dmem_dout_sel
                  );

  -- fetch_sig <= (
  --  branch_en <= control_word.branch_en,
  --  jump_en   <= control_word.jump_en
  --);
  -- decode_sig <= (
  --    jal_en         <=control_word.jal_en ,
  --    rf_wen         <=control_word.rf_wen         ,
  --    j_type_imm_sel <=control_word.j_type_imm_sel
  --);
  -- execute_sig <= (
  --  r_type_sel   <=control_word.r_type_sel   ,
  --  imm_sel      <=control_word.imm_sel      ,
  --  pc_pls_4_sel <=control_word.pc_pls_4_sel ,
  --  alu_func     <=control_word.alu_func
  --);

  -- memory_sig <= (
  --  dmem_wen <=control_word.dmem_wen
  --);

  -- writeback_sig <= (
  --  rf_wb_dmem_dout_sel <=control_word.rf_wb_dmem_dout_sel
  --);

  CTRL_WORD.branch_en           <= fetch_sig.branch_en;
  CTRL_WORD.jump_en             <= fetch_sig.jump_en;
  CTRL_WORD.jal_en              <= decode_sig_d1.jal_en;
  CTRL_WORD.rf_wen              <= decode_sig_d1.rf_wen;
  CTRL_WORD.j_type_imm_sel      <= decode_sig_d1.j_type_imm_sel;
  CTRL_WORD.r_type_sel          <= execute_sig_d2.r_type_sel;
  CTRL_WORD.imm_sel             <= execute_sig_d2.imm_sel;
  CTRL_WORD.pc_pls_4_sel        <= execute_sig_d2.pc_pls_4_sel;
  CTRL_WORD.alu_func            <= execute_sig_d2.alu_func;
  CTRL_WORD.dmem_wen            <= memory_sig_d3.dmem_wen;
  CTRL_WORD.rf_wb_dmem_dout_sel <= writeback_sig_d4.rf_wb_dmem_dout_sel;

  ----------------------------------------------------------- PROCESSES

  -- process to pipeline control words
  P_DELAYS : process (CLK, RST_AN) is
  begin

    if (RST_AN = '0') then
      decode_sig_d1 <= C_DECODE_STAGE_SIG_0S;

      execute_sig_d1 <= C_EXECUTE_STAGE_SIG_0S;
      execute_sig_d2 <= C_EXECUTE_STAGE_SIG_0S;

      memory_sig_d1 <= C_MEMORY_STAGE_SIG_0S;
      memory_sig_d2 <= C_MEMORY_STAGE_SIG_0S;
      memory_sig_d3 <= C_MEMORY_STAGE_SIG_0S;

      writeback_sig_d1 <= C_WRITEBACK_STAGE_SIG_0S;
      writeback_sig_d2 <= C_WRITEBACK_STAGE_SIG_0S;
      writeback_sig_d3 <= C_WRITEBACK_STAGE_SIG_0S;
      writeback_sig_d4 <= C_WRITEBACK_STAGE_SIG_0S;
    elsif (CLK'event and CLK = '1') then     -- rising clock edge
      decode_sig_d1 <= decode_sig;

      execute_sig_d1 <= execute_sig;
      execute_sig_d2 <= execute_sig_d1;

      memory_sig_d1 <= memory_sig;
      memory_sig_d2 <= memory_sig_d1;
      memory_sig_d3 <= memory_sig_d2;

      writeback_sig_d1 <= writeback_sig;
      writeback_sig_d2 <= writeback_sig_d1;
      writeback_sig_d3 <= writeback_sig_d2;
      writeback_sig_d4 <= writeback_sig_d3;
    end if;

  end process P_DELAYS;

end architecture BEHAVIORAL;

-- configuration CFG_CU_BEHAVIORAL of CU is
-- for BEHAVIORAL
-- end for;
-- end configuration;

