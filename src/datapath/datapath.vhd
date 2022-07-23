--------------------------------------------------------------------------------
-- Engineer: Simone Ruffini [simone.ruffini@studenti.polito.it,simone.ruffini@tutanota.com]
--           Matteo Bonora  [matteo.bonora@studenti.polito.it]
--
-- Create Date:     Sat 23 16:09:34 PM CEST 2022
-- Design Name:     datapath
-- Module Name:     datapath.vhd
-- Project Name:    DLX
-- Description:     DLX datapath
--
-- Revision:
-- Revision 00 - Matteo Bonora
--  * Created
-- Additional Comments:
--
--------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;

library work;

entity datapath is
  generic (
    addr_w : integer := 32;
    data_w : integer := 32
  );
  port (
    rf_we              : in    std_logic;
    wb_mux_sel         : in    std_logic;
    pc_latch_en        : in    std_logic;
    jump_en            : in    std_logic;
    lmd_latch_en       : in    std_logic;
    dram_we            : in    std_logic;
    eq_cond            : in    std_logic;
    alu_outreg_en      : in    std_logic;
    mux_b_sel          : in    std_logic;
    mux_a_sel          : in    std_logic;
    reg_i_imm_latch_en : in    std_logic;
    reg_b_latch_en     : in    std_logic;
    reg_a_latch_en     : in    std_logic;
    NPC_EN       : in    std_logic;
    IR_EN        : in    std_logic;
    ALU_OP             : in    std_logic_vector(3 downto 0)
  );
end entity datapath;

architecture behavioural of datapath is

begin

end architecture behavioural;
