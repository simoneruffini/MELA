--------------------------------------------------------------------------------
-- Engineer: Simone Ruffini [simone.ruffini@studenti.polito.it]
-- 
-- Create Date:     Mon Apr  4 21:44:22 CEST 2022
-- Design Name:     P4_ADDER
-- Module Name:     P4_ADDER.vhd
-- Project Name:    P4 adder
-- Description:     Pentium 4 Adder
-- Constraints:
--                  NBIT must be power of 2
-- Revision:
-- Revision 00 - Simone Ruffini
--  * Created
-- Additional Comments:
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity P4_ADDER is
  generic (
    NBIT :  integer := 32
  );
  port (
    A    : in std_logic_vector(NBIT-1 downto 0);
    B    : in std_logic_vector(NBIT-1 downto 0);
    Cin  : in std_logic;
    S    : out std_logic_vector(NBIT-1 downto 0);
    Cout : out std_logic
  );
end P4_ADDER;

architecture STRUCTURAL of P4_ADDER is
 
  -- Example for NBIT:32
  --                                                 B[31:0]A[31:0]
  --                                                   │      │
  --     ┌─────────────────────────────────────────────▼───── ▼───────────┐
  --     │    B32                                                         │
  --     │  A32 │  ...                                      ...  A0 B0    │
  --     │    │ │                                                 │ │     │
  --     │   ┌▼─▼─────────────────────────────────────────────────▼─▼┐    │
  --     │   │                                                       ◄──┬─┼─Cin
  --     │C7 │                Carry Generator    Carry 4bit          │  │ │
  -- Cout◄───┤                                                       │  │ │
  --     │G31└────┬──────┬──────┬──────┬──────┬──────┬──────┬────────┘  │ │
  --     │        │C6    │C5    │C4    │C3    │C2    │C1    │C0    ┌────┘ │
  --     │ B[31:4]│      │      │      │      │      │      │B[3:0]│      │
  --     │ A[31:4]│      │      │      │      │      │      │A[3:0]│      │
  --     │ │      │G27   │G23   │G19   │G15   │G11   │ G7   │G3│ │ │Cin   │
  --     │ │ ┌────▼──────▼──────▼──────▼──────▼──────▼──────▼─┐▼─▼─▼─┐    │
  --     │ ├─►                                                │ RCA  │    │
  --     │ └─►                 Sum Generator                  │      │    │
  --     │   │                                                │ 4bit │    │
  --     │   └────────────────┬───────────────────────────────┴┬─────┘    │
  --    S◄──────────────────+◄┘ S[31:4]                        │S[3:0]    │
  --     │                  ^──────────────────────────────────┘          │
  --     └────────────────────────────────────────────────────────────────┘
  constant NBIT_CARRY_BLOCK : INTEGER := 4; -- the pentium 4 adder uses 4 bit per carry lines

  signal carry_gen_Co  : STD_LOGIC_VECTOR((NBIT/NBIT_CARRY_BLOCK) - 1 downto 0);

  COMPONENT RCA IS
    generic (
      NBIT : INTEGER
    );
    port (
      A  : in STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
      B  : in STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
      Ci : in STD_LOGIC;
      S  : out STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
      Co : out STD_LOGIC
    );
  end component;
  component CARRY_GENERATOR is
    generic (
      NBIT           : INTEGER := 32;
      NBIT_PER_BLOCK : INTEGER := 4
    );
    port (
      A   : in STD_LOGIC_VECTOR(NBIT - 1 downto 0);
      B   : in STD_LOGIC_VECTOR(NBIT - 1 downto 0);
      Cin : in STD_LOGIC;
      Co  : out STD_LOGIC_VECTOR((NBIT/NBIT_PER_BLOCK) - 1 downto 0)
    );
  end component;
  component SUM_GENERATOR IS
  	generic (
  		NBIT_PER_BLOCK : INTEGER := 4;
  		NBLOCKS        : INTEGER := 8
    );
  	port (
  		A  : in STD_LOGIC_VECTOR(NBIT_PER_BLOCK * NBLOCKS - 1 DOWNTO 0);
  		B  : in STD_LOGIC_VECTOR(NBIT_PER_BLOCK * NBLOCKS - 1 DOWNTO 0);
  		Ci : in STD_LOGIC_VECTOR(NBLOCKS - 1 DOWNTO 0);
  		S  : out STD_LOGIC_VECTOR(NBIT_PER_BLOCK * NBLOCKS - 1 DOWNTO 0)
    );
  end component;

begin

  U_CARRY_GENERATOR: CARRY_GENERATOR
    generic map(
      NBIT           => NBIT,
      NBIT_PER_BLOCK => NBIT_CARRY_BLOCK
    )
    port map(
      A   => A,
      B   => B,
      Cin => Cin,
      Co  => carry_gen_Co
    );

  Cout <= carry_gen_Co(carry_gen_Co'length-1); -- C(NBIT_PER_BLOCK-1) is the carry out

  -- The sum generator doesn't 
  U_FIRST_RCA: RCA
    generic map(
      NBIT => NBIT_CARRY_BLOCK
    )
    port map(
      A  => A(NBIT_CARRY_BLOCK-1 downto 0),
      B  => B(NBIT_CARRY_BLOCK-1 downto 0),
      Ci => Cin,
      S  => S(NBIT_CARRY_BLOCK-1 downto 0),
      Co => open
    );

  U_SUM_GENERATOR: SUM_GENERATOR
  	generic map (
  		NBIT_PER_BLOCK => NBIT_CARRY_BLOCK,
  		NBLOCKS        => ((NBIT/NBIT_CARRY_BLOCK) - 1) -- -1: the first block can be reduced to a single RCA since C0 is known 
    )
  	port map(
  		A  => A(A'length-1 downto NBIT_CARRY_BLOCK),
  		B  => B(B'length-1 downto NBIT_CARRY_BLOCK),
  		Ci => carry_gen_Co((carry_gen_Co'length-1) -1 downto 0), -- -1: See Cout assignment
  		S  => S(S'length-1 downto NBIT_CARRY_BLOCK)
    );

end STRUCTURAL;

CONFIGURATION CFG_P4_ADDER_STRUCTURAL OF P4_ADDER IS
	FOR STRUCTURAL
    FOR ALL : RCA
      USE CONFIGURATION WORK.CFG_RCA_BEHAVIORAL;
    END FOR;
    FOR ALL: CARRY_GENERATOR
      USE CONFIGURATION WORK.CFG_CARRY_GENERATOR_STRUCTURAL;
    END FOR;
    FOR ALL: SUM_GENERATOR
      USE CONFIGURATION WORK.CFG_SUM_GENERATOR_STRUCTURAL;
    END FOR;
	END FOR;
END CFG_P4_ADDER_STRUCTURAL;
