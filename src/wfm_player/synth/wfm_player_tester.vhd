-- ----------------------------------------------------------------------------
-- FILE:          wfm_player_tester.vhd
-- DESCRIPTION:   describe file
-- DATE:          Jan 27, 2016
-- AUTHOR(s):     12:28 PM Thursday, November 2, 2017
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
entity wfm_player_tester is
   generic(
      avl_data_width             : integer := 64;
      
      wfm_infifo_wrusedw_width   : integer := 11;
      wfm_infifo_wdata_width     : integer := 32;
      
      wfm_outfifo_rdusedw_width  : integer := 11;
      wfm_outfifo_rdata_width    : integer := 32
   );
   port (

      clk            : in std_logic;
      reset_n        : in std_logic;
      
      --wfm player control signals
      wfm_load       : out std_logic;
      wfm_play_stop  : out std_logic;
      
      --wfm infifo wfm_data -> wfm_infifo -> external memory
      wfm_infifo_wclk            : in std_logic;
      wfm_infifo_reset_n         : out std_logic;
      wfm_infifo_wrreq           : out std_logic;
      wfm_infifo_wdata           : out std_logic_vector(wfm_infifo_wdata_width-1 downto 0);
      wfm_infifo_wfull           : in std_logic;
      
      --wfm outfifo external memory -> wfm_outfifo -> wfm_data
      wfm_outfifo_rclk           : in std_logic;
      wfm_outfifo_rdreq          : out std_logic;
      wfm_outfifo_q              : in std_logic_vector(wfm_outfifo_rdata_width-1 downto 0);
      wfm_outfifo_rdempty        : in std_logic
      
        );
end wfm_player_tester;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of wfm_player_tester is
--declare signals,  components here
type state_type is (idle, wfm_load_hi, wfm_load_proc1, wfm_load_proc2, wfm_load_low);
signal current_state, next_state : state_type;

signal idle_cnt            : unsigned(16 downto 0);
signal wfm_load_hi_cnt     : unsigned(7 downto 0);
signal wfm_load_proc1_cnt  : unsigned(7 downto 0);
signal wfm_load_proc2_cnt  : unsigned(7 downto 0);
signal wfm_load_low_cnt    : unsigned(7 downto 0);
signal wfm_load_int        : std_logic;
signal wfm_infifo_wrreq_int: std_logic;
signal wfm_infifo_wdata_int: unsigned(wfm_infifo_wdata_width-1 downto 0);
signal wfm_play_stop_int   : std_logic;
signal wfm_load_rising     : std_logic;
signal fsm_reset_n         : std_logic;



  
begin
   
   edge_pulse_inst0 : entity work.edge_pulse(arch_rising)
   port map(
      clk         => clk,
      reset_n     => reset_n,
      sig_in      => wfm_load_int,
      pulse_out   => wfm_load_rising
   );
   
   wfm_infifo_reset_n   <= not wfm_load_rising;
   fsm_reset_n          <= not wfm_load_rising;
   
   
   process(clk, reset_n)
   begin
      if reset_n = '0' then 
         idle_cnt <= (others=>'0');
      elsif (clk'event AND clk='1') then 
         if current_state = idle then 
            idle_cnt <= idle_cnt + 1;
         else 
            idle_cnt <= (others=>'0');
         end if;
      end if;
   end process;
   
   process(clk, reset_n)
   begin
      if reset_n = '0' then 
         wfm_load_hi_cnt <= (others=>'0');
      elsif (clk'event AND clk='1') then 
         if current_state = wfm_load_hi then 
            wfm_load_hi_cnt <= wfm_load_hi_cnt + 1;
         else 
            wfm_load_hi_cnt <= (others=>'0');
         end if;
      end if;
   end process;

process(clk, reset_n)
   begin
      if reset_n = '0' then 
         wfm_load_proc1_cnt <= (others=>'0');
      elsif (clk'event AND clk='1') then 
         if wfm_infifo_wrreq_int = '1' then 
            wfm_load_proc1_cnt <= wfm_load_proc1_cnt + 1;
         else 
            wfm_load_proc1_cnt <= (others=>'0');
         end if;
      end if;
   end process;
   
   process(clk, reset_n)
   begin
   if reset_n = '0' then 
         wfm_load_proc2_cnt <= (others=>'0');
      elsif (clk'event AND clk='1') then 
         if wfm_infifo_wrreq_int = '1' then 
            wfm_load_proc2_cnt <= wfm_load_proc2_cnt + 1;
         else 
            wfm_load_proc2_cnt <= (others=>'0');
         end if;
      end if;
   end process;
   
   

process(clk, reset_n)
   begin
      if reset_n = '0' then 
         wfm_load_low_cnt <= (others=>'0');
      elsif (clk'event AND clk='1') then 
         if current_state = wfm_load_low then 
            wfm_load_low_cnt <= wfm_load_low_cnt + 1;
         else 
            wfm_load_low_cnt <= (others=>'0');
         end if;
      end if;
   end process;  
   
process(current_state)
   begin
      if current_state = wfm_load_hi OR current_state = wfm_load_proc1 OR current_state = wfm_load_low OR current_state = wfm_load_proc2 then 
         wfm_load_int <= '1';
      else
         wfm_load_int <= '0';
      end if;
   end process;
   
   
process(current_state)
   begin
   if current_state = idle then 
         wfm_play_stop_int <= '1';
      else
         wfm_play_stop_int <= '0';
      end if;
   end process; 
   
   wfm_play_stop <= wfm_play_stop_int;
   
   
   
   wfm_load <= wfm_load_int;
   
   
   process(clk, reset_n)
   begin
      if reset_n = '0' then 
         wfm_infifo_wrreq_int <= '0';
      elsif (clk'event AND clk='1') then
         if (current_state = wfm_load_proc1 OR current_state = wfm_load_proc2) and wfm_infifo_wfull = '0' then 
            wfm_infifo_wrreq_int <= '1';
         else 
            wfm_infifo_wrreq_int <= '0';
         end if;
      end if;
   end process;
   
   wfm_infifo_wrreq <= wfm_infifo_wrreq_int;
   
   process(clk, reset_n)
   begin
      if reset_n = '0' then 
         wfm_infifo_wdata_int <= (others=>'0');
      elsif (clk'event AND clk='1') then
         if current_state = wfm_load_proc1 OR current_state = wfm_load_proc2 OR current_state = wfm_load_low then
               if wfm_infifo_wrreq_int = '1' then 
                  wfm_infifo_wdata_int <= wfm_infifo_wdata_int + 1;
               else
                  wfm_infifo_wdata_int <= wfm_infifo_wdata_int;
               end if;
         else 
            wfm_infifo_wdata_int <= (others=>'0');
         end if;
      end if;
   end process;
   
   wfm_infifo_wdata <= std_logic_vector(wfm_infifo_wdata_int);
   
   
-- ----------------------------------------------------------------------------
--state machine to control when to read from FIFO
-- ----------------------------------------------------------------------------
fsm_f : process(clk, reset_n) begin
	if(reset_n = '0')then
		current_state <= idle;
	elsif(clk'event and clk = '1')then 
		current_state <= next_state;
	end if;	
end process;

-- ----------------------------------------------------------------------------
--state machine combo
-- ----------------------------------------------------------------------------
fsm : process(current_state, idle_cnt, wfm_load_hi_cnt, wfm_load_proc1_cnt, wfm_load_proc2_cnt, wfm_load_low_cnt) begin
	next_state <= current_state;
	case current_state is
	  
		when idle =>               --idle state
         if idle_cnt > 510 then
            next_state <= wfm_load_hi;
         else 
            next_state <= idle;
         end if;
         
      when wfm_load_hi =>        --
         if wfm_load_hi_cnt > 15 then 
            next_state <= wfm_load_proc1;
         else 
            next_state <= wfm_load_hi;
         end if;
      
      when wfm_load_proc1 =>
         if wfm_load_proc1_cnt > 16 then 
            next_state <= wfm_load_low;
         else
            next_state <= wfm_load_proc1;
         end if;
      
      when wfm_load_low =>
         if wfm_load_low_cnt > 15 then 
            next_state <= wfm_load_proc2;
         else
            next_state <= wfm_load_low;
         end if;
         
      when wfm_load_proc2 =>
         if wfm_load_proc2_cnt > 16 then 
            next_state <= idle;
         else
            next_state <= wfm_load_proc2;
         end if;  
         
		when others => 
			next_state<=idle;
         
	end case;
end process;
  
end arch;   


