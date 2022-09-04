--------------------------------------------------------------------------------
-- Engineer: Simone Ruffini [simone.ruffini@studenti.polito.it,simone.ruffini@tutanota.com]
--           Matteo Bonora  [matteo.bonora@studenti.polito.it]
--
-- Create Date:     Fri Jul 22 03:03:26 PM CEST 2022
-- Design Name:     ALU
-- Module Name:     ALU.vhd
-- Project Name:    ALU
-- Description:     Arithmetic Logic Unit
--
-- Revision:
-- Revision 00 - Simone Ruffini
--  * Created
-- Additional Comments:
--
--------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.alu_pkg.all;
  use work.dlx_pkg.all;

entity alu is
  generic (
    d_width : integer := 32 -- Input/Outputs Data Width
  );
  port (
    func : in    alu_func_t;                             -- ALU function
    a    : in    std_logic_vector(d_width - 1 downto 0); -- A port
    b    : in    std_logic_vector(d_width - 1 downto 0); -- B port
    res  : out   std_logic_vector(d_width - 1 downto 0)  -- Result port
  );
end entity alu;

architecture behavioral of alu is

  signal a_u : integer (RANGE 0 to d_width - 1);
  signal b_u : integer (RANGE 0 to d_width - 1);
  signal a_i : integer (RANGE 0 to d_width - 1);
  signal b_i : integer (RANGE 0 to d_width - 1);

  signal p4_adder_cin : std_logic;
  signal p4_adder_b   : std_logic_vector(d_width - 1 downto 0);
  signal p4_adder_s   : std_logic_vector(d_width - 1 downto 0);

begin

  -- Combinatorial Functions
  ------------------------------------------------------------------------------

  -- helpers
  a_u <= unsigned(a);
  b_u <= unsigned(b);
  a_i <= to_integer(a_u);
  b_i <= to_integer(b_u);

  -- Instantiations
  ------------------------------------------------------------------------------
  p4_adder_u : entity work.p4_adder("STRUCTURAL")
    generic map (
      nbit => C_ALU_PRECISION_BIT
    )
    port map (
      a    => a,
      b    => p4_adder_b,
      cin  => p4_adder_cin,
      s    => p4_adder_s,
      cout => open
    );

  p_alu : process (func, a, b) is
  begin

    -- Defaults for disabling latch inference
    res          <= (others => '0');
    p4_adder_cin <= '0';
    p4_adder_b   <= b;

    case func is

      when ADD =>

        p4_adder_b   <= b;
        p4_adder_cin <= '0';
        res          <= p4_adder_s;

      when SUB =>

        p4_adder_b   <= not b;                           -- Negate B to make the number 2's complement
        p4_adder_cin <= '1';                             -- Add 1 to make B negative in 2's complement
        res          <= p4_adder_s;

      when BITAND =>

        res <= a and b;

      when BITOR =>

        res <= a or b;

      when BITXOR =>

        res <= a xor b;

      when LSL =>

        res <= std_logic_vector(SHIFT_LEFT(a_u, b_i));   -- Logical shift left

      when LSR =>

        res <= std_logic_vector(SHIFT_RIGHT(a_u, b_i));  -- Logical shift right

      when RL =>

        res <= std_logic_vector(ROTATE_LEFT(a_u,  b_i)); -- rotate left

      when RR =>

        res <= std_logic_vector(ROTATE_RIGHT(a_u, b_i)); -- rotate right

      when GEQ =>

        res <= (others => '0');
        res(0)<= '1' when a_u >= b_u else '0';

      when LEQ =>

        res <= (others => '0');
        res(0)<= '1' when a_u <= b_u else '0';

      when NEQ =>

        res <= (others => '0');
        res(0)<= '1' when a_u /= b_u else '0';

      when others =>

        res <= (others => '0');                          -- Disables latch inference

    end case;

  end process p_alu;

end architecture behavioral;

configuration CFG_ALU_BEHAVIORAL of ALU is
  for BEHAVIORAL
  end for;
end CFG_ALU_BEHAVIORAL;
