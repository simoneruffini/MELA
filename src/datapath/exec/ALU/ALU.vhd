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
  use ieee.std_logic_unsigned.all;
  --use ieee.std_logic_arith.all;
  use ieee.numeric_std.all;
library work;
  use work.ALU_PKG.all;

entity ALU is
  generic (
    N : integer := 32
  );
  port (
    FUNC    : in type_op;
    DATA1   : in std_logic_vector(N - 1 downto 0);
    DATA2   : in std_logic_vector(N - 1 downto 0);
    OUTALU  : out std_logic_vector(N - 1 downto 0));
end ALU;

architecture BEHAVIORAL of ALU is
begin

  P_ALU : process (FUNC, DATA1, DATA2)
  begin
    case FUNC is
      when ADD      => OUTALU <= DATA1 + DATA2;
      when SUB      => OUTALU <= DATA1 - DATA2;
      when MULT     => OUTALU <= DATA1 ((N/2) - 1 downto 0) * DATA2 ((N/2) - 1 downto 0);
      when BITAND   => OUTALU <= DATA1 AND DATA2; 
      when BITOR    => OUTALU <= DATA1 OR DATA2; 
      when BITXOR   => OUTALU <= DATA1 XOR DATA2;
      when FUNCLSL  => OUTALU <= std_logic_vector( SHIFT_LEFT(unsigned(DATA1), to_integer(unsigned(DATA2))) );
      when FUNCLSR  => OUTALU <= std_logic_vector( SHIFT_RIGHT(unsigned(DATA1), to_integer(unsigned(DATA2))) );
      when FUNCRL   => OUTALU <= std_logic_vector( ROTATE_LEFT(unsigned(DATA1),  to_integer(unsigned(DATA2))) ); -- rotate left
      when FUNCRR   => OUTALU <= std_logic_vector( ROTATE_RIGHT(unsigned(DATA1), to_integer(unsigned(DATA2))) ); -- rotate right
      when others   => NULL;
    end case;

  end process P_ALU;

end BEHAVIORAL;

configuration CFG_ALU_BEHAVIORAL of ALU is
  for BEHAVIORAL
  end for;
end CFG_ALU_BEHAVIORAL;
