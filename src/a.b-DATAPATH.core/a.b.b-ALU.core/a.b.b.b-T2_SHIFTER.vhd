--------------------------------------------------------------------------------
-- Engineer: Matteo Bonora  [matteo.bonora@polito.it]
--
-- Create Date:     Sun Oct 02 16:03:00 CET 2022
-- Design Name:     T2 Shifter Unit
-- Module Name:     t2-shifter
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

entity T2_SHIFTER is
  generic (
    DATA_W : integer := 32 -- Instruction memory data port bit width
  );
  port (
    A         : in    std_logic_vector(DATA_W - 1 downto 0);           -- Operand
    AMOUNT    : in    std_logic_vector(DATA_W - 1 downto 0);           -- Shift amount
    OP        : in    std_logic_vector(1 downto 0);                    -- Opcode
    S         : out   std_logic_vector(DATA_W - 1 downto 0)            -- Data Output Port
  );
end entity T2_SHIFTER;

architecture BEHAVIOURAL of T2_SHIFTER is

  constant C_MASK_SIZE : natural := DATA_W + 9;

  signal m0            : std_logic_vector(C_MASK_SIZE - 1 downto 0);
  signal m8            : std_logic_vector(C_MASK_SIZE - 1 downto 0);
  signal m16           : std_logic_vector(C_MASK_SIZE - 1 downto 0);
  signal m24           : std_logic_vector(C_MASK_SIZE - 1 downto 0);
  signal msb           : std_logic;
  signal m_selected    : std_logic_vector(C_MASK_SIZE - 1 downto 0); -- Mask selected by the coarse shift block

  signal op_fine       : std_logic_vector(2 downto 0);               -- Op code for the fine shift block

begin

  MASKGEN : entity work.mask_gen(BEHAVIOURAL)
    generic map (
      DATA_W    => DATA_W,
      MASK_SIZE => C_MASK_SIZE
    )
    port map (
      OP     => OP,
      A      => A,
      MASK0  => m0,
      MASK8  => m8,
      MASK16 => m16,
      MASK24 => m24,
      MSB    => msb
    );

  COARSESHIFT : entity work.coarse_shift(BEHAVIOURAL)
    generic map (
      DATA_W    => DATA_W,
      MASK_SIZE => C_MASK_SIZE
    )
    port map (
      MASK0  => m0,
      MASK8  => m8,
      MASK16 => m16,
      MASK24 => m24,
      MSB    => msb,
      AMOUNT => AMOUNT(DATA_W - 1 downto 3),
      S      => m_selected
    );

  FINESHIFT : entity work.fine_shift(BEHAVIOURAL)
    generic map (
      DATA_W    => DATA_W,
      MASK_SIZE => C_MASK_SIZE
    )
    port map (
      A      => m_selected,
      AMOUNT => op_fine,
      S      => S
    );

  INV_OP : process (A, AMOUNT, OP) is
  begin

    case OP is

      when "00" =>
        op_fine <= AMOUNT(2 downto 0);

      when "01" =>
        op_fine <= not (AMOUNT(2 downto 0));

      when "10" =>
        op_fine <= not (AMOUNT(2 downto 0));

      when others =>
        op_fine <= "XXX";

    end case;

  end process INV_OP;

end architecture BEHAVIOURAL;
