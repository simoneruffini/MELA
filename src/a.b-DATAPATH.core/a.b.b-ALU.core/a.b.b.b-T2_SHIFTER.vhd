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
    OP        : in    std_logic_vector(2 - 1 downto 0);                    -- Opcode
    S         : out   std_logic_vector(DATA_W - 1 downto 0)            -- Data Output Port
  );
end entity T2_SHIFTER;

architecture STRUCTURAL of T2_SHIFTER is

  constant C_MASK_SIZE : natural := DATA_W + 9;

  signal m0            : std_logic_vector(C_MASK_SIZE - 1 downto 0);
  signal m8            : std_logic_vector(C_MASK_SIZE - 1 downto 0);
  signal m16           : std_logic_vector(C_MASK_SIZE - 1 downto 0);
  signal m24           : std_logic_vector(C_MASK_SIZE - 1 downto 0);
  signal msb           : std_logic;
  signal m_selected    : std_logic_vector(C_MASK_SIZE - 1 downto 0); -- Mask selected by the coarse shift block

  signal op_fine       : std_logic_vector(2 downto 0);               -- Op code for the fine shift block

  component COARSE_SHIFT is
    generic (
      DATA_W    : integer;
      MASK_SIZE : integer
    );
    port (
      MASK0        : in    std_logic_vector(MASK_SIZE - 1 downto 0);
      MASK8        : in    std_logic_vector(MASK_SIZE - 1 downto 0);
      MASK16       : in    std_logic_vector(MASK_SIZE - 1 downto 0);
      MASK24       : in    std_logic_vector(MASK_SIZE - 1 downto 0);
      MSB          : in    std_logic;
      AMOUNT       : in    std_logic_vector(DATA_W - 3 - 1  downto 0);
      S            : out   std_logic_vector(MASK_SIZE - 1 downto 0)
    );
  end component;

  component FINE_SHIFT is
    generic (
      DATA_W    : integer;
      MASK_SIZE : integer
    );
    port (
      A             : in    std_logic_vector(MASK_SIZE - 1 downto 0);
      AMOUNT        : in    std_logic_vector(2 downto 0);
      S             : out   std_logic_vector(DATA_W - 1 downto 0)
    );
  end component;

  component MASK_GEN is
    generic (
      DATA_W    : integer;
      MASK_SIZE : integer
    );
    port (
      OP       : in    std_logic_vector(1 downto 0);
      A        : in    std_logic_vector(DATA_W - 1 downto 0);
      MASK0    : out   std_logic_vector(MASK_SIZE - 1 downto 0);
      MASK8    : out   std_logic_vector(MASK_SIZE - 1 downto 0);
      MASK16   : out   std_logic_vector(MASK_SIZE - 1 downto 0);
      MASK24   : out   std_logic_vector(MASK_SIZE - 1 downto 0);
      MSB      : out   std_logic
    );
  end component;

begin

  MASKGEN : mask_gen
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

  COARSESHIFT : coarse_shift
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

  FINESHIFT : fine_shift
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

end architecture STRUCTURAL;

configuration CFG_T2_SHIFTER_STRUCT of T2_SHIFTER is
  for STRUCTURAL
    for all : MASK_GEN
      use configuration work.CFG_MASK_GEN_BEHAV;
    end for;
    for all : COARSE_SHIFT
      use configuration work.CFG_COARSE_SHIFT_BEHAV;
    end for;
    for all : FINE_SHIFT
      use configuration work.CFG_FINE_SHIFT_BEHAV;
    end for;
  end for;
end configuration CFG_T2_SHIFTER_STRUCT;
