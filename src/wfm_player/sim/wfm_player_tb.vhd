-- ----------------------------------------------------------------------------
-- FILE:          wfm_player_tb.vhd
-- DESCRIPTION:   
-- DATE:          3:08 PM Tuesday, October 31, 2017
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- NOTES:
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
   constant clk0_period          : time := 6.25 ns;
   constant clk1_period          : time := 6.25 ns;
   constant clk2_period          : time := 20 ns; 
   --signals
   signal clk0,clk1,clk2         : std_logic;
   signal reset_n                : std_logic;
   
   --dut0
   signal dut0_avl_ready         : std_logic;
   signal dut0_wfm_infifo_wfull  : std_logic;
   signal dut0_wfm_outfifo_q     : std_logic_vector(63 downto 0);
   signal dut0_wfm_outfifo_rdempty: std_logic;
   signal dut0_avl_rddata        : std_logic_vector(63 downto 0);
   signal dut0_avl_rddata_valid  : std_logic;
   signal dut0_avl_read_req      : std_logic;
   signal dut0_avl_addr          : std_logic_vector(24 downto 0);
   --dut1 
   signal dut1_wfm_load          : std_logic;
   signal dut1_wfm_play_stop     : std_logic;
   signal dut1_wfm_infifo_reset_n: std_logic;
   signal dut1_wfm_infifo_wrreq  : std_logic;
   signal dut1_wfm_infifo_wdata  : std_logic_vector(31 downto 0);
   signal dut1_wfm_outfifo_rdreq : std_logic;

   
   
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
  
   
   process is
   begin
      dut0_avl_ready <= '0'; wait until rising_edge(clk0);
      for i in 0 to 2 loop
         dut0_avl_ready <= '1';
         wait until rising_edge(clk0);
      end loop;
   end process;
   
   

   
-- design under test  
wfm_player_dut0 : entity work.wfm_player
   generic map(
      dev_family                 => "Cyclone V",
                                 
      avl_addr_width             => 25,
      avl_data_width             => 64,
      avl_burst_count_width      => 2,
      avl_be_width               => 4,
      avl_max_burst_count        => 2,
      avl_traffic_gen_buff_size  => 16,
                                 
      wfm_infifo_wrusedw_width   => 11,
      wfm_infifo_wdata_width     => 32,
                                 
      wfm_outfifo_rdusedw_width  => 10,
      wfm_outfifo_rdata_width    => 64
   )
   port map(

      clk                        => clk0,
      reset_n                    => reset_n,
     
      --wfm player control signals
      wfm_load                   => dut1_wfm_load,
      wfm_play_stop              => dut1_wfm_play_stop,
      
      --Avalon interface to external memory
      avl_ready                  => dut0_avl_ready,
      avl_write_req              => open,
      avl_read_req               => dut0_avl_read_req,
      avl_burstbegin             => open,
      avl_addr                   => dut0_avl_addr,
      avl_size                   => open,
      avl_wdata                  => open,
      avl_be                     => open,
      avl_rddata                 => dut0_avl_rddata,
      avl_rddata_valid           => dut0_avl_rddata_valid,
      
      --wfm infifo wfm_data -> wfm_infifo -> external memory
      wfm_infifo_wclk            => clk1,
      wfm_infifo_reset_n         => dut1_wfm_infifo_reset_n,
      wfm_infifo_wrreq           => dut1_wfm_infifo_wrreq,
      wfm_infifo_wdata           => dut1_wfm_infifo_wdata,
      wfm_infifo_wfull           => dut0_wfm_infifo_wfull,
      wfm_infifo_wrusedw         => open,
      
      --wfm outfifo external memory -> wfm_outfifo -> wfm_data
      wfm_outfifo_rclk           => clk2,
      wfm_outfifo_reset_n        => reset_n,
      wfm_outfifo_rdreq          => dut1_wfm_outfifo_rdreq,
      wfm_outfifo_q              => dut0_wfm_outfifo_q,
      wfm_outfifo_rdempty        => dut0_wfm_outfifo_rdempty,
      wfm_outfifo_rdusedw        => open
      
      );
      
      process(clk0, reset_n)
      begin
         if reset_n = '0' then 
            dut0_avl_rddata_valid <= '0';
            dut0_avl_rddata <= (others=>'0');
         elsif (clk0'event AND clk0='1') then
            dut0_avl_rddata(63 downto 25) <= (others=> '0');
            dut0_avl_rddata(24 downto 0) <= dut0_avl_addr;
            if dut0_avl_ready = '1' AND dut0_avl_read_req = '1' then 
               dut0_avl_rddata_valid <= '1';
            else 
               dut0_avl_rddata_valid <= '0';
            end if;
         end if;
      end process;
      
      
      
   wfm_player_tester_dut1 :entity work.wfm_player_tester
   generic map(
      avl_data_width             => 64,
      
      wfm_infifo_wrusedw_width   => 11,
      wfm_infifo_wdata_width     => 32,
                                 
      wfm_outfifo_rdusedw_width  => 11,
      wfm_outfifo_rdata_width    => 64
   )
   port map(

      clk                        => clk1,
      reset_n                    => reset_n,
      
      --wfm player control signals
      wfm_load                   => dut1_wfm_load,
      wfm_play_stop              => dut1_wfm_play_stop,
      
      --wfm infifo wfm_data -> wfm_infifo -> external memory
      wfm_infifo_wclk            => clk1,
      wfm_infifo_reset_n         => dut1_wfm_infifo_reset_n,
      wfm_infifo_wrreq           => dut1_wfm_infifo_wrreq,
      wfm_infifo_wdata           => dut1_wfm_infifo_wdata,
      wfm_infifo_wfull           => dut0_wfm_infifo_wfull,
      
      --wfm outfifo external memory -> wfm_outfifo -> wfm_data
      wfm_outfifo_rclk           => clk2,
      wfm_outfifo_rdreq          => dut1_wfm_outfifo_rdreq,
      wfm_outfifo_q              => dut0_wfm_outfifo_q,
      wfm_outfifo_rdempty        => dut0_wfm_outfifo_rdempty
      
        );

end tb_behave;

