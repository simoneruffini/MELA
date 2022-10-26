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
    MSB          : in    std_logic;
    AMOUNT       : in    std_logic_vector(DATA_W - 3 - 1  downto 0);                -- Shift Amount (MSB)
    S            : out   std_logic_vector(MASK_SIZE - 1 downto 0)
  );
end entity COARSE_SHIFT;

architecture BEHAVIOURAL of COARSE_SHIFT is

begin

  COARSESHIFT : process (MASK0, MASK8, MASK16, MASK24, MSB, AMOUNT) is

    constant C_MASK0_SEL  : std_logic_vector(DATA_W - 3 - 1 downto 0) := (others => '0');
    constant C_MASK8_SEL  : std_logic_vector(DATA_W - 3 - 1 downto 0) := (DATA_W - 3 - 1 downto 2 => '0') & "01";
    constant C_MASK16_SEL : std_logic_vector(DATA_W - 3 - 1 downto 0) := (DATA_W - 3 - 1 downto 2 => '0') & "10";
    constant C_MASK24_SEL : std_logic_vector(DATA_W - 3 - 1 downto 0) := (DATA_W - 3 - 1 downto 2 => '0') & "11";

  begin

    if (AMOUNT=C_MASK0_SEL) then
      S <= MASK0;
    elsif (AMOUNT=C_MASK8_SEL) then
      S <= MASK8;
    elsif (AMOUNT=C_MASK16_SEL) then
      S <= MASK16;
    elsif (AMOUNT=C_MASK24_SEL) then
      S <= MASK24;
    else
      S <= (others => MSB);
    end if;

  end process COARSESHIFT;

end architecture BEHAVIOURAL;

configuration CFG_COARSE_SHIFT_BEHAV of COARSE_SHIFT is
  for BEHAVIOURAL
  end for;
end configuration CFG_COARSE_SHIFT_BEHAV;
