--------------------------------------------------------------------------------
-- Engineer: Simone Ruffini [simone.ruffini@studenti.polito.it]
-- 
-- Create Date:     Thu Mar 24 10:31:29 CET 2022
-- Design Name:     CARRY GENERATOR
-- Module Name:     CARRY_GENERATOR.vhd
-- Project Name:    P4 adder
-- Description:     Ladner-Fisher sparse tree parallel-prefix carry generator
-- Constraints:
--                  NBIT > NBIT_PER_BLOCK
--                  NBIT, NBIT_PER_BLOCK must be power of 2
-- Revision:
-- Revision 00 - Simone Ruffini
--  * Created
-- Additional Comments:
-- Co(0) == Carry out on NBIT_PER_BLOCK bits A,B[NBIT_PER_BLOCK-1:0]
-- Co(1) == Carry out on NBIT_PER_BLOCK bits A,B[2*NBIT_PER_BLOCK-1:0]
-- ...
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library WORK;
use work.CARRY_GENERATOR_PKG.all;

entity CARRY_GENERATOR is
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
end CARRY_GENERATOR;


architecture STRUCTURAL of CARRY_GENERATOR is

  component PG_PRIM is
    port (
      A : IN STD_LOGIC;
      B : IN STD_LOGIC;
      g : OUT STD_LOGIC;
      p : OUT STD_LOGIC
    );
  end component;
  component GG IS
    port (
      G_current   : IN STD_LOGIC; 
      P_current   : IN STD_LOGIC; 
      G_prev      : IN STD_LOGIC; 
      G           : OUT STD_LOGIC
    );
  end component;
  component gp is
    port (
      P_current   : IN STD_LOGIC; 
      P_prev      : IN STD_LOGIC; 
      P           : out STD_LOGIC
    );
  end component;

  constant log_nbit      : natural := integer(log2(real(NBIT)));
  constant H_sparse_tree : natural := log_nbit;                             -- heigth sparse tree
  constant H_bkbone      : natural := integer(log2(real(NBIT_PER_BLOCK)));  -- heigth backbone
  constant H_GPGG_net    : natural := H_sparse_tree - H_bkbone;             -- heigth group P/ group G network

  -- carry generator crossbars (+1 bit for carry_in in position 0)
  signal CG_xbars   : crossbar_t (log_nbit downto 0, NBIT downto 0); 
  signal A_local : STD_LOGIC_VECTOR(NBIT - 1 downto 0);
  signal B_local : STD_LOGIC_VECTOR(NBIT - 1 downto 0);

begin
  

  -- Asserts compliance of the inputs 
  TEST_GENERIC_PROCEDURE : assert_bits( BIT_WIDTH => NBIT , CARRY_STEP => NBIT_PER_BLOCK );
  

  -------------------------- PRIMITIVE P,G NETWORK -----------------------------

  -- Generate PG primitives network
  GEN_PG_PRIM_NET : for I in 0 to NBIT-1 generate
    signal g_0,p_0 : std_logic;
  begin
       
    -- The Carry Network has a carry_in signal that needs to be take into account
    -- To correctly generate the Ladner-Fisher sparse tree parallel-prefix carry
    -- network and to simplify the design a Group Generate block is used directly
    -- at the output of the p0g0 to take into account the carry_in and to keep the 
    -- backbone of the network regular

    GEN_FIRST_RXMOST_PG_PRIM: if I = 0 generate
      U_PG_PRIM: PG_PRIM
        port map (
          A => A(i),
          B => B(i),
          g => g_0,
          p => p_0
        );

      U_RXMOST_PG_PRIM_IS_GG_UNIT: GG
        port map(
          G_current => g_0,
          P_current => p_0,
          G_prev    => Cin,
          G         => CG_xbars(0,i)(g_idx)
        );

      CG_xbars(0,i)(p_idx) <= '0'; -- Definition of P[0;0]=0

    end generate GEN_FIRST_RXMOST_PG_PRIM;

    -- other PG primitives use A,B inputs
    GEN_OTHER_PG_PRIM: if I>0 generate
      U_PG_PRIM: PG_PRIM
        port map (
          A => A(i),
          B => B(i),
          g => CG_xbars(0,i)(g_idx),
          p => CG_xbars(0,i)(p_idx)
        );
    end generate GEN_OTHER_PG_PRIM;

  end generate GEN_PG_PRIM_NET;
  ------------------------------------------------------------------------------

  -------------------------- CARRY NETWORK -------------------------------------

  ----------------------------------------------------
  -- BACKBONE OF CARRY NETWORK 
  ----------------------------------------------------

  -- Generate backbone of GP/GG network
  GEN_BKBONE_GPGG_NET: for i in 1 to H_bkbone generate

    GEN_BKBONE_GPGG_NET_ROW: for j in 0 to NBIT - 1 generate

      -- generate group P/G units
      GEN_BKBONE_GRP_UNITS: if ( ( (j+1) mod (2 ** i) ) = 0 ) generate

        -- all nodes in theory could be PG_PRFX_OP nodes but it would be useless for the first rightmost ones.
        -- the P value wouldn't be used because this nodes will generate the full carry till this point so G_PRFX_OP is
        -- enough to get that value

        U_BKBONE_GG_UNIT: GG
          port map(
            G_current => CG_xbars(i-1,j)(g_idx),
            P_current => CG_xbars(i-1,j)(p_idx),
            G_prev    => CG_xbars(i-1,j - (2 ** (i- 1)) )(g_idx),
            G         => CG_xbars(i,j)(g_idx)
          );
        GEN_GP_UNIT: if (j+1) > (2 ** i) generate
          U_BKBONE_GP_UNIT: GP
            port map(
              P_current => CG_xbars(i-1,j)(p_idx),
              P_prev    => CG_xbars(i-1,j - (2 ** (i- 1)) )(p_idx),
              p         => CG_xbars(i,j)(p_idx)
            );

        end generate GEN_GP_UNIT; 

      end generate GEN_BKBONE_GRP_UNITS; -- END if ( (j+1) mod (2 ** i) ) = 0 generate

    end generate GEN_BKBONE_GPGG_NET_ROW;
       
  end generate GEN_BKBONE_GPGG_NET;

  ------------------------------------------------------------
  -- Ladner-Fisher GP & GG NETWORK on NBIT_PER_BLOCK steps
  ------------------------------------------------------------

  GEN_LF_GPGG_NET: for i in 1 to H_GPGG_net generate

    GEN_LF_GPGG_NET_ROW: for j in 0 to NBIT generate

      -- Select the columns that will generate the carry signal
      GEN_LF_GRP_UNITS: if ((j+1) mod NBIT_PER_BLOCK ) = 0 generate

        -- This algorithm works in a recursive bottom up approach:
        --
        -- 0| recursive(start_idx,end_idx):
        -- 1|   if start_idx>=end_idx : exit
        -- 2|   for i=start_idx to (start_idx+end_idx)/2 :
        -- 3|     if i % NBIT_PER_BLOCK == 0 :
        -- 4|       place GP/GG block and connect with next level leftmost block 
        -- 5|   recursive(start_idx,(start_idx+end_idx)/2);
        -- 6|   recursive((start_idx+end_idx)/2,end_idx);
        --
        -- call: recursive(0,NBIT)
        -- 
        -- But we make this algorithm iterative and in top down approach 
        -- mod 2 = 1 selects the left side of the section (line 2 of algorithm)
        -- j/NBIT_PER_BLOCK)/( 2 ** (i - 1) selects the halfs (idxs from recursion)
        GEN_LF_ALG: if ( (j/NBIT_PER_BLOCK)/( 2 ** (i - 1) ) ) mod 2 = 1 generate
             
          --              j                     +>  j%(2^(i-1)*NBIT) <+
          -- [i=n-1]      V                  ...|---------------------|0
          -- [i=n]   ...--*----------*----------*----------*----------|0
          U_LF_GG_UNIT: GG
            port map(
              G_current => CG_xbars(H_bkbone + i-1 ,j)(g_idx),
              P_current => CG_xbars(H_bkbone + i-1 ,j)(p_idx),
              G_prev    => CG_xbars(H_bkbone + i-1 ,j - (j mod (2 ** (i - 1) * NBIT_PER_BLOCK) ) -1)(g_idx), -- see below
              G         => CG_xbars(H_bkbone + i,j)(g_idx)
            );

          -- place GP units only once all GG units are placed
          GEN_LF_GP_UNITS: if ( (j+1) > ( 2 ** i * NBIT_PER_BLOCK ) ) generate
            U_LF_GP_UNIT: GP
              port map(
                P_current => CG_xbars(H_bkbone + i -1,j)(p_idx),
                P_prev    => CG_xbars(H_bkbone + i -1,j - (j mod (2 ** (i - 1) * NBIT_PER_BLOCK) ) -1)(p_idx),
                p         => CG_xbars(H_bkbone + i,j)(p_idx)
              );
          end generate GEN_LF_GP_UNITS;

        end generate GEN_LF_ALG; -- END if ( (j/NBIT_PER_BLOCK)/( 2 ** (i - 1) ) ) mod 2 = 1
        --ELSE
        GEN_BUFFER_PREV_RESULT: if not (( (j/NBIT_PER_BLOCK)/( 2 ** (i - 1) ) ) mod 2 = 1) generate

              -- get previous level results to this level
              CG_xbars(H_bkbone + i,j) <= CG_xbars(H_bkbone + i -1,j);

        end generate GEN_BUFFER_PREV_RESULT;


      end generate GEN_LF_GRP_UNITS; --END if ((j+1) mod NBIT_PER_BLOCK ) = 0

    end generate GEN_LF_GPGG_NET_ROW;

  end generate GEN_LF_GPGG_NET;

  -------------------------- OUTPUTS -------------------------------------------

  GEN_ASSIGN_OUTPUT: for i in 1 to (NBIT/NBIT_PER_BLOCK) generate
      Co(i-1) <= CG_xbars(H_sparse_tree ,(i*NBIT_PER_BLOCK)-1)(g_idx);
  end generate GEN_ASSIGN_OUTPUT;
  ------------------------------------------------------------------------------

end STRUCTURAL;

configuration CFG_CARRY_GENERATOR_STRUCTURAL of CARRY_GENERATOR is
  for STRUCTURAL
    for GEN_PG_PRIM_NET
      for GEN_FIRST_RXMOST_PG_PRIM
        for all: PG_PRIM
          USE CONFIGURATION WORK.CFG_PG_PRIM_BEHAVIORAL_XOR;
        end for;
        for all: GG
          USE CONFIGURATION WORK.CFG_GG_BEHAVIORAL;
        end for;
      end for;
      for GEN_OTHER_PG_PRIM
        for all: PG_PRIM
          USE CONFIGURATION WORK.CFG_PG_PRIM_BEHAVIORAL_XOR;
        end for;
      end for;
    end for;
    for GEN_BKBONE_GPGG_NET
      for GEN_BKBONE_GPGG_NET_ROW
        for GEN_BKBONE_GRP_UNITS
          for all: GG
            USE CONFIGURATION WORK.CFG_GG_BEHAVIORAL;
          end for;
          for GEN_GP_UNIT
            for all: GP
              USE CONFIGURATION WORK.CFG_GP_BEHAVIORAL;
            end for;
          end for;
        end for;
      end for;
    end for;
    for GEN_LF_GPGG_NET
      for GEN_LF_GPGG_NET_ROW
        for GEN_LF_GRP_UNITS
          for GEN_LF_ALG
            for all: GG
              USE CONFIGURATION WORK.CFG_GG_BEHAVIORAL;
            end for;
            for GEN_LF_GP_UNITS
              for all: GP
                USE CONFIGURATION WORK.CFG_GP_BEHAVIORAL;
              end for;
            end for;
          end for;
        end for;
      end for;
    end for;
  end for;
end CFG_CARRY_GENERATOR_STRUCTURAL;
