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

------------------------------------------------------------- PACKAGES/LIBRARIES
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

library WORK;
  use work.carry_generator_pkg.all;

------------------------------------------------------------- ENTITY

entity CARRY_GENERATOR is
  generic (
    NBIT           : integer := 32;
    NBIT_PER_BLOCK : integer := 4
  );
  port (
    A   : in    std_logic_vector(NBIT - 1 downto 0);
    B   : in    std_logic_vector(NBIT - 1 downto 0);
    CIN : in    std_logic;
    CO  : out   std_logic_vector((NBIT / NBIT_PER_BLOCK) - 1 downto 0)
  );
end entity CARRY_GENERATOR;

------------------------------------------------------------- ARCHITECTURE

architecture STRUCTURAL of CARRY_GENERATOR is

  component PG_PRIM is
    port (
      A : in    std_logic;
      B : in    std_logic;
      G : out   std_logic;
      P : out   std_logic
    );
  end component;

  component GG is
    port (
      G_CURRENT   : in    std_logic;
      P_CURRENT   : in    std_logic;
      G_PREV      : in    std_logic;
      G           : out   std_logic
    );
  end component;

  component GP is
    port (
      P_CURRENT   : in    std_logic;
      P_PREV      : in    std_logic;
      P           : out   std_logic
    );
  end component;

  ----------------------------------------------------------- CONSTANTS 1

  constant LOG_NBIT      : natural := integer(log2(real(NBIT)));
  constant H_SPARSE_TREE : natural := LOG_NBIT;                             -- heigth sparse tree
  constant H_BKBONE      : natural := integer(log2(real(NBIT_PER_BLOCK)));  -- heigth backbone
  constant H_GPGG_NET    : natural := H_SPARSE_TREE - H_BKBONE;             -- heigth group P/ group G network

  ----------------------------------------------------------- TYPES

  ----------------------------------------------------------- FUNCTIONS

  ----------------------------------------------------------- CONSTANTS 2

  ----------------------------------------------------------- SIGNALS

  -- carry generator crossbars (+1 bit for carry_in in position 0)
  signal cg_xbars        : crossbar_t (LOG_NBIT downto 0, NBIT downto 0);
  signal a_local         : std_logic_vector(NBIT - 1 downto 0);
  signal b_local         : std_logic_vector(NBIT - 1 downto 0);

  -- Asserts compliance of the inputs
  signal test : natural := assert_bits(BIT_WIDTH => NBIT, CARRY_STEP => NBIT_PER_BLOCK);
  
begin


  -------------------------- PRIMITIVE P,G NETWORK -----------------------------

  -- Generate PG primitives network

  GEN_PG_PRIM_NET : for I in 0 to NBIT - 1 generate
    signal g_0, p_0 : std_logic;
  begin

    -- The Carry Network has a carry_in signal that needs to be take into account
    -- To correctly generate the Ladner-Fisher sparse tree parallel-prefix carry
    -- network and to simplify the design a Group Generate block is used directly
    -- at the output of the p0g0 to take into account the carry_in and to keep the
    -- backbone of the network regular

    GEN_FIRST_RXMOST_PG_PRIM : if I = 0 generate

      U_PG_PRIM : PG_PRIM
        port map (
          A => A(i),
          B => B(i),
          G => g_0,
          P => p_0
        );

      U_RXMOST_PG_PRIM_IS_GG_UNIT : GG
        port map (
          G_CURRENT => g_0,
          P_CURRENT => p_0,
          G_PREV    => CIN,
          G         => cg_xbars(0,i)(g_idx)
        );

      cg_xbars(0,i)(p_idx) <= '0'; -- Definition of P[0;0]=0

    end generate GEN_FIRST_RXMOST_PG_PRIM;

    -- other PG primitives use A,B inputs

    GEN_OTHER_PG_PRIM : if I>0 generate

      U_PG_PRIM : PG_PRIM
        port map (
          A => A(i),
          B => B(i),
          G => cg_xbars(0,i)(g_idx),
          P => cg_xbars(0,i)(p_idx)
        );

    end generate GEN_OTHER_PG_PRIM;

  end generate GEN_PG_PRIM_NET;

  ------------------------------------------------------------------------------

  -------------------------- CARRY NETWORK -------------------------------------

  ----------------------------------------------------
  -- BACKBONE OF CARRY NETWORK
  ----------------------------------------------------

  -- Generate backbone of GP/GG network

  GEN_BKBONE_GPGG_NET : for i in 1 to H_BKBONE generate

    GEN_BKBONE_GPGG_NET_ROW : for j in 0 to NBIT - 1 generate

      -- generate group P/G units

      GEN_BKBONE_GRP_UNITS : if (((j + 1) mod (2 ** i)) = 0) generate

        -- all nodes in theory could be PG_PRFX_OP nodes but it would be useless for the first rightmost ones.
        -- the P value wouldn't be used because this nodes will generate the full carry till this point so G_PRFX_OP is
        -- enough to get that value

        U_BKBONE_GG_UNIT : GG
          port map (
            G_CURRENT => cg_xbars(i - 1,j)(g_idx),
            P_CURRENT => cg_xbars(i - 1,j)(p_idx),
            G_PREV    => cg_xbars(i - 1,j - (2 ** (i - 1)) )(g_idx),
            G         => cg_xbars(i,j)(g_idx)
          );

        GEN_GP_UNIT : if (j + 1) > (2 ** i) generate

          U_BKBONE_GP_UNIT : GP
            port map (
              P_CURRENT => cg_xbars(i - 1,j)(p_idx),
              P_PREV    => cg_xbars(i - 1,j - (2 ** (i - 1)) )(p_idx),
              P         => cg_xbars(i,j)(p_idx)
            );

        end generate GEN_GP_UNIT;

      end generate GEN_BKBONE_GRP_UNITS; -- END if ( (j+1) mod (2 ** i) ) = 0 generate

    end generate GEN_BKBONE_GPGG_NET_ROW;

  end generate GEN_BKBONE_GPGG_NET;

  ------------------------------------------------------------
  -- Ladner-Fisher GP & GG NETWORK on NBIT_PER_BLOCK steps
  ------------------------------------------------------------

  GEN_LF_GPGG_NET : for i in 1 to H_GPGG_NET generate

    GEN_LF_GPGG_NET_ROW : for j in 0 to NBIT generate

      -- Select the columns that will generate the carry signal

      GEN_LF_GRP_UNITS : if ((j + 1) mod NBIT_PER_BLOCK) = 0 generate

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

        GEN_LF_ALG : if ((j / NBIT_PER_BLOCK) / ( 2 ** (i - 1))) mod 2 = 1 generate

          --              j                     +>  j%(2^(i-1)*NBIT) <+
          -- [i=n-1]      V                  ...|---------------------|0
          -- [i=n]   ...--*----------*----------*----------*----------|0
          U_LF_GG_UNIT : GG
            port map (
              G_CURRENT => cg_xbars(H_BKBONE + i - 1 ,j)(g_idx),
              P_CURRENT => cg_xbars(H_BKBONE + i - 1 ,j)(p_idx),
              G_PREV    => cg_xbars(H_BKBONE + i - 1 ,j - (j mod (2 ** (i - 1) * NBIT_PER_BLOCK) ) - 1)(g_idx),
              G         => cg_xbars(H_BKBONE + i,j)(g_idx)
            );

          -- place GP units only once all GG units are placed

          GEN_LF_GP_UNITS : if ((j + 1) > ( 2 ** i * NBIT_PER_BLOCK)) generate

            U_LF_GP_UNIT : GP
              port map (
                P_CURRENT => cg_xbars(H_BKBONE + i - 1,j)(p_idx),
                P_PREV    => cg_xbars(H_BKBONE + i - 1,j - (j mod (2 ** (i - 1) * NBIT_PER_BLOCK) ) - 1)(p_idx),
                P         => cg_xbars(H_BKBONE + i,j)(p_idx)
              );

          end generate GEN_LF_GP_UNITS;

        end generate GEN_LF_ALG; -- END if ( (j/NBIT_PER_BLOCK)/( 2 ** (i - 1) ) ) mod 2 = 1

        -- ELSE

        GEN_BUFFER_PREV_RESULT : if not (((j / NBIT_PER_BLOCK) / ( 2 ** (i - 1))) mod 2 = 1) generate

          -- get previous level results to this level
          cg_xbars(H_BKBONE + i,j) <= cg_xbars(H_BKBONE + i - 1, j);

        end generate GEN_BUFFER_PREV_RESULT;

      end generate GEN_LF_GRP_UNITS; -- END if ((j+1) mod NBIT_PER_BLOCK ) = 0

    end generate GEN_LF_GPGG_NET_ROW;

  end generate GEN_LF_GPGG_NET;

  -------------------------- OUTPUTS -------------------------------------------

  GEN_ASSIGN_OUTPUT : for i in 1 to (NBIT / NBIT_PER_BLOCK) generate
    Co(i - 1) <= cg_xbars(H_SPARSE_TREE, (i * NBIT_PER_BLOCK) - 1)(g_idx);
  end generate GEN_ASSIGN_OUTPUT;

------------------------------------------------------------------------------

end architecture STRUCTURAL;

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
