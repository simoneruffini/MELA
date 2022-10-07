--------------------------------------------------------------------------------
-- Engineer: Matteo Bonora [matteo.bonora@studenti.polito.it]
--           Lorenzo Latella [lorenzo.latella@studenti.polito.it]
--           Simone Ruffini [simone.ruffini@studenti.poilito.it]
--
-- Create Date:     Fri Apr 25 11:03:55 CEST 2022
-- Design Name:     Windowed register file address decoder
-- Module Name:     ADDR_DEC.vhd
-- Project Name:    Windowed Register File
-- Description:     Windowed register file address decoder
--
--
-- Revision:
-- Revision 00 - Matteo Bonora
--  first implementation
-- Additional Comments:
--
--------------------------------------------------------------------------------
library IEEE;
  use IEEE.std_logic_1164.ALL;
  use IEEE.numeric_std.ALL;
  use IEEE.math_real.ALL;

library WORK;
  use WORK.COMM_PKG.ALL;

entity ADDR_DEC is
  generic (
    N_GLOBAL_REG  : INTEGER; -- M
    N_REG_PER_WIN : INTEGER; -- N
    N_WIN         : INTEGER  -- F
  );
  port (
    VIRT_ADDR     : in std_logic_vector(addr_w_virt(N_WIN,N_REG_PER_WIN,N_GLOBAL_REG)-1 downto 0); -- Virtual Address
    CWP           : in std_logic_vector(addr_w_phys(N_WIN,N_REG_PER_WIN,N_GLOBAL_REG)-1 downto 0);    
    PHY_ADDR      : out std_logic_vector(addr_w_phys(N_WIN,N_REG_PER_WIN,N_GLOBAL_REG)-1 downto 0) -- Physical Address
  );
end ADDR_DEC;

--- First architecture. This used a LUT to handle CWP, but it was not syntesizable.
architecture Behavioural OF ADDR_DEC IS
  constant GLOBAL_ADDR : integer := (2 * N_WIN)* N_REG_PER_WIN;
  type lut_t is array (N_WIN - 1 downto 0) of integer range 0 to (2 * N_REG_PER_WIN * (N_WIN-1));

  -- N_WIN = 8
  -- N_REG_PER_WIN = 8
  --   PHYS_ADDR (range 0 to 2*N_WIN*N_REG_PER_WIN -1)
  --|lutaddr|lutval| 
  --|   0   | 0000 |  CWP 0   full_window [0 2]
  --|   1   | 0016 |  CWP 2   full_window [2 4]
  --|   2   | 0032 |  CWP 4   full_window [4 6]
  --|   3   | 0064 |  CWP 6   full_window [6 8]
  --|   4   | 0048 |  CWP 8   full_window [8 10]
  --|   5   | 0080 |  CWP 10  full_window [10 12]
  --|   6   | 0096 |  CWP 12  full_window [12 14]
  --|   7   | 0112 |  CWP 14  full_window [14 0]

  impure function generate_wp_lut(
    nubmer_of_window : INTEGER;
    number_of_registers_per_window : INTEGER
  ) return lut_t is

    variable ret : lut_t;

  begin
    for i in 0 to nubmer_of_window - 1 loop
      ret(i) := (i * 2 * number_of_registers_per_window);
    end loop;
    return ret;
  end function generate_wp_lut;

  SIGNAL cwp_lut : lut_t := generate_WP_lut(N_WIN, N_REG_PER_WIN); -- translates CWP values to physical memory addersses

BEGIN

  DECODER : process (VIRT_ADDR, CWP)
  begin
    -- If the virtual address is in the global address space, then we point to
    -- the global addresses which are at the end of the addressing space
    if ( to_integer(unsigned(VIRT_ADDR)) > ( (3*N_REG_PER_WIN) - 1) ) then
      -- Global registers are at the end of the RF
      PHY_ADDR <= std_logic_vector(
                    GLOBAL_ADDR + 
                    ( resize(unsigned(VIRT_ADDR),PHY_ADDR'length) - ( 3 * N_REG_PER_WIN) )
                  );  
    else
      -- Otherwise, the physical address starts at CWP and we just add the
      -- virtual address. To handle the circular buffer we need a modulo
      -- operator to turn the value round to 0

      -- Mod operator is not syntesizable
      PHY_ADDR <= std_logic_vector(
                    (unsigned(CWP) + resize(unsigned(VIRT_ADDR),PHY_ADDR'length) ) mod (N_REG_PER_WIN * N_WIN * 2)
                  );  
    end if;
  end process DECODER;
end Behavioural;

-- This architecture does not make use of the modulo, but uses simple
-- subtractions to figure out the correct physical address
architecture Behavioural2 OF ADDR_DEC IS
  constant GLOBAL_ADDR : integer := (2 * N_WIN)* N_REG_PER_WIN;

BEGIN

  DECODER : process (VIRT_ADDR, CWP)
  begin
    -- This condition is the same as Behavioural
    if ( to_integer(unsigned(VIRT_ADDR)) > ( (3*N_REG_PER_WIN) - 1) ) then
      -- Global registers are at the end of the RF
      PHY_ADDR <= std_logic_vector(
                    GLOBAL_ADDR + 
                    ( resize(unsigned(VIRT_ADDR),PHY_ADDR'length) - ( 3 * N_REG_PER_WIN) )
                  );
    
    else
      -- If the number of addresses left (from CWP to the start of the
      -- GLOBAL_ADDRESSES) is less than our virtual address, then we cannot
      -- simply add CWP to the virtual address, since we will end up in the
      -- globals. To circumvent this, if this condition is verified, we set the
      -- physical address as the virtual address subtracted by the number of
      -- addresses between CWP and GLOBAL_ADDR.
      if(((GLOBAL_ADDR-1)-unsigned(CWP)) < unsigned(VIRT_ADDR)) then
        PHY_ADDR<=std_logic_vector( 
                    resize(unsigned(VIRT_ADDR),PHY_ADDR'length) - ( GLOBAL_ADDR -resize(unsigned(CWP),PHY_ADDR'length))
                  );
      else
        PHY_ADDR <= std_logic_vector( unsigned(CWP) + resize(unsigned(VIRT_ADDR),PHY_ADDR'length) );  
      end if;
    end if;
  end process DECODER;
end Behavioural2;

-- This architecture should work like Behavioural2, but has never been tested
architecture Behavioural3 OF ADDR_DEC IS
  constant GLOBAL_ADDR : integer := (2 * N_WIN)* N_REG_PER_WIN;

BEGIN

  -- Virtual Address:
  -- [0               ,   N_REG_PER_WIN-1] => GLOBAL BLOCK  => CONDITION A
  -- [N_REG_PER_WIN   , 2*N_REG_PER_WIN-1] => INPUT BLOCK 
  -- [2*N_REG_PER_WIN , 3*N_REG_PER_WIN-1] => LOCAL BLOCK 
  -- [3*N_REG_PER_WIN , 4*N_REG_PER_WIN-1] => OUTPUT BLOCK  => CONDITION B
  DECODER : process (VIRT_ADDR, CWP)
  begin
    
    -- CONDITION A
    if ( to_integer(unsigned(VIRT_ADDR)) < N_REG_PER_WIN ) then
      PHY_ADDR <= std_logic_vector(
                    GLOBAL_ADDR + 
                    ( resize(unsigned(VIRT_ADDR),PHY_ADDR'length) - ( 3 * N_REG_PER_WIN) )
                  );  
    else
      PHY_ADDR <= std_logic_vector( unsigned(CWP) + resize(unsigned(VIRT_ADDR),PHY_ADDR'length) );  

      -- Corner case when CWP is in the last position and the OUTPUT block is on top of the RF
      if (unsigned(CWP) = 2*(N_WIN-1)*N_REG_PER_WIN)then

        -- CONDITION B
        if( to_integer(unsigned(VIRT_ADDR)) > 3*N_REG_PER_WIN -1 ) then
          PHY_ADDR <= std_logic_vector( 0 + resize(unsigned(VIRT_ADDR),PHY_ADDR'length) - (3*N_REG_PER_WIN) );  
        end if;
      end if;
    end if;
  end process DECODER;
end Behavioural3;

configuration CFG_ADDR_DEC_BEHAVIOURAL OF ADDR_DEC IS
  for Behavioural
  end for;
end configuration;
configuration CFG_ADDR_DEC_BEHAVIOURAL2 OF ADDR_DEC IS
  for Behavioural2
  end for;
end configuration;
configuration CFG_ADDR_DEC_BEHAVIOURAL3 OF ADDR_DEC IS
  for Behavioural3
  end for;
end configuration;
