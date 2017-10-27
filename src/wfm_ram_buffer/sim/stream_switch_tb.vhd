-- ----------------------------------------------------------------------------
-- FILE:          stream_switch_tb.vhd
-- DESCRIPTION:   
-- DATE:          9:42 AM Thursday, October 5, 2017
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- NOTES:
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.STD_LOGIC_TEXTIO.ALL;
use STD.textio.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity stream_switch_tb is
end stream_switch_tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of stream_switch_tb is
   constant clk0_period    : time := 10 ns;
   constant clk1_period    : time := 10 ns; 
   --signals
   signal clk0,clk1        : std_logic;
   signal reset_n          : std_logic; 
   
   signal pct_data         : std_logic_vector(31 downto 0);
   signal rd_pct           : std_logic;
   signal pct_data_valid   : std_logic;
  
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
 
 



process is
   begin
      rd_pct <= '0'; wait until (reset_n='1' AND rising_edge(clk0));
      rd_pct <= '1';
      for i in 0 to 1023 loop 
         wait until rising_edge(clk0);
      end loop;
      rd_pct <= '0';
      for i in 0 to 7 loop 
         wait until rising_edge(clk0);
      end loop;
      rd_pct <= '1';
      for i in 0 to 31 loop 
         wait until rising_edge(clk0);
      end loop;
      rd_pct <= '0';
      for i in 0 to 7 loop 
         wait until rising_edge(clk0);
      end loop;
      
end process;
-- ----------------------------------------------------------------------------
-- Read packet data
-- ----------------------------------------------------------------------------   
process(clk0, reset_n)
   
   FILE in_file      : TEXT OPEN READ_MODE IS "sim/pct_data.txt";
   
   VARIABLE in_line  : LINE;
   VARIABLE data     : std_logic_vector(31 downto 0);
begin
   if reset_n = '0' then 
      pct_data <= (others=>'0');
      pct_data_valid <= '0';
   elsif (clk0'event AND clk0='1') then 
      if rd_pct = '1' then 
         READLINE(in_file, in_line);
         HREAD(in_line, data);
         pct_data <= data;
      else 
         pct_data <= pct_data;
      end if;
      
      pct_data_valid <= rd_pct;

   end if;
end process;


stream_switch_dut0 : entity work.stream_switch
	generic map(
			data_width					=>  32,
			wfm_fifo_wrusedw_size	=>  12,
			wfm_limit					=>  4096
	)
	port map(
        clk       			=> clk0,
        reset_n   			=> reset_n,
		  data_in 				=> pct_data,
		  data_in_valid		=> pct_data_valid,
		  data_in_rdy			=> open,
		                     
		  dest_sel				=> '1',
		                     
		  tx_fifo_rdy			=> '1',
		  tx_fifo_wr			=> open,
		  tx_fifo_data			=> open,
		                     
		  wfm_rdy				=> '1',
		  wfm_fifo_wr			=> open,
		  wfm_data				=> open,
		  wfm_fifo_wrusedw	=> (others=> '0')
		        
        );
        

    
    
process(clk0) is
      FILE out_file  : TEXT OPEN WRITE_MODE IS "sim/my_file";    
      variable out_line : LINE;
begin
   if rising_edge(clk0) then 
      HWRITE(out_line,x"00");
      WRITELINE(out_file, out_line);
   end if;
end process;

end tb_behave;

