--------------------------------------------------------------------------------
-- Engineer: Simone Ruffini [simone.ruffini@studenti.polito.it,simone.ruffini@tutanota.com]
--           Matteo Bonora  [matteo.bonora@studenti.polito.it]
--
-- Create Date:     Sat 23 16:09:34 PM CEST 2022
-- Design Name:     fetch
-- Module Name:     fetch.vhd
-- Project Name:    DLX
-- Description:     Fetch pipeline stage
--
-- Revision:
-- Revision 00 - Matteo Bonora
--  * Created
-- Additional Comments:
--
--------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;

entity fetch is
  generic (
    addr_w : integer := 32;
    data_w : integer := 32
  );
  port (
    pc_latch_en        : in    std_logic;
    mux_b_sel          : in    std_logic;
    mux_a_sel          : in    std_logic;
    reg_i_imm_latch_en : in    std_logic;
    reg_b_latch_en     : in    std_logic;
    reg_a_latch_en     : in    std_logic;
    npc_latch_en       : in    std_logic;
    ir_latch_en        : in    std_logic;
    alu_op             : in    std_logic_vector(3 downto 0)
  );
end entity fetch;

architecture behavioural of fetch is

begin

end architecture behavioural;
