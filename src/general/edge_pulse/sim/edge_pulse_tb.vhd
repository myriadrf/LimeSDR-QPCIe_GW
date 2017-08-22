-- ----------------------------------------------------------------------------	
-- FILE: edge_pulse_tb.vhd
-- DESCRIPTION:   
-- DATE: August 17, 2017
-- AUTHOR(s): Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity edge_pulse_tb is
end edge_pulse_tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of edge_pulse_tb is
   constant clk0_period    : time := 10 ns;
   --signals
   signal clk0             : std_logic;
   signal reset_n          : std_logic;
   signal test_sign        : std_logic;
  
begin 
  
      clock0: process is
   begin
      clk0 <= '0'; wait for clk0_period/2;
      clk0 <= '1'; wait for clk0_period/2;
   end process clock0;
   
      res: process is
   begin
      reset_n <= '0'; wait for 20 ns;
      reset_n <= '1'; wait;
   end process res;
   
   process is 
   begin 
      test_sign <= '0';
      wait until reset_n = '1';
      wait until rising_edge(clk0);
      test_sign <= '1'; wait for 200 ns;
      wait until rising_edge(clk0);
      test_sign <= '0'; wait for 200 ns;
   end process;
   
       
  edge_pulse_inst0 : entity work.edge_pulse(arch_rising) 
port map(
   clk         => clk0,
   reset_n     => reset_n, 
   sig_in      => test_sign,
   pulse_out   => open
    );
   
   end tb_behave;
  
  


  
