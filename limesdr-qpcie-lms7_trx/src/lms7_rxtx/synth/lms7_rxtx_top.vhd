-- ----------------------------------------------------------------------------	
-- FILE: 	lms7_rxtx_top.vhd
-- DESCRIPTION:	describe file
-- DATE:	May 15, 2017
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity lms7_rxtx_top is
   generic(
      dev_family              : string := "Cyclone V";
      rx_ddio_clkinv          : string := "ON";            
      rx_diq_width            : integer := 12; -- Physical RX IO interface width
      rx_smpl_buff_rdusedw_w  : integer := 11; -- RX buffer size for samples before packets 
      rx_pct_fifo_wrusedw_w   : integer := 12; -- RX packet FIFO buffer wrusedw size
      
      tx_diq_width            : integer := 12; -- Physical TX IO interface width
      tx_pct_size_w           : integer := 16;
      tx_n_buff               : integer := 4; -- 2,4 valid values
      tx_in_pct_data_w        : integer := 32;
      tx_out_pct_data_w       : integer := 64;
      tx_decomp_fifo_size     : integer := 9 -- 256 words
      
      
   );
   port (      
      --LimeLight interface settings
      lml_smpl_width          : in std_logic_vector(1 downto 0); --"10"-12bit, "01"-14bit, "00"-16bit;
      lml_mode                : in std_logic; -- JESD207: 1; TRXIQ: 0
      lml_trxiqpulse          : in std_logic; -- trxiqpulse on: 1; trxiqpulse off: 0
      lml_ddr_en              : in std_logic; -- DDR: 1; SDR: 0
      lml_mimo_en             : in std_logic; -- SISO: 0; MIMO: 1
      lml_ch_en               : in std_logic_vector(1 downto 0); --"11" - Ch. A, "10" - Ch. B, "11" - Ch. A and Ch. B.
      lml_fidm                : in std_logic; -- 0 - Frame start at fsync = 0. 1- Frame start at fsync = 1.
      
      --RX interface (RF2BB, -> FPGA receive)
      rx_pll_in_clk           : in std_logic; -- PLL clk in
      rx_pll_areset           : in std_logic;
      rx_pll_c0               : out std_logic; --FCLK, connect directly to pin 
      rx_pll_c1               : out std_logic;
      rx_pll_locked           : out std_logic;
      rx_pll_rcnfg_in         : in std_logic_vector(63 downto 0);
      rx_pll_rcnfg_out        : out std_logic_vector(63 downto 0);
         
      rx_clk_en               : in std_logic_vector(1 downto 0); --clock output enable
      rx_drct_clk_en          : in std_logic_vector(1 downto 0); --1- Direct clk, 0 - PLL clocks 
      
      rx_io_reset_n           : in std_logic;   
      rx_logic_reset_n        : in std_logic;
      rx_tst_ptrn_en          : in std_logic;
      rx_smpl_src_sel         : in std_logic;
      
      rx_smpl_fifo_wrreq		: in std_logic;
		rx_smpl_fifo_data			: in std_logic_vector(rx_diq_width*4-1 downto 0);
		rx_smpl_fifo_wfull	   : out std_logic;
      rx_smpl_fifo_wrreq_out  : out std_logic;
      
      rx_diq                  : in std_logic_vector(rx_diq_width-1 downto 0);
      rx_diq_fsync            : in std_logic;
      rx_diq_h                : out std_logic_vector(rx_diq_width downto 0);
      rx_diq_l                : out std_logic_vector(rx_diq_width downto 0);
      rx_smpl_nr_clr          : in std_logic;
      rx_smpl_nr_ld           : in std_logic;
      rx_smpl_nr_in           : in std_logic_vector(63 downto 0);
      rx_smpl_nr_out          : out std_logic_vector(63 downto 0);
      rx_pct_loss_flg_clr     : in std_logic;
      rx_pct_fifo_wrusedw     : in std_logic_vector(rx_pct_fifo_wrusedw_w-1 downto 0);
      rx_pct_fifo_wrreq       : out std_logic;
      rx_pct_fifo_wdata       : out std_logic_vector(63 downto 0);
      --sample compare
      rx_smpl_cmp_start       : in std_logic;
      rx_smpl_cmp_length      : in std_logic_vector(15 downto 0);
      rx_smpl_cmp_done        : out std_logic;
      rx_smpl_cmp_err         : out std_logic; 
      
      --TX interface (BB2RF, FPGA transmit)  
      
      tx_pll_in_clk           : in std_logic; -- PLL clk in
      tx_pll_areset           : in std_logic;
      tx_pll_c0               : out std_logic; --FCLK, connect directly to pin 
      tx_pll_c1               : out std_logic;
      tx_pll_locked           : out std_logic;
      tx_pll_rcnfg_in         : in std_logic_vector(63 downto 0);
      tx_pll_rcnfg_out        : out std_logic_vector(63 downto 0);
         
      tx_clk_en               : in std_logic_vector(1 downto 0); --clock output enable
      tx_drct_clk_en          : in std_logic_vector(1 downto 0); --1- Direct clk, 0 - PLL clocks
      
      tx_pct_wclk             : in std_logic;
      tx_io_reset_n           : in std_logic;
      tx_logic_reset_n        : in std_logic;
      tx_xen                  : in std_logic;
      tx_sync_dis             : in std_logic;
      tx_par_mode_en          : in std_logic;
      tx_pct_wrreq            : in std_logic;
      tx_pct_full             : out std_logic;
      tx_pct_data             : in std_logic_vector(31 downto 0);
      tx_diq                  : out std_logic_vector(tx_diq_width-1 downto 0);
      tx_diq_fsync            : out std_logic;     
      tx_diqab_h              : out std_logic_vector(tx_diq_width downto 0);
      tx_diqab_l              : out std_logic_vector(tx_diq_width downto 0);
      tx_diqb_h               : out std_logic_vector(tx_diq_width downto 0);
      tx_diqb_l               : out std_logic_vector(tx_diq_width downto 0)      
      
      


        );
end lms7_rxtx_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of lms7_rxtx_top is
--declare signals,  components here
--inst 0
signal inst0_c0            : std_logic;
signal inst0_c1            : std_logic;
signal inst0_pll_locked    : std_logic;

--inst 1
signal inst1_c0            : std_logic;
signal inst1_c1            : std_logic;
signal inst1_pll_locked    : std_logic;



  
begin
   

----------------------------------------------------------------------------
-- TX PLL
----------------------------------------------------------------------------
tx_pll_top_cyc5_inst0 : entity work.tx_pll_top_cyc5
   generic map(
      intended_device_family  => dev_family,
      drct_c0_ndly            => 2,
      drct_c1_ndly            => 3
   )
   port map(
   --PLL input 
   pll_inclk         => tx_pll_in_clk,
   pll_areset        => tx_pll_areset,
   inv_c0            => '0',
   c0                => inst0_c0, --muxed clock output
   c1                => inst0_c1, --muxed clock output
   pll_locked        => inst0_pll_locked,
   --Bypass control
   clk_ena           => tx_clk_en, --clock output enable
   drct_clk_en       => tx_drct_clk_en, --1- Direct clk, 0 - PLL clocks 
   --Reconfiguration ports
   rcnfg_to_pll      => tx_pll_rcnfg_in,
   rcnfg_from_pll    => tx_pll_rcnfg_out
   
   );
   
   
----------------------------------------------------------------------------
-- RX PLL
----------------------------------------------------------------------------
rx_pll_top_cyc5_inst1 : entity work.rx_pll_top_cyc5
   generic map(
      intended_device_family  => dev_family,
      drct_c0_ndly            => 2,
      drct_c1_ndly            => 3
   )
   port map(
   --PLL input 
   pll_inclk         => rx_pll_in_clk,
   pll_areset        => rx_pll_areset,
   inv_c0            => '0',
   c0                => inst1_c0, --muxed clock output
   c1                => inst1_c1, --muxed clock output
   pll_locked        => inst1_pll_locked,
   --Bypass control
   clk_ena           => rx_clk_en, --clock output enable
   drct_clk_en       => rx_drct_clk_en, --1- Direct clk, 0 - PLL clocks 
   --Reconfiguration ports
   rcnfg_to_pll      => rx_pll_rcnfg_in,
   rcnfg_from_pll    => rx_pll_rcnfg_out
   
   );
   
   
   
limelight_top_inst2 : entity work.limelight_top
   generic map(
      dev_family              => dev_family,
      rx_ddio_clkinv          => rx_ddio_clkinv,     
      rx_diq_width            => rx_diq_width, -- Physical RX IO interface width
      rx_smpl_buff_rdusedw_w  => rx_smpl_buff_rdusedw_w, -- RX buffer size for samples before packets 
      rx_pct_fifo_wrusedw_w   => rx_pct_fifo_wrusedw_w, -- RX packet FIFO buffer wrusedw size
      
      tx_diq_width            => tx_diq_width, -- Physical TX IO interface width
      tx_pct_size_w           => tx_pct_size_w,
      tx_n_buff               => tx_n_buff, -- 2,4 valid values
      tx_in_pct_data_w        => tx_in_pct_data_w, 
      tx_out_pct_data_w       => tx_out_pct_data_w, 
      tx_decomp_fifo_size     => tx_decomp_fifo_size -- 256 words
    
   )
   port map(      
      --LimeLight interface settings
      lml_smpl_width          => lml_smpl_width, --"10"-12bit, "01"-14bit, "00"-16bit;
      lml_mode                => lml_mode, -- JESD207: 1; TRXIQ: 0
      lml_trxiqpulse          => lml_trxiqpulse, -- trxiqpulse on: 1; trxiqpulse off: 0
      lml_ddr_en              => lml_ddr_en, -- DDR: 1; SDR: 0
      lml_mimo_en             => lml_mimo_en, -- SISO: 0; MIMO: 1
      lml_ch_en               => lml_ch_en, --"11" - Ch. A, "10" - Ch. B, "11" - Ch. A and Ch. B.
      lml_fidm                => lml_fidm, -- 0 - Frame start at fsync = 0. 1- Frame start at fsync = 1.
      
      --RX interface (RF2BB, -> FPGA receive)
      rx_clk                  => inst1_c1,
      rx_io_reset_n           => inst1_pll_locked,   
      rx_logic_reset_n        => rx_logic_reset_n,
      rx_tst_ptrn_en          => rx_tst_ptrn_en,
      rx_smpl_src_sel         => rx_smpl_src_sel,
      
      rx_smpl_fifo_wrreq		=> rx_smpl_fifo_wrreq,
		rx_smpl_fifo_data			=> rx_smpl_fifo_data,
		rx_smpl_fifo_wfull	   => rx_smpl_fifo_wfull,
      rx_smpl_fifo_wrreq_out  => rx_smpl_fifo_wrreq_out,
      
      rx_diq                  => rx_diq,
      rx_diq_fsync            => rx_diq_fsync,
      rx_diq_h                => rx_diq_h,
      rx_diq_l                => rx_diq_l ,
      rx_smpl_nr_clr          => rx_smpl_nr_clr,
      rx_smpl_nr_ld           => rx_smpl_nr_ld,
      rx_smpl_nr_in           => rx_smpl_nr_in,
      rx_smpl_nr_out          => rx_smpl_nr_out,
      rx_pct_loss_flg_clr     => rx_pct_loss_flg_clr,
      rx_pct_fifo_wrusedw     => rx_pct_fifo_wrusedw,
      rx_pct_fifo_wrreq       => rx_pct_fifo_wrreq,
      rx_pct_fifo_wdata       => rx_pct_fifo_wdata,
      rx_smpl_cmp_start       => rx_smpl_cmp_start,     
      rx_smpl_cmp_length      => rx_smpl_cmp_length,
      rx_smpl_cmp_done        => rx_smpl_cmp_done, 
      rx_smpl_cmp_err         => rx_smpl_cmp_err,   
      
      --TX interface (BB2RF, FPGA transmit)      
      tx_clk                  => inst0_c1,
      tx_pct_wclk             => tx_pct_wclk,
      tx_io_reset_n           => inst0_pll_locked,
      tx_logic_reset_n        => tx_logic_reset_n,
      tx_xen                  => tx_xen,
      tx_par_mode_en          => tx_par_mode_en,
      tx_sync_dis             => tx_sync_dis,
      tx_pct_wrreq            => tx_pct_wrreq,
      tx_pct_full             => tx_pct_full,
      tx_pct_data             => tx_pct_data,
      tx_diq                  => tx_diq,
      tx_diq_fsync            => tx_diq_fsync,
      tx_diqab_h              => tx_diqab_h,
      tx_diqab_l              => tx_diqab_l,
      tx_diqb_h               => tx_diqb_h,
      tx_diqb_l               => tx_diqb_l   
        );
        
tx_pll_c0      <= inst0_c0;
tx_pll_c1      <= inst0_c1; 
tx_pll_locked  <= inst0_pll_locked;
 
rx_pll_c0      <= inst1_c0;
rx_pll_c1      <= inst1_c1;
rx_pll_locked  <= inst1_pll_locked;

  
end arch;   





