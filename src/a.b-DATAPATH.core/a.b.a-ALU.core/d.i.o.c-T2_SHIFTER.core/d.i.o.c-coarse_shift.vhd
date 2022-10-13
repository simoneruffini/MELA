--------------------------------------------------------------------------------
-- Engineer: Matteo Bonora  [matteo.bonora@polito.it]
--
-- Create Date:     Sun Oct 12 16:46:00 CET 2022
-- Design Name:     T2 Shifter Coarse Shift Stage
-- Module Name:     coarse_shift
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

entity COARSE_SHIFT is
  generic (
    DATA_W    : integer;  -- Instruction memory data port bit width
    MASK_SIZE : integer   -- Size of masks
  );
  port (
    MASK0        : in    std_logic_vector(MASK_SIZE - 1 downto 0);
    MASK8        : in    std_logic_vector(MASK_SIZE - 1 downto 0);
    MASK16       : in    std_logic_vector(MASK_SIZE - 1 downto 0);
    MASK24       : in    std_logic_vector(MASK_SIZE - 1 downto 0);
    AMOUNT       : in    std_logic_vector(1 downto 0);                -- Shift Amount (MSB)
    S            : out   std_logic_vector(MASK_SIZE - 1 downto 0)
  );
end entity COARSE_SHIFT;

architecture BEHAVIOURAL of COARSE_SHIFT is

begin

  COARSESHIFT : process (MASK0, MASK8, MASK16, MASK24, AMOUNT) is
  begin

    case AMOUNT is

      when "00" =>
        S <= MASK0;

      when "01" =>
        S <= MASK8;

      when "10" =>
        S <= MASK16;

      when "11" =>
        S <= MASK24;

      when others =>
        S <= (others => 'X');

    end case;

  end process COARSESHIFT;

end architecture BEHAVIOURAL;
