-- ----------------------------------------------------------------------------	
-- FILE: 	wfm_player_rst_ctrl_tb.vhd
-- DESCRIPTION:	
-- DATE:	Feb 13, 2014
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity wfm_player_rst_ctrl_tb is
end wfm_player_rst_ctrl_tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of wfm_player_rst_ctrl_tb is
   constant clk0_period   : time := 10 ns;
   constant clk1_period   : time := 10 ns; 
   --signals
	signal clk0,clk1		   : std_logic;
	signal reset_n          : std_logic;
   
   signal dut0_wfm_load    : std_logic;
 

begin 
  
      clock0: process is
	begin
		clk0 <= '0'; wait for clk0_period/2;
		clk0 <= '1'; wait for clk0_period/2;
	end process clock0;

   	clock: process is
	begin
		clk1 <= '0'; wait for clk1_period/2;
		clk1 <= '1'; wait for clk1_period/2;
	end process clock;
	
		res: process is
	begin
		reset_n <= '0'; wait for 20 ns;
		reset_n <= '1'; wait;
	end process res;
   
   wfm_load: process is
	begin
		dut0_wfm_load <= '0'; 
      wait until reset_n = '1';
      wait until rising_edge(clk0);
      dut0_wfm_load <= '1';
      wait;
	end process wfm_load;
  
  
  wfm_player_rst_ctrl_dut0 : entity work.wfm_player_rst_ctrl
   port map(

      clk                     => clk0,
      global_reset_n          => reset_n,

      wfm_load                => dut0_wfm_load,
      wfm_load_ext            => open,
      wfm_play_stop           => '0',

      ram_init_done           => '0',
      ram_global_reset_n      => open,
      ram_soft_reset_n        => open,
      ram_wcmd_reset_n        => open,
      ram_rcmd_reset_n        => open,

      wfm_player_reset_n      => open,
      wfm_player_wcmd_reset_n => open,
      wfm_player_rcmd_reset_n => open,

      dcmpr_reset_n           => open
        );
	
	end tb_behave;
  
  


  
