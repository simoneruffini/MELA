--------------------------------------------------------------------------------
-- Engineer: Matteo Bonora  [matteo.bonora@polito.it]
--
-- Create Date:     Sun Oct 12 16:32:00 CET 2022
-- Design Name:     T2 Shifter Mask Generator
-- Module Name:     mask_gen
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

entity MASK_GEN is
  generic (
    DATA_W    : integer;  -- Instruction memory data port bit width
    MASK_SIZE : integer   -- Size of masks
  );
  port (
    OP       : in    std_logic_vector(1 downto 0);                 -- Shift Operation
    A        : in    std_logic_vector(DATA_W - 1 downto 0);        -- Input A Port
    MASK0    : out   std_logic_vector(MASK_SIZE - 1 downto 0);     -- Mask00 (shifted by 8)
    MASK8    : out   std_logic_vector(MASK_SIZE - 1 downto 0);     -- Mask08 (shifted by 16)
    MASK16   : out   std_logic_vector(MASK_SIZE - 1 downto 0);     -- Mask16 (shifted by 24)
    MASK24   : out   std_logic_vector(MASK_SIZE - 1 downto 0)      -- Mask24 (shifted by 32)
  );
end entity MASK_GEN;

architecture BEHAVIOURAL of MASK_GEN is

begin

  MASKGEN : process (A, OP) is
  begin

    case OP is

      -- Leading/trailing signle zeros are to handle right shifts, when the
      -- 'AMOUNT' value has to be inverted for the fine shift stage.

      when "00" =>                                                                        -- Logic Left
        MASK0  <= "0" & A(DATA_W - 1  downto 0) & "00000000";                             -- Append 8 zeros
        MASK8  <= "0" & A(DATA_W - 1 - 8  downto 0) & "0000000000000000";                 -- Append 16 zeros
        MASK16 <= "0" & A(DATA_W - 1 - 16 downto 0) & "000000000000000000000000";         -- Append 24 zeros
        MASK24 <= "0" & A(DATA_W - 1 - 24 downto 0) & "00000000000000000000000000000000"; -- Append 32 zeros

      when "01" =>                                                                        -- Logic Right
        MASK0  <= "00000000" & A(DATA_W - 1 downto 0) & "0";
        MASK8  <= "0000000000000000" & A(DATA_W - 1 downto 8) & "0";
        MASK16 <= "000000000000000000000000" & A(DATA_W - 1 downto 16) & "0";
        MASK24 <= "00000000000000000000000000000000" & A(DATA_W - 1 downto 24) & "0";

      when "10" =>                                                                        -- Arithmetic Right
        MASK0  <= (DATA_W - 1 downto (DATA_W - 8) => A(DATA_W - 1)) & A & "0";
        MASK8  <= (DATA_W - 1 downto (DATA_W - 16) => A(DATA_W - 1)) & A(DATA_W - 1 downto 8) & "0";
        MASK16 <= (DATA_W - 1 downto (DATA_W - 24) => A(DATA_W - 1)) & A(DATA_W - 1 downto 16) & "0";
        MASK24 <= (DATA_W - 1 downto (DATA_W - 32) => A(DATA_W - 1)) & A(DATA_W - 1 downto 24) & "0";

      when others =>
        MASK0  <= (others=>'0');
        MASK8  <= (others=>'0');
        MASK16 <= (others=>'0');
        MASK24 <= (others=>'0');

    end case;

  end process MASKGEN;

end architecture BEHAVIOURAL;
