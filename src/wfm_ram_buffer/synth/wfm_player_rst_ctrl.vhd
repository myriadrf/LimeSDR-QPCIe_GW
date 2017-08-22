-- ----------------------------------------------------------------------------	
-- FILE: 	wfm_player_rst_ctrl.vhd
-- DESCRIPTION:	reset controller for wfm player
-- DATE:	August 18, 2017
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity wfm_player_rst_ctrl is
   port (

      clk                     : in std_logic;
      global_reset_n          : in std_logic;
      
      wfm_load                : in std_logic;
      wfm_play_stop           : in std_logic;
      
      ram_init_done           : in std_logic;
      ram_global_reset_n      : out std_logic;
      ram_soft_reset_n        : out std_logic;
      ram_wcmd_reset_n        : out std_logic;
      ram_rcmd_reset_n        : out std_logic;
            
      wfm_player_reset_n      : out std_logic;
      wfm_player_wcmd_reset_n : out std_logic;
      wfm_player_rcmd_reset_n : out std_logic;
      
      dcmpr_reset_n           : out std_logic


        );
end wfm_player_rst_ctrl;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of wfm_player_rst_ctrl is
--declare signals,  components here
signal wfm_load_pulse_on_rising : std_logic;

--ram internal signals
signal ram_global_reset_n_int       : std_logic;
signal ram_soft_reset_n_int         : std_logic;
signal ram_wcmd_reset_n_int         : std_logic;
signal ram_rcmd_reset_n_int         : std_logic;
--wfm player internal signals
signal wfm_player_reset_n_int       : std_logic;
signal wfm_player_wcmd_reset_n_int  : std_logic;
signal wfm_player_rcmd_reset_n_int  : std_logic;

--data decompres signals
signal dcmpr_reset_n_int            : std_logic;
  
begin


--to detect rising edge of wfm_load
edge_pulse_inst0 : entity work.edge_pulse(arch_rising) 
port map(
   clk         => clk,
   reset_n     => global_reset_n, 
   sig_in      => wfm_load,
   pulse_out   => wfm_load_pulse_on_rising
);



-- ----------------------------------------------------------------------------
-- Ram reset part
-- ----------------------------------------------------------------------------
ram_global_reset_n_int  <= global_reset_n;
ram_soft_reset_n_int    <= not wfm_load_pulse_on_rising;
ram_wcmd_reset_n_int    <= not wfm_load_pulse_on_rising;
ram_rcmd_reset_n_int    <= ram_init_done;

-- ----------------------------------------------------------------------------
-- wfm player part
-- ----------------------------------------------------------------------------
wfm_player_reset_n_int      <= global_reset_n;
wfm_player_wcmd_reset_n_int <= not wfm_load_pulse_on_rising;
wfm_player_rcmd_reset_n_int <= ram_init_done;

-- ----------------------------------------------------------------------------
-- data decompres reset part
-- ----------------------------------------------------------------------------
dcmpr_reset_n_int <= not wfm_load;

-- ----------------------------------------------------------------------------
-- Output registers
-- ----------------------------------------------------------------------------
 process(global_reset_n, clk)
    begin
      if global_reset_n='0' then        
         ram_soft_reset_n        <= '0'; 
         ram_wcmd_reset_n        <= '0';
         ram_rcmd_reset_n        <= '0';     
         wfm_player_reset_n      <= '0';
         wfm_player_wcmd_reset_n <= '0';
         wfm_player_rcmd_reset_n <= '0';
         dcmpr_reset_n           <= '0';
      elsif (clk'event and clk = '1') then 
         ram_soft_reset_n        <= ram_soft_reset_n_int; 
         ram_wcmd_reset_n        <= ram_wcmd_reset_n_int;
         ram_rcmd_reset_n        <= ram_rcmd_reset_n_int;     
         wfm_player_reset_n      <= wfm_player_reset_n_int;
         wfm_player_wcmd_reset_n <= wfm_player_wcmd_reset_n_int;
         wfm_player_rcmd_reset_n <= wfm_player_rcmd_reset_n_int;
         dcmpr_reset_n           <= dcmpr_reset_n_int;
 	    end if;
    end process;
    
   ram_global_reset_n      <= ram_global_reset_n_int; 
  
end arch;   





