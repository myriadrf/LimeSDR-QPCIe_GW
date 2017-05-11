-- ----------------------------------------------------------------------------	
-- FILE: limelight_top.vhd
-- DESCRIPTION: describe file
-- DATE: May 11, 2017
-- AUTHOR(s): Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity limelight_top is
   generic(
      dev_family				   : string := "Cyclone V";
      rx_ddio_clkinv          : string := "ON";            
      rx_diq_width            : integer := 12; -- Physical RX IO interface width
      rx_smpl_buff_rdusedw_w  : integer := 11; -- RX buffer size for samples before packets 
      rx_pct_fifo_wrusedw_w   : integer := 12; -- RX packet FIFO buffer wrusedw size
      
      txdiq_width             : integer := 12; -- Physical TX IO interface width
   );
   port (      
      --LimeLight interface settings
      lml_smpl_width       : in std_logic(1 downto 0); --"10"-12bit, "01"-14bit, "00"-16bit;
      lml_mode             : in std_logic; -- JESD207: 1; TRXIQ: 0
      lml_trxiqpulse       : in std_logic; -- trxiqpulse on: 1; trxiqpulse off: 0
      lml_ddr_en           : in std_logic; -- DDR: 1; SDR: 0
      lml_mimo_en          : in std_logic; -- SISO: 0; MIMO: 1
      lml_ch_en            : in std_logic_vector(1 downto 0); --"11" - Ch. A, "10" - Ch. B, "11" - Ch. A and Ch. B.
      lml_fidm             : in std_logic; -- 0 - Frame start at fsync = 0. 1- Frame start at fsync = 1.
      
      --RX interface (RF2BB, LMS7002 -> FPGA)
      rx_clk               : in std_logic;
      rx_io_reset_n        : in std_logic;   
      rx_logic_reset_n     : in std_logic;
      rx_tst_ptrn_en       : in std_logic;
      
      rx_diq               : in std_logic_vector(rx_diq_width-1 downto 0);
      rx_diq_fsync         : in std_logic;
      rx_diq_h             : out std_logic_vector(rx_diq_width downto 0);
      rx_diq_l             : out std_logic_vector(rx_diq_width downto 0);
      rx_smpl_nr_clr       : in std_logic;
      rx_smpl_nr_ld        : in std_logic;
      rx_smpl_nr_in        : in std_logic_vector(63 downto 0);
      rx_smpl_nr_out       : out std_logic_vector(63 downto 0);
      rx_pct_loss_flg_clr  : in std_logic;
      rx_pct_fifo_wrusedw  : in std_logic_vector(rx_pct_fifo_wrusedw_w-1 downto 0);
      rx_pct_fifo_wrreq    : out std_logic;
      rx_pct_fifo_wdata    : out std_logic_vector(63 downto 0);
      
      
      --TX interface (BB2RF, FPGA -> LMS7002)      
      tx_clk               : in std_logic;
      tx_pct_wclk          : in std_logic;
      tx_io_reset_n        : in std_logic;
      tx_logic_reset_n     : in std_logic;
      
      


        );
end limelight_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of limelight_top is
--declare signals,  components here
signal inst0_DIQ_h : std_logic_vector (rx_diq_width downto 0); 
signal inst0_DIQ_l : std_logic_vector (rx_diq_width downto 0); 
  
begin
   
-- ----------------------------------------------------------------------------
-- RX instance
-- ----------------------------------------------------------------------------   
   rx_path_top_inst0 : entity work.rx_path_top
   generic map( 
      dev_family           => dev_family,
      iq_width             => rx_diq_width,
      invert_input_clocks  => rx_ddio_clkinv,
      smpl_buff_rdusedw_w  => rx_smpl_buff_rdusedw_w,
      pct_buff_wrusedw_w   => rx_pct_fifo_wrusedw_w
      )
   port map(
      clk                  => rx_clk,
      reset_n              => rx_logic_reset_n,
      io_reset_n           => rx_io_reset_n,
      test_ptrn_en         => rx_tst_ptrn_en,
      --Mode settings (lml_ signals are synced to rx_clk inside this module)     
      sample_width         => lml_smpl_width,
      mode                 => lml_mode,
      trxiqpulse           => lml_trxiqpulse,
      ddr_en               => lml_ddr_en,
      mimo_en              => lml_mimo_en,
      ch_en                => lml_ch_en,
      fidm                 => lml_fidm,
      --Rx interface data 
      DIQ                  => rx_diq,
      fsync                => rx_diq_fsync,
      DIQ_h                => inst0_DIQ_h,
      DIQ_l                => inst0_DIQ_l,
      --samples            
      smpl_fifo_wrreq_out  => open,
      --Packet fifo ports  
      pct_fifo_wusedw      => rx_pct_fifo_wrusedw,
      pct_fifo_wrreq       => inst0_pct_fifo_wrreq,
      pct_fifo_wdata       => inst0_pct_fifo_wdata,
      --sample nr          
      clr_smpl_nr          => rx_smpl_nr_clr,
      ld_smpl_nr           => rx_smpl_nr_ld,
      smpl_nr_in           => rx_smpl_nr_in,
      smpl_nr_cnt          => rx_smpl_nr_out,
      --flag control       
      tx_pct_loss          => ,
      tx_pct_loss_clr      => rx_pct_loss_flg_clr,
     
        );

-- ----------------------------------------------------------------------------
-- Output ports
-- ----------------------------------------------------------------------------
rx_diq_h          <= inst0_DIQ_h;
rx_diq_l          <= inst0_DIQ_l;
rx_pct_fifo_wrreq <= inst0_pct_fifo_wrreq;
rx_pct_fifo_wdata <= inst0_pct_fifo_wdata;
  
end arch;   





