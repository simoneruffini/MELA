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
  use work.vhdl_help_func_pkg.all;

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

------------------------------------------------------------- ARCHITECTURE BEHAVIOURAL

architecture BEHAVIOURAL of ALU is

  ----------------------------------------------------------- COMPONENTS

  ----------------------------------------------------------- CONSTANTS 1

  ----------------------------------------------------------- TYPES

  ----------------------------------------------------------- FUNCTIONS

  -- retuns the max shiftable amount for the current bus width as an unsigned

  function get_max_shift_amount (bus_width: integer) return unsigned is

    variable ret : unsigned(bus_width - 1 downto 0);

  begin

    ret                        := (others => '0');
    ret(vhfp_ilog2(bus_width)) := '1';
    return ret;

  end function;

  ----------------------------------------------------------- CONSTANTS 2

  -- NOTE: this constant is generated through a function to overcome this warning
  -- that then becomes an error in synthesis
  --   Array aggregate error: a non-locally static choice must be the single choice
  -- The error appears in case the assignment was done like this (its not fault of the function)
  --   constant C_MAX_SHIFTABLE_AMOUNT : unsigned (DATA_W - 1 downto 0) := (vhfp_ilog2(DATA_W) =>'1', others=>'0');
  -- see more here
  --   https://electronics.stackexchange.com/questions/337121/vhdl-non-locally-static-choice-warning

  -- max possibile shifts for a DATA_W architecture are of DATA_W positions
  constant C_MAX_SHIFTABLE_AMOUNT : unsigned (DATA_W - 1 downto 0) := get_max_shift_amount(DATA_W);

  ----------------------------------------------------------- SIGNALS

  signal a_u                      : unsigned (DATA_W - 1 downto 0);
  signal b_u                      : unsigned (DATA_W - 1 downto 0);
  signal a_s                      : signed (DATA_W - 1 downto 0);
  signal shift_amount             : natural range 0 to DATA_W;

begin

  -- helpers
  a_u <= unsigned(A);
  b_u <= unsigned(B);
  a_s <= signed(A);

  ----------------------------------------------------------- ENTITY DEFINITION

  ----------------------------------------------------------- COMBINATORIAL

  -- If we need to shift less then DATA_W bits then we get the data from b_u
  -- otherwise just shift DATA_W bits
  P_MAX_SHIFT_AMNT : process (b_u) is
  begin

    -- the reason we use an unsigned instead of an integer is becasue VHDL
    -- is limited to 32 bits integer, so if b_u > 2^31-1 we overflow, bad :(
    if (b_u >= C_MAX_SHIFTABLE_AMOUNT) then
      shift_amount <= DATA_W;
    else
      shift_amount <= to_integer(resize(b_u, vhfp_ilog2(DATA_W)));
    end if;

  end process P_MAX_SHIFT_AMNT;

  P_ALU : process (FUNC, A, a_u, B, b_u, a_s, shift_amount) is
  begin

    -- Defaults for disabling latch inference
    RES <= (others => '0');

    case FUNC is

      when ADD =>
        RES <= std_logic_vector(a_u + b_u);

      when SUB =>
        RES <= std_logic_vector(a_u - b_u);

      when BITAND =>
        RES <= A and B;

      when BITOR =>
        RES <= A or B;

      when BITXOR =>
        RES <= A xor B;

      when LSL =>
        RES <= std_logic_vector(SHIFT_LEFT(a_u, shift_amount));   -- Logical shift left

      when LSR =>
        RES <= std_logic_vector(SHIFT_RIGHT(a_u, shift_amount));  -- Logical shift right

      when ASR =>
        RES <= std_logic_vector(SHIFT_RIGHT(a_s, shift_amount));  -- arithmetic shift right

      when GEQ =>
        if ( a_u >= b_u ) then
          RES(0) <= '1';
        end if;

      when LEQ =>
        if ( a_u <= b_u ) then
          RES(0) <= '1';
        end if;

      when NEQ =>
        if ( a_u /= b_u ) then
          RES(0) <= '1';
        end if;

      when others =>
        RES <= (others => '0');                                   -- Disables latch inference

    end case;

  end process P_ALU;

end architecture BEHAVIOURAL;

------------------------------------------------------------- END ARCHITECTURE BEHAVIOURAL

------------------------------------------------------------- ARCHITECTURE BEHAVIOURAL + P4 ADDER

architecture BEHAV_P4ADDER of ALU is

  ----------------------------------------------------------- COMPONENTS
  component P4_ADDER is
    generic (
      NBIT : integer := 32
    );
    port (
      A    : in    std_logic_vector(NBIT - 1 downto 0);
      B    : in    std_logic_vector(NBIT - 1 downto 0);
      CIN  : in    std_logic;
      S    : out   std_logic_vector(NBIT - 1 downto 0);
      COUT : out   std_logic
    );
  end component;

  ----------------------------------------------------------- CONSTANTS 1

  ----------------------------------------------------------- TYPES

  ----------------------------------------------------------- FUNCTIONS

  -- retuns the max shiftable amount for the current bus width as an unsigned

  function get_max_shift_amount (bus_width: integer) return unsigned is

    variable ret : unsigned(bus_width - 1 downto 0);

  begin

    ret                        := (others => '0');
    ret(vhfp_ilog2(bus_width)) := '1';
    return ret;

  end function;

  ----------------------------------------------------------- CONSTANTS 2

  -- NOTE: this constant is generated through a function to overcome this warning
  -- that then becomes an error in synthesis
  --   Array aggregate error: a non-locally static choice must be the single choice
  -- The error appears in case the assignment was done like this (its not fault of the function)
  --   constant C_MAX_SHIFTABLE_AMOUNT : unsigned (DATA_W - 1 downto 0) := (vhfp_ilog2(DATA_W) =>'1', others=>'0');
  -- see more here
  --   https://electronics.stackexchange.com/questions/337121/vhdl-non-locally-static-choice-warning

  -- max possibile shifts for a DATA_W architecture are of DATA_W positions
  constant C_MAX_SHIFTABLE_AMOUNT : unsigned (DATA_W - 1 downto 0) := get_max_shift_amount(DATA_W);

  ----------------------------------------------------------- SIGNALS
  signal a_u                      : unsigned (DATA_W - 1 downto 0);
  signal b_u                      : unsigned (DATA_W - 1 downto 0);
  signal a_s                      : signed (DATA_W - 1 downto 0);
  signal shift_amount             : natural range 0 to (2 * DATA_W) - 1;

  signal p4_adder_cin             : std_logic;
  signal p4_adder_b               : std_logic_vector(DATA_W - 1 downto 0);
  signal p4_adder_s               : std_logic_vector(DATA_W - 1 downto 0);

begin

  -- helpers
  a_u <= unsigned(A);
  b_u <= unsigned(B);
  a_s <= signed(A);

  ----------------------------------------------------------- ENTITY DEFINITION

  P4_ADDER_U : P4_ADDER
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

  ----------------------------------------------------------- COMBINATORIAL

  -- If we need to shift less then DATA_W bits then we get the data from b_u
  -- otherwise just shift DATA_W bits
  P_MAX_SHIFT_AMNT : process (b_u) is
  begin

    -- the reason we use an unsigned instead of an integer is becasue VHDL
    -- is limited to 32 bits integer, so if b_u > 2^31-1 we overflow, bad :(
    if (b_u >= C_MAX_SHIFTABLE_AMOUNT) then
      shift_amount <= DATA_W;
    else
      shift_amount <= to_integer(resize(b_u, vhfp_ilog2(DATA_W)));
    end if;

  end process P_MAX_SHIFT_AMNT;

  P_ALU : process (FUNC, A, a_u, B, b_u, a_s, shift_amount, p4_adder_s) is
  begin

    -- Defaults for disabling latch inference
    RES          <= (others => '0');
    p4_adder_b   <= B;
    p4_adder_cin <= '0';

    case FUNC is

      when ADD =>
        p4_adder_b   <= B;
        p4_adder_cin <= '0';
        RES          <= p4_adder_s;

      when SUB =>
        p4_adder_b   <= not B;                                    -- Negate B to make the number 2's complement
        p4_adder_cin <= '1';                                      -- Add 1 to make B negative in 2's complement
        RES          <= p4_adder_s;

      when BITAND =>
        RES <= A and B;

      when BITOR =>
        RES <= A or B;

      when BITXOR =>
        RES <= A xor B;

      when LSL =>
        RES <= std_logic_vector(SHIFT_LEFT(a_u, shift_amount));   -- Logical shift left

      when LSR =>
        RES <= std_logic_vector(SHIFT_RIGHT(a_u, shift_amount));  -- Logical shift right

      when ASR =>
        RES <= std_logic_vector(SHIFT_RIGHT(a_s, shift_amount));  -- arithmetic shift right

      when GEQ =>
        if ( a_u >= b_u ) then
          RES(0) <= '1';
        end if;

      when LEQ =>
        if ( a_u <= b_u ) then
          RES(0) <= '1';
        end if;

      when NEQ =>
        if ( a_u /= b_u ) then
          RES(0) <= '1';
        end if;

      when others =>
        RES <= (others => '0');                                   -- Disables latch inference

    end case;

  end process P_ALU;

end architecture BEHAV_P4ADDER;

------------------------------------------------------------- END ARCHITECTURE BEHAVIOURAL + P4 ADDER

------------------------------------------------------------- ARCHITECTURE BEHAVIOURAL + T2 LOGIC

architecture BEHAV_T2LOGIC of ALU is

  ----------------------------------------------------------- COMPONENTS

  component T2_LOGIC is
    generic (
      DATA_W : integer
    );
    port (
      OP     : in    std_logic_vector(4 - 1 downto 0);
      A      : in    std_logic_vector(DATA_W - 1 downto 0);
      B      : in    std_logic_vector(DATA_W - 1 downto 0);
      S      : out   std_logic_vector(DATA_W - 1 downto 0)
    );
  end component;

  ----------------------------------------------------------- CONSTANTS 1

  ----------------------------------------------------------- TYPES

  ----------------------------------------------------------- FUNCTIONS

  -- retuns the max shiftable amount for the current bus width as an unsigned

  function get_max_shift_amount (bus_width: integer) return unsigned is

    variable ret : unsigned(bus_width - 1 downto 0);

  begin

    ret                        := (others => '0');
    ret(vhfp_ilog2(bus_width)) := '1';
    return ret;

  end function;

  ----------------------------------------------------------- CONSTANTS 2

  -- NOTE: this constant is generated through a function to overcome this warning
  -- that then becomes an error in synthesis
  --   Array aggregate error: a non-locally static choice must be the single choice
  -- The error appears in case the assignment was done like this (its not fault of the function)
  --   constant C_MAX_SHIFTABLE_AMOUNT : unsigned (DATA_W - 1 downto 0) := (vhfp_ilog2(DATA_W) =>'1', others=>'0');
  -- see more here
  --   https://electronics.stackexchange.com/questions/337121/vhdl-non-locally-static-choice-warning

  -- max possibile shifts for a DATA_W architecture are of DATA_W positions
  constant C_MAX_SHIFTABLE_AMOUNT : unsigned (DATA_W - 1 downto 0) := get_max_shift_amount(DATA_W);

  ----------------------------------------------------------- SIGNALS
  signal a_u                      : unsigned (DATA_W - 1 downto 0);
  signal b_u                      : unsigned (DATA_W - 1 downto 0);
  signal a_s                      : signed (DATA_W - 1 downto 0);
  signal shift_amount             : natural range 0 to (2 * DATA_W) - 1;

  signal t2_logic_s               : std_logic_vector(DATA_W - 1 downto 0);
  signal t2_logic_op              : std_logic_vector(4 - 1 downto 0);

begin

  -- helpers
  a_u <= unsigned(A);
  b_u <= unsigned(B);
  a_s <= signed(A);

  ----------------------------------------------------------- ENTITY DEFINITION

  T2_LOGIC_U : T2_LOGIC
    generic map (
      DATA_W => C_ALU_PRECISION_BIT
    )
    port map (
      OP => t2_logic_op,
      A  => A,
      B  => B,
      S  => t2_logic_s
    );

  ----------------------------------------------------------- COMBINATORIAL

  -- If we need to shift less then DATA_W bits then we get the data from b_u
  -- otherwise just shift DATA_W bits
  P_MAX_SHIFT_AMNT : process (b_u) is
  begin

    -- the reason we use an unsigned instead of an integer is becasue VHDL
    -- is limited to 32 bits integer, so if b_u > 2^31-1 we overflow, bad :(
    if (b_u >= C_MAX_SHIFTABLE_AMOUNT) then
      shift_amount <= DATA_W;
    else
      shift_amount <= to_integer(resize(b_u, vhfp_ilog2(DATA_W)));
    end if;

  end process P_MAX_SHIFT_AMNT;

  P_ALU : process (FUNC, a_u, b_u, a_s, shift_amount, t2_logic_s) is
  begin

    -- Defaults for disabling latch inference
    RES          <= (others => '0');
    t2_logic_op  <= (others => '0');                              -- in theory xnor (aka ==)

    case FUNC is

      when ADD =>
        RES <= std_logic_vector(a_u + b_u);

      when SUB =>
        RES <= std_logic_vector(a_u - b_u);

      when BITAND =>
        RES         <= t2_logic_s;
        t2_logic_op <= C_T2_LOGIC_OP_AND;

      when BITOR =>
        RES         <= t2_logic_s;
        t2_logic_op <= C_T2_LOGIC_OP_OR;

      when BITXOR =>
        RES         <= t2_logic_s;
        t2_logic_op <= C_T2_LOGIC_OP_XOR;

      when LSL =>
        RES <= std_logic_vector(SHIFT_LEFT(a_u, shift_amount));   -- Logical shift left

      when LSR =>
        RES <= std_logic_vector(SHIFT_RIGHT(a_u, shift_amount));  -- Logical shift right

      when ASR =>
        RES <= std_logic_vector(SHIFT_RIGHT(a_s, shift_amount));  -- arithmetic shift right

      when GEQ =>
        if ( a_u >= b_u ) then
          RES(0) <= '1';
        end if;

      when LEQ =>
        if ( a_u <= b_u ) then
          RES(0) <= '1';
        end if;

      when NEQ =>
        if ( a_u /= b_u ) then
          RES(0) <= '1';
        end if;

      when others =>
        RES <= (others => '0');                                   -- Disables latch inference

    end case;

  end process P_ALU;

end architecture BEHAV_T2LOGIC;

------------------------------------------------------------- END ARCHITECTURE BEHAVIOURAL + T2 LOGIC

------------------------------------------------------------- ARCHITECTURE BEHAVIOURAL + T2 SHIFTER

architecture BEHAV_T2SHIFTER of ALU is

  ----------------------------------------------------------- COMPONENTS

  component T2_SHIFTER is
    generic (
      DATA_W : integer := 32
    );
    port (
      A         : in    std_logic_vector(DATA_W - 1 downto 0);
      AMOUNT    : in    std_logic_vector(DATA_W - 1 downto 0);
      OP        : in    std_logic_vector(1 downto 0);
      S         : out   std_logic_vector(DATA_W - 1 downto 0)
    );
  end component;

  ----------------------------------------------------------- CONSTANTS 1

  ----------------------------------------------------------- TYPES

  ----------------------------------------------------------- FUNCTIONS

  ----------------------------------------------------------- CONSTANTS 2

  ----------------------------------------------------------- SIGNALS
  signal a_u                      : unsigned (DATA_W - 1 downto 0);
  signal b_u                      : unsigned (DATA_W - 1 downto 0);

  signal t2_shifter_op      : std_logic_vector(2 - 1 downto 0);
  signal t2_shifter_s       : std_logic_vector(DATA_W - 1  downto 0);

begin

  ----------------------------------------------------------- ENTITY DEFINITION

  T2_SHIFTER_U : T2_SHIFTER
    generic map (
      DATA_W => C_ALU_PRECISION_BIT
    )
    port map (
      A      => A,
      AMOUNT => B,
      OP     => t2_shifter_op,
      S      => t2_shifter_s
    );

  -- helpers
  a_u <= unsigned(A);
  b_u <= unsigned(B);

  ----------------------------------------------------------- PROCESSES
  P_ALU : process (FUNC, A, a_u, B, b_u, t2_shifter_s) is
  begin

    -- Defaults for disabling latch inference
    RES           <= (others => '0');
    t2_shifter_op <= (others => '0'); -- shift by 0 (identity operation)

    case FUNC is

      when ADD =>
        RES <= std_logic_vector(a_u + b_u);

      when SUB =>
        RES <= std_logic_vector(a_u - b_u);

      when BITAND =>
        RES <= A and B;

      when BITOR =>
        RES <= A or B;

      when BITXOR =>
        RES <= A xor B;

      when LSL =>                                                  -- Logical shift left
        t2_shifter_op <= C_T2_SHIFTER_OP_SLL;
        RES           <= t2_shifter_s;

      when LSR =>                                                  -- Logical shift right
        t2_shifter_op <= C_T2_SHIFTER_OP_SRL;
        RES           <= t2_shifter_s;

      when ASR =>                                                  -- Arithmetic shift right
        t2_shifter_op <= C_T2_SHIFTER_OP_SRA;
        RES           <= t2_shifter_s;

      when GEQ =>
        if ( a_u >= b_u ) then
          RES(0) <= '1';
        end if;

      when LEQ =>
        if ( a_u <= b_u ) then
          RES(0) <= '1';
        end if;

      when NEQ =>
        if ( a_u /= b_u ) then
          RES(0) <= '1';
        end if;

      when others =>
        RES <= (others => '0');                                    -- Disables latch inference

    end case;

  end process P_ALU;

end architecture BEHAV_T2SHIFTER;

------------------------------------------------------------- END ARCHITECTURE BEHAVIOURAL + T2 SHIFTER

------------------------------------------------------------- ARCHITECTURE STRUCTURAL

architecture STRUCTURAL of ALU is

  ----------------------------------------------------------- COMPONENTS
  component P4_ADDER is
    generic (
      NBIT : integer := 32
    );
    port (
      A    : in    std_logic_vector(NBIT - 1 downto 0);
      B    : in    std_logic_vector(NBIT - 1 downto 0);
      CIN  : in    std_logic;
      S    : out   std_logic_vector(NBIT - 1 downto 0);
      COUT : out   std_logic
    );
  end component;

  component T2_LOGIC is
    generic (
      DATA_W : integer
    );
    port (
      OP     : in    std_logic_vector(4 - 1 downto 0);
      A      : in    std_logic_vector(DATA_W - 1 downto 0);
      B      : in    std_logic_vector(DATA_W - 1 downto 0);
      S      : out   std_logic_vector(DATA_W - 1 downto 0)
    );
  end component;

  component T2_SHIFTER is
    generic (
      DATA_W : integer := 32
    );
    port (
      A         : in    std_logic_vector(DATA_W - 1 downto 0);
      AMOUNT    : in    std_logic_vector(DATA_W - 1 downto 0);
      OP        : in    std_logic_vector(1 downto 0);
      S         : out   std_logic_vector(DATA_W - 1 downto 0)
    );
  end component;

  ----------------------------------------------------------- CONSTANTS 1

  ----------------------------------------------------------- TYPES

  ----------------------------------------------------------- FUNCTIONS

  ----------------------------------------------------------- CONSTANTS 2

  ----------------------------------------------------------- SIGNALS
  signal a_u                : unsigned (DATA_W - 1 downto 0);
  signal b_u                : unsigned (DATA_W - 1 downto 0);

  signal p4_adder_cin       : std_logic;
  signal p4_adder_b         : std_logic_vector(DATA_W - 1 downto 0);
  signal p4_adder_s         : std_logic_vector(DATA_W - 1 downto 0);

  signal t2_logic_s         : std_logic_vector(DATA_W - 1 downto 0);
  signal t2_logic_op        : std_logic_vector(4 - 1 downto 0);

  signal t2_shifter_s       : std_logic_vector(DATA_W - 1  downto 0);
  signal t2_shifter_op      : std_logic_vector(2 - 1 downto 0);

begin

  ----------------------------------------------------------- ENTITY DEFINITION

  P4_ADDER_U : P4_ADDER
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

  T2_LOGIC_U : T2_LOGIC
    generic map (
      DATA_W => C_ALU_PRECISION_BIT
    )
    port map (
      OP => t2_logic_op,
      A  => A,
      B  => B,
      S  => t2_logic_s
    );

  T2_SHIFTER_U : T2_SHIFTER
    generic map (
      DATA_W => C_ALU_PRECISION_BIT
    )
    port map (
      A      => A,
      AMOUNT => B,
      OP     => t2_shifter_op,
      S      => t2_shifter_s
    );

  -- helpers
  a_u <= unsigned(A);
  b_u <= unsigned(B);

  ----------------------------------------------------------- PROCESSES
  P_ALU : process (FUNC, a_u, B, b_u, p4_adder_s, t2_logic_s, t2_shifter_s) is
  begin

    -- Defaults for disabling latch inference
    RES           <= (others => '0');
    p4_adder_cin  <= '0';
    p4_adder_b    <= B;
    t2_logic_op   <= (others => '0');                              -- in theory xnor (aka ==)
    t2_shifter_op <= (others => '0');                              -- shift by 0 (identity operation)

    case FUNC is

      when ADD =>
        p4_adder_b   <= B;
        p4_adder_cin <= '0';
        RES          <= p4_adder_s;

      when SUB =>
        p4_adder_b   <= not B;                                     -- Negate B to make the number 2's complement
        p4_adder_cin <= '1';                                       -- Add 1 to make B negative in 2's complement
        RES          <= p4_adder_s;

      when BITAND =>
        RES         <= t2_logic_s;
        t2_logic_op <= C_T2_LOGIC_OP_AND;

      when BITOR =>
        RES         <= t2_logic_s;
        t2_logic_op <= C_T2_LOGIC_OP_OR;

      when BITXOR =>
        RES         <= t2_logic_s;
        t2_logic_op <= C_T2_LOGIC_OP_XOR;

      when LSL =>                                                  -- Logical shift left
        t2_shifter_op <= C_T2_SHIFTER_OP_SLL;
        RES           <= t2_shifter_s;

      when LSR =>                                                  -- Logical shift right
        t2_shifter_op <= C_T2_SHIFTER_OP_SRL;
        RES           <= t2_shifter_s;

      when ASR =>                                                  -- Arithmetic shift right
        t2_shifter_op <= C_T2_SHIFTER_OP_SRA;
        RES           <= t2_shifter_s;

      when GEQ =>
        if ( a_u >= b_u ) then
          RES(0) <= '1';
        end if;

      when LEQ =>
        if ( a_u <= b_u ) then
          RES(0) <= '1';
        end if;

      when NEQ =>
        if ( a_u /= b_u ) then
          RES(0) <= '1';
        end if;

      when others =>
        RES <= (others => '0');                                    -- Disables latch inference

    end case;

  end process P_ALU;

end architecture STRUCTURAL;

------------------------------------------------------------- END ARCHITECTURE STRUCTURAL

configuration CFG_ALU_BEHAV of ALU is
  for BEHAVIOURAL
    end for;
end configuration;

configuration CFG_ALU_BEHAV_P4ADDER of ALU is
  for BEHAV_P4ADDER
    for all: P4_ADDER
      use configuration work.CFG_P4_ADDER_STRUCT;
    end for;
  end for;
end configuration;

configuration CFG_ALU_BEHAV_T2LOGIC of ALU is
  for BEHAV_T2LOGIC
    for all: T2_LOGIC
      use configuration work.CFG_T2_LOGIC_DATAFLOW;
    end for;
  end for;
end configuration;

configuration CFG_ALU_BEHAV_T2SHIFTER of ALU is
  for BEHAV_T2SHIFTER
    for all: T2_SHIFTER
      use configuration work.CFG_T2_SHIFTER_STRUCT;
    end for;
  end for;
end configuration;

configuration CFG_ALU_STRUCTURAL of ALU is
  for STRUCTURAL
    for all: P4_ADDER
      use configuration work.CFG_P4_ADDER_STRUCT;
    end for;
    for all: T2_LOGIC
      use configuration work.CFG_T2_LOGIC_DATAFLOW;
    end for;
    for all: T2_SHIFTER
      use configuration work.CFG_T2_SHIFTER_STRUCT;
    end for;
  end for;
end configuration;
