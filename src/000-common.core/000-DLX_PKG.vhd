--------------------------------------------------------------------------------
-- Engineer: Simone Ruffini  [simone.ruffini@studenti.polito.it]
-- Engineer: Matteo Bonora    [matteo.bonora@studenti.polito.it]
-- Engineer: Lorenzo Latella  [s292653@studenti.polito,it]
--
-- Create Date:     Wed May  4 09:47:35 PM CEST 2022
-- Design Name:     DLX_PKG
-- Project Name:    DLX
-- Description:     Common package
--
-- Revision:
-- Revision 00 - Simone Ruffini
--  first implementation
-- Additional Comments:
--
--------------------------------------------------------------------------------

------------------------------------------------------------- PACKAGES/LIBRARIES

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

library work;
  use work.vhdl_help_func_pkg.all;
  use work.alu_pkg.all; -- TODO: try to remove this dependency

------------------------------------------------------------- PACKAGE
package DLX_PKG is

  ----------------------------------------------------------- CONSTANTS 1

  -- DLX Architecture bit depth
  constant C_ARCH_BIT_DEPTH : integer := 32; -- Don't use this constant directly

  -- DLX GLOBAL CONSTANTS ======================================================
  -- ===========================================================================

  -- DLX Instruction Operation Code width
  constant C_INSTR_OPCODE_W : integer := 6;
  -- DLX Instruction Function Code width (r-type instructions)
  constant C_INSTR_FUNC_W : integer := 11;
  -- DLX Register File Address Width
  -- => DLX RF address space == 32
  constant C_RF_ADDR_W : integer := VHFP_ilog2(32);
  -- DLX Instruction Memory Address Width
  -- => DLX I-MEM address space == 2**C_DMEM_ADDRW
  constant C_IMEM_ADDR_W : integer := 8;
  -- DLX Data Memory Address Width
  -- => DLX D-MEM address space == 2**C_DMEM_ADDRW
  constant C_DMEM_ADDR_W : integer := 8;
  -- TODO maybe place constant in different file
  -- Register number in which jal instruction will save the return address
  constant C_JAL_RET_ADDR_REG : integer := 31;

  -- DERIVED CONSTANTS =========================================================
  -- ===========================================================================

  constant C_ALU_PRECISION_BIT : integer := C_ARCH_BIT_DEPTH;

  -- Widths
  ---
  -- DLX architecture word width
  constant C_ARCH_WORD_W : integer := C_ARCH_BIT_DEPTH;
  -- DLX Instruction Generic Field width (5)
  constant C_INSTR_FIELD_W : integer := C_RF_ADDR_W;
  -- DLX Instruction I-Type immediate field width (16)
  constant C_INSTR_I_TYPE_IMM_W : integer := C_ARCH_BIT_DEPTH - (C_INSTR_OPCODE_W + 2 * C_INSTR_FIELD_W);
  -- DLX Instruction J-Type immediate field width (26)
  constant C_INSTR_J_TYPE_IMM_W : integer := C_ARCH_BIT_DEPTH - C_INSTR_OPCODE_W;

  -- Bit Index Position of fields inside instruction Word
  --
  constant C_INSTR_OPCODE_START_POS_BIT : integer := C_ARCH_BIT_DEPTH - C_INSTR_OPCODE_W;
  constant C_INSTR_RS1_START_POS_BIT    : integer := C_ARCH_BIT_DEPTH - (C_INSTR_OPCODE_W + C_INSTR_FIELD_W);
  constant C_INSTR_RS1_W                : integer := C_INSTR_FIELD_W;
  constant C_INSTR_RS2_START_POS_BIT    : integer := C_INSTR_RS1_START_POS_BIT - C_INSTR_FIELD_W;
  constant C_INSTR_RS2_W                : integer := C_INSTR_FIELD_W;
  constant C_INSTR_RS3_START_POS_BIT    : integer := C_INSTR_RS2_START_POS_BIT - C_INSTR_FIELD_W;
  constant C_INSTR_RS3_W                : integer := C_INSTR_FIELD_W;
  constant C_INSTR_FUNC_START_POS_BIT   : integer := C_INSTR_RS3_START_POS_BIT - C_INSTR_FUNC_W;
  -- I type instructions have 2 operand fields and then the immediate field
  constant C_INSTR_I_TYPE_IMM_START_POS_BIT : integer := C_INSTR_RS2_START_POS_BIT - C_INSTR_I_TYPE_IMM_W;
  -- J type instruction have only one field
  constant C_INSTR_J_TYPE_IMM_START_POS_BIT : integer := C_ARCH_BIT_DEPTH - (C_INSTR_OPCODE_W + C_INSTR_J_TYPE_IMM_W);

  ----------------------------------------------------------- TYPES

  -- CONTROL WORD TYPE =========================================================
  -- ===========================================================================

  type ctrl_word_t is record
    --======================= Fetch
    --======================= Decode
    j_type_imm_sel : std_logic;
    --======================= Execute
    r_type_sel   : std_logic;  -- selects whethere the write back address is the one obtained from an i-type INSTR or a R-TYPE
    imm_sel      : std_logic;
    pc_pls_4_sel : std_logic;
    alu_func     : alu_func_t; -- the convertion for this signal is done inside the control unit (integer to alu_func_t)
    --======================= Memory
    jump_en       : std_logic; -- selects wheter the PC will take the jump instruction address instead of PC+4
    branch_en     : std_logic; -- selects wheter the PC will take the branch instruction address instead of PC+4
    comp_0_invert : std_logic;
    dmem_wen      : std_logic;
    --======================= Writeback
    rf_wb_dmem_dout_sel : std_logic;
    jal_en              : std_logic;
    rf_wen              : std_logic;
  end record ctrl_word_t;

  ----------------------------------------------------------- CONSTANTS 2
  constant C_CTRL_WORD_0S : ctrl_word_t :=
  (
    j_type_imm_sel      =>'0',
    r_type_sel          =>'0',
    imm_sel             =>'0',
    pc_pls_4_sel        =>'0',
    alu_func            =>NOP,
    jump_en             =>'0',
    branch_en           =>'0',
    comp_0_invert       =>'0',
    dmem_wen            =>'0',
    rf_wb_dmem_dout_sel =>'0',
    jal_en              =>'0',
    rf_wen              =>'0'
  );

  -- DATAPATH SIGNALS TYPE =====================================================
  -- ===========================================================================

  type dp_sig_t is record
    --======================= Fetch
    --======================= Decode
    --======================= Execute
    --======================= Memory
    cmpr_0_is_0_m  : std_logic;                                       -- 0 comprator output is 0 (stage memory signal)
    instr_opcode_m : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0); -- opcode of the instruction in memory stage
  --======================= Writeback
  end record dp_sig_t;

  ----------------------------------------------------------- CONSTANTS 2
  constant C_DP_SIG_0S : dp_sig_t :=
  (
    instr_opcode_m => (others => '1'), -- non existent instruction
    cmpr_0_is_0_m  => '0'              -- data is 0
  );

  -- HAZARD SIGNALS TYPE =======================================================
  -- ===========================================================================

  type hzrd_sig_t is record
    --======================= Fetch/Decode
    stall_fd : std_logic;  -- stall the fetch stage
    flush_fd : std_logic;  -- flush fetch stage pipeline registers
    --======================= Decode/Execute
    stall_de : std_logic;  -- stall the fetch stage
    flush_de : std_logic;  -- flush decode stage pipeline registers
    --======================= Execute/Memory
    flush_em : std_logic;  -- flush execute stage pipeline registers
    --======================= Memory/WriteBack
    flush_mwb : std_logic; -- flush memory stage pipeline registers
  --======================= Writeback
  -- nothing can be done here
  end record hzrd_sig_t;

  ----------------------------------------------------------- CONSTANTS 2
  constant C_HZRD_SIG_0S : hzrd_sig_t :=
  (
    stall_fd  => '0', -- do not stall fetch
    flush_fd  => '0', -- do not flush decode
    stall_de  => '0', -- do not stall decode
    flush_de  => '0', -- do not flush decode
    flush_em  => '0', -- do not flush execute
    flush_mwb => '0'  -- do not flush memory
  );

  ----------------------------------------------------------- FUNCTIONS

  -- This function checks the derived constants calculated in the DLX_PKG
  -- NB run this function in the top_level of the DLX design

  function dlx_pkg_check_assertions
    return natural;

  function print_ctrl_wrd (ctrl_word : ctrl_word_t)
    return string;

  -- return opcode of instruction

  function get_opcode (instr: std_logic_vector(C_ARCH_WORD_W - 1 downto 0))
    return std_logic_vector; -- std_logic_vector(C_INSTR_OPCODE_W-1 downto 0)

  -- return func of instruction

  function get_func (instr: std_logic_vector(C_ARCH_WORD_W - 1 downto 0))
    return std_logic_vector; -- std_logic_vector(C_INSTR_FUNC_W-1 downto 0)

  -- return rs1 field of instruction

  function get_rs1 (instr: std_logic_vector(C_ARCH_WORD_W - 1 downto 0))
    return std_logic_vector;

  -- return rs2 field of instruction

  function get_rs2 (instr: std_logic_vector(C_ARCH_WORD_W - 1 downto 0))
    return std_logic_vector;

  -- return rs3 field of instruction

  function get_rs3 (instr: std_logic_vector(C_ARCH_WORD_W - 1 downto 0))
    return std_logic_vector;

  -- return i-type immediate of instruction

  function get_i_type_imm (instr: std_logic_vector(C_ARCH_WORD_W - 1 downto 0))
    return std_logic_vector; -- std_logic_vector(C_INSTR_I_TYPE_IMM_W-1 downto 0);

  -- return j-type immediate of instruction

  function get_j_type_imm (instr: std_logic_vector(C_ARCH_WORD_W - 1 downto 0))
    return std_logic_vector; -- std_logic_vector(C_INSTR_J_TYPE_IMM_W-1 downto 0);

end package DLX_PKG;

package body DLX_PKG is

  function dlx_pkg_check_assertions return natural is

  begin

    -- Asserts on derived constants
    assert C_INSTR_FIELD_W > 0
      report "The constant C_INSTR_FIELD_W is less then equal 0, check why"
      severity failure;
    report "C_INSTR_FIELD_W                  = " & integer'image(C_INSTR_FIELD_W);

    assert C_INSTR_I_TYPE_IMM_W > 0
      report "The constant C_INSTR_I_TYPE_IMM_W is less then equal 0, check why"
      severity failure;
    report "C_INSTR_I_TYPE_IMM_W             = " & integer'image(C_INSTR_I_TYPE_IMM_W);

    assert C_INSTR_J_TYPE_IMM_W > 0
      report "The constant C_INSTR_J_TYPE_IMM_W is less then equal 0, check why"
      severity failure;
    report "C_INSTR_J_TYPE_IMM_W             = " & integer'image(C_INSTR_J_TYPE_IMM_W);

    assert C_INSTR_OPCODE_START_POS_BIT >= 0
      report "The constant C_INSTR_OPCODE_START_POS_BIT is less then equal 0, check why"
      severity failure;
    report "C_INSTR_OPCODE_START_POS_BIT     = " & integer'image(C_INSTR_OPCODE_START_POS_BIT);

    assert C_INSTR_RS1_START_POS_BIT >= 0
      report "The constant C_INSTR_RS1_START_POS_BIT is negative, check displacements"
      severity failure;
    report "C_INSTR_RS1_START_POS_BIT        = " & integer'image(C_INSTR_RS1_START_POS_BIT);

    assert C_INSTR_RS2_START_POS_BIT >= 0
      report "The constant C_INSTR_RS2_START_POS_BIT is negative, check displacements"
      severity failure;
    report "C_INSTR_RS2_START_POS_BIT        = " & integer'image(C_INSTR_RS2_START_POS_BIT);

    assert C_INSTR_RS3_START_POS_BIT >= 0
      report "The constant C_INSTR_RS3_START_POS_BIT is negative, check displacements"
      severity failure;
    report "C_INSTR_RS3_START_POS_BIT        = " & integer'image(C_INSTR_RS3_START_POS_BIT);

    assert C_INSTR_I_TYPE_IMM_START_POS_BIT >= 0
      report "The constant C_INSTR_I_TYPE_IMM_START_POS_BIT is negative, check displacements"
      severity failure;
    report "C_INSTR_I_TYPE_IMM_START_POS_BIT = " & integer'image(C_INSTR_I_TYPE_IMM_START_POS_BIT);

    assert C_INSTR_J_TYPE_IMM_START_POS_BIT >= 0
      report "The constant C_INSTR_J_TYPE_IMM_START_POS_BIT is negative, check displacements"
      severity failure;
    report "C_INSTR_J_TYPE_IMM_START_POS_BIT = " & integer'image(C_INSTR_J_TYPE_IMM_START_POS_BIT);

    assert C_INSTR_FUNC_START_POS_BIT >= 0
      report "The constant C_INSTR_FUNC_START_POS_BIT is negative, check displacements"
      severity failure;
    report "C_INSTR_FUNC_START_POS_BIT        = " & integer'image(C_INSTR_FUNC_START_POS_BIT);

    report "-> All checks are correct!";
    return 0;

  end dlx_pkg_check_assertions;

  function print_ctrl_wrd (ctrl_word : ctrl_word_t) return string is
  begin

    return "CTRL_WORD: {" &
  " jal_en =" & std_logic'image(ctrl_word.jal_en) &
 ", j_type_imm_sel =" & std_logic'image(ctrl_word.j_type_imm_sel) &
 ", r_type_sel =" & std_logic'image(ctrl_word.r_type_sel) &
 ", imm_sel =" & std_logic'image(ctrl_word.imm_sel) &
 ", pc_pls_4_sel =" & std_logic'image(ctrl_word.pc_pls_4_sel) &
 ", alu_func =" & alu_func_t'image(ctrl_word.alu_func) &
 ", jump_en =" & std_logic'image(ctrl_word.jump_en) &
 ", branch_en =" & std_logic'image(ctrl_word.branch_en) &
 ", comp_0_invert =" & std_logic'image(ctrl_word.comp_0_invert) &
 ", dmem_wen =" & std_logic'image(ctrl_word.dmem_wen) &
 ", rf_wb_dmem_dout_sel =" & std_logic'image(ctrl_word.rf_wb_dmem_dout_sel) &
 ", rf_wen =" & std_logic'image(ctrl_word.rf_wen) & "}";

  end function print_ctrl_wrd;

  function get_opcode (instr: std_logic_vector(C_ARCH_WORD_W - 1 downto 0)) return std_logic_vector is

    variable ret : std_logic_vector(C_INSTR_OPCODE_W - 1 downto 0);

  begin

    ret := instr((C_INSTR_OPCODE_START_POS_BIT + C_INSTR_OPCODE_W) - 1 downto C_INSTR_OPCODE_START_POS_BIT);
    return ret;

  end function;

  function get_func (instr: std_logic_vector(C_ARCH_WORD_W - 1 downto 0)) return std_logic_vector is

    variable ret : std_logic_vector(C_INSTR_FUNC_W - 1 downto 0);

  begin

    ret := instr((C_INSTR_FUNC_START_POS_BIT + C_INSTR_FUNC_W) - 1 downto C_INSTR_FUNC_START_POS_BIT);
    return ret;

  end function;

  function get_rs1 (instr: std_logic_vector(C_ARCH_WORD_W - 1 downto 0)) return std_logic_vector is

    variable ret : std_logic_vector(C_INSTR_RS1_W - 1 downto 0);

  begin

    ret := instr((C_INSTR_RS1_START_POS_BIT + C_INSTR_RS1_W) - 1 downto C_INSTR_RS1_START_POS_BIT);
    return ret;

  end function;

  function get_rs2 (instr: std_logic_vector(C_ARCH_WORD_W - 1 downto 0)) return std_logic_vector is

    variable ret : std_logic_vector(C_INSTR_RS2_W - 1 downto 0);

  begin

    ret := instr((C_INSTR_RS2_START_POS_BIT + C_INSTR_RS2_W) - 1 downto C_INSTR_RS2_START_POS_BIT);
    return ret;

  end function;

  function get_rs3 (instr: std_logic_vector(C_ARCH_WORD_W - 1 downto 0)) return std_logic_vector is

    variable ret : std_logic_vector(C_INSTR_RS3_W - 1 downto 0);

  begin

    ret := instr((C_INSTR_RS3_START_POS_BIT + C_INSTR_RS3_W) - 1 downto C_INSTR_RS3_START_POS_BIT);
    return ret;

  end function;

  function get_i_type_imm (instr: std_logic_vector(C_ARCH_WORD_W - 1 downto 0)) return std_logic_vector is

    variable ret : std_logic_vector(C_INSTR_I_TYPE_IMM_W - 1 downto 0);

  begin

    ret := instr((C_INSTR_I_TYPE_IMM_START_POS_BIT + C_INSTR_I_TYPE_IMM_W) - 1 downto C_INSTR_I_TYPE_IMM_START_POS_BIT);
    return ret;

  end function;

  function get_j_type_imm (instr: std_logic_vector(C_ARCH_WORD_W - 1 downto 0)) return std_logic_vector is

    variable ret : std_logic_vector(C_INSTR_J_TYPE_IMM_W - 1 downto 0);

  begin

    ret := instr((C_INSTR_J_TYPE_IMM_START_POS_BIT + C_INSTR_J_TYPE_IMM_W) - 1 downto C_INSTR_J_TYPE_IMM_START_POS_BIT);
    return ret;

  end function;

end package body DLX_PKG;
