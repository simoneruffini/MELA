--------------------------------------------------------------------------------
-- Engineer: Matteo Bonora  [matteo.bonora@polito.it]
--
-- Create Date:     Mon Mar 23 12:09:00 CET 2022
-- Design Name:     Booth's Encoder
-- Module Name:     boothenc.vhd
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
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

-- The encoder takes A from the previous encoder block so that it only has to do
-- a shift of 2 bits.

entity BOOTHENC is
  generic (
    NBIT : integer;
    I    : integer
  );
  port (
    A_S   : in    std_logic_vector(NBIT - 1 downto 0);
    A_NS  : in    std_logic_vector(NBIT - 1 downto 0);
    B     : in    std_logic_vector(NBIT - 1 downto 0);
    O     : out   std_logic_vector(NBIT - 1 downto 0);
    A_SO  : out   std_logic_vector(NBIT - 1 downto 0);
    A_NSO : out   std_logic_vector(NBIT - 1 downto 0)
  );
end entity BOOTHENC;

architecture BEHAVIORAL of BOOTHENC is

  signal bapp  : std_logic_vector(NBIT downto 0);

  -- Shifted A
  signal a_s1  : std_logic_vector(NBIT - 1 downto 0);
  signal a_s2  : std_logic_vector(NBIT - 1 downto 0);

  -- Shifted -A
  signal a_ns1 : std_logic_vector(NBIT - 1 downto 0);
  signal a_ns2 : std_logic_vector(NBIT - 1 downto 0);

begin

  -- Append a 0 at the beginning to B
  bapp <= B & '0';

  -- If this is the first mux, we shift A only once

  A0 : if I = 0 generate
    a_s1  <= A_S;
    a_ns1 <= A_NS;
  end generate A0;

  AN : if I > 0 generate
    -- Positive shift
    a_s1 <= std_logic_vector(shift_left(signed(A_S), 1));
    -- Negative shift
    a_ns1 <= std_logic_vector(shift_left(signed(A_NS), 1));
  end generate AN;

  -- Shift another time
  a_s2 <= std_logic_vector(shift_left(signed(a_s1), 1));
  A_SO <= a_s2;

  a_ns2 <= std_logic_vector(shift_left(signed(a_ns1), 1));
  A_NSO <= a_ns2;

  ENC : process (a_s1, a_s2, a_ns1, a_ns2, bapp) is
  begin

    if (((bapp(I + 2) = '0') and (bapp(I + 1) = '0') and (bapp(I) = '1')) or ((bapp(I + 2) = '0') and (bapp(I + 1) = '1') and (bapp(I) = '0'))) then
      -- A<<i
      O <= a_s1;
    elsif ((bapp(I + 2) = '0') and (bapp(I + 1) = '1') and (bapp(I) = '1')) then
      -- A<<(i+1)
      O <= a_s2;
    elsif ((bapp(I + 2) = '1') and (bapp(I + 1) = '0') and (bapp(I) = '0')) then
      -- -1 * (A<<(i+1))
      O <= a_ns2;
    elsif (((bapp(I + 2) = '1') and (bapp(I + 1) = '0') and (bapp(I) = '1')) or ((bapp(I + 2) = '1') and (bapp(I + 1) = '1') and (bapp(I) = '0'))) then
      -- -1 * (A<<i)
      O <= a_ns1;
    else
      O <= (OTHERS => '0');
    end if;

  end process ENC;

end architecture BEHAVIORAL;

-- CONFIGURATION CFG_BOOTHENC_BEHAVIORAL OF BOOTHENC IS
--  FOR BEHAVIORAL
--  END FOR;
-- END CFG_BOOTHENC_BEHAVIORAL;
