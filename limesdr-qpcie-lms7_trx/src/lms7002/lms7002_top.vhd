-- ----------------------------------------------------------------------------
-- FILE:          lms7002_top.vhd
-- DESCRIPTION:   Top file for LMS7002M IC
-- DATE:          9:16 AM Wednesday, August 29, 2018
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
--NOTES:
-- ----------------------------------------------------------------------------
-- altera vhdl_input_version vhdl_2008
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fpgacfg_pkg.all;
use work.tstcfg_pkg.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity lms7002_top is
   generic(
      g_DEV_FAMILY      : string := "Cyclone IV E";
      g_IQ_WIDTH        : integer := 12;
      g_INV_INPUT_CLK   : string := "ON"
   );
   port (  
      from_fpgacfg      : in  t_FROM_FPGACFG;
      from_tstcfg       : in  t_FROM_TSTCFG;      
      -- PORT1 interface
      MCLK1             : in  std_logic;  -- TX interface clock
      FCLK1             : out std_logic;  -- TX interface feedback clock
      DIQ1              : out std_logic_vector(g_IQ_WIDTH-1 downto 0);
      ENABLE_IQSEL1     : out std_logic;
      TXNRX1            : out std_logic;
      -- PORT2 interface
      MCLK2             : in  std_logic;  -- RX interface clock
      FCLK2             : out std_logic;  -- RX interface feedback clock
      DIQ2              : in  std_logic_vector(g_IQ_WIDTH-1 downto 0);
      ENABLE_IQSEL2     : in  std_logic;
      TXNRX2            : out std_logic;
      -- MISC
      RESET             : out std_logic; 
      TXEN              : out std_logic;
      RXEN              : out std_logic;
      CORE_LDO_EN       : out std_logic;
      -- Internal TX ports
      tx_reset_n        : in  std_logic;
      tx_src_sel        : in  std_logic_vector(1 downto 0);
      tx_diq_h          : in  std_logic_vector(g_IQ_WIDTH downto 0);
      tx_diq_l          : in  std_logic_vector(g_IQ_WIDTH downto 0);
      tx_wrfull         : out std_logic;
      tx_wrreq          : in  std_logic;
      tx_data           : in  std_logic_vector(g_IQ_WIDTH*4-1 downto 0);
      -- Internal RX ports
      rx_reset_n        : in  std_logic;
      rx_diq_h          : out std_logic_vector(g_IQ_WIDTH downto 0);
      rx_diq_l          : out std_logic_vector(g_IQ_WIDTH downto 0);
      rx_data_valid     : out std_logic;
      rx_data           : out std_logic_vector(g_IQ_WIDTH*4-1 downto 0);
      --sample compare
      rx_smpl_cmp_start : in std_logic;
      rx_smpl_cmp_length: in std_logic_vector(15 downto 0);
      rx_smpl_cmp_done  : out std_logic;
      rx_smpl_cmp_err   : out std_logic
   );
end lms7002_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of lms7002_top is
--declare signals,  components here
signal inst2_diq_h : std_logic_vector (g_IQ_WIDTH downto 0); 
signal inst2_diq_l : std_logic_vector (g_IQ_WIDTH downto 0); 

signal rx_smpl_cmp_start_sync : std_logic;
--inst0
signal inst0_reset_n : std_logic;
  
begin

   sync_reg0 : entity work.sync_reg 
   port map(MCLK2, rx_reset_n, from_fpgacfg.rx_en, inst0_reset_n);
   
   sync_reg1 : entity work.sync_reg 
   port map(MCLK2, '1', rx_smpl_cmp_start, rx_smpl_cmp_start_sync);

-- ----------------------------------------------------------------------------
-- RX interface
-- ----------------------------------------------------------------------------
inst0_diq2fifo : entity work.diq2fifo
   generic map( 
      dev_family           => g_DEV_FAMILY,
      iq_width             => g_IQ_WIDTH,
      invert_input_clocks  => g_INV_INPUT_CLK
   )
   port map(
      clk            => MCLK2,
      reset_n        => inst0_reset_n,
      test_ptrn_en   => from_fpgacfg.rx_ptrn_en,
      --Mode settings
      mode           => from_fpgacfg.mode,         -- JESD207: 1; TRXIQ: 0
      trxiqpulse     => from_fpgacfg.trxiq_pulse,  -- trxiqpulse on: 1; trxiqpulse off: 0
      ddr_en         => from_fpgacfg.ddr_en,       -- DDR: 1; SDR: 0
      mimo_en        => from_fpgacfg.mimo_int_en,  -- SISO: 1; MIMO: 0
      ch_en          => from_fpgacfg.ch_en(1 downto 0),  --"01" - Ch. A, "10" - Ch. B, "11" - Ch. A and Ch. B. 
      fidm           => '0',  -- Frame start at fsync = 0, when 0. Frame start at fsync = 1, when 1.
      --Rx interface data 
      DIQ            => DIQ2,
      fsync          => ENABLE_IQSEL2,
      --fifo ports 
      fifo_wfull     => '0',
      fifo_wrreq     => rx_data_valid,
      fifo_wdata     => rx_data,
      --sample compare
      smpl_cmp_start => rx_smpl_cmp_start_sync,
      smpl_cmp_length=> rx_smpl_cmp_length,
      smpl_cmp_done  => rx_smpl_cmp_done,
      smpl_cmp_err   => rx_smpl_cmp_err
   );
   
-- ----------------------------------------------------------------------------
-- TX interface
-- ----------------------------------------------------------------------------  
   -- TX MUX 
   inst2_txiqmux : entity work.txiqmux
   generic map(
      diq_width   => g_IQ_WIDTH
   )
   port map(
      clk               => MCLK1,
      reset_n           => tx_reset_n,
      test_ptrn_en      => from_fpgacfg.tx_ptrn_en,   -- Enables test pattern
      test_ptrn_fidm    => '0',   -- External Frame ID mode. Frame start at fsync = 0, when 0. Frame start at fsync = 1, when 1.
      test_ptrn_I       => from_tstcfg.TX_TST_I,
      test_ptrn_Q       => from_tstcfg.TX_TST_Q,
      test_data_en      => from_fpgacfg.tx_cnt_en,
      test_data_mimo_en => '1',
      mux_sel           => from_fpgacfg.wfm_play,   -- Mux select: 0 - tx, 1 - wfm
      tx_diq_h          => (others => '0'),
      tx_diq_l          => (others => '0'),
      wfm_diq_h         => (others => '0'),
      wfm_diq_l         => (others => '0'),
      diq_h             => inst2_diq_h,
      diq_l             => inst2_diq_l
   );
   
   -- lms7002_ddout instance. Double data rate cells
   inst3_lms7002_ddout : entity work.lms7002_ddout
   generic map( 
      dev_family     => g_DEV_FAMILY,
      iq_width       => g_IQ_WIDTH
   )
   port map(
      --input ports 
      clk            => MCLK1,
      reset_n        => tx_reset_n,
      data_in_h      => inst2_diq_h,
      data_in_l      => inst2_diq_l,
      --output ports 
      txiq           => DIQ1,
      txiqsel        => ENABLE_IQSEL1
   ); 
 
-- ----------------------------------------------------------------------------
-- Output ports
-- ---------------------------------------------------------------------------- 
   RESET       	<= from_fpgacfg.LMS1_RESET;
   TXEN        	<= from_fpgacfg.LMS1_TXEN;
   RXEN        	<= from_fpgacfg.LMS1_RXEN;
   CORE_LDO_EN 	<= from_fpgacfg.LMS1_CORE_LDO_EN;
   TXNRX1      	<= from_fpgacfg.LMS1_TXNRX1;
   TXNRX2      	<= from_fpgacfg.LMS1_TXNRX2;
   
   
end arch;   


