--------------------------------------------------------------------------------
-- Engineer: Matteo Bonora  [matteo.bonora@polito.it]
--
-- Create Date:     Sun Oct 02 17:11:00 CET 2022
-- Design Name:     T2 Shifter Fine Shift Stage
-- Module Name:     fine_shift
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

library work;

entity FINE_SHIFT is
  generic (
    DATA_W    : integer;  -- Instruction memory data port bit width
    MASK_SIZE : integer   -- Size of masks
  );
  port (
    A             : in    std_logic_vector(MASK_SIZE - 1 downto 0);
    AMOUNT        : in    std_logic_vector(2 downto 0);                -- Shift Amount (LSB)
    S             : out   std_logic_vector(DATA_W - 1 downto 0)
  );
end entity FINE_SHIFT;

architecture BEHAVIOURAL of FINE_SHIFT is

begin

  FINESHIFT : process (A, AMOUNT) is
  begin

    case AMOUNT is

      when "000" =>
        S <= A((DATA_W - 1) + 8 downto 8);

      when "001" =>
        S <= A((DATA_W - 1) + 7 downto 7);

      when "010" =>
        S <= A((DATA_W - 1) + 6 downto 6);

      when "011" =>
        S <= A((DATA_W - 1) + 5 downto 5);

      when "100" =>
        S <= A((DATA_W - 1) + 4 downto 4);

      when "101" =>
        S <= A((DATA_W - 1) + 3 downto 3);

      when "110" =>
        S <= A((DATA_W - 1) + 2 downto 2);

      when "111" =>
        S <= A((DATA_W - 1) + 1 downto 1);

      when others =>
        S <= (others => 'X');

    end case;

  end process FINESHIFT;

end architecture BEHAVIOURAL;
