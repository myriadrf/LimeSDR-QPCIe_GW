-- ----------------------------------------------------------------------------
-- FILE:          pll_top.vhd
-- DESCRIPTION:   Top wrapper file for PLLs
-- DATE:          10:50 AM Wednesday, May 9, 2018
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
use work.pllcfg_pkg.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity pll_top is
   generic(
      INTENDED_DEVICE_FAMILY     : STRING    := "Cyclone V GX";
      N_PLL                      : integer   := 5;
      -- TX pll parameters
      LMS1_TXPLL_DRCT_C0_NDLY    : integer   := 1;
      LMS1_TXPLL_DRCT_C1_NDLY    : integer   := 2;
      -- RX pll parameters
      LMS1_RXPLL_DRCT_C0_NDLY    : integer   := 1;
      LMS1_RXPLL_DRCT_C1_NDLY    : integer   := 2;
      -- TX pll parameters
      LMS2_TXPLL_DRCT_C0_NDLY    : integer   := 1;
      LMS2_TXPLL_DRCT_C1_NDLY    : integer   := 2;
      -- RX pll parameters
      LMS2_RXPLL_DRCT_C0_NDLY    : integer   := 1;
      LMS2_RXPLL_DRCT_C1_NDLY    : integer   := 2

   );
   port (
      -- LMS#1 TX PLL ports
      lms1_txpll_inclk              : in  std_logic;
      lms1_txpll_reconfig_clk       : in  std_logic;
      lms1_txpll_rcnfg_to_pll       : in  std_logic_vector(63 downto 0);
      lms1_txpll_rcnfg_from_pll     : out std_logic_vector(63 downto 0);
      lms1_txpll_logic_reset_n      : in  std_logic;
      lms1_txpll_clk_ena            : in  std_logic_vector(1 downto 0);
      lms1_txpll_drct_clk_en        : in  std_logic_vector(1 downto 0);
      lms1_txpll_c0                 : out std_logic;
      lms1_txpll_c1                 : out std_logic;
      lms1_txpll_locked             : out std_logic;
      -- LMS#1 RX PLL ports
      lms1_rxpll_inclk              : in  std_logic;
      lms1_rxpll_reconfig_clk       : in  std_logic;
      lms1_rxpll_rcnfg_to_pll       : in  std_logic_vector(63 downto 0);
      lms1_rxpll_rcnfg_from_pll     : out std_logic_vector(63 downto 0);
      lms1_rxpll_logic_reset_n      : in  std_logic;
      lms1_rxpll_clk_ena            : in  std_logic_vector(1 downto 0);
      lms1_rxpll_drct_clk_en        : in  std_logic_vector(1 downto 0); 
      lms1_rxpll_c0                 : out std_logic;
      lms1_rxpll_c1                 : out std_logic;
      lms1_rxpll_locked             : out std_logic;
      -- Sample comparing ports from LMS#1 RX interface
      lms1_smpl_cmp_en              : out std_logic;
      lms1_smpl_cmp_done            : in  std_logic;
      lms1_smpl_cmp_error           : in  std_logic;
      lms1_smpl_cmp_cnt             : out std_logic_vector(15 downto 0);
      -- LMS#2 TX PLL ports 
      lms2_txpll_inclk              : in  std_logic;
      lms2_txpll_reconfig_clk       : in  std_logic;
      lms2_txpll_rcnfg_to_pll       : in  std_logic_vector(63 downto 0);
      lms2_txpll_rcnfg_from_pll     : out std_logic_vector(63 downto 0);
      lms2_txpll_logic_reset_n      : in  std_logic;
      lms2_txpll_clk_ena            : in  std_logic_vector(1 downto 0);
      lms2_txpll_drct_clk_en        : in  std_logic_vector(1 downto 0);
      lms2_txpll_c0                 : out std_logic;
      lms2_txpll_c1                 : out std_logic;
      lms2_txpll_locked             : out std_logic;
      -- LMS#2 RX PLL  0 ports
      lms2_rxpll_inclk              : in  std_logic;
      lms2_rxpll_reconfig_clk       : in  std_logic;
      lms2_rxpll_rcnfg_to_pll       : in  std_logic_vector(63 downto 0);
      lms2_rxpll_rcnfg_from_pll     : out std_logic_vector(63 downto 0);
      lms2_rxpll_logic_reset_n      : in  std_logic;
      lms2_rxpll_clk_ena            : in  std_logic_vector(1 downto 0);
      lms2_rxpll_drct_clk_en        : in  std_logic_vector(1 downto 0); 
      lms2_rxpll_c0                 : out std_logic;
      lms2_rxpll_c1                 : out std_logic;
      lms2_rxpll_locked             : out std_logic;
      -- Sample comparing ports from LMS#2 RX interface 
      lms2_smpl_cmp_en              : out std_logic;   
      lms2_smpl_cmp_done            : in  std_logic;
      lms2_smpl_cmp_error           : in  std_logic;
      lms2_smpl_cmp_cnt             : out std_logic_vector(15 downto 0);
      -- PLL for DAC, ADC
      pll_0_inclk                   : in  std_logic;
      pll_0_rcnfg_to_pll            : in  std_logic_vector(63 downto 0);
      pll_0_rcnfg_from_pll          : out std_logic_vector(63 downto 0);
      pll_0_c0                      : out std_logic;
      pll_0_c1                      : out std_logic;
      pll_0_locked                  : out std_logic;
         --Reconfiguration  0 ports
      rcnfg_0_mgmt_readdata         : in  std_logic_vector(31 downto 0);		
      rcnfg_0_mgmt_waitrequest      : in  std_logic;
      rcnfg_0_mgmt_read             : out std_logic;
      rcnfg_0_mgmt_write            : out std_logic;
      rcnfg_0_mgmt_address          : out std_logic_vector(5 downto 0);
      rcnfg_0_mgmt_writedata        : out std_logic_vector(31 downto 0);
         --Reconfiguration  1 ports
      rcnfg_1_mgmt_readdata         : in  std_logic_vector(31 downto 0);		
      rcnfg_1_mgmt_waitrequest      : in  std_logic;
      rcnfg_1_mgmt_read             : out std_logic;
      rcnfg_1_mgmt_write            : out std_logic;
      rcnfg_1_mgmt_address          : out std_logic_vector(5 downto 0);
      rcnfg_1_mgmt_writedata        : out std_logic_vector(31 downto 0);   
      -- pllcfg ports
      to_pllcfg                     : out t_TO_PLLCFG;
      from_pllcfg                   : in  t_FROM_PLLCFG
      );
end pll_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of pll_top is
--declare signals,  components here
   --inst0
   signal inst0_pll_locked             : std_logic;
   signal inst0_smpl_cmp_en            : std_logic;
   signal inst0_busy                   : std_logic;
   signal inst0_dynps_done             : std_logic;
   signal inst0_dynps_status           : std_logic;
   signal inst0_rcnfig_status          : std_logic;
   signal inst0_rcnfg_mgmt_readdata    : std_logic_vector(31 downto 0);		
   signal inst0_rcnfg_mgmt_waitrequest : std_logic;
   signal inst0_rcnfg_mgmt_read        : std_logic;
   signal inst0_rcnfg_mgmt_write       : std_logic;
   signal inst0_rcnfg_mgmt_address     : std_logic_vector(5 downto 0);
   signal inst0_rcnfg_mgmt_writedata   : std_logic_vector(31 downto 0);
   signal inst0_rcnfg_to_pll           : std_logic_vector(63 downto 0);
   signal inst0_rcnfg_from_pll         : std_logic_vector(63 downto 0);

   --inst1
   signal inst1_pll_locked             : std_logic;
   signal inst1_smpl_cmp_en            : std_logic;
   signal inst1_busy                   : std_logic;
   signal inst1_dynps_done             : std_logic;
   signal inst1_dynps_status           : std_logic;
   signal inst1_rcnfig_status          : std_logic;
   signal inst1_rcnfg_mgmt_readdata    : std_logic_vector(31 downto 0);		
   signal inst1_rcnfg_mgmt_waitrequest : std_logic;
   signal inst1_rcnfg_mgmt_read        : std_logic;
   signal inst1_rcnfg_mgmt_write       : std_logic;
   signal inst1_rcnfg_mgmt_address     : std_logic_vector(5 downto 0);
   signal inst1_rcnfg_mgmt_writedata   : std_logic_vector(31 downto 0);
   signal inst1_rcnfg_to_pll           : std_logic_vector(63 downto 0);
   signal inst1_rcnfg_from_pll         : std_logic_vector(63 downto 0);
   
   --inst2
   signal inst2_pllcfg_busy      : std_logic_vector(N_PLL-1 downto 0);
   signal inst2_pllcfg_done      : std_logic_vector(N_PLL-1 downto 0);
   signal inst2_pll_lock         : std_logic_vector(N_PLL-1 downto 0);
   signal inst2_phcfg_start      : std_logic_vector(N_PLL-1 downto 0);
   signal inst2_pllcfg_start     : std_logic_vector(N_PLL-1 downto 0);
   signal inst2_pllrst_start     : std_logic_vector(N_PLL-1 downto 0);
   signal inst2_auto_phcfg_done  : std_logic_vector(N_PLL-1 downto 0);
   signal inst2_auto_phcfg_err   : std_logic_vector(N_PLL-1 downto 0);
   signal inst2_phcfg_mode       : std_logic;
   signal inst2_phcfg_tst        : std_logic;
   signal inst2_phcfg_updn       : std_logic;
   signal inst2_cnt_ind          : std_logic_vector(4 downto 0);
   signal inst2_cnt_phase        : std_logic_vector(15 downto 0);
   signal inst2_pllcfg_data      : std_logic_vector(143 downto 0);
   signal inst2_auto_phcfg_smpls : std_logic_vector(15 downto 0);
   signal inst2_auto_phcfg_step  : std_logic_vector(15 downto 0);
   
   signal pllcfg_busy            : std_logic;
   signal pllcfg_done            : std_logic;
   
  
begin

-- ----------------------------------------------------------------------------
-- TX PLL instance
-- ----------------------------------------------------------------------------
   inst0_tx_pll_top_cyc5 : entity work.tx_pll_top_cyc5
   generic map(
      intended_device_family  => INTENDED_DEVICE_FAMILY,
      drct_c0_ndly            => LMS1_TXPLL_DRCT_C0_NDLY,
      drct_c1_ndly            => LMS1_TXPLL_DRCT_C1_NDLY,
      cntsel_width            => 5
   )
   port map(
   free_running_clk           => lms1_txpll_reconfig_clk,
   --PLL input    
   pll_inclk                  => lms1_txpll_inclk,
   pll_areset                 => inst2_pllrst_start(0),
   pll_logic_reset_n          => lms1_txpll_logic_reset_n,
   inv_c0                     => '0',
   c0                         => lms1_txpll_c0, --muxed clock output
   c1                         => lms1_txpll_c1, --muxed clock output
   pll_locked                 => inst0_pll_locked,
   --Bypass control
   clk_ena                    => lms1_txpll_clk_ena,       --clock output enable
   drct_clk_en                => lms1_txpll_drct_clk_en,   --1 - Direct clk, 0 - PLL clocks  
   --Reconfiguration ports
   rcnfg_mgmt_readdata        => inst0_rcnfg_mgmt_readdata,	
   rcnfg_mgmt_waitrequest     => inst0_rcnfg_mgmt_waitrequest,
   rcnfg_mgmt_read            => inst0_rcnfg_mgmt_read,
   rcnfg_mgmt_write           => inst0_rcnfg_mgmt_write,
   rcnfg_mgmt_address         => inst0_rcnfg_mgmt_address,
   rcnfg_mgmt_writedata       => inst0_rcnfg_mgmt_writedata,
   rcnfg_to_pll               => inst0_rcnfg_to_pll,
   rcnfg_from_pll             => inst0_rcnfg_from_pll,
   --Dynamic phase shift ports
   dynps_mode                 => inst2_phcfg_mode, -- 0 - manual, 1 - auto
   dynps_areset_n             => not inst2_pllrst_start(0),
   dynps_en                   => inst2_phcfg_start(0),
   dynps_tst                  => inst2_phcfg_tst,
   dynps_dir                  => inst2_phcfg_updn,
   dynps_cnt_sel              => inst2_cnt_ind(4 downto 0),
   -- max phase steps in auto mode, phase steps to shift in manual mode 
   dynps_phase                => inst2_cnt_phase(9 downto 0),
   dynps_step_size            => inst2_auto_phcfg_step(9 downto 0),
   dynps_busy                 => open,
   dynps_done                 => inst0_dynps_done,
   dynps_status               => inst0_dynps_status,
   --signals from sample compare module (required for automatic phase searching)
   smpl_cmp_en                => inst0_smpl_cmp_en,
   smpl_cmp_done              => lms1_smpl_cmp_done,
   smpl_cmp_error             => lms1_smpl_cmp_error
   );
   
-- ----------------------------------------------------------------------------
-- RX PLL instance
-- ----------------------------------------------------------------------------
   inst1_rx_pll_top_cyc5 : entity work.rx_pll_top_cyc5
   generic map(
      intended_device_family  => INTENDED_DEVICE_FAMILY,
      drct_c0_ndly            => LMS1_RXPLL_DRCT_C0_NDLY,
      drct_c1_ndly            => LMS1_RXPLL_DRCT_C1_NDLY,
      cntsel_width            => 5
   )
   port map(
   free_running_clk           => lms1_rxpll_reconfig_clk,
   --PLL input
   pll_inclk                  => lms1_rxpll_inclk,
   pll_areset                 => inst2_pllrst_start(1),
   pll_logic_reset_n          => lms1_rxpll_logic_reset_n,
   inv_c0                     => '0',
   c0                         => lms1_rxpll_c0, --muxed clock output
   c1                         => lms1_rxpll_c1, --muxed clock output
   pll_locked                 => inst1_pll_locked,
   --Bypass control
   clk_ena                    => lms1_rxpll_clk_ena,       --clock output enable
   drct_clk_en                => lms1_rxpll_drct_clk_en,   --1 - Direct clk, 0 - PLL clocks 
   --Reconfiguration ports
   rcnfg_mgmt_readdata        => inst1_rcnfg_mgmt_readdata,   
   rcnfg_mgmt_waitrequest     => inst1_rcnfg_mgmt_waitrequest,
   rcnfg_mgmt_read            => inst1_rcnfg_mgmt_read,   
   rcnfg_mgmt_write           => inst1_rcnfg_mgmt_write,      
   rcnfg_mgmt_address         => inst1_rcnfg_mgmt_address,    
   rcnfg_mgmt_writedata       => inst1_rcnfg_mgmt_writedata,  
   rcnfg_to_pll               => inst1_rcnfg_to_pll,          
   rcnfg_from_pll             => inst1_rcnfg_from_pll,        
   --Dynamic phase shift ports
   dynps_mode                 => inst2_phcfg_mode, -- 0 - manual, 1 - auto
   dynps_areset_n             => not inst2_pllrst_start(1),
   dynps_en                   => inst2_phcfg_start(1),
   dynps_tst                  => inst2_phcfg_tst,
   dynps_dir                  => inst2_phcfg_updn,
   dynps_cnt_sel              => inst2_cnt_ind(4 downto 0),
   -- max phase steps in auto mode, phase steps to shift in manual mode 
   dynps_phase                => inst2_cnt_phase(9 downto 0),
   dynps_step_size            => inst2_auto_phcfg_step(9 downto 0),
   dynps_busy                 => open,
   dynps_done                 => inst1_dynps_done,
   dynps_status               => inst1_dynps_status,
   --signals from sample compare module (required for automatic phase searching)
   smpl_cmp_en                => inst1_smpl_cmp_en,
   smpl_cmp_done              => lms1_smpl_cmp_done,
   smpl_cmp_error             => lms1_smpl_cmp_error
   
   );


   pllcfg_busy <= inst1_busy OR inst0_busy;
   pllcfg_done <= not pllcfg_busy;
   
   
-- ----------------------------------------------------------------------------
-- pllcfg_top instance
-- ----------------------------------------------------------------------------
   process(pllcfg_busy) 
      begin 
         inst2_pllcfg_busy <= (others=>'0');
         inst2_pllcfg_busy(0) <= pllcfg_busy;
   end process;
   
   process(pllcfg_done) 
      begin 
         inst2_pllcfg_done <= (others=>'1');
         inst2_pllcfg_done(0) <= pllcfg_done;
   end process;
   
   process(inst1_pll_locked, inst0_pll_locked) 
      begin 
         inst2_pll_lock    <= (others=>'0');
         inst2_pll_lock(0) <= inst0_pll_locked;
         inst2_pll_lock(1) <= inst1_pll_locked;
   end process;
   
   process(inst0_dynps_done, inst1_dynps_done) 
      begin 
         inst2_auto_phcfg_done <= (others=>'0');
         inst2_auto_phcfg_done(0) <= inst0_dynps_done;
         inst2_auto_phcfg_done(1) <= inst1_dynps_done;
   end process;
   
   process(inst0_dynps_status) 
      begin 
         inst2_auto_phcfg_err <= (others=>'1');
         inst2_auto_phcfg_err(0) <= inst0_dynps_status;
         inst2_auto_phcfg_err(1) <= inst1_dynps_status;
   end process;
     

   pll_ctrl_inst2 : entity work.pll_ctrl 
   generic map(
      n_pll	=> N_PLL
   )
   port map(
      to_pllcfg         => to_pllcfg,
      from_pllcfg       => from_pllcfg,
         -- Status Inputs
      pllcfg_busy       => inst2_pllcfg_busy,
      pllcfg_done       => inst2_pllcfg_done,
         -- PLL Lock flags
      pll_lock          => inst2_pll_lock,
         -- PLL Configuration Related
      phcfg_mode        => inst2_phcfg_mode,
      phcfg_tst         => inst2_phcfg_tst,
      phcfg_start       => inst2_phcfg_start,   --
      pllcfg_start      => inst2_pllcfg_start,  --
      pllrst_start      => inst2_pllrst_start,  --
      phcfg_updn        => inst2_phcfg_updn,
      cnt_ind           => inst2_cnt_ind,       --
      cnt_phase         => inst2_cnt_phase,     --
      pllcfg_data       => inst2_pllcfg_data,
      auto_phcfg_done   => inst2_auto_phcfg_done,
      auto_phcfg_err    => inst2_auto_phcfg_err,
      auto_phcfg_smpls  => inst2_auto_phcfg_smpls,
      auto_phcfg_step   => inst2_auto_phcfg_step
        
      );
-- ----------------------------------------------------------------------------
-- Output ports
-- ----------------------------------------------------------------------------  
lms1_txpll_locked    <= inst0_pll_locked;
lms1_rxpll_locked    <= inst1_pll_locked;
lms1_smpl_cmp_en     <= inst0_smpl_cmp_en OR inst1_smpl_cmp_en;
lms1_smpl_cmp_cnt    <= inst2_auto_phcfg_smpls;


lms2_smpl_cmp_cnt    <= inst2_auto_phcfg_smpls;


end arch;   


