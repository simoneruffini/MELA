--------------------------------------------------------------------------------
-- Engineer: Simone Ruffini [simone.ruffini@studenti.polito.it,simone.ruffini@tutanota.com]
--           Matteo Bonora  [matteo.bonora@studenti.polito.it]
--
-- Create Date:     Sat 23 16:09:34 PM CEST 2022
-- Module Name:     DATAPATH
-- Project Name:    DLX
-- Description:     DLX datapath
--
-- Revision:
-- Revision 00 - Matteo Bonora
--  * Created
-- Additional Comments:
--
--------------------------------------------------------------------------------

------------------------------------------------------------- PACKAGES/LIBRARIES
library ieee;
  use ieee.STD_LOGIC_1164.all;
  use ieee.NUMERIC_STD.all;

library work;
  use work.DLX_PKG.all;

------------------------------------------------------------- ENTITY 
entity DATAPATH is
  port (
    CLK             : in    std_logic;                                               -- Clock Signal (rising-edge trigger)
    RST_AN          : in    std_logic;                                               -- Reset Signal: Asyncronous Negative 
    CTRL_WRD        : in  controlword_t(cw_signals_type'POS(CW_SIZE) - 1 downto 0);  -- Control Word from CU
    NPC             : out std_logic_vector(C_ARCH_WORD_W - 1 downto 0);              -- New Program Counter (PC++4)
    INSTR           : in  std_logic_vector(C_ARCH_WORD_W - 1 downto 0);              -- Instruction Word from Instr.MEM
    DMEM_ADDR       : out std_logic_vector(C_ARCH_WORD_W - 1 downto 0);              -- Data Memory address
    DMEM_DOUT       : in  std_logic_vector(C_ARCH_WORD_W - 1 downto 0)               -- Data Memory data output
  );
end entity DATAPATH;

------------------------------------------------------------- ARCHITECTURE 
architecture BEHAVIORAL of DATAPATH is
  ----------------------------------------------------------- CONSTANTS 1 

  ----------------------------------------------------------- TYPES 

  ----------------------------------------------------------- FUNCTIONS 

  ----------------------------------------------------------- CONSTANTS 2 

  ----------------------------------------------------------- SIGNALS 

begin

  ----------------------------------------------------------- ENTITY DEFINITION 
  U_ALU : entity work.ALU("Behavioural") is 
    port map();

  ----------------------------------------------------------- PROCESSES


end architecture BEHAVIORAL;

configuration CFG_DATAPATH_BEHAVIORAL of DATAPATH is
  for BEHAVIORAL
  end for;
end CFG_DATAPATH_BEHAVIORAL;
