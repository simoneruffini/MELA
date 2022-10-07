--------------------------------------------------------------------------------
-- Engineer: Simone Ruffini [simone.ruffini@studenti.polito.it]
--
-- Create Date:     Fri Apr 22 17:03:55 CEST 2022
-- Design Name:     Windowed Register File Control Unit
-- Module Name:     WRF_CU_CU.vhd
-- Project Name:    Windowed Register File
-- Description:     Fixed Window Register File Control Unit
--
--
-- Revision:
-- Revision 00 - Simone Ruffini
--  first implementation
-- Additional Comments:
--
--------------------------------------------------------------------------------
library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  use IEEE.math_real.all;

library WORK;
  use WORK.COMM_PKG.all;

entity WRF_CU is
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
end WRF_CU;

architecture Behavioural of WRF_CU is

  -- CONSTANTS #################################################################
  constant C_FRST_WNDW_PTR  : integer := 0;
  constant C_LAST_WNDW_PTR  : integer := 2*(N_WIN-1)*N_REG_PER_WIN;
  --constant C_LAST_WNDW_PTR  : integer := 2*(N_WIN-1);

  -- FUNCTIONS #################################################################

  -- Advance CWP/SWP pointer function 
  -- the pointer is advanced with the circular buffer constraint 
  function advance_ptr(wp: integer) return integer is
  begin
    if (wp = C_LAST_WNDW_PTR) then -- if the WP reached the end of the RF then it goes back as in a circular queue
        return C_FRST_WNDW_PTR;
    else
      return wp + (2*N_REG_PER_WIN);
      --return wp + 2;
    end if;
  end function advance_ptr;

  -- Retract CWP/SWP pointer function 
  -- the pointer is retracted with the circular buffer constraint
  function retract_ptr(wp: integer) return integer is
  begin
    if (wp = C_FRST_WNDW_PTR) then -- if the WP reached the end of the RF then it goes back as in a circular queue
        return C_LAST_WNDW_PTR;
    else
      return wp - (2*N_REG_PER_WIN);
      --return wp - 2;
    end if;
  end function retract_ptr;

  -- suggested structures
  type WRF_CU_fsm_state  is (
    INIT_s,      -- Initialization state
    FILL_s,      -- RF is filling data from memory
    SPILL_s,     -- RF is pushing data to memory
    RUN_s,       -- RF is running normally
    SUB_CALL_s,  -- RF is mowing forward the current set of windows due to a context switch (new subrutine)
    SUB_RET_s    -- RF is mowing backward the current set of windows due to a context switch (return of subrutine)
  );
  
  -- SIGNALS #################################################################

  signal wrf_cu_cur_state   : WRF_CU_fsm_state ;
  signal wrf_cu_fut_state   : WRF_CU_fsm_state ;
  signal can_save           : std_logic;
  signal can_restore        : std_logic;

  signal cwp_cntr : integer range 0 to (2*N_WIN)*N_REG_PER_WIN-1; -- current window pointer counter
  signal swp_cntr : integer range 0 to (2*N_WIN)*N_REG_PER_WIN-1; -- save window pointer counter
  --signal cwp_cntr : integer range 0 to (2*N_WIN)-1; -- current window pointer counter
  --signal swp_cntr : integer range 0 to (2*N_WIN)-1; -- save window pointer counter

  signal spill_cntr : std_logic_vector(N_WIN-1 -1 downto 0); -- spill_cntr(0) <=> can_save
  signal fill_cntr  : std_logic_vector(N_WIN-1 -1 downto 0);  -- fill_cntr(0) <=> can_restore

begin 

  -- WRF FSM >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

  -- Sequential process of the FSM
  WRF_FSM_SEQ: process (CLK,RESET)
  begin
    if (RESET='1') then

      wrf_cu_cur_state <= INIT_s; 

    elsif(rising_edge(CLK)) then

      wrf_cu_cur_state <= wrf_cu_fut_state ;

    end if;
  end process WRF_FSM_SEQ;

  -- Gotchas:
  -- Consecutive open/close contexts
  --
  -- After opening a context (subrutine call) or closing a context (subrutine exit)
  -- the FSM goes into RUN mode, thus two consecutive open/close contexts cannot
  -- be performed, they are always interleaved by a run state.
  --
  -- open/close context on fill/spill
  --
  -- If a open/close context is issued this does not mean that the operation completed 
  -- succesfully. If the next state is run the OK, otherwise if the next state is
  -- fill/spill then the context is completed at the end of the operation.

  -- Future state depends only on inputs and curent state
  WRF_FSM_FUT_STATE: process (
                        wrf_cu_cur_state,
                        OP,
                        can_save,
                        can_restore,
                        TRNSF_CPLT_ACK
                      ) 
  begin
    -- defaults on modified signals (remove possible latch inference)
    wrf_cu_fut_state <= wrf_cu_cur_state;

    case wrf_cu_cur_state is
      when INIT_s     =>
        wrf_cu_fut_state <= RUN_s;

      when RUN_s      =>
        case OP is
          when WRF_OPN_CTX =>
            if (can_save = '1') then
              wrf_cu_fut_state <= SUB_CALL_s;
            else
              wrf_cu_fut_state <= SPILL_s;
            end if;
          when WRF_CLS_CTX =>
            if (can_restore = '1') then
              wrf_cu_fut_state <= SUB_RET_s;
            else
              wrf_cu_fut_state <= FILL_s;
            end if;
          when WRF_NO_OP =>
           -- do nothing and remain in run
        end case;

      when SUB_CALL_s =>
        wrf_cu_fut_state <= RUN_s;

      when SUB_RET_s  =>
        wrf_cu_fut_state <= RUN_s;

      when FILL_s     =>
        if(TRNSF_CPLT_ACK = '1') then
          wrf_cu_fut_state <= RUN_s;
        end if;

      when SPILL_s    =>
        if(TRNSF_CPLT_ACK = '1' ) then
          wrf_cu_fut_state <= RUN_s;
        end if;

    end case;
  end process WRF_FSM_FUT_STATE;

  -- mooooooore machine
  WRF_FSM_MOORE_OUTPUTS: process ( wrf_cu_cur_state )
  begin 
    -- Defaults
    case wrf_cu_cur_state is
      when INIT_s     =>
        STATE <= INACTIVE_s;
      when RUN_s      =>
        STATE <= READY_s;
      when SUB_CALL_s =>
        STATE <= READY_s;
      when SUB_RET_s  =>
        STATE <= READY_s;
      when FILL_s     =>
        STATE <= FILL_s;
      when SPILL_s    =>
        STATE <= SPILL_s;
    end case;
  end process WRF_FSM_MOORE_OUTPUTS;

  -- WRF FSM <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
 
  -- This process uses the combinatory future_state of WRF_CU FSM, this is not
  -- a best practice but the combinatory logic stops here with a sequential circuit 
  -- so the delays are controlled

  P_NON_COMB_OUTPUTS: process (CLK,RESET) is 
  begin
    if (RESET = '1') then
      cwp_cntr <= 0;
      swp_cntr <= 0;
      spill_cntr    <= (others => '1');
      spill_cntr(1) <= '0';
      fill_cntr     <= (others => '1');
      fill_cntr(0)  <= '0';
    elsif (rising_edge(CLK)) then

      case wrf_cu_fut_state is

        when INIT_s     =>
          cwp_cntr      <= 0;
          swp_cntr      <= 0;
          spill_cntr    <= (others => '1');
          spill_cntr(1) <= '0';
          fill_cntr     <= (others => '1');
          fill_cntr(0)  <= '0';

        when RUN_s      =>
          cwp_cntr   <= cwp_cntr; -- latch
          swp_cntr   <= swp_cntr; -- latch
          spill_cntr <= spill_cntr;
          fill_cntr  <= fill_cntr ;

          -- if we just completed spilling advance SWP
          if(wrf_cu_cur_state = SPILL_s AND TRNSF_CPLT_ACK = '1') then
            swp_cntr <=advance_ptr(swp_cntr);
          end if;

          -- if we just completed filling retract SWP
          if(wrf_cu_cur_state = FILL_s AND TRNSF_CPLT_ACK = '1') then
            swp_cntr <=retract_ptr(swp_cntr);
          end if;

        when SUB_CALL_s =>
          cwp_cntr   <= advance_ptr(cwp_cntr);
          spill_cntr <= spill_cntr(spill_cntr'length-2 downto 0) & spill_cntr(spill_cntr'length-1); -- rotate left
          fill_cntr  <= fill_cntr(0) & fill_cntr(fill_cntr'length-1 downto 1); -- rotate right

        when SUB_RET_s  =>
          cwp_cntr    <= retract_ptr(cwp_cntr);
          spill_cntr  <= spill_cntr(0) & spill_cntr(spill_cntr'length-1 downto 1); -- rotate right
          fill_cntr   <= fill_cntr(fill_cntr'length-2 downto 0) & fill_cntr(fill_cntr'length-1); -- rotate left

        when FILL_s     =>
          -- do this operation once
          if (wrf_cu_cur_state /= FILL_s) then
            spill_cntr <= spill_cntr(spill_cntr'length-2 downto 0) & spill_cntr(spill_cntr'length-1); -- rotate left
            fill_cntr  <= fill_cntr(0) & fill_cntr(fill_cntr'length-1 downto 1); -- rotate right
          end if;

        when SPILL_s    =>
          -- do this operation once
          if (wrf_cu_cur_state /= SPILL_s) then
            spill_cntr <= spill_cntr(0) & spill_cntr(spill_cntr'length-1 downto 1); -- rotate right
            fill_cntr  <= fill_cntr(fill_cntr'length-2 downto 0) & fill_cntr(fill_cntr'length-1); -- rotate left
          end if;
      end case;
    end if;
  end process P_NON_COMB_OUTPUTS; 


  CWP <= std_logic_vector(to_unsigned(cwp_cntr,CWP'length));
  SWP <= std_logic_vector(to_unsigned(swp_cntr,SWP'length));
  --CWP <= std_logic_vector(to_unsigned(cwp_cntr*N_REG_PER_WIN,CWP'length));
  --SWP <= std_logic_vector(to_unsigned(swp_cntr*N_REG_PER_WIN,SWP'length));
  can_save    <= spill_cntr(0);
  can_restore <= fill_cntr(0);

end Behavioural;
----

configuration CFG_WRF_CU_BEHAVIOURAL of WRF_CU is
  for Behavioural
  end for;
end configuration;
