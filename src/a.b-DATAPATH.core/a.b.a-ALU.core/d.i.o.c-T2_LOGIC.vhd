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

library work;

entity T2_LOGIC is
  generic (
    DATA_W : integer  -- Instruction memory data port bit width
  );
  port (
    OP     : in    std_logic_vector(4 downto 0);           -- Opcode
    A      : in    std_logic_vector(DATA_W - 1 downto 0);  -- Input A Port
    B      : in    std_logic_vector(DATA_W - 1 downto 0);  -- Input B Port
    S      : out   std_logic_vector(DATA_W - 1 downto 0)   -- Data Output Port
  );
end entity T2_LOGIC;

architecture STRUCTURAL of T2_LOGIC is

  signal l0 : std_logic_vector(DATA_W - 1 downto 0);
  signal l1 : std_logic_vector(DATA_W - 1 downto 0);
  signal l2 : std_logic_vector(DATA_W - 1 downto 0);
  signal l3 : std_logic_vector(DATA_W - 1 downto 0);

begin

  LOGIC : process (OP, A, B) is
  begin

    l0 <= OP(0) nand not A nand not B;
    l1 <= OP(1) nand not A nand B;
    l2 <= OP(2) nand A nand not B;
    l3 <= OP(3) nand A nand B;

    S <= l0 nand l1 nand l2 nand l3;

  end process LOGIC;

end architecture STRUCTURAL;

architecture BEHAVIOURAL of T2_LOGIC is

begin

  LOGIC : process (OP, A, B) is
  begin

    case OP is

      when '0001' =>
        RES <= A and B;

      when '1110' =>
        RES <= A nand B;

      when '0111' =>
        RES <= A or B;

      when '1000' =>
        RES <= A nor B;

      when '0110' =>
        RES <= A xor B;

    end case;

  end process LOGIC;

end architecture BEHAVIOURAL;
