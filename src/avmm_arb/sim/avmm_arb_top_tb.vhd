-- ----------------------------------------------------------------------------
-- FILE:          avmm_arb_top_tb.vhd
-- DESCRIPTION:   
-- DATE:          11:35 AM Friday, September 1, 2017
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
entity avmm_arb_top_tb is
   generic(
      dev_family        : string  := "Cyclone V GX";
      cntrl_rate        : integer := 1; --1 - full rate, 2 - half rate
      addr_size         : integer := 26;
      lcl_bus_size      : integer := 64
      );
end avmm_arb_top_tb;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------

architecture tb_behave of avmm_arb_top_tb is
   constant clk0_period          : time := 10 ns;
   constant clk1_period          : time := 10 ns;
   constant clk2_period          : time := 10 ns;
   --signals
   signal clk0,clk1,clk2         : std_logic;
   signal reset_n                : std_logic;
   signal reset                  : std_logic;
   
   --dut0
   signal dut0_wcmd_addr         : std_logic_vector(addr_size-1 downto 0);
   signal dut0_wcmd_wr           : std_logic;
   signal dut0_wcmd_brst_en      : std_logic;
   signal dut0_wcmd_data         : std_logic_vector(lcl_bus_size-1 downto 0);
   signal dut0_wcmd_rdy          : std_logic;

   signal dut0_rcmd_addr         : std_logic_vector(addr_size-1 downto 0);
   signal dut0_rcmd_wr           : std_logic;
   signal dut0_rcmd_brst_en      : std_logic;
   signal dut0_rcmd_rdy          : std_logic;

   signal dut0_local_ready       : std_logic;
   signal dut0_local_addr        : std_logic_vector(addr_size-1 downto 0);
   signal dut0_local_write_req   : std_logic;
   signal dut0_local_read_req    : std_logic;
   signal dut0_local_burstbegin  : std_logic;
   signal dut0_local_wdata       : std_logic_vector(lcl_bus_size-1 downto 0);
   signal dut0_local_be          : std_logic_vector(lcl_bus_size/8*cntrl_rate-1 downto 0);
   signal dut0_local_size        : std_logic_vector(1 downto 0);
   
   --dut1
   signal dut1_avs_readdata      : std_logic_vector(lcl_bus_size-1 downto 0);
   signal dut1_avs_readdatavalid : std_logic;
   signal dut1_avs_waitrequest   : std_logic;
   
   
   
   
  
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
   
   reset <= not reset_n;
   
   -- design under test  
avmm_arb_top_dut0 : entity work.avmm_arb_top
   generic map(
      dev_family        => dev_family,
      cntrl_rate        => 1, --1 - full rate, 2 - half rate
      cntrl_bus_size    => 16,
      addr_size         => addr_size,
      lcl_bus_size      => lcl_bus_size,
      lcl_burst_length  => 2,
      cmd_fifo_size     => 9,
      outfifo_size      => 10 -- outfifo buffer size
      )
  port map(
      clk               => clk0,
      reset_n           => reset_n,
      --Write command ports
      wcmd_clk          => clk1,
      wcmd_reset_n      => reset_n,
      wcmd_rdy          => dut0_wcmd_rdy,
      wcmd_addr         => dut0_wcmd_addr,
      wcmd_wr           => dut0_wcmd_wr,
      wcmd_brst_en      => dut0_wcmd_brst_en,
      wcmd_data         => dut0_wcmd_data,
      --rd command ports
      rcmd_clk          => clk2,
      rcmd_reset_n      => reset_n,
      rcmd_rdy          => dut0_rcmd_rdy,
      rcmd_addr         => dut0_rcmd_addr,
      rcmd_wr           => dut0_rcmd_wr,
      rcmd_brst_en      => dut0_rcmd_brst_en,
      
      outbuf_wrusedw    => (others=> '0'),
      
      local_ready       => dut0_local_ready,
      local_addr        => dut0_local_addr,
      local_write_req   => dut0_local_write_req,
      local_read_req    => dut0_local_read_req,
      local_burstbegin  => dut0_local_burstbegin,
      local_wdata       => dut0_local_wdata,
      local_be          => dut0_local_be,
      local_size        => dut0_local_size
        );
        
      dut0_wcmd_addr    <= (others=>'0');
      dut0_wcmd_wr      <= '1';        
      
      dut0_rcmd_addr    <= (others=>'0');
      dut0_rcmd_wr      <= dut0_rcmd_rdy;
      
      
      dut0_local_ready  <= not dut1_avs_waitrequest;
      
      
      
      
      
        
avmm_slave_bfm_dut1 : entity work.avmm_slave_bfm
		port map (
			clk                    => clk0,                    --       clk.clk
			reset                  => reset,                 -- clk_reset.reset
			avs_writedata          => dut0_local_wdata,        --        s0.writedata
			avs_beginbursttransfer => dut0_local_burstbegin,   --          .beginbursttransfer
			avs_burstcount         => dut0_local_size,         --          .burstcount
			avs_readdata           => dut1_avs_readdata,       --          .readdata
			avs_address            => dut0_local_addr,         --          .address
			avs_waitrequest        => dut1_avs_waitrequest,    --          .waitrequest_n
			avs_write              => '1',    --          .write
			avs_read               => dut0_local_read_req,     --          .read
			avs_byteenable         => dut0_local_be,           --          .byteenable
			avs_readdatavalid      => dut1_avs_readdatavalid   --          .readdatavalid
		);

end tb_behave;

