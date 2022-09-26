--------------------------------------------------------------------------------
-- Engineer: Simone Ruffini [simone.ruffini@studenti.polito.it,simone.ruffini@tutanota.com]
--           Matteo Bonora  [matteo.bonora@studenti.polito.it]
--
-- Create Date:     Sat 24 09:13:22 PM CEST 2022
-- Design Name:     decode
-- Module Name:     decode.vhd
-- Project Name:    DLX
-- Description:     Decode pipeline stage
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

entity decode is
  generic (
    addr_w : integer := 32;
    data_w : integer := 32
  );
  port (
    ck        : in    std_logic;
    ctrl_word    : in    controlword_t(cw_signals_type'POS(CW_SIZE) - 1 downto 0);
    -- Inputs
    pci         : in    std_logic_vector(addr_w - 1 downto 0);
    instruction : in    std_logic_vector(data_w - 1 downto 0);
    wb          : in    std_logic_vector(data_w - 1 downto 0);
    -- Outputs
    pco : out   std_logic_vector(addr_w - 1 downto 0);
    a   : out   std_logic_vector(data_w - 1 downto 0);
    b   : out   std_logic_vector(data_w - 1 downto 0);
    imm : out   std_logic_vector(data_w - 1 downto 0)
  );
end entity decode;

architecture BEHAVIORAL of decode is

begin

end architecture BEHAVIORAL;

configuration CFG_DECODE_BEHAVIORAL of decode is
  for BEHAVIORAL
  end for;
end CFG_DECODE_BEHAVIORAL;
