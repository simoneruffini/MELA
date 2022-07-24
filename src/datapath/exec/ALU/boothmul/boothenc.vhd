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
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

-- The encoder takes A from the previous encoder block so that it only has to do
-- a shift of 2 bits.
ENTITY BOOTHENC IS
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
END BOOTHENC;

ARCHITECTURE BEHAVIOURAL OF BOOTHENC IS

	SIGNAL BAPP : STD_LOGIC_VECTOR(NBIT DOWNTO 0);

	-- Shifted A
	SIGNAL A_s1 : STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
	SIGNAL A_s2 : STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);

	-- Shifted -A
	SIGNAL A_ns1 : STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
	SIGNAL A_ns2 : STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);

BEGIN
	-- Append a 0 at the beginning to B
	BAPP <= B & '0';

	-- If this is the first mux, we shift A only once
	A0 : IF i = 0 GENERATE
		A_s1 <= A_s;
		A_ns1 <= A_ns;
	END GENERATE;
	AN : IF i > 0 GENERATE
		-- Positive shift
		A_s1 <= STD_LOGIC_VECTOR(shift_left(signed(A_s), 1));
		-- Negative shift
		A_ns1 <= STD_LOGIC_VECTOR(shift_left(signed(A_ns), 1));
	END GENERATE;

	-- Shift another time
	A_s2 <= STD_LOGIC_VECTOR(shift_left(signed(A_s1), 1));
	A_so <= A_s2;

	A_ns2 <= STD_LOGIC_VECTOR(shift_left(signed(A_ns1), 1));
	A_nso <= A_ns2;

	ENC : PROCESS (A_s1, A_s2, A_ns1, A_ns2, BAPP)
	BEGIN
		IF (((BAPP(i + 2) = '0') AND (BAPP(i + 1) = '0') AND (BAPP(i) = '1')) OR ((BAPP(i + 2) = '0') AND (BAPP(i + 1) = '1') AND (BAPP(i) = '0'))) THEN
			-- A<<i
			O <= A_s1;

		ELSIF (BAPP(i + 2) = '0') AND (BAPP(i + 1) = '1') AND (BAPP(i) = '1') THEN
			-- A<<(i+1)
			O <= A_s2;

		ELSIF (BAPP(i + 2) = '1') AND (BAPP(i + 1) = '0') AND (BAPP(i) = '0') THEN
			-- -1 * (A<<(i+1))
			O <= A_ns2;

		ELSIF (((BAPP(i + 2) = '1') AND (BAPP(i + 1) = '0') AND (BAPP(i) = '1')) OR ((BAPP(i + 2) = '1') AND (BAPP(i + 1) = '1') AND (BAPP(i) = '0'))) THEN
			-- -1 * (A<<i)
			O <= A_ns1;

		ELSE
			O <= (OTHERS => '0');
		END IF;

	END PROCESS;
END BEHAVIOURAL;

CONFIGURATION CFG_BOOTHENC_BEHAVIOURAL OF BOOTHENC IS
	FOR BEHAVIOURAL
	END FOR;
END CFG_BOOTHENC_BEHAVIOURAL;