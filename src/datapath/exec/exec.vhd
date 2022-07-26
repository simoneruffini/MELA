--------------------------------------------------------------------------------
-- Engineer: Simone Ruffini [simone.ruffini@studenti.polito.it,simone.ruffini@tutanota.com]
--           Matteo Bonora  [matteo.bonora@studenti.polito.it]
--
-- Create Date:     Sat 24 09:33:06 PM CEST 2022
-- Design Name:     Execute
-- Module Name:     exec.vhd
-- Project Name:    DLX
-- Description:     Execute pipeline stage
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
  use work.comm_pkg.all;

entity execute is
  generic (
    addr_w : integer := 32;
    data_w : integer := 32
  );
  port (
    ck        : in    std_logic;
    ctrl_word : in    controlword_t(CW_SIZE - 1 downto 0);
    -- Inputs
    pci : in    std_logic_vector(addr_w - 1 downto 0);
    a   : in    std_logic_vector(data_w - 1 downto 0);
    b   : in    std_logic_vector(data_w - 1 downto 0);
    imm : in    std_logic_vector(data_w - 1 downto 0);
    -- Outputs
    pco     : out   std_logic_vector(addr_w - 1 downto 0);
    cond    : out   std_logic;
    alu_out : out   std_logic_vector(data_w - 1 downto 0);
    me      : out   std_logic_vector(data_w - 1 downto 0)
  );
end entity execute;

architecture BEHAVIORAL of execute is

begin

end architecture BEHAVIORAL;

configuration CFG_EXECUTE_BEHAVIORAL of execute is
  for BEHAVIORAL
  end for;
end CFG_EXECUTE_BEHAVIORAL;
