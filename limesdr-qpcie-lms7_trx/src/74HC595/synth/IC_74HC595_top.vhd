-- ----------------------------------------------------------------------------
-- FILE:          IC_74HC595_top.vhd
-- DESCRIPTION:   top file for IC_74HC595
-- DATE:          4:36 PM Thursday, December 14, 2017
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
--NOTES:
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity IC_74HC595_top is
   port (

      clk      : in std_logic;
      reset_n  : in std_logic;
      data     : in std_logic_vector(15 downto 0);
      busy     : out std_logic;
      
      SHCP     : out std_logic;  -- shift register clock
      STCP     : out std_logic;  -- storage register clock
      DS       : out std_logic   -- serial data
      
        );
end IC_74HC595_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of IC_74HC595_top is
--declare signals,  components here
signal data_remaped  : std_logic_vector (15 downto 0) ;
signal data_sync     : std_logic_vector (15 downto 0); 
signal data_sync_reg : std_logic_vector (15 downto 0);
signal data_change   : std_logic;

begin

-- ----------------------------------------------------------------------------
-- Remaping data into desired order
-- ----------------------------------------------------------------------------
data_remaped(0)   <= data(0);
data_remaped(1)   <= data(1);
data_remaped(2)   <= data(2);
data_remaped(3)   <= data(3);
data_remaped(4)   <= data(4);
data_remaped(5)   <= data(5);
data_remaped(6)   <= data(6);
data_remaped(7)   <= data(7);
data_remaped(8)   <= data(8);
data_remaped(9)   <= data(9);
data_remaped(10)  <= data(10);
data_remaped(11)  <= data(11);
data_remaped(12)  <= data(12);
data_remaped(13)  <= data(13);
data_remaped(14)  <= data(14);
data_remaped(15)  <= data(15);
 
-- ----------------------------------------------------------------------------
-- Data synchronization into clk domain
-- ----------------------------------------------------------------------------
bus_sync_reg0 : entity work.bus_sync_reg
generic map (16)
port map(clk, '1', data_remaped, data_sync);

-- ----------------------------------------------------------------------------
-- Detecting signal change
-- ----------------------------------------------------------------------------
 process(reset_n, clk)
    begin
      if reset_n='0' then
         data_sync_reg  <= (others=> '0');
         data_change    <= '0';
      elsif (clk'event and clk = '1') then
         data_sync_reg <= data_sync;
         if data_sync_reg = data_sync then 
            data_change <= '0';
         else 
            data_change <= '1';
         end if;
      end if;
    end process;

-- ----------------------------------------------------------------------------
-- Module instance
-- ----------------------------------------------------------------------------
IC_74HC595_inst0 : entity work.IC_74HC595
   generic map (
      data_width   => 16
   )
   port map (
      clk      => clk,
      reset_n  => reset_n,
      en       => data_change,
      data     => data_sync_reg,
      busy     => busy,
      
      SHCP     => SHCP,
      STCP     => STCP,
      DS       => DS
      );
  
end arch;   


