--------------------------------------------------------------------------------
-- Engineer: Matteo Bonora  [matteo.bonora@polito.it]
--
-- Create Date:     Sun Oct 02 01:27:00 CET 2022
-- Design Name:     T2 Logic Unit
-- Module Name:     t2-logic
-- Project Name:
-- Description:
--
--
-- Revision:
-- Revision 00 - Matteo Bonora
--  * File Created
-- Additional Comments:
--
--------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.std_logic_textio.all; -- synopsis

library work;
  use work.dlx_pkg.all;
  use std.textio.all;

entity T2_LOGIC is
  generic (
    DATA_W : integer  -- Instruction memory data port bit width
  );
  port (
    CLK    : in    std_logic;                              -- Clock Signal (rising-edge trigger)
    OP     : in    std_logic_vector(4 downto 0);           -- Opcode
    AIN    : in    std_logic_vector(DATA_W - 1 downto 0);  -- Input A Port
    BIN    : in    std_logic_vector(DATA_W - 1 downto 0);  -- Input B Port
    DOUT   : out   std_logic_vector(DATA_W - 1 downto 0)   -- Data Output Port
  );
end entity T2_LOGIC;

architecture BEHAVIOURAL of T2_LOGIC is

  signal l0 : std_logic_vector(DATA_W - 1 downto 0);
  signal l1 : std_logic_vector(DATA_W - 1 downto 0);
  signal l2 : std_logic_vector(DATA_W - 1 downto 0);
  signal l3 : std_logic_vector(DATA_W - 1 downto 0);

begin

  LOGIC : process (CLK) is
  begin

    if (CLK='1' and CLK'event) then
      l0 <= OP(0) nand not AIN nand not BIN;
      l1 <= OP(1) nand not AIN nand BIN;
      l2 <= OP(2) nand AIN nand not BIN;
      l3 <= OP(3) nand AIN nand BIN;

      DOUT <= l0 nand l1 nand l2 nand l3;
    end if;

  end process LOGIC;

end architecture BEHAVIOURAL;
