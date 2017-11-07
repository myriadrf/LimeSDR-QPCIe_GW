-- ----------------------------------------------------------------------------
-- FILE:          wfm_player_x2_top.vhd
-- DESCRIPTION:   
-- DATE:          10:55 AM Monday, November 6, 2017
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
entity wfm_player_x2_top is
   generic(
      dev_family                    : string  := "Cyclone V";
      
      --External memory controller parameters
      mem_cntrl_rate                : integer := 1; --1 - full rate, 2 - half rate
      mem_dq_width                  : integer := 32;
      mem_dqs_width                 : integer := 4;
      mem_addr_width                : integer := 14;
      mem_ba_width                  : integer := 3;
      mem_dm_width                  : integer := 4;
      
      --Avalon 0 interface parameters
      avl_0_addr_width              : integer := 26;
      avl_0_data_width              : integer := 64;
      avl_0_burst_count_width       : integer := 2;
      avl_0_be_width                : integer := 8;
      avl_0_max_burst_count         : integer := 2; -- only 2 is for now
      avl_0_rd_latency_words        : integer := 32;
      avl_0_traffic_gen_buff_size   : integer := 16;
      
      --Avalon 1 interface parameters
      avl_1_addr_width              : integer := 26;
      avl_1_data_width              : integer := 64;
      avl_1_burst_count_width       : integer := 2;
      avl_1_be_width                : integer := 8;
      avl_1_max_burst_count         : integer := 2; -- only 2 is for now
      avl_1_rd_latency_words        : integer := 32;
      avl_1_traffic_gen_buff_size   : integer := 16;
      
      -- wfm 0 player parameters
      wfm_0_infifo_wrusedw_width    : integer := 11;
      wfm_0_infifo_wdata_width      : integer := 32;      
      wfm_0_outfifo_rdusedw_width   : integer := 11;
      wfm_0_outfifo_rdata_width     : integer := 32;
      
      -- wfm 1 player parameters
      wfm_1_infifo_wrusedw_width    : integer := 11;
      wfm_1_infifo_wdata_width      : integer := 32;      
      wfm_1_outfifo_rdusedw_width   : integer := 11;
      wfm_1_outfifo_rdata_width     : integer := 32;
      
      wfm_0_iq_width                : integer := 16;
      wfm_1_iq_width                : integer := 16
           
   );
   port (

      clk                     : in     std_logic;      -- PLL reference clock
      reset_n                 : in     std_logic;
      
      ----------------WFM port 0------------------
      wfm_0_load              : in     std_logic;
      wfm_0_play_stop         : in     std_logic; -- 1- play, 0- stop
      --control ports   
      wfm_0_sample_width      : in     std_logic_vector(1 downto 0); -- "00"-16bit, "01"-14bit, "10"-12bit
      wfm_0_fr_start          : in     std_logic;
      wfm_0_ch_en             : in     std_logic_vector(1 downto 0);
      wfm_0_mimo_en           : in     std_logic;
      wfm_0_intrlv_dis        : in     std_logic; -- 0 - interleaved data, 1 - parallel data
      --infifo 
      wfm_0_infifo_wclk       : in     std_logic;
      wfm_0_infifo_reset_n    : in     std_logic;
      wfm_0_infifo_wrreq      : in     std_logic;
      wfm_0_infifo_wdata      : in     std_logic_vector(wfm_0_infifo_wdata_width-1 downto 0);
      wfm_0_infifo_wfull      : out    std_logic;
      wfm_0_infifo_wrusedw    : out    std_logic_vector(wfm_0_infifo_wrusedw_width-1 downto 0);
      --outfifo   
      wfm_0_outfifo_rclk      : in     std_logic;
      wfm_0_outfifo_reset_n   : in     std_logic;
      wfm_0_xen               : in     std_logic; -- wfm 0 data read enable
      wfm_0_Aiq_h             : out    std_logic_vector(wfm_0_iq_width downto 0);
      wfm_0_Aiq_l             : out    std_logic_vector(wfm_0_iq_width downto 0);
      wfm_0_Biq_h             : out    std_logic_vector(wfm_0_iq_width downto 0);
      wfm_0_Biq_l             : out    std_logic_vector(wfm_0_iq_width downto 0);
      
      ----------------WFM port 1------------------
      wfm_1_load              : in     std_logic;
      wfm_1_play_stop         : in     std_logic; -- 1- play, 0- stop
      --control ports   
      wfm_1_sample_width      : in     std_logic_vector(1 downto 0); -- "00"-16bit, "01"-14bit, "10"-12bit
      wfm_1_fr_start          : in     std_logic;
      wfm_1_ch_en             : in     std_logic_vector(1 downto 0);
      wfm_1_mimo_en           : in     std_logic;
      wfm_1_intrlv_dis        : in     std_logic; -- 0 - interleaved data, 1 - parallel data
      --infifo 
      wfm_1_infifo_wclk       : in     std_logic;
      wfm_1_infifo_reset_n    : in     std_logic;
      wfm_1_infifo_wrreq      : in     std_logic;
      wfm_1_infifo_wdata      : in     std_logic_vector(wfm_1_infifo_wdata_width-1 downto 0);
      wfm_1_infifo_wfull      : out    std_logic;
      wfm_1_infifo_wrusedw    : out    std_logic_vector(wfm_1_infifo_wrusedw_width-1 downto 0);
      --outfifo   
      wfm_1_outfifo_rclk      : in     std_logic;
      wfm_1_outfifo_reset_n   : in     std_logic;
      wfm_1_xen               : in     std_logic; -- wfm 0 data read enable
      wfm_1_Aiq_h             : out    std_logic_vector(wfm_1_iq_width downto 0);
      wfm_1_Aiq_l             : out    std_logic_vector(wfm_1_iq_width downto 0);
      wfm_1_Biq_h             : out    std_logic_vector(wfm_1_iq_width downto 0);
      wfm_1_Biq_l             : out    std_logic_vector(wfm_1_iq_width downto 0);

      ---------------------External memory signals
      mem_a                   : out    std_logic_vector(mem_addr_width-1 downto 0);      --             memory.mem_a
      mem_ba                  : out    std_logic_vector(mem_ba_width-1 downto 0);        --                   .mem_ba
      mem_ck                  : out    std_logic_vector(0 downto 0);                     --                   .mem_ck
      mem_ck_n                : out    std_logic_vector(0 downto 0);                     --                   .mem_ck_n
      mem_cke                 : out    std_logic_vector(0 downto 0);                     --                   .mem_cke
      mem_cs_n                : out    std_logic_vector(0 downto 0);                     --                   .mem_cs_n
      mem_dm                  : out    std_logic_vector(mem_dm_width-1 downto 0);        --                   .mem_dm
      mem_ras_n               : out    std_logic_vector(0 downto 0);                     --                   .mem_ras_n
      mem_cas_n               : out    std_logic_vector(0 downto 0);                     --                   .mem_cas_n
      mem_we_n                : out    std_logic_vector(0 downto 0);                     --                   .mem_we_n
      mem_reset_n             : out    std_logic;                                        --                   .mem_reset_n
      mem_dq                  : inout  std_logic_vector(mem_dq_width-1 downto 0);        --                   .mem_dq
      mem_dqs                 : inout  std_logic_vector(mem_dqs_width-1 downto 0);       --                   .mem_dqs
      mem_dqs_n               : inout  std_logic_vector(mem_dqs_width-1 downto 0);       --                   .mem_dqs_n
      mem_odt                 : out    std_logic_vector(0 downto 0);                
      phy_clk                 : out    std_logic;
      oct_rzqin               : in     std_logic := '0'                                  --                oct.rzqin
        );
end wfm_player_x2_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of wfm_player_x2_top is
--declare signals,  components here
--inst0
signal inst0_reset_n             : std_logic;
signal inst0_avl_write_req           : std_logic;
signal inst0_avl_read_req            : std_logic;
signal inst0_avl_burstbegin          : std_logic;
signal inst0_avl_addr                : std_logic_vector(avl_0_addr_width-1 downto 0);
signal inst0_avl_size                : std_logic_vector(avl_0_burst_count_width-1 downto 0);
signal inst0_avl_wdata               : std_logic_vector(avl_0_data_width-1 downto 0);
signal inst0_avl_be                  : std_logic_vector(avl_0_be_width-1 downto 0);
signal inst0_wfm_infifo_reset_n      : std_logic;
signal inst0_wfm_outfifo_q       : std_logic_vector(wfm_0_outfifo_rdata_width-1 downto 0);
signal inst0_wfm_outfifo_rdempty : std_logic;
signal inst0_wfm_outfifo_rdusedw : std_logic_vector(wfm_0_outfifo_rdusedw_width-1 downto 0);

--inst1
signal inst1_reset_n                   : std_logic;
signal inst1_wfm_infifo_reset_n         : std_logic;
signal inst1_avl_write_req           : std_logic;
signal inst1_avl_read_req            : std_logic;
signal inst1_avl_burstbegin          : std_logic;
signal inst1_avl_addr                : std_logic_vector(avl_1_addr_width-1 downto 0);
signal inst1_avl_size                : std_logic_vector(avl_1_burst_count_width-1 downto 0);
signal inst1_avl_wdata               : std_logic_vector(avl_1_data_width-1 downto 0);
signal inst1_avl_be                  : std_logic_vector(avl_1_be_width-1 downto 0);
signal inst1_wfm_outfifo_q       : std_logic_vector(wfm_1_outfifo_rdata_width-1 downto 0);
signal inst1_wfm_outfifo_rdempty : std_logic;
signal inst1_wfm_outfifo_rdusedw : std_logic_vector(wfm_1_outfifo_rdusedw_width-1 downto 0);

--inst2
--Avalon port 0
signal inst2_avl_ready_0         : std_logic;
signal inst2_avl_rdata_valid_0   : std_logic; 
signal inst2_avl_rdata_0         : std_logic_vector(avl_0_data_width-1 downto 0);
--Avalon port 1
signal inst2_avl_ready_1         : std_logic;
signal inst2_avl_rdata_valid_1   : std_logic; 
signal inst2_avl_rdata_1         : std_logic_vector(avl_1_data_width-1 downto 0);

---
signal inst2_mp_cmd_clk_0_clk             : std_logic;
signal inst2_mp_cmd_reset_n_0_reset_n     : std_logic;
signal inst2_mp_cmd_clk_1_clk             : std_logic;
signal inst2_mp_cmd_reset_n_1_reset_n     : std_logic;
signal inst2_mp_rfifo_clk_0_clk           : std_logic;
signal inst2_mp_rfifo_reset_n_0_reset_n   : std_logic;
signal inst2_mp_wfifo_clk_0_clk           : std_logic;
signal inst2_mp_wfifo_reset_n_0_reset_n   : std_logic;
signal inst2_mp_rfifo_clk_1_clk           : std_logic;
signal inst2_mp_rfifo_reset_n_1_reset_n   : std_logic;
signal inst2_mp_wfifo_clk_1_clk           : std_logic;
signal inst2_mp_wfifo_reset_n_1_reset_n   : std_logic;

signal inst2_local_init_done              : std_logic;
signal inst2_local_cal_success            : std_logic;
signal inst2_local_cal_fail               : std_logic;

signal inst2_pll_locked                    : std_logic;
signal inst2_soft_reset_n                 : std_logic;

signal inst2_afi_half_clk                 : std_logic;

signal wfm_0_load_inst2_afi_half_clk         : std_logic;
signal wfm_0_load_inst2_afi_half_clk_rising  : std_logic;
signal wfm_0_play_stop_inst2_afi_half_clk    : std_logic;

signal wfm_1_load_inst2_afi_half_clk         : std_logic;
signal wfm_1_load_inst2_afi_half_clk_rising  : std_logic;
signal wfm_1_play_stop_inst2_afi_half_clk    : std_logic;

signal wfm_0_load_wfm_0_infifo_wclk          : std_logic;
signal wfm_0_load_wfm_0_infifo_wclk_rising   : std_logic;

signal wfm_1_load_wfm_1_infifo_wclk          : std_logic;
signal wfm_1_load_wfm_1_infifo_wclk_rising   : std_logic;




component ddr3_sdram is
	port (
		pll_ref_clk                : in    std_logic                     := '0';             --        pll_ref_clk.clk
		global_reset_n             : in    std_logic                     := '0';             --       global_reset.reset_n
		soft_reset_n               : in    std_logic                     := '0';             --         soft_reset.reset_n
		afi_clk                    : out   std_logic;                                        --            afi_clk.clk
		afi_half_clk               : out   std_logic;                                        --       afi_half_clk.clk
		afi_reset_n                : out   std_logic;                                        --          afi_reset.reset_n
		afi_reset_export_n         : out   std_logic;                                        --   afi_reset_export.reset_n
		mem_a                      : out   std_logic_vector(13 downto 0);                    --             memory.mem_a
		mem_ba                     : out   std_logic_vector(2 downto 0);                     --                   .mem_ba
		mem_ck                     : out   std_logic_vector(0 downto 0);                     --                   .mem_ck
		mem_ck_n                   : out   std_logic_vector(0 downto 0);                     --                   .mem_ck_n
		mem_cke                    : out   std_logic_vector(0 downto 0);                     --                   .mem_cke
		mem_cs_n                   : out   std_logic_vector(0 downto 0);                     --                   .mem_cs_n
		mem_dm                     : out   std_logic_vector(3 downto 0);                     --                   .mem_dm
		mem_ras_n                  : out   std_logic_vector(0 downto 0);                     --                   .mem_ras_n
		mem_cas_n                  : out   std_logic_vector(0 downto 0);                     --                   .mem_cas_n
		mem_we_n                   : out   std_logic_vector(0 downto 0);                     --                   .mem_we_n
		mem_reset_n                : out   std_logic;                                        --                   .mem_reset_n
		mem_dq                     : inout std_logic_vector(31 downto 0) := (others => '0'); --                   .mem_dq
		mem_dqs                    : inout std_logic_vector(3 downto 0)  := (others => '0'); --                   .mem_dqs
		mem_dqs_n                  : inout std_logic_vector(3 downto 0)  := (others => '0'); --                   .mem_dqs_n
		mem_odt                    : out   std_logic_vector(0 downto 0);                     --                   .mem_odt
		avl_ready_0                : out   std_logic;                                        --              avl_0.waitrequest_n
		avl_burstbegin_0           : in    std_logic                     := '0';             --                   .beginbursttransfer
		avl_addr_0                 : in    std_logic_vector(25 downto 0) := (others => '0'); --                   .address
		avl_rdata_valid_0          : out   std_logic;                                        --                   .readdatavalid
		avl_rdata_0                : out   std_logic_vector(63 downto 0);                    --                   .readdata
		avl_wdata_0                : in    std_logic_vector(63 downto 0) := (others => '0'); --                   .writedata
		avl_be_0                   : in    std_logic_vector(7 downto 0)  := (others => '0'); --                   .byteenable
		avl_read_req_0             : in    std_logic                     := '0';             --                   .read
		avl_write_req_0            : in    std_logic                     := '0';             --                   .write
		avl_size_0                 : in    std_logic_vector(1 downto 0)  := (others => '0'); --                   .burstcount
		avl_ready_1                : out   std_logic;                                        --              avl_1.waitrequest_n
		avl_burstbegin_1           : in    std_logic                     := '0';             --                   .beginbursttransfer
		avl_addr_1                 : in    std_logic_vector(25 downto 0) := (others => '0'); --                   .address
		avl_rdata_valid_1          : out   std_logic;                                        --                   .readdatavalid
		avl_rdata_1                : out   std_logic_vector(63 downto 0);                    --                   .readdata
		avl_wdata_1                : in    std_logic_vector(63 downto 0) := (others => '0'); --                   .writedata
		avl_be_1                   : in    std_logic_vector(7 downto 0)  := (others => '0'); --                   .byteenable
		avl_read_req_1             : in    std_logic                     := '0';             --                   .read
		avl_write_req_1            : in    std_logic                     := '0';             --                   .write
		avl_size_1                 : in    std_logic_vector(1 downto 0)  := (others => '0'); --                   .burstcount
		mp_cmd_clk_0_clk           : in    std_logic                     := '0';             --       mp_cmd_clk_0.clk
		mp_cmd_reset_n_0_reset_n   : in    std_logic                     := '0';             --   mp_cmd_reset_n_0.reset_n
		mp_cmd_clk_1_clk           : in    std_logic                     := '0';             --       mp_cmd_clk_1.clk
		mp_cmd_reset_n_1_reset_n   : in    std_logic                     := '0';             --   mp_cmd_reset_n_1.reset_n
		mp_rfifo_clk_0_clk         : in    std_logic                     := '0';             --     mp_rfifo_clk_0.clk
		mp_rfifo_reset_n_0_reset_n : in    std_logic                     := '0';             -- mp_rfifo_reset_n_0.reset_n
		mp_wfifo_clk_0_clk         : in    std_logic                     := '0';             --     mp_wfifo_clk_0.clk
		mp_wfifo_reset_n_0_reset_n : in    std_logic                     := '0';             -- mp_wfifo_reset_n_0.reset_n
		mp_rfifo_clk_1_clk         : in    std_logic                     := '0';             --     mp_rfifo_clk_1.clk
		mp_rfifo_reset_n_1_reset_n : in    std_logic                     := '0';             -- mp_rfifo_reset_n_1.reset_n
		mp_wfifo_clk_1_clk         : in    std_logic                     := '0';             --     mp_wfifo_clk_1.clk
		mp_wfifo_reset_n_1_reset_n : in    std_logic                     := '0';             -- mp_wfifo_reset_n_1.reset_n
		local_init_done            : out   std_logic;                                        --             status.local_init_done
		local_cal_success          : out   std_logic;                                        --                   .local_cal_success
		local_cal_fail             : out   std_logic;                                        --                   .local_cal_fail
		oct_rzqin                  : in    std_logic                     := '0';             --                oct.rzqin
		pll_mem_clk                : out   std_logic;                                        --        pll_sharing.pll_mem_clk
		pll_write_clk              : out   std_logic;                                        --                   .pll_write_clk
		pll_locked                 : out   std_logic;                                        --                   .pll_locked
		pll_write_clk_pre_phy_clk  : out   std_logic;                                        --                   .pll_write_clk_pre_phy_clk
		pll_addr_cmd_clk           : out   std_logic;                                        --                   .pll_addr_cmd_clk
		pll_avl_clk                : out   std_logic;                                        --                   .pll_avl_clk
		pll_config_clk             : out   std_logic;                                        --                   .pll_config_clk
		pll_mem_phy_clk            : out   std_logic;                                        --                   .pll_mem_phy_clk
		afi_phy_clk                : out   std_logic;                                        --                   .afi_phy_clk
		pll_avl_phy_clk            : out   std_logic                                         --                   .pll_avl_phy_clk
	);
end component;
begin
      
-- ----------------------------------------------------------------------------
-- Signals synchronised to inst2_afi_half_clk
-- ----------------------------------------------------------------------------
--for wfm0 ports 
sync_reg0 : entity work.sync_reg 
port map(inst2_afi_half_clk, inst2_pll_locked, wfm_0_load, wfm_0_load_inst2_afi_half_clk);

sync_reg1 : entity work.sync_reg 
port map(inst2_afi_half_clk, inst2_pll_locked, wfm_0_play_stop, wfm_0_play_stop_inst2_afi_half_clk);

edge_pulse0 : entity work.edge_pulse(arch_rising)
   port map(
      clk         => inst2_afi_half_clk,
      reset_n     => inst2_pll_locked,
      sig_in      => wfm_0_load_inst2_afi_half_clk,
      pulse_out   => wfm_0_load_inst2_afi_half_clk_rising
   );
   
inst0_reset_n <= not wfm_0_load_inst2_afi_half_clk_rising;

--for wfm1 ports 
sync_reg2 : entity work.sync_reg 
port map(inst2_afi_half_clk, inst2_pll_locked, wfm_1_load, wfm_1_load_inst2_afi_half_clk);

sync_reg3 : entity work.sync_reg 
port map(inst2_afi_half_clk, inst2_pll_locked, wfm_1_play_stop, wfm_1_play_stop_inst2_afi_half_clk);

edge_pulse1 : entity work.edge_pulse(arch_rising)
   port map(
      clk         => inst2_afi_half_clk,
      reset_n     => inst2_pll_locked,
      sig_in      => wfm_1_load_inst2_afi_half_clk,
      pulse_out   => wfm_1_load_inst2_afi_half_clk_rising
   );
   
inst1_reset_n              <= not wfm_1_load_inst2_afi_half_clk_rising;


-- ----------------------------------------------------------------------------
-- Signals synchronised to wfm_0_infifo_wclk
-- ----------------------------------------------------------------------------
sync_reg4 : entity work.sync_reg 
port map(wfm_0_infifo_wclk, '1', wfm_0_load, wfm_0_load_wfm_0_infifo_wclk);

edge_pulse2 : entity work.edge_pulse(arch_rising)
   port map(
      clk         => wfm_0_infifo_wclk,
      reset_n     => '1',
      sig_in      => wfm_0_load_wfm_0_infifo_wclk,
      pulse_out   => wfm_0_load_wfm_0_infifo_wclk_rising
   );
   
inst0_wfm_infifo_reset_n   <= not wfm_0_load_wfm_0_infifo_wclk_rising;

-- ----------------------------------------------------------------------------
-- Signals synchronised to wfm_0_infifo_wclk
-- ----------------------------------------------------------------------------
sync_reg5 : entity work.sync_reg 
port map(wfm_1_infifo_wclk, '1', wfm_1_load, wfm_1_load_wfm_1_infifo_wclk);

edge_pulse3 : entity work.edge_pulse(arch_rising)
   port map(
      clk         => wfm_1_infifo_wclk,
      reset_n     => '1',
      sig_in      => wfm_1_load_wfm_1_infifo_wclk,
      pulse_out   => wfm_1_load_wfm_1_infifo_wclk_rising
   );

inst1_wfm_infifo_reset_n <= not wfm_1_load_wfm_1_infifo_wclk_rising;

   
  wfm_player_inst0 : entity work.wfm_player
   generic map(
      dev_family                 => dev_family,

      avl_addr_width             => avl_0_addr_width,
      avl_data_width             => avl_0_data_width,
      avl_burst_count_width      => avl_0_burst_count_width,
      avl_be_width               => avl_0_be_width,
      avl_max_burst_count        => avl_0_max_burst_count,
      avl_rd_latency_words       => avl_0_rd_latency_words,
      avl_traffic_gen_buff_size  => avl_0_traffic_gen_buff_size,

      wfm_infifo_wrusedw_width   => wfm_0_infifo_wrusedw_width,
      wfm_infifo_wdata_width     => wfm_0_infifo_wdata_width,

      wfm_outfifo_rdusedw_width  => wfm_0_outfifo_rdusedw_width,
      wfm_outfifo_rdata_width    => wfm_0_outfifo_rdata_width
   )
   port map(

      clk                        => inst2_afi_half_clk,
      reset_n                    => inst0_reset_n,
     
      --wfm player control signals
      wfm_load                   => wfm_0_load_inst2_afi_half_clk,
      wfm_play_stop              => wfm_0_play_stop_inst2_afi_half_clk,
      
      --Avalon interface to external memory
      avl_ready                  => inst2_avl_ready_0,
      avl_write_req              => inst0_avl_write_req,
      avl_read_req               => inst0_avl_read_req,
      avl_burstbegin             => inst0_avl_burstbegin,
      avl_addr                   => inst0_avl_addr,
      avl_size                   => inst0_avl_size,
      avl_wdata                  => inst0_avl_wdata,
      avl_be                     => inst0_avl_be,
      avl_rddata                 => inst2_avl_rdata_0,
      avl_rddata_valid           => inst2_avl_rdata_valid_0,
      
      --wfm infifo wfm_data -> wfm_infifo -> external memory
      wfm_infifo_wclk            => wfm_0_infifo_wclk,
      wfm_infifo_reset_n         => inst0_wfm_infifo_reset_n,
      wfm_infifo_wrreq           => wfm_0_infifo_wrreq,
      wfm_infifo_wdata           => wfm_0_infifo_wdata,
      wfm_infifo_wfull           => wfm_0_infifo_wfull,
      wfm_infifo_wrusedw         => wfm_0_infifo_wrusedw,
      
      --wfm outfifo external memory -> wfm_outfifo -> wfm_data
      wfm_outfifo_rclk           => wfm_0_outfifo_rclk,
      wfm_outfifo_reset_n        => '0',
      wfm_outfifo_rdreq          => '0',
      wfm_outfifo_q              => inst0_wfm_outfifo_q,
      wfm_outfifo_rdempty        => inst0_wfm_outfifo_rdempty,
      wfm_outfifo_rdusedw        => inst0_wfm_outfifo_rdusedw
      
      );
      
      
  wfm_player_inst1 : entity work.wfm_player
   generic map(
      dev_family                 => dev_family,

      avl_addr_width             => avl_1_addr_width,
      avl_data_width             => avl_1_data_width,
      avl_burst_count_width      => avl_1_burst_count_width,
      avl_be_width               => avl_1_be_width,
      avl_max_burst_count        => avl_1_max_burst_count,
      avl_rd_latency_words       => avl_1_rd_latency_words,
      avl_traffic_gen_buff_size  => avl_1_traffic_gen_buff_size,

      wfm_infifo_wrusedw_width   => wfm_1_infifo_wrusedw_width,
      wfm_infifo_wdata_width     => wfm_1_infifo_wdata_width,

      wfm_outfifo_rdusedw_width  => wfm_1_outfifo_rdusedw_width,
      wfm_outfifo_rdata_width    => wfm_1_outfifo_rdata_width
   )
   port map(

      clk                        => inst2_afi_half_clk,
      reset_n                    => inst1_reset_n,
     
      --wfm player control signals
      wfm_load                   => wfm_1_load_inst2_afi_half_clk,
      wfm_play_stop              => wfm_1_play_stop_inst2_afi_half_clk,
      
      --Avalon interface to external memory
      avl_ready                  => inst2_avl_ready_1,
      avl_write_req              => inst1_avl_write_req,
      avl_read_req               => inst1_avl_read_req,
      avl_burstbegin             => inst1_avl_burstbegin,
      avl_addr                   => inst1_avl_addr,
      avl_size                   => inst1_avl_size,
      avl_wdata                  => inst1_avl_wdata,
      avl_be                     => inst1_avl_be,
      avl_rddata                 => inst2_avl_rdata_1,
      avl_rddata_valid           => inst2_avl_rdata_valid_1,
      
      --wfm infifo wfm_data -> wfm_infifo -> external memory
      wfm_infifo_wclk            => wfm_1_infifo_wclk,
      wfm_infifo_reset_n         => inst1_wfm_infifo_reset_n,
      wfm_infifo_wrreq           => wfm_1_infifo_wrreq,
      wfm_infifo_wdata           => wfm_1_infifo_wdata,
      wfm_infifo_wfull           => wfm_1_infifo_wfull,
      wfm_infifo_wrusedw         => wfm_1_infifo_wrusedw,
      
      --wfm outfifo external memory -> wfm_outfifo -> wfm_data
      wfm_outfifo_rclk           => wfm_1_outfifo_rclk,
      wfm_outfifo_reset_n        => '0',
      wfm_outfifo_rdreq          => '0',
      wfm_outfifo_q              => inst1_wfm_outfifo_q,
      wfm_outfifo_rdempty        => inst1_wfm_outfifo_rdempty,
      wfm_outfifo_rdusedw        => inst1_wfm_outfifo_rdusedw
      
      );
      
   inst2_soft_reset_n <= reset_n;
      
ext_mem_inst2 : ddr3_sdram
	port map(
		pll_ref_clk                => clk,                                --        pll_ref_clk.clk
		global_reset_n             => reset_n,                            --       global_reset.reset_n
		soft_reset_n               => inst2_soft_reset_n,                 --         soft_reset.reset_n
		afi_clk                    => open,                               --            afi_clk.clk
		afi_half_clk               => inst2_afi_half_clk,                 --       afi_half_clk.clk
		afi_reset_n                => open,                               --          afi_reset.reset_n
		afi_reset_export_n         => open,                               --   afi_reset_export.reset_n
      
		mem_a                      => mem_a,                              --             memory.mem_a
		mem_ba                     => mem_ba,                             --                   .mem_ba
		mem_ck                     => mem_ck,                             --                   .mem_ck
		mem_ck_n                   => mem_ck_n,                           --                   .mem_ck_n
		mem_cke                    => mem_cke,                            --                   .mem_cke
		mem_cs_n                   => mem_cs_n,                           --                   .mem_cs_n
		mem_dm                     => mem_dm,                             --                   .mem_dm
		mem_ras_n                  => mem_ras_n,                          --                   .mem_ras_n
		mem_cas_n                  => mem_cas_n,                          --                   .mem_cas_n
		mem_we_n                   => mem_we_n,                           --                   .mem_we_n
		mem_reset_n                => mem_reset_n,                        --                   .mem_reset_n
		mem_dq                     => mem_dq,                             --                   .mem_dq
		mem_dqs                    => mem_dqs,                            --                   .mem_dqs
		mem_dqs_n                  => mem_dqs_n,                          --                   .mem_dqs_n
		mem_odt                    => mem_odt,                            --                   .mem_odt
      
		avl_ready_0                => inst2_avl_ready_0,                  --              avl_0.waitrequest_n
		avl_burstbegin_0           => inst0_avl_burstbegin,               --                   .beginbursttransfer
		avl_addr_0                 => inst0_avl_addr,                     --                   .address
		avl_rdata_valid_0          => inst2_avl_rdata_valid_0,            --                   .readdatavalid
		avl_rdata_0                => inst2_avl_rdata_0,                  --                   .readdata
		avl_wdata_0                => inst0_avl_wdata,                    --                   .writedata
		avl_be_0                   => inst0_avl_be,                       --                   .byteenable
		avl_read_req_0             => inst0_avl_read_req,                 --                   .read
		avl_write_req_0            => inst0_avl_write_req,                --                   .write
		avl_size_0                 => inst0_avl_size,                     --                   .burstcount
      
		avl_ready_1                => inst2_avl_ready_1,                  --              avl_1.waitrequest_n
		avl_burstbegin_1           => inst1_avl_burstbegin,               --                   .beginbursttransfer
		avl_addr_1                 => inst1_avl_addr,                     --                   .address
		avl_rdata_valid_1          => inst2_avl_rdata_valid_1,            --                   .readdatavalid
		avl_rdata_1                => inst2_avl_rdata_1,                  --                   .readdata
		avl_wdata_1                => inst1_avl_wdata,                    --                   .writedata
		avl_be_1                   => inst1_avl_be,                       --                   .byteenable
		avl_read_req_1             => inst1_avl_read_req,                 --                   .read
		avl_write_req_1            => inst1_avl_write_req,                --                   .write
		avl_size_1                 => inst1_avl_size,                     --                   .burstcount
      
		mp_cmd_clk_0_clk           => inst2_mp_cmd_clk_0_clk,             --       mp_cmd_clk_0.clk
		mp_cmd_reset_n_0_reset_n   => inst2_mp_cmd_reset_n_0_reset_n,     --   mp_cmd_reset_n_0.reset_n
		mp_cmd_clk_1_clk           => inst2_mp_cmd_clk_1_clk,             --       mp_cmd_clk_1.clk
		mp_cmd_reset_n_1_reset_n   => inst2_mp_cmd_reset_n_1_reset_n,     --   mp_cmd_reset_n_1.reset_n
		mp_rfifo_clk_0_clk         => inst2_mp_rfifo_clk_0_clk,           --     mp_rfifo_clk_0.clk
		mp_rfifo_reset_n_0_reset_n => inst2_mp_rfifo_reset_n_0_reset_n,   -- mp_rfifo_reset_n_0.reset_n
		mp_wfifo_clk_0_clk         => inst2_mp_wfifo_clk_0_clk,           --     mp_wfifo_clk_0.clk
		mp_wfifo_reset_n_0_reset_n => inst2_mp_wfifo_reset_n_0_reset_n,   -- mp_wfifo_reset_n_0.reset_n
		mp_rfifo_clk_1_clk         => inst2_mp_rfifo_clk_1_clk,           --     mp_rfifo_clk_1.clk
		mp_rfifo_reset_n_1_reset_n => inst2_mp_rfifo_reset_n_1_reset_n,   -- mp_rfifo_reset_n_1.reset_n
		mp_wfifo_clk_1_clk         => inst2_mp_wfifo_clk_1_clk,           --     mp_wfifo_clk_1.clk
		mp_wfifo_reset_n_1_reset_n => inst2_mp_wfifo_reset_n_1_reset_n,   -- mp_wfifo_reset_n_1.reset_n
      
		local_init_done            => inst2_local_init_done,              --             status.local_init_done
		local_cal_success          => inst2_local_cal_success,            --                   .local_cal_success
		local_cal_fail             => inst2_local_cal_fail,               --                   .local_cal_fail
      
		oct_rzqin                  => oct_rzqin,                          --                oct.rzqin
      
		pll_mem_clk                => open,                               --        pll_sharing.pll_mem_clk
		pll_write_clk              => open,                               --                   .pll_write_clk
		pll_locked                 => inst2_pll_locked,                    --                   .pll_locked
		pll_write_clk_pre_phy_clk  => open,                               --                   .pll_write_clk_pre_phy_clk
		pll_addr_cmd_clk           => open,                               --                   .pll_addr_cmd_clk
		pll_avl_clk                => open,                               --                   .pll_avl_clk
		pll_config_clk             => open,                               --                   .pll_config_clk
		pll_mem_phy_clk            => open,                               --                   .pll_mem_phy_clk
		afi_phy_clk                => open,                               --                   .afi_phy_clk
		pll_avl_phy_clk            => open                                --                   .pll_avl_phy_clk
	);
   
   --MPFE(multi-port front-end) cmd FIFO clk signals
   inst2_mp_cmd_clk_0_clk   <= inst2_afi_half_clk;
   inst2_mp_cmd_clk_1_clk   <= inst2_afi_half_clk;
   inst2_mp_rfifo_clk_0_clk <= inst2_afi_half_clk;
   inst2_mp_wfifo_clk_0_clk <= inst2_afi_half_clk;
   inst2_mp_rfifo_clk_1_clk <= inst2_afi_half_clk;
   inst2_mp_wfifo_clk_1_clk <= inst2_afi_half_clk;
   
   --MPFE(multi-port front-end) cmd FIFO reset signals
   inst2_mp_cmd_reset_n_0_reset_n      <= inst2_pll_locked AND inst2_local_cal_success AND inst2_local_init_done;
   inst2_mp_cmd_reset_n_1_reset_n      <= inst2_pll_locked AND inst2_local_cal_success AND inst2_local_init_done;
   inst2_mp_rfifo_reset_n_0_reset_n    <= inst2_pll_locked AND inst2_local_cal_success AND inst2_local_init_done;
   inst2_mp_wfifo_reset_n_0_reset_n    <= inst2_pll_locked AND inst2_local_cal_success AND inst2_local_init_done;
   inst2_mp_rfifo_reset_n_1_reset_n    <= inst2_pll_locked AND inst2_local_cal_success AND inst2_local_init_done;
   inst2_mp_wfifo_reset_n_1_reset_n    <= inst2_pll_locked AND inst2_local_cal_success AND inst2_local_init_done;
   
  
end arch;   


