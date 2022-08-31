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
  use work.ALU_PKG.all;
  use work.DLX_PKG.all;

entity ALU is
  generic (
    D_WIDTH : integer := 32                                 -- Input/Outputs Data Width
  );
  port (
    FUNC    : in alu_func_t;                                -- ALU function
    A       : in std_logic_vector(D_WIDTH - 1 downto 0);    -- A port
    B       : in std_logic_vector(D_WIDTH - 1 downto 0);    -- B port
    RES     : out std_logic_vector(D_WIDTH - 1 downto 0)    -- Result port
  );
end ALU;

architecture BEHAVIORAL of ALU is

  signal A_u : integer (RANGE 0 to D_WIDTH-1);
  signal B_u : integer (RANGE 0 to D_WIDTH-1);
  signal A_i : integer (RANGE 0 to D_WIDTH-1);
  signal B_i : integer (RANGE 0 to D_WIDTH-1);

  signal P4_ADDER_Cin : std_logic;
  signal P4_ADDER_B   : std_logic_vector(D_WIDTH - 1 downto 0);
  signal P4_ADDER_S   : std_logic_vector(D_WIDTH - 1 downto 0);

begin

  -- Combinatorial Functions
  ------------------------------------------------------------------------------

  -- helpers 
  A_u <= unsigned(A);
  B_u <= unsigned(B);
  A_i <= to_integer(A_u);
  B_i <= to_integer(B_u);

  -- Instantiations
  ------------------------------------------------------------------------------
  P4_ADDER_U: work.P4_ADDER("STRUCTURAL") is
    generic map (
      NBIT =>  C_ALU_PRECISION_BIT
    )
    port map (
      A    => A,
      B    => P4_ADDER_B,
      Cin  => P4_ADDER_Cin,
      S    => P4_ADDER_S,
      Cout => open
    );

  
  P_ALU : process (FUNC, A, B)
  begin
    -- Defaults for disabling latch inference
    RES <= (others => '0');
    P4_ADDER_Cin  <= '0';
    P4_ADDER_B    <= B;

    case FUNC is
      when ADD     => P4_ADDER_B <= B;
                      P4_ADDER_Cin <= '0';
                      RES <= P4_ADDER_S;
      when SUB     => P4_ADDER_B <= not B; -- Negate B to make the number 2's complement
                      P4_ADDER_Cin <= '1'; -- Add 1 to make B negative in 2's complement
                      RES <= P4_ADDER_S;
      when BITAND  => RES <= A AND B; 
      when BITOR   => RES <= A OR B; 
      when BITXOR  => RES <= A XOR B;
      when LSL     => RES <= std_logic_vector( SHIFT_LEFT(A_u, B_i ) ); -- Logical shift left
      when LSR     => RES <= std_logic_vector( SHIFT_RIGHT(A_u, B_i ) ); -- Logical shift right
      when RL      => RES <= std_logic_vector( ROTATE_LEFT(A_u,  B_i ) ); -- rotate left
      when RR      => RES <= std_logic_vector( ROTATE_RIGHT(A_u, B_i ) ); -- rotate right
      when GEQ     => RES <= (others => '0');
                      RES(0)<= '1' when A_u >= B_u else '0';
      when LEQ     => RES <= (others => '0');
                      RES(0)<= '1' when A_u <= B_u else '0';
      when NEQ     => RES <= (others => '0');
                      RES(0)<= '1' when A_u /= B_u else '0'; 
      when others  => RES <= (others => '0'); -- Disables latch inference
    end case;

  end process P_ALU;

end BEHAVIORAL;

configuration CFG_ALU_BEHAVIORAL of ALU is
  for BEHAVIORAL
  end for;
end CFG_ALU_BEHAVIORAL;
