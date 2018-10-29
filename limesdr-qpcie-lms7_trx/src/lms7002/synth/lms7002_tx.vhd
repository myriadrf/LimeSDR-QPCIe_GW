-- ----------------------------------------------------------------------------
-- FILE:          lms7002_tx.vhd
-- DESCRIPTION:   Transmit interface for LMS7002 IC
-- DATE:          11:32 AM Friday, August 31, 2018
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- NOTES:
-- 
-- ----------------------------------------------------------------------------
-- altera vhdl_input_version vhdl_2008
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.FIFO_PACK.all;
use work.memcfg_pkg.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity lms7002_tx is
   generic( 
      g_DEV_FAMILY         : string := "Cyclone IV E";
      g_IQ_WIDTH           : integer := 12;
      g_SMPL_FIFO_WRUSEDW  : integer := 9;
      g_SMPL_FIFO_DATAW    : integer := 128  -- Must be multiple of four IQ samples, minimum four IQ samples
      );
   port (
      clk                  : in  std_logic;
      clk_2x               : in  std_logic;
      reset_n              : in  std_logic;
      mem_reset_n          : in  std_logic;
      from_memcfg          : in  t_FROM_MEMCFG;
      --Mode settings
      mode                 : in  std_logic; -- JESD207: 1; TRXIQ: 0
      trxiqpulse           : in  std_logic; -- trxiqpulse on: 1; trxiqpulse off: 0
      ddr_en               : in  std_logic; -- DDR: 1; SDR: 0
      mimo_en              : in  std_logic; -- SISO: 1; MIMO: 0
      ch_en                : in  std_logic_vector(1 downto 0); --"01" - Ch. A, "10" - Ch. B, "11" - Ch. A and Ch. B. 
      fidm                 : in  std_logic; -- Frame start at fsync = 0, when 0. Frame start at fsync = 1, when 1.
      --TX testing
      test_ptrn_en         : in  std_logic;
      test_ptrn_I          : in  std_logic_vector(15 downto 0);
      test_ptrn_Q          : in  std_logic_vector(15 downto 0);
      test_cnt_en          : in  std_logic;
      txant_en             : out std_logic;                 
      --Tx interface data 
      DIQ                  : out std_logic_vector(g_IQ_WIDTH-1 downto 0);
      fsync                : out std_logic;
      -- Source select
      tx_src_sel           : in std_logic;  -- 0 - FIFO, 1 - diq_h/diq_l
      --TX sample FIFO ports 
      fifo_wrreq           : in  std_logic;
      fifo_data            : in  std_logic_vector(g_SMPL_FIFO_DATAW-1 downto 0);
      fifo_wrfull          : out std_logic;
      fifo_wrusedw         : out std_logic_vector(g_SMPL_FIFO_WRUSEDW-1 downto 0);
      --TX sample ports (direct access to DDR cells)
      diq_h                : in  std_logic_vector(g_IQ_WIDTH downto 0);
      diq_l                : in  std_logic_vector(g_IQ_WIDTH downto 0);
      -- SPI for internal modules
      sdin                 : in std_logic;   -- Data in
      sclk                 : in std_logic;   -- Data clock
      sen                  : in std_logic;   -- Enable signal (active low)
      sdout                : out std_logic  -- Data out
      );
end lms7002_tx;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of lms7002_tx is
--declare signals,  components here
--inst0
constant c_INST0_RDUSEDW   : integer := FIFORD_SIZE (g_SMPL_FIFO_DATAW, 64, g_SMPL_FIFO_WRUSEDW); 
signal inst0_q             : std_logic_vector(63 downto 0);
signal inst0_rdempty       : std_logic;
signal inst0_rdusedw       : std_logic_vector(c_INST0_RDUSEDW-1 downto 0);

--inst1
signal inst1_fifo_rdreq    : std_logic;
signal inst1_DIQ_h         : std_logic_vector(g_IQ_WIDTH downto 0);
signal inst1_DIQ_l         : std_logic_vector(g_IQ_WIDTH downto 0);
signal inst1_fifo_q        : std_logic_vector(g_IQ_WIDTH*4-1 downto 0);

--inst2 
signal inst2_diq_h         : std_logic_vector(g_IQ_WIDTH downto 0);
signal inst2_diq_l         : std_logic_vector(g_IQ_WIDTH downto 0);

--inst4
signal inst4_diq_out       : std_logic_vector(63 downto 0);
signal inst4_xen           : std_logic;

--inst5
signal inst5_wrfull        : std_logic;
signal inst5_q             : std_logic_vector(63 downto 0);
signal inst5_rdempty       : std_logic;
signal inst5_rdusedw       : std_logic_vector(c_INST0_RDUSEDW-1 downto 0);
  
begin

-- ----------------------------------------------------------------------------
-- FIFO for storing TX samples
-- ----------------------------------------------------------------------------
inst0_fifo_inst : entity work.fifo_inst
   generic map(
      dev_family     => g_DEV_FAMILY,
      wrwidth        => g_SMPL_FIFO_DATAW,
      wrusedw_witdth => g_SMPL_FIFO_WRUSEDW, 
      rdwidth        => 64,
      rdusedw_width  => c_INST0_RDUSEDW,
      show_ahead     => "OFF"
  ) 
   port map(
      reset_n  => reset_n,
      wrclk    => clk,
      wrreq    => fifo_wrreq,
      data     => fifo_data,
      wrfull   => fifo_wrfull,
      wrempty  => open,
      wrusedw  => fifo_wrusedw,
      rdclk    => clk_2x,
      rdreq    => inst4_xen AND (NOT inst0_rdempty),
      q        => inst0_q,
      rdempty  => inst0_rdempty,
      rdusedw  => inst0_rdusedw  
   );
   
   
   
   inst4_cfir_top : entity work.cfir_top
   port map(
      clk         => clk_2x,
      reset_n     => reset_n,
      mem_reset_n => mem_reset_n,
      from_memcfg => from_memcfg,
      
      sdin        => sdin,    -- Data in
      sclk        => sclk,    -- Data clock
      sen         => sen,     -- Enable signal (active low)
      sdout       => sdout,   -- Data out
      xen         => inst4_xen,
      diq_in      => inst0_q,
      diq_out     => inst4_diq_out
    );
    
   inst5_fifo_inst : entity work.fifo_inst
   generic map(
      dev_family     => g_DEV_FAMILY,
      wrwidth        => 64,
      wrusedw_witdth => 10, 
      rdwidth        => 64,
      rdusedw_width  => 10,
      show_ahead     => "OFF"
  ) 
   port map(
      reset_n  => reset_n,
      wrclk    => clk_2x,
      wrreq    => inst4_xen AND (NOT inst5_wrfull),
      data     => inst4_diq_out,
      wrfull   => inst5_wrfull,
      wrempty  => open,
      wrusedw  => open,
      rdclk    => clk,
      rdreq    => inst1_fifo_rdreq,
      q        => inst5_q,
      rdempty  => inst5_rdempty,
      rdusedw  => inst5_rdusedw  
   );
   

  
-- ----------------------------------------------------------------------------
-- FIFO for storing TX samples
-- ----------------------------------------------------------------------------  
--   inst1_fifo_q <=   inst0_q(63 downto 64-g_IQ_WIDTH) & 
--                     inst0_q(47 downto 48-g_IQ_WIDTH) &
--                     inst0_q(31 downto 32-g_IQ_WIDTH) & 
--                     inst0_q(15 downto 16-g_IQ_WIDTH);
                     
   inst1_fifo_q <=   inst5_q(63 downto 64-g_IQ_WIDTH) & 
                     inst5_q(47 downto 48-g_IQ_WIDTH) &
                     inst5_q(31 downto 32-g_IQ_WIDTH) & 
                     inst5_q(15 downto 16-g_IQ_WIDTH);

   inst1_fifo2diq : entity work.fifo2diq
   generic map( 
      dev_family           => g_DEV_FAMILY,
      iq_width             => g_IQ_WIDTH
      )
   port map(
      clk                  => clk,
      reset_n              => reset_n,
      --Mode settings
      mode                 => mode, -- JESD207: 1; TRXIQ: 0
      trxiqpulse           => trxiqpulse, -- trxiqpulse on: 1; trxiqpulse off: 0
      ddr_en               => ddr_en, -- DDR: 1; SDR: 0
      mimo_en              => mimo_en, -- SISO: 1; MIMO: 0
      ch_en                => ch_en, --"01" - Ch. A, "10" - Ch. B, "11" - Ch. A and Ch. B. 
      fidm                 => fidm, -- External Frame ID mode. Frame start at fsync = 0, when 0. Frame start at fsync = 1, when 1.
      pct_sync_mode        => '0', -- 0 - timestamp, 1 - external pulse 
      pct_sync_pulse       => '0', -- external packet synchronisation pulse signal
      pct_sync_size        => (others=>'0'), -- valid in external pulse mode only
      pct_buff_rdy         => '0',
      --txant
      txant_cyc_before_en  => (others=>'0'), -- valid in external pulse sync mode only
      txant_cyc_after_en   => (others=>'0'), -- valid in external pulse sync mode only 
      txant_en             => open,                  
      --Tx interface data 
      DIQ                  => open,
      fsync                => open,
      DIQ_h                => inst1_DIQ_h, 
      DIQ_l                => inst1_DIQ_l, 
      --fifo ports 
      fifo_rdempty         => inst5_rdempty, 
      fifo_rdreq           => inst1_fifo_rdreq,
      fifo_q               => inst1_fifo_q
   );
   
-- ----------------------------------------------------------------------------
-- TX MUX
-- ----------------------------------------------------------------------------  
   inst2_txiqmux : entity work.txiqmux
   generic map(
      diq_width   => g_IQ_WIDTH
   )
   port map(
      clk               => clk,
      reset_n           => reset_n,
      test_ptrn_en      => test_ptrn_en,  -- Enables test pattern
      test_ptrn_fidm    => '0',           -- Frame start at fsync = 0, when 0. Frame start at fsync = 1, when 1.
      test_ptrn_I       => test_ptrn_I,
      test_ptrn_Q       => test_ptrn_Q,
      test_data_en      => test_cnt_en,
      test_data_mimo_en => '1',
      mux_sel           => tx_src_sel,   -- Mux select: 0 - tx, 1 - wfm
      tx_diq_h          => inst1_DIQ_h,
      tx_diq_l          => inst1_DIQ_l,
      wfm_diq_h         => diq_h,
      wfm_diq_l         => diq_l,
      diq_h             => inst2_diq_h,
      diq_l             => inst2_diq_l
   );
   
-- ----------------------------------------------------------------------------
-- lms7002_ddout instance. Double data rate cells
-- ----------------------------------------------------------------------------     
   inst3_lms7002_ddout : entity work.lms7002_ddout
   generic map( 
      dev_family     => g_DEV_FAMILY,
      iq_width       => g_IQ_WIDTH
   )
   port map(
      --input ports 
      clk            => clk,
      reset_n        => reset_n,
      data_in_h      => inst2_diq_h,
      data_in_l      => inst2_diq_l,
      --output ports 
      txiq           => DIQ,
      txiqsel        => fsync
   ); 
   
end arch;   


