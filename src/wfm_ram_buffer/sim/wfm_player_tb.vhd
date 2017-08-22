-- ----------------------------------------------------------------------------	
-- FILE:          wfm_player_tb.vhd
-- DESCRIPTION:   
-- DATE:          August 22, 2017
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity wfm_player_tb is
end wfm_player_tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of wfm_player_tb is
   constant clk0_period    : time := 10 ns;
   constant clk1_period    : time := 10 ns; 
   constant clk2_period    : time := 10 ns;
   
   signal wfm_infifo_data_word_count   : integer := 8;
   --signals
   signal clk0,clk1,clk2         : std_logic;
   signal reset_n                : std_logic;
   
   --dut0
   signal dut0_wfm_load          : std_logic;
   signal dut0_wfm_load_rising   : std_logic;
   signal dut0_wfm_play_stop     : std_logic;
   signal dut0_wfm_infifo_reset_n: std_logic;
   signal dut0_wfm_infifo_wrclk  : std_logic;
   signal dut0_wfm_infifo_data   : std_logic_vector(31 downto 0);
   signal dut0_wfm_infifo_wrreq  : std_logic;
   signal dut0_wcmd_clk          : std_logic;
   signal dut0_wcmd_reset_n      : std_logic;
   signal dut0_wcmd_rdy          : std_logic;
   signal dut0_rcmd_clk          : std_logic;
   signal dut0_rcmd_reset_n      : std_logic;
   signal dut0_rcmd_rdy          : std_logic;
   

begin 
  
      clock0: process is
   begin
      clk0 <= '0'; wait for clk0_period/2;
      clk0 <= '1'; wait for clk0_period/2;
   end process clock0;

      clock1: process is
   begin
      clk1 <= '0'; wait for clk1_period/2;
      clk1 <= '1'; wait for clk1_period/2;
   end process clock1;
   
   clock2: process is
   begin
      clk2 <= '0'; wait for clk2_period/2;
      clk2 <= '1'; wait for clk2_period/2;
   end process clock2;
   
      res: process is
   begin
      reset_n <= '0'; wait for 20 ns;
      reset_n <= '1'; wait;
   end process res;
   
   wfm_load : process is
   begin
      dut0_wfm_load <= '0';
      wait until reset_n = '1';
      wait until rising_edge(clk0);
      dut0_wfm_load <= '1';      
      for i in 0 to wfm_infifo_data_word_count+4 loop
         wait until rising_edge(clk0);
      end loop;
      dut0_wfm_load <= '0';
      wait;     
   end process wfm_load;
   
   edge_pulse_inst0 : entity work.edge_pulse(arch_rising) 
   port map(
   clk         => clk0,
   reset_n     => reset_n, 
   sig_in      => dut0_wfm_load,
   pulse_out   => dut0_wfm_load_rising
);
   
   
   wfm_infifo_wrreq : process is
   begin
      dut0_wfm_infifo_wrreq <= '0';
      wait until dut0_wfm_load = '1';
            for i in 0 to 3 loop
         wait until rising_edge(clk0);
      end loop;
      dut0_wfm_infifo_wrreq <= '1';
      for i in 0 to wfm_infifo_data_word_count-1 loop
         wait until rising_edge(clk0);
      end loop;
      dut0_wfm_infifo_wrreq <= '0';
      wait;    
   end process wfm_infifo_wrreq;
   
   
   wfm_infifo_data : process(clk0, reset_n)
   begin
      if reset_n = '0' then 
         dut0_wfm_infifo_data <= (others => '0');
      elsif (clk0'event AND clk0 = '1') then
         if dut0_wfm_infifo_wrreq = '1' then 
            dut0_wfm_infifo_data <= std_logic_vector(unsigned(dut0_wfm_infifo_data)+1);
         else 
            dut0_wfm_infifo_data <= dut0_wfm_infifo_data;
         end if;
      end if;
   end process;
   
   rcmd_reset_n : process is
   begin
      dut0_rcmd_reset_n <= '1';
      wait until rising_edge(dut0_wfm_load);
      wait until rising_edge(clk2);
      dut0_rcmd_reset_n <= '0';
      for i in 0 to 63 loop
         wait until rising_edge(clk2);
      end loop;     
   end process;
   
    

dut0_wfm_infifo_reset_n <= not dut0_wfm_load_rising;
dut0_wcmd_reset_n       <= not dut0_wfm_load_rising;
dut0_wcmd_rdy           <= dut0_rcmd_reset_n;
dut0_rcmd_rdy           <= dut0_rcmd_reset_n;

dut0_wfm_play_stop <= '1';

 
wfm_player_dut0 : entity work.wfm_player
   generic map(
      dev_family           => "Cyclone IV E",
      --Parameters for FIFO buffer before external memory
      wfm_infifo_wrwidth   => 32,
      wfm_infifo_wrsize    => 12,
      wfm_infifo_rdwidth   => 32,
      wfm_infifo_rdsize    => 12,      
      --Avalon MM interface of external memory controller parameters 
      avmm_addr_size       => 27,
      avmm_burst_length    => 2,
      avmm_bus_size        => 32   
)
   port map(
      wfm_load             => dut0_wfm_load,
      wfm_play_stop        => dut0_wfm_play_stop,

      wfm_infifo_wrclk     => clk0,
      wfm_infifo_reset_n   => dut0_wfm_infifo_reset_n,
      wfm_infifo_data      => dut0_wfm_infifo_data,
      wfm_infifo_wrreq     => dut0_wfm_infifo_wrreq,
      wfm_infifo_wrusedw   => open,
      wfm_infifo_wfull     => open,
      
      wcmd_clk             => clk1,
      wcmd_reset_n         => dut0_wcmd_reset_n,
      wcmd_rdy             => dut0_wcmd_rdy,
      wcmd_addr            => open,
      wcmd_wr              => open,
      wcmd_brst_en         => open,
      wcmd_data            => open,
      rcmd_clk             => clk2,
      rcmd_reset_n         => dut0_rcmd_reset_n,
      rcmd_rdy             => dut0_rcmd_rdy,
      rcmd_addr            => open,
      rcmd_wr              => open,
      rcmd_brst_en         => open
        );
 
   
   end tb_behave;

