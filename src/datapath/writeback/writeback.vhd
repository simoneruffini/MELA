--------------------------------------------------------------------------------
-- Engineer: Simone Ruffini [simone.ruffini@studenti.polito.it,simone.ruffini@tutanota.com]
--           Matteo Bonora  [matteo.bonora@studenti.polito.it]
--
-- Create Date:     Sat 24 09:54:43 PM CEST 2022
-- Design Name:     Writeback
-- Module Name:     writeback.vhd
-- Project Name:    DLX
-- Description:     Writeback pipeline stage
--
-- Revision:
-- Revision 00 - Matteo Bonora
--  * Created
-- Additional Comments:
--
--------------------------------------------------------------------------------

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

library work;
  use work.comm_pkg.all;

entity writeback is
  generic (
    addr_w : integer := 32;
    data_w : integer := 32
  );
  port (
    ctrl_word : in    controlword_t(CW_SIZE - 1 downto 0);
    -- Inputs
    alu_out : in    std_logic_vector(data_w - 1 downto 0);
    lmd     : in    std_logic_vector(data_w - 1 downto 0);
    -- Outputs
    datapath_out : out   std_logic_vector(data_w - 1 downto 0);
    wb           : out   std_logic_vector(data_w - 1 downto 0)
  );
end entity writeback;

architecture behavioural of writeback is

  signal muxout : std_logic_vector(data_w - 1 downto 0);

begin

  datapath_out <= muxout;
  wb           <= muxout;

  wb_mux0 : process (ctrl_word, alu_out, lmd) is
  begin

    if (ctrl_word(WB_MUX)='1') then
      muxout <= lmd;
    else
      muxout <= alu_out;
    end if;

  end process wb_mux0;

end architecture behavioural;
