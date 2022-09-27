--------------------------------------------------------------------------------
-- Engineer: Simone Ruffini [simone.ruffini@studenti.polito.it,simone.ruffini@tutanota.com]
--           Matteo Bonora  [matteo.bonora@studenti.polito.it]
--
-- Create Date:     Fri Jul 22 03:03:26 PM CEST 2022
-- Module Name:     ALU
-- Project Name:    ALU
-- Description:     Arithmetic Logic Unit
--
-- Revision:
-- Revision 00 - Simone Ruffini
--  * Created
-- Revision 01 - Simone Ruffini
--  * Refactoring
-- Additional Comments:
--
--------------------------------------------------------------------------------

------------------------------------------------------------- PACKAGES/LIBRARIES

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.alu_pkg.all;
  use work.dlx_pkg.all;

------------------------------------------------------------- ENTITY

entity ALU is
  generic (
    DATA_W : integer := 32 -- Input/Outputs Data Width
  );
  port (
    FUNC : in    alu_func_t;                            -- ALU function
    A    : in    std_logic_vector(DATA_W - 1 downto 0); -- A port
    B    : in    std_logic_vector(DATA_W - 1 downto 0); -- B port
    RES  : out   std_logic_vector(DATA_W - 1 downto 0)  -- Result port
  );
end entity ALU;

------------------------------------------------------------- ARCHITECTURE

architecture BEHAVIORAL of ALU is

  ----------------------------------------------------------- CONSTANTS 1

  ----------------------------------------------------------- TYPES

  ----------------------------------------------------------- FUNCTIONS

  ----------------------------------------------------------- CONSTANTS 2

  ----------------------------------------------------------- SIGNALS
  signal a_u          : integer (RANGE 0 to DATA_W - 1);
  signal b_u          : integer (RANGE 0 to DATA_W - 1);
  signal a_i          : integer (RANGE 0 to DATA_W - 1);
  signal b_i          : integer (RANGE 0 to DATA_W - 1);

  signal p4_adder_cin : std_logic;
  signal p4_adder_b   : std_logic_vector(DATA_W - 1 downto 0);
  signal p4_adder_s   : std_logic_vector(DATA_W - 1 downto 0);

begin

  ----------------------------------------------------------- ENTITY DEFINITION
  P4_ADDER_U : entity work.p4_adder("STRUCTURAL")
    generic map (
      NBIT => C_ALU_PRECISION_BIT
    )
    port map (
      A    => A,
      B    => p4_adder_b,
      CIN  => p4_adder_cin,
      S    => p4_adder_s,
      COUT => open
    );

  -- helpers
  a_u <= unsigned(A);
  b_u <= unsigned(B);
  a_i <= to_integer(a_u);
  b_i <= to_integer(b_u);

  ----------------------------------------------------------- PROCESSES
  P_ALU : process (FUNC, A, B) is
  begin

    -- Defaults for disabling latch inference
    RES          <= (others => '0');
    p4_adder_cin <= '0';
    p4_adder_b   <= B;

    case FUNC is

      when ADD =>
        p4_adder_b   <= B;
        p4_adder_cin <= '0';
        RES          <= p4_adder_s;

      when SUB =>
        p4_adder_b   <= not B;                           -- Negate B to make the number 2's complement
        p4_adder_cin <= '1';                             -- Add 1 to make B negative in 2's complement
        RES          <= p4_adder_s;

      when BITAND =>
        RES <= A and B;

      when BITOR =>
        RES <= A or B;

      when BITXOR =>
        RES <= A xor B;

      when LSL =>
        RES <= std_logic_vector(SHIFT_LEFT(a_u, b_i));   -- Logical shift left

      when LSR =>
        RES <= std_logic_vector(SHIFT_RIGHT(a_u, b_i));  -- Logical shift right

      when RL =>
        RES <= std_logic_vector(ROTATE_LEFT(a_u,  b_i)); -- rotate left

      when RR =>
        RES <= std_logic_vector(ROTATE_RIGHT(a_u, b_i)); -- rotate right

      when GEQ =>
        RES <= (others => '0');
        RES(0)<= '1' when a_u >= b_u else '0';

      when LEQ =>
        RES <= (others => '0');
        RES(0)<= '1' when a_u <= b_u else '0';

      when NEQ =>
        RES <= (others => '0');
        RES(0)<= '1' when a_u /= b_u else '0';

      when others =>
        RES <= (others => '0');                          -- Disables latch inference

    end case;

  end process P_ALU;

end architecture BEHAVIORAL;

-- configuration CFG_ALU_BEHAVIORAL of ALU is
--  for BEHAVIORAL
--  end for;
-- end CFG_ALU_BEHAVIORAL;
