--------------------------------------------------------------------------------
-- Engineer: Simone Ruffini  [simone.ruffini@studenti.polito.it]
-- Engineer: Matteo Bonora    [matteo.bonora@studenti.polito.it]
-- Engineer: Lorenzo Latella  [s292653@studenti.polito,it]
--
-- Create Date:     Wed May  4 09:47:35 PM CEST 2022
-- Design Name:     Common Package
-- Module Name:     DLX_PKG.vhd
-- Project Name:    DLX
-- Description:     Common package
--
-- Revision:
-- Revision 00 - Simone Ruffini
--  first implementation
-- Additional Comments:
--
--------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library ieee;
  use work.alu_pkg.all;

package DLX_PKG is

  -- DLX GLOBAL CONSTANTS
  constant C_ARCH_BIT_DEPTH : integer := 32; -- DLX Architecture bit depth
  constant C_INSTR_OPCODE_W : integer := 6;  -- DLX Instruction Operation Code width
  constant C_INSTR_FIELD_W  : integer := 5;  -- DLX Instruction Generic Field width

  -- DERIVED CONSTANTS
  constant C_ARCH_WORD_W       : integer := C_ARCH_BIT_DEPTH; -- DLX architecture word width
  constant C_ALU_PRECISION_BIT : integer := C_ARCH_BIT_DEPTH;
  constant C_INSTR_RS1_W       : integer := C_INSTR_FIELD_W;
  constant C_INSTR_RS2_W       : integer := C_INSTR_FIELD_W;
  constant C_INSTR_RS3_W       : integer := C_INSTR_FIELD_W;

  type cntrl_wrd_t is record
    -- Fetch
    -- Decode
    jal      : std_logic;
    rf_ra_en : std_logic;
    rf_rb_en : std_logic;
    rf_wen   : std_logic;
    reg_we   : std_logic;
    -- Execute
    r_type_sel   : std_logic;  -- selects whethere the write back address is the one obtained from an i-type INSTR or a R-TYPE
    imm_sel      : std_logic;
    pc_pls_4_sel : std_logic;
    alu_func     : alu_func_t; -- the convertion for this signal is done inside the control unit (integer to alu_func_t)
  -- Memory
  -- Writeback
  end record cntrl_wrd_t;

  type cw_signals_type is (
    -- Decode
    A_RE,
    B_RE,
    REG_WE,
    -- Execute
    IMM_SEL,
    PC_SEL,
    ALU_OP0,
    ALU_OP1,
    ALU_OP2,
    ALU_OP3,
    J_TYPE,
    -- Memory
    DM_RE,
    DM_WE,
    -- Writeback
    WB_MUX,
    CW_SIZE
  );

  ---- Position of the control word signals. Used internally to map the internal
  ---- std_logic_vector to the output signals.
  ---- Decode
  -- constant A_RE : integer := 0;  -- enables the read port 1 of the Register File
  -- constant B_RE : integer := 1;  -- enables the read port 2 of the Register File
  -- constant REG_WE : integer := 2;  -- Selects the right immediate value for the instruction type
  -- constant IMM_SEL : integer := 3;  -- enables register file write
  ---- Execute
  -- constant PC_SEL  : integer := 4;  -- selects the immediate register as the second input for the ALU
  -- constant ALU_OP1 : integer := 5;  -- alu control bit
  -- constant ALU_OP2 : integer := 6;  -- alu control bit
  -- constant ALU_OP3 : integer := 7;  -- alu control bit
  -- constant ALU_OP4 : integer := 8;  -- alu control bit
  ---- Memory
  -- constant J_TYPE  : integer := 9;  -- enables the read-out of the memory
  -- constant DM_RE  : integer := 10; -- enables the write-in of the memory
  ---- Write-back
  -- constant DM_WE : integer := 12; -- Selects the output of the datapath
  -- constant WB_MUX : integer := 13; -- Selects the output of the datapath
  -- constant CW_SIZE  : integer := 14; -- Length of the control word == Number of control signals

  ---- Control unit input size
  -- constant OP_CODE_SIZE : integer :=  6;  -- OPCODE field size
  -- constant FUNC_SIZE    : integer :=  11; -- FUNC field size

  -- ALU control word (ALU0,ALU1,ALU2,ALU3 control signals)
  constant ALU_CW_SIZE : integer := 4;
  constant ALU_ADD_CW  : std_logic_vector(ALU_CW_SIZE - 1 downto 0) := "0000"; -- ALU1=0 ALU2=0
  constant ALU_SUB_CW  : std_logic_vector(ALU_CW_SIZE - 1 downto 0) := "0001"; -- ALU1=0 ALU2=1
  constant ALU_AND_CW  : std_logic_vector(ALU_CW_SIZE - 1 downto 0) := "0010"; -- ALU1=1 ALU2=0
  constant ALU_OR_CW   : std_logic_vector(ALU_CW_SIZE - 1 downto 0) := "0011"; -- ALU1=1 ALU2=1

end package DLX_PKG;
