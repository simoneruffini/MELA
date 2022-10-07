--------------------------------------------------------------------------------
-- Engineer:  Simone Ruffini [simone.ruffini@studenti.unitn.it]
--
--
-- Create Date:     Fri Apr 22 07:21:29 PM CEST 2022
-- Design Name:     Windowed Register File
-- Module Name:     WRF.vhd
-- Project Name:    Windowed Register File
-- Description:     windowed register file
--
-- Revision:
-- Revision 00 - Simone Ruffini
--  * File Created
-- Additional Comments:
--
--------------------------------------------------------------------------------
library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  use IEEE.math_real.all;

library WORK;
  use WORK.COMM_PKG.all;

entity WRF is
  generic (
    DATA_W        : integer;  -- Register Data Width
    N_WIN         : integer;  -- Number of windows
    N_REG_PER_WIN : integer;  -- Nubmer of register per window
    N_GLOBAL_REG  : integer   -- Number of register in the global "window"
  );
  port ( 
    CLK            : IN std_logic;                                                                      -- Rising Edge Clock
    RESET          : IN std_logic;                                                                      -- Positive RESET
    -- RF Ports
    ENABLE         : IN std_logic;                                                                      -- Enable Register File
    RD1_EN         : IN std_logic;                                                                      -- Read Enable on RADDR1/DOUT1
    RD2_EN         : IN std_logic;                                                                      -- Read Enable on RADDR2/DOUT2
    WR_EN          : IN std_logic;                                                                      -- Write Enable on WADDR/DIN
    WADDR          : IN std_logic_vector(addr_w_virt(N_WIN,N_REG_PER_WIN,N_GLOBAL_REG) - 1 downto 0);   -- Write address
    RADDR1         : IN std_logic_vector(addr_w_virt(N_WIN,N_REG_PER_WIN,N_GLOBAL_REG) - 1 downto 0);   -- Read address 1
    RADDR2         : IN std_logic_vector(addr_w_virt(N_WIN,N_REG_PER_WIN,N_GLOBAL_REG) - 1 downto 0);   -- Read address 2
    DIN            : IN std_logic_vector(DATA_W - 1 downto 0);                                          -- Data input (written on WADDR)
    DOUT1          : OUT std_logic_vector(DATA_W - 1 downto 0);                                         -- Data output 1 (from RADDR1)
    DOUT2          : OUT std_logic_vector(DATA_W - 1 downto 0);                                         -- Data output 2 (from RADDR2)
    -- Control Signal
    TRNSF_CPLT_ACK : IN std_logic;                                                                      -- Memory to register (or viceversa) data transfer complete ack. 
                                                                                                        -- IMOPRTANT the above signal must be a 1CLK period impulse
    OP             : IN wrf_op;                                                                         -- Issued Operation
    STATE          : OUT wrf_state;                                                                     -- state of WRF
    CWP            : OUT std_logic_vector(addr_w_phys(N_WIN,N_REG_PER_WIN,N_GLOBAL_REG)-1 downto 0);    -- Current Window Pointer
    SWP            : OUT std_logic_vector(addr_w_phys(N_WIN,N_REG_PER_WIN,N_GLOBAL_REG)-1 downto 0)     -- Save Window Pointer
  );
end WRF;

architecture Behavioural of WRF is 

  component WRF_CU is
    generic (
      N_GLOBAL_REG  : integer;  -- Number of register in the global "window"
      N_REG_PER_WIN : integer;  -- Nubmer of register per window
      N_WIN         : integer   -- Number of windows
    );
    port ( 
      CLK            : IN std_logic;                                                                   -- Rising Edge Clock
      RESET          : IN std_logic;                                                                   -- Positive RESET
      TRNSF_CPLT_ACK : IN std_logic;                                                                   -- Memory to register (or viceversa) data transfer complete ack. 
                                                                                                       -- IMOPRTANT the above signal must be a 1CLK period impulse
      OP             : IN wrf_op;                                                                      -- Issued Operation
      STATE          : OUT wrf_state;                                                                  -- state of WRF
      CWP            : OUT std_logic_vector(addr_w_phys(N_WIN,N_REG_PER_WIN,N_GLOBAL_REG)-1 downto 0); -- Current Window Pointer
      SWP            : OUT std_logic_vector(addr_w_phys(N_WIN,N_REG_PER_WIN,N_GLOBAL_REG)-1 downto 0)  -- Save Window Pointer
    );
  end component ;

  component ADDR_DEC is
    generic (
      N_GLOBAL_REG  : integer;  -- Number of register in the global "window"
      N_REG_PER_WIN : integer;  -- Nubmer of register per window
      N_WIN         : integer   -- Number of windows
    );
    port (
      VIRT_ADDR     : in std_logic_vector(addr_w_virt(N_WIN,N_REG_PER_WIN,N_GLOBAL_REG)-1 downto 0); -- Virtual Address
      CWP           : in std_logic_vector(addr_w_phys(N_WIN,N_REG_PER_WIN,N_GLOBAL_REG)-1 downto 0);    
      PHY_ADDR      : out std_logic_vector(addr_w_phys(N_WIN,N_REG_PER_WIN,N_GLOBAL_REG)-1 downto 0) -- Physical Address
    );
  end component ;

  component RF is
    generic(
      ADDR_W : INTEGER := integer(log2(32.0)); -- address signal width
      DATA_W : INTEGER := 64                   -- data input/output signal width
    );
    port ( 
      CLK     : IN std_logic;
      RESET   : IN std_logic;
      ENABLE  : IN std_logic;
      RD1     : IN std_logic;
      RD2     : IN std_logic;
      WR      : IN std_logic;
      ADD_WR  : IN std_logic_vector(ADDR_W - 1 downto 0);
      ADD_RD1 : IN std_logic_vector(ADDR_W - 1 downto 0);
      ADD_RD2 : IN std_logic_vector(ADDR_W - 1 downto 0);
      DATAIN  : IN std_logic_vector(DATA_W - 1 downto 0);
      OUT1    : OUT std_logic_vector(DATA_W - 1 downto 0);
      OUT2    : OUT std_logic_vector(DATA_W - 1 downto 0)
    );
  end component;

  signal cwp_s       : std_logic_vector(addr_w_phys(N_WIN,N_REG_PER_WIN,N_GLOBAL_REG)-1 downto 0); 

  signal waddr_phys  : std_logic_vector(addr_w_phys(N_WIN,N_REG_PER_WIN,N_GLOBAL_REG) - 1 downto 0);   -- Write address
  signal raddr1_phys : std_logic_vector(addr_w_phys(N_WIN,N_REG_PER_WIN,N_GLOBAL_REG) - 1 downto 0);   -- Read address 1
  signal raddr2_phys : std_logic_vector(addr_w_phys(N_WIN,N_REG_PER_WIN,N_GLOBAL_REG) - 1 downto 0);   -- Read address 2

begin

  U_WRF_CU: WRF_CU 
  generic map(
    N_GLOBAL_REG   => N_GLOBAL_REG,
    N_REG_PER_WIN  => N_REG_PER_WIN,
    N_WIN          => N_WIN
  )
  port map( 
    CLK            => CLK,
    RESET          => RESET,
    TRNSF_CPLT_ACK => TRNSF_CPLT_ACK,
    OP             => OP,    
    STATE          => STATE,
    CWP            => cwp_s,   
    SWP            => SWP   
  );

  U_ADDR_DEC_WADDR: ADDR_DEC 
  generic map(
    N_GLOBAL_REG  => N_GLOBAL_REG,
    N_REG_PER_WIN => N_REG_PER_WIN,
    N_WIN         => N_WIN        
  )
  port map(
    VIRT_ADDR     => WADDR,
    CWP           => cwp_s,
    PHY_ADDR      => waddr_phys
  );

  U_ADDR_DEC_RADDR1: ADDR_DEC 
  generic map(
    N_GLOBAL_REG  => N_GLOBAL_REG,
    N_REG_PER_WIN => N_REG_PER_WIN,
    N_WIN         => N_WIN        
  )
  port map(
    VIRT_ADDR     => RADDR1,
    CWP           => cwp_s,
    PHY_ADDR      => raddr1_phys
  );

  U_ADDR_DEC_RADDR2: ADDR_DEC 
  generic map(
    N_GLOBAL_REG  => N_GLOBAL_REG,
    N_REG_PER_WIN => N_REG_PER_WIN,
    N_WIN         => N_WIN        
  )
  port map(
    VIRT_ADDR     => RADDR2,
    CWP           => cwp_s,
    PHY_ADDR      => raddr2_phys
  );

  U_RF: RF 
  generic map(
    ADDR_W => addr_w_phys(N_WIN,N_REG_PER_WIN,N_GLOBAL_REG), -- address signal width
    DATA_W => DATA_W
  )
  port map( 
    CLK     => CLK, 
    RESET   => RESET, 
    ENABLE  => ENABLE, 
    RD1     => RD1_EN,
    RD2     => RD2_EN, 
    WR      => WR_EN, 
    ADD_WR  => waddr_phys, 
    ADD_RD1 => raddr1_phys, 
    ADD_RD2 => raddr2_phys, 
    DATAIN  => DIN, 
    OUT1    => DOUT1, 
    OUT2    => DOUT2
  );

  CWP <= cwp_s;

end Behavioural;

configuration CFG_WRF_BEHAVIOURAL of WRF is 
  for Behavioural
    for all: WRF_CU
      use configuration WORK.CFG_WRF_CU_BEHAVIOURAL;
    end for;
    for all: ADDR_DEC
      use configuration WORK.CFG_ADDR_DEC_BEHAVIOURAL2;
    end for;
    for all: RF
      use configuration WORK.CFG_RF_BEHAVIOURAL;
    end for;
  end for;
end configuration;
