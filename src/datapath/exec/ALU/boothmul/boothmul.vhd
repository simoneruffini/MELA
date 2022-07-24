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
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY BOOTHMUL IS
	GENERIC (NBIT : INTEGER := 32);
	PORT (
		A : IN STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
		B : IN STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
		S : OUT STD_LOGIC_VECTOR(NBIT * 2 - 1 DOWNTO 0)
	);
END BOOTHMUL;

ARCHITECTURE BEHAVIOURAL OF BOOTHMUL IS

	-- How many stages of encoders/muxes
	CONSTANT NSTAGE : INTEGER := NBIT/2;
	-- Max bit size. + 2 to account for the last SHIFT which is bigger than NBIT*2
	CONSTANT NSIZE : INTEGER := (NBIT * 2) + 2;

	-- We use RCA as an adder
	COMPONENT RCA IS
		GENERIC (
			NBIT : INTEGER
		);
		PORT (
			A : IN STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
			B : IN STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
			Ci : IN STD_LOGIC;
			S : OUT STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
			Co : OUT STD_LOGIC
		);

	END COMPONENT;
	COMPONENT BOOTHENC IS
		GENERIC (
			NBIT : INTEGER;
			i : INTEGER
		);
		PORT (
			A_s : IN STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
			A_ns : IN STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
			B : IN STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
			O : OUT STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
			A_so : OUT STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
			A_nso : OUT STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0)
		);
	END COMPONENT;

	-- Returns the size of the ith block.
	FUNCTION input_bit_width(i : INTEGER) RETURN INTEGER IS
	BEGIN
		-- NBIT+1 because we only shift one time in the first encoder
		-- 2*i because we shift two times for every encoder
		-- The last +1 to account for the sign
		RETURN NBIT + 1 + (2 * i) + 1;
	END FUNCTION;

	TYPE TMPARR_t IS ARRAY (NATURAL RANGE <>) OF STD_LOGIC_VECTOR(NSIZE - 1 DOWNTO 0);

	-- ENC/MUX out signals
	SIGNAL OTMP : TMPARR_t(NSTAGE - 1 DOWNTO 0);

	-- ADDER out signals
	SIGNAL PTMP : TMPARR_t(NSTAGE - 1 DOWNTO 0);

	-- Shifted A and -A signals
	SIGNAL SHIFT : TMPARR_t (NSTAGE DOWNTO 0);
	SIGNAL SHIFT_n : TMPARR_t (NSTAGE DOWNTO 0);

	-- -A
	SIGNAL A_n : STD_LOGIC_VECTOR(NSIZE - 1 DOWNTO 0);

	-- Resized A and B
	SIGNAL ABIG : STD_LOGIC_VECTOR(NSIZE - 1 DOWNTO 0);
	SIGNAL BBIG : STD_LOGIC_VECTOR(NSIZE - 1 DOWNTO 0);

BEGIN
	-- Resize A and B to NBIT*2
	ABIG <= STD_LOGIC_VECTOR(resize(signed(A), ABIG'length));
	BBIG <= STD_LOGIC_VECTOR(resize(signed(B), BBIG'length));

	-- Instead of doing a negation in every mux, we negate A here in order to
	-- use only one adder.
	A_n <= STD_LOGIC_VECTOR(resize(to_signed(-1 * to_integer(signed(ABIG)), A_n'length + 1), A_n'length));

	-- Set initial values of the shift vector
	SHIFT(0) <= ABIG;
	SHIFT_n(0) <= A_n;

	-- Create NSTAGE encoders/muxes
	-- First encoder is a special child
	ENC1 : BOOTHENC
	GENERIC MAP(
		i => 0,
		NBIT => input_bit_width(0)
	)
	PORT MAP(
		A_s => SHIFT(0)((input_bit_width(0) - 1) DOWNTO 0),
		A_ns => SHIFT_n(0)((input_bit_width(0) - 1) DOWNTO 0),
		B => BBIG((input_bit_width(0) - 1) DOWNTO 0),
		O => OTMP(0)(input_bit_width(0) - 1 DOWNTO 0),
		A_so => SHIFT(1)((input_bit_width(0) - 1) DOWNTO 0),
		A_nso => SHIFT_n(1)((input_bit_width(0) - 1) DOWNTO 0)
	);

	-- Enlarge first encoder's output by 2 bit
	OTMP(0)(input_bit_width(0)) <= OTMP(0)(input_bit_width(0) - 1);
	OTMP(0)(input_bit_width(0) + 1) <= OTMP(0)(input_bit_width(0) - 1);

	-- Enlarge shift signals for next block
	SHIFT(1)(input_bit_width(0)) <= SHIFT(1)(input_bit_width(0) - 1);
	SHIFT(1)(input_bit_width(0) + 1) <= SHIFT(1)(input_bit_width(0) - 1);
	SHIFT_n(1)(input_bit_width(0)) <= SHIFT_n(1)(input_bit_width(0) - 1);
	SHIFT_n(1)(input_bit_width(0) + 1) <= SHIFT_n(1)(input_bit_width(0) - 1);

	GEN_BOOTHSTAGE : FOR I IN 1 TO NSTAGE - 1 GENERATE
		ENC : BOOTHENC
		GENERIC MAP(
			i => (I * 2),
			NBIT => input_bit_width(I)
		)
		PORT MAP(
			A_s => SHIFT(I)((input_bit_width(I) - 1) DOWNTO 0),
			A_ns => SHIFT_n(I)((input_bit_width(I) - 1) DOWNTO 0),
			B => BBIG((input_bit_width(I) - 1) DOWNTO 0),
			O => OTMP(I)((input_bit_width(I) - 1) DOWNTO 0),
			A_so => SHIFT(I + 1)(input_bit_width(I) - 1 DOWNTO 0),
			A_nso => SHIFT_n(I + 1)(input_bit_width(I) - 1 DOWNTO 0)
		);

		-- Resize output shift signal for next block
		SHIFT(I + 1)(input_bit_width(I)) <= SHIFT(I + 1)(input_bit_width(I) - 1);
		SHIFT(I + 1)(input_bit_width(I) + 1) <= SHIFT(I + 1)(input_bit_width(I) - 1);
		SHIFT_n(I + 1)(input_bit_width(I)) <= SHIFT_n(I + 1)(input_bit_width(I) - 1);
		SHIFT_n(I + 1)(input_bit_width(I) + 1) <= SHIFT_n(I + 1)(input_bit_width(I) - 1);
	END GENERATE;

	-- First adder is fed from first and second encoders. It's the only adder fed only by encoders
	ADDER1 : RCA
	GENERIC MAP(NBIT => input_bit_width(1))
	PORT MAP(
		A => OTMP(0)(input_bit_width(1) - 1 DOWNTO 0),
		B => OTMP(1)(input_bit_width(1) - 1 DOWNTO 0),
		Ci => '0',
		S => PTMP(0)(input_bit_width(1) - 1 DOWNTO 0),
		Co => OPEN
	);

	-- Resize adder output to match adder+1 input size
	PTMP(0)(input_bit_width(1)) <= PTMP(0)(input_bit_width(1) - 1);
	PTMP(0)(input_bit_width(1) + 1) <= PTMP(0)(input_bit_width(1) - 1);

	-- Adders take A (output of I-1th adder) and B (output of Ith encoder)
	GEN_ADDERS : FOR I IN 2 TO NSTAGE - 1 GENERATE
		ADDER : RCA
		GENERIC MAP(NBIT => input_bit_width(I))
		PORT MAP(
			A => PTMP(I - 2)(input_bit_width(I) - 1 DOWNTO 0),
			B => OTMP(I)(input_bit_width(I) - 1 DOWNTO 0),
			Ci => '0',
			S => PTMP(I - 1)(input_bit_width(I) - 1 DOWNTO 0),
			Co => OPEN
		);

		-- Enlarge each adder's output by 2 bit
		PTMP(I - 1)(input_bit_width(I)) <= PTMP(I - 1)(input_bit_width(I) - 1);
		PTMP(I - 1)(input_bit_width(I) + 1) <= PTMP(I - 1)(input_bit_width(I) - 1);
	END GENERATE;

	-- Output of the last adder is our solution
	S <= PTMP(NSTAGE - 2)(S'length - 1 DOWNTO 0);

END BEHAVIOURAL;

CONFIGURATION CFG_BOOTHMUL_MIXED OF BOOTHMUL IS
	FOR BEHAVIOURAL
		FOR GEN_BOOTHSTAGE
			FOR ALL : BOOTHENC
				USE CONFIGURATION WORK.CFG_BOOTHENC_BEHAVIOURAL;
			END FOR;
		END FOR;
		FOR GEN_ADDERS
			FOR ALL : RCA
				USE CONFIGURATION WORK.CFG_RCA_DIRECT;
			END FOR;
		END FOR;
	END FOR;
END CFG_BOOTHMUL_MIXED;