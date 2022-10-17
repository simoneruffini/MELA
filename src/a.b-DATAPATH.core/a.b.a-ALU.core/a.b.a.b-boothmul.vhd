--------------------------------------------------------------------------------
-- Engineer: Matteo Bonora  [matteo.bonora@polito.it]
--
-- Create Date:     Mon Mar 23 11:56:00 CET 2022
-- Design Name:     Booth's Multiplier
-- Module Name:     boothmul.vhd
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

entity BOOTHMUL is
  generic (
    NBIT : integer := 32
  );
  port (
    A : in    std_logic_vector(NBIT - 1 downto 0);
    B : in    std_logic_vector(NBIT - 1 downto 0);
    S : out   std_logic_vector(NBIT * 2 - 1 downto 0)
  );
end entity BOOTHMUL;

architecture BEHAVIOURAL of BOOTHMUL is

  -- How many stages of encoders/muxes
  constant NSTAGE : integer := NBIT / 2;
  -- Max bit size. + 2 to account for the last SHIFT which is bigger than NBIT*2
  constant NSIZE  : integer := (NBIT * 2) + 2;

  -- We use RCA as an adder
  component RCA is
    generic (
      NBIT : integer
    );
    port (
      A  : in    std_logic_vector(NBIT - 1 downto 0);
      B  : in    std_logic_vector(NBIT - 1 downto 0);
      CI : in    std_logic;
      S  : out   std_logic_vector(NBIT - 1 downto 0);
      CO : out   std_logic
    );
  end component;

  component BOOTHENC is
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
  end component;

  -- Returns the size of the ith block.

  function input_bit_width (I : integer) RETURN INTEGER is
  begin

    -- NBIT+1 because we only shift one time in the first encoder
    -- 2*i because we shift two times for every encoder
    -- The last +1 to account for the sign
    RETURN NBIT + 1 + (2 * I) + 1;

  end function;

  type tmparr_t is ARRAY (NATURAL RANGE <>) OF std_logic_vector(NSIZE - 1 downto 0);

  -- ENC/MUX out signals
  signal otmp     : tmparr_t(NSTAGE - 1 downto 0);

  -- ADDER out signals
  signal ptmp     : tmparr_t(NSTAGE - 1 downto 0);

  -- Shifted A and -A signals
  signal shift    : tmparr_t (NSTAGE downto 0);
  signal shift_n  : tmparr_t (NSTAGE downto 0);

  -- -A
  signal a_n      : std_logic_vector(NSIZE - 1 downto 0);

  -- Resized A and B
  signal abig     : std_logic_vector(NSIZE - 1 downto 0);
  signal bbig     : std_logic_vector(NSIZE - 1 downto 0);

begin

  -- Resize A and B to NBIT*2
  abig <= std_logic_vector(resize(signed(A), abig'length));
  bbig <= std_logic_vector(resize(signed(B), bbig'length));

  -- Instead of doing a negation in every mux, we negate A here in order to
  -- use only one adder.
  a_n <= std_logic_vector(resize(to_signed(-1 * to_integer(signed(abig)), a_n'length + 1), a_n'length));

  -- Set initial values of the shift vector
  shift(0)   <= abig;
  shift_n(0) <= a_n;

  -- Create NSTAGE encoders/muxes
  -- First encoder is a special child
  ENC1 : BOOTHENC
    generic map (
      I    => 0,
      NBIT => input_bit_width(0)
    )
    port map (
      A_S   => shift(0)((input_bit_width(0) - 1) DOWNTO 0),
      A_NS  => shift_n(0)((input_bit_width(0) - 1) DOWNTO 0),
      B     => bbig((input_bit_width(0) - 1) DOWNTO 0),
      O     => otmp(0)(input_bit_width(0) - 1 DOWNTO 0),
      A_SO  => shift(1)((input_bit_width(0) - 1) DOWNTO 0),
      A_NSO => shift_n(1)((input_bit_width(0) - 1) DOWNTO 0)
    );

  -- Enlarge first encoder's output by 2 bit
  otmp(0)(input_bit_width(0))     <= otmp(0)(input_bit_width(0) - 1);
  otmp(0)(input_bit_width(0) + 1) <= otmp(0)(input_bit_width(0) - 1);

  -- Enlarge shift signals for next block
  shift(1)(input_bit_width(0))       <= shift(1)(input_bit_width(0) - 1);
  shift(1)(input_bit_width(0) + 1)   <= shift(1)(input_bit_width(0) - 1);
  shift_n(1)(input_bit_width(0))     <= shift_n(1)(input_bit_width(0) - 1);
  shift_n(1)(input_bit_width(0) + 1) <= shift_n(1)(input_bit_width(0) - 1);

  GEN_BOOTHSTAGE : for I IN 1 to NSTAGE - 1 generate

    ENC : BOOTHENC
      generic map (
        I    => (I * 2),
        NBIT => input_bit_width(I)
      )
      port map (
        A_S   => shift(I)((input_bit_width(I) - 1) DOWNTO 0),
        A_NS  => shift_n(I)((input_bit_width(I) - 1) DOWNTO 0),
        B     => bbig((input_bit_width(I) - 1) DOWNTO 0),
        O     => otmp(I)((input_bit_width(I) - 1) DOWNTO 0),
        A_SO  => shift(I + 1)(input_bit_width(I) - 1 DOWNTO 0),
        A_NSO => shift_n(I + 1)(input_bit_width(I) - 1 DOWNTO 0)
      );

    -- Resize output shift signal for next block
    shift(I + 1)(input_bit_width(I))       <= shift(I + 1)(input_bit_width(I) - 1);
    shift(I + 1)(input_bit_width(I) + 1)   <= shift(I + 1)(input_bit_width(I) - 1);
    shift_n(I + 1)(input_bit_width(I))     <= shift_n(I + 1)(input_bit_width(I) - 1);
    shift_n(I + 1)(input_bit_width(I) + 1) <= shift_n(I + 1)(input_bit_width(I) - 1);
  end generate GEN_BOOTHSTAGE;

  -- First adder is fed from first and second encoders. It's the only adder fed only by encoders
  ADDER1 : RCA
    generic map (
      NBIT => input_bit_width(1)
    )
    port map (
      A  => otmp(0)(input_bit_width(1) - 1 DOWNTO 0),
      B  => otmp(1)(input_bit_width(1) - 1 DOWNTO 0),
      CI => '0',
      S  => ptmp(0)(input_bit_width(1) - 1 DOWNTO 0),
      CO => OPEN
    );

  -- Resize adder output to match adder+1 input size
  ptmp(0)(input_bit_width(1))     <= ptmp(0)(input_bit_width(1) - 1);
  ptmp(0)(input_bit_width(1) + 1) <= ptmp(0)(input_bit_width(1) - 1);

  -- Adders take A (output of I-1th adder) and B (output of Ith encoder)

  GEN_ADDERS : for I IN 2 to NSTAGE - 1 generate

    ADDER : RCA
      generic map (
        NBIT => input_bit_width(I)
      )
      port map (
        A  => ptmp(I - 2)(input_bit_width(I) - 1 DOWNTO 0),
        B  => otmp(I)(input_bit_width(I) - 1 DOWNTO 0),
        CI => '0',
        S  => ptmp(I - 1)(input_bit_width(I) - 1 DOWNTO 0),
        CO => OPEN
      );

    -- Enlarge each adder's output by 2 bit
    ptmp(I - 1)(input_bit_width(I))     <= ptmp(I - 1)(input_bit_width(I) - 1);
    ptmp(I - 1)(input_bit_width(I) + 1) <= ptmp(I - 1)(input_bit_width(I) - 1);
  end generate GEN_ADDERS;

  -- Output of the last adder is our solution
  S <= ptmp(NSTAGE - 2)(S'length - 1 downto 0);

end architecture BEHAVIOURAL;

-- CONFIGURATION CFG_BOOTHMUL_MIXED OF BOOTHMUL IS
--  FOR BEHAVIOURAL
--    FOR GEN_BOOTHSTAGE
--      FOR ALL : BOOTHENC
--        USE CONFIGURATION WORK.CFG_BOOTHENC_BEHAVIOURAL;
--      END FOR;
--    END FOR;
--    FOR GEN_ADDERS
--      FOR ALL : RCA
--        USE CONFIGURATION WORK.CFG_RCA_DIRECT;
--      END FOR;
--    END FOR;
--  END FOR;
-- END CFG_BOOTHMUL_MIXED;
