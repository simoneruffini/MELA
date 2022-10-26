--------------------------------------------------------------------------------
-- Engineer: Simone Ruffini [simone.ruffini@studenti.polito.it,simone.ruffini@tutanota.com]
--
-- Create Date:     Wed Oct 19 01:14:03 PM CEST 2022
-- Module Name:     HU
-- Project Name:    DLX
-- Description:     Hazard Unit
-- Constraints:
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

entity HU is
  port (
    CLK              : in    std_logic;  -- Clock Signal (rising-edge trigger)
    RST_AN           : in    std_logic;  -- Reset Signal: Asyncronous Active Low (Negative)
    DP_SIG           : in    dp_sig_t;   -- datapath signals
    HZRD_SIG         : out   hzrd_sig_t  -- hazard signals
  );
end entity HU;

------------------------------------------------------------- ARCHITECTURE

architecture BEHAVIOURAL of HU is

  ----------------------------------------------------------- CONSTANTS 1

  ----------------------------------------------------------- TYPES

  ----------------------------------------------------------- FUNCTIONS

  ----------------------------------------------------------- CONSTANTS 2

  ----------------------------------------------------------- SIGNALS

  signal flush_pipeline_branch : std_logic;
  signal flush_pipeline_jump   : std_logic;

  -- DBUG STUFF
  signal dbg_instr_opcode_m    : instr_t;

begin

  ----------------------------------------------------------- ENTITY DEFINITION

  ----------------------------------------------------------- COMBINATORIAL

  --======================= Fetch/Decode
  HZRD_SIG.stall_fd <= '0';
  HZRD_SIG.flush_fd <= flush_pipeline_branch or flush_pipeline_jump;
  --======================= Decode/Execute
  HZRD_SIG.stall_de <= '0';
  HZRD_SIG.flush_de <= flush_pipeline_branch or flush_pipeline_jump;
  --======================= Execute/Memory
  HZRD_SIG.flush_em <= flush_pipeline_branch or flush_pipeline_jump;
  --======================= Memory/WriteBack
  HZRD_SIG.flush_mwb <= '0';
  --======================= Writeback
  -- nothing to do here

  -- evaluation on memory stage of the OPCODE because
  -- the branch operation is known in that stage
  P_BRANCH_FLUSH : process (DP_SIG) is
  begin

    -- avoid creation of latch
    flush_pipeline_branch <= '0';

    -- The following are mutually exclusive if cases

    if (DP_SIG.instr_opcode_m = BEQZ_OPCODE) then
      -- if equal 0, branch -> flush pipeline
      if (DP_SIG.cmpr_0_is_0_m = '1') then
        flush_pipeline_branch <= '1';
      end if;
    end if;

    if (DP_SIG.instr_opcode_m = BNEZ_OPCODE) then
      -- if not equal 0, branch -> flush pipeline
      if (not (DP_SIG.cmpr_0_is_0_m = '1')) then
        flush_pipeline_branch <= '1';
      end if;
    end if;

  end process P_BRANCH_FLUSH;

  P_JUMP_FLUSH : process (DP_SIG) is
  begin

    -- avoid creation of latch
    flush_pipeline_jump <= '0';

    -- The following are mutually exclusive if cases

    if (DP_SIG.instr_opcode_m = J_OPCODE) then
      flush_pipeline_jump <= '1';
    end if;

    if (DP_SIG.instr_opcode_m = JAL_OPCODE) then
      flush_pipeline_jump <= '1';
    end if;

  end process P_JUMP_FLUSH;

  ----------------------------------------------------------- SEQUENTIAL

  -- DEBUG STUFF
  P_DBG_PRINT : process (DP_SIG) is
  begin

    dbg_instr_opcode_m <= print_instr_op(DP_SIG.instr_opcode_m);

  end process P_DBG_PRINT;

end architecture BEHAVIOURAL;

configuration CFG_HU_BEHAV of HU is
 for BEHAVIOURAL
 end for;
end CFG_HU_BEHAV;

