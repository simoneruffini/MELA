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

------------------------------------------------------------- PACKAGES/LIBRARIES

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

------------------------------------------------------------- ENTITY

entity T2_LOGIC is
  generic (
    DATA_W : integer  -- Instruction memory data port bit width
  );
  port (
    OP     : in    std_logic_vector(4 - 1 downto 0);           -- Opcode
    A      : in    std_logic_vector(DATA_W - 1 downto 0);      -- Input A Port
    B      : in    std_logic_vector(DATA_W - 1 downto 0);      -- Input B Port
    S      : out   std_logic_vector(DATA_W - 1 downto 0)       -- Data Output Port
  );
end entity T2_LOGIC;

------------------------------------------------------------- ARCHITECTURE

architecture STRUCTURAL of T2_LOGIC is

  ----------------------------------------------------------- CONSTANTS 1

  ----------------------------------------------------------- TYPES

  ----------------------------------------------------------- FUNCTIONS

  ----------------------------------------------------------- CONSTANTS 2

  ----------------------------------------------------------- SIGNALS

  signal l0 : std_logic_vector(DATA_W - 1 downto 0);
  signal l1 : std_logic_vector(DATA_W - 1 downto 0);
  signal l2 : std_logic_vector(DATA_W - 1 downto 0);
  signal l3 : std_logic_vector(DATA_W - 1 downto 0);

begin

  ----------------------------------------------------------- PROCESSES

  P_LOGIC : process (OP, A, B) is
  begin

    logic : for i in 0 to DATA_W - 1 loop

      l0(i) <= not (OP(0) and (not A(i)) and (not B(i)));
      l1(i) <= not (OP(1) and (not A(i)) and B(i));
      l2(i) <= not (OP(2) and A(i) and (not B(i)));
      l3(i) <= not (OP(3) and A(i) and B(i));
      S(i)  <= not (l0(i) and l1(i) and l2(i) and l3(i));

    end loop;

  end process P_LOGIC;

end architecture STRUCTURAL;

------------------------------------------------------------- ARCHITECTURE

architecture BEHAVIOURAL of T2_LOGIC is

----------------------------------------------------------- CONSTANTS 1

----------------------------------------------------------- TYPES

----------------------------------------------------------- FUNCTIONS

----------------------------------------------------------- CONSTANTS 2

----------------------------------------------------------- SIGNALS

begin

  LOGIC : process (OP, A, B) is
  begin

    case OP is

      when "0001" =>
        S <= A and B;

      when "1110" =>
        S <= A nand B;

      when "0111" =>
        S <= A or B;

      when "1000" =>
        S <= A nor B;

      when "0110" =>
        S <= A xor B;

      when others =>
        S <= (others => '0');

    end case;

  end process LOGIC;

end architecture BEHAVIOURAL;
