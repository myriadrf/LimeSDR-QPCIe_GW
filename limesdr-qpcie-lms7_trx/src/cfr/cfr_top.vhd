-- ----------------------------------------------------------------------------
-- FILE:          cfir_top.vhd
-- DESCRIPTION:   Top file for cfr modules
-- DATE:          10:55 AM Friday, October 26, 2018
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
use work.memcfg_pkg.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity cfir_top is
   port (
      clk         : in std_logic;
      reset_n     : in std_logic;
      mem_reset_n : in std_logic;
      from_memcfg : in t_FROM_MEMCFG;
      
      sdin        : in std_logic;   -- Data in
      sclk        : in std_logic;   -- Data clock
      sen         : in std_logic;   -- Enable signal (active low)
      sdout       : out std_logic;  -- Data out
      data_req    : out std_logic;
      data_valid  : out std_logic;
      diq_in      : in std_logic_vector(63 downto 0);
      diq_out     : out std_logic_vector(63 downto 0)
   );
end cfir_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of cfir_top is
--declare signals,  components here

signal ai_in                  : std_logic_vector(15 downto 0);
signal aq_in                  : std_logic_vector(15 downto 0);
signal bi_in                  : std_logic_vector(15 downto 0);
signal bq_in                  : std_logic_vector(15 downto 0);


--inst0
signal inst0_sdout            : std_logic;
signal inst0_cfr0_bypass      : std_logic;
signal inst0_cfr1_bypass      : std_logic;
signal inst0_cfr0_sleep       : std_logic;
signal inst0_cfr1_sleep       : std_logic;
signal inst0_cfr0_half_order  : std_logic_vector(7 downto 0);
signal inst0_cfr1_half_order  : std_logic_vector(7 downto 0);
signal inst0_cfr0_threshold   : std_logic_vector(15 downto 0);
signal inst0_cfr1_threshold   : std_logic_vector(15 downto 0);
signal inst0_gain_cfr_A       : std_logic_vector(15 downto 0);
signal inst0_gain_cfr_B       : std_logic_vector(15 downto 0);
signal inst0_gain_cfr0_bypass : std_logic;
signal inst0_gain_cfr1_bypass : std_logic;


signal inst0_temp             : std_logic_vector(7 downto 0);
signal inst0_gfir0_byp        : std_logic;
signal inst0_gfir1_byp        : std_logic;

--inst1
signal inst1_sdout            : std_logic;
signal inst1_yi               : std_logic_vector(15 downto 0);
signal inst1_yq               : std_logic_vector(15 downto 0);
signal inst1_xen              : std_logic;
signal inst1_xen_reg0         : std_logic;
signal inst1_xen_reg1         : std_logic;

--inst2
signal inst2_sdout            : std_logic;
signal inst2_yi               : std_logic_vector(15 downto 0);
signal inst2_yq               : std_logic_vector(15 downto 0);
signal inst2_xen              : std_logic;

--inst3
signal inst3_yi               : std_logic_vector(24 downto 0);
signal inst3_yq               : std_logic_vector(24 downto 0);
signal inst3_xen              : std_logic;
signal inst3_sdout            : std_logic;

--inst4
signal inst4_yi               : std_logic_vector(24 downto 0);
signal inst4_yq               : std_logic_vector(24 downto 0);
signal inst4_xen              : std_logic;
signal inst4_sdout            : std_logic;

--inst5
signal inst5_q                : std_logic_vector(31 downto 0);
signal inst5_rdempty          : std_logic;
signal inst5_wrfull           : std_logic;

--inst6
signal inst6_q                : std_logic_vector(31 downto 0);
signal inst6_rdempty          : std_logic;
signal inst6_wrfull           : std_logic;

--inst7
signal inst7_ypi_o            : std_logic_vector(15 downto 0);
signal inst7_ypq_o            : std_logic_vector(15 downto 0);

--inst8
signal inst8_ypi_o            : std_logic_vector(15 downto 0);
signal inst8_ypq_o            : std_logic_vector(15 downto 0);


begin
   
   ai_in <= diq_in(16*1-1 downto 16*0);
   aq_in <= diq_in(16*2-1 downto 16*1);
   bi_in <= diq_in(16*3-1 downto 16*2);
   bq_in <= diq_in(16*4-1 downto 16*3);
   
-- ----------------------------------------------------------------------------
-- SPI memory
-- ----------------------------------------------------------------------------   
   inst0_adpdcfg : entity work.adpdcfg
   port map(
      -- Address and location of this module
      -- Will be hard wired at the top level
      maddress       => "0000000010",
      mimo_en        => '1',
   
      -- Serial port IOs
      sdin           => sdin,          -- Data in
      sclk           => sclk,          -- Data clock
      sen            => sen,           -- Enable signal (active low)
      sdout          => inst0_sdout,   -- Data out
   
      lreset         => mem_reset_n,   -- Logic reset signal, resets logic cells only  (use only one reset)
      mreset         => mem_reset_n,   -- Memory reset signal, resets configuration memory only (use only one reset)
      
      oen            => open,
      stateo         => open,          
      
      --ADPD
      ADPD_BUFF_SIZE    => open, 
      ADPD_CONT_CAP_EN  => open, 
      ADPD_CAP_EN       => open, 
      
      adpd_config0      => open, 
      adpd_config1      => open, 
      adpd_data         => open, 
      
      cfr0_bypass       => inst0_cfr0_bypass,
      cfr1_bypass       => inst0_cfr1_bypass,
      cfr0_sleep        => inst0_cfr0_sleep,
      cfr1_sleep        => inst0_cfr1_sleep,
      cfr0_half_order   => inst0_cfr0_half_order,
      cfr1_half_order   => inst0_cfr1_half_order,
      cfr0_threshold    => inst0_cfr0_threshold,
      cfr1_threshold    => inst0_cfr1_threshold,
   
      hb0_bypass        => open,
      hb1_bypass        => open,
      isinc0_bypass     => open,
      isinc1_bypass     => open,
      
      select_DACs       => open,
      select_chA        => open,
      
      space_cnt_rst     => open,
      space_address_msb => open,
      
      gain_cfr_A        => inst0_gain_cfr_A,
      gain_cfr_B        => inst0_gain_cfr_B,
      gain_cfr0_bypass  => inst0_gain_cfr0_bypass,
      gain_cfr1_bypass  => inst0_gain_cfr1_bypass,
      
      temp              => inst0_temp,
      hb2_bypass        => open,
      delay3            => open,
      gfir0_byp         => inst0_gfir0_byp,
      gfir1_byp         => inst0_gfir1_byp
      
   );
   
 
-- ----------------------------------------------------------------------------
-- CH A filter
-- ----------------------------------------------------------------------------   
   inst3_gfirhf16mod_bj : entity work.gfirhf16mod_bj 
   port map (  -- RED_FILTRA/2 CLK PERIOD DELAY
      sleep       => inst0_cfr0_sleep,
      clk         => clk,
      reset       => reset_n,
      bypass      => inst0_gfir0_byp,
      xi          => ai_in,
      xq          => aq_in,
      n           => "00000011",
      l           => "111",
      maddressf0  => "000001001", -- donji red
      maddressf1  => "000001010", -- feedback
      mimo_en     => '1',
      sdin        => sdin,
      sclk        => sclk,
      sen         => sen OR (not from_memcfg.mac(0)),
      sdout       => inst3_sdout,
      oen         => open,
      yi          => inst3_yi,
      yq          => inst3_yq,
      xen         => inst3_xen
      );
      
      
   inst5_fifo_inst : entity work.fifo_inst
   generic map(
      dev_family     => "Cyclone V",
      wrwidth        => 32,
      wrusedw_witdth => 9, 
      rdwidth        => 32,
      rdusedw_width  => 9,
      show_ahead     => "OFF"
  ) 
   port map(
      reset_n  => reset_n,
      wrclk    => clk,
      wrreq    => inst3_xen AND (NOT inst5_wrfull),
      data     => inst3_yq(24 downto 9) & inst3_yi(24 downto 9),
      wrfull   => inst5_wrfull,
      wrempty  => open,
      wrusedw  => open,
      rdclk    => clk,
      rdreq    => inst1_xen AND (NOT inst5_rdempty),
      q        => inst5_q,
      rdempty  => inst5_rdempty,
      rdusedw  => open  
   );
-- ----------------------------------------------------------------------------
-- CH A CFR
-- ----------------------------------------------------------------------------
inst1_cfir_bj : entity work.cfir_bj
   generic map(
      nd => 20
      )
   port map(
      -- Clock related inputs
      sleep       => inst0_cfr0_sleep, -- Sleep signal
      clk         => clk,     -- Clock
      reset       => reset_n, -- Reset
      bypass      => inst0_cfr0_bypass, --  Bypass
   
      -- Data input signals
      -- xi          => inst5_q(15 downto 0),
      -- xq          => inst5_q(31 downto 16),
      xi          => inst3_yi(24 downto 9),
      xq          => inst3_yq(24 downto 9),
      -- Filter configuration
      half_order  => '0' & inst0_cfr0_half_order(7 downto 1),
      threshold   => inst0_cfr0_threshold,
   
      n           => "00000011", -- Clock division ratio = n+1
      l           => "111", -- Number of taps is 5*(l+1)
      
      -- Coeffitient memory interface
      maddressf0  => "000000111",
      maddressf1  => "000001000",
   
      mimo_en     => '1',
      sdin        => sdin, -- Data in
      sclk        => sclk, -- Data clock
      sen         => sen OR (not from_memcfg.mac(0)),  -- Enable signal (active low)
      sdout       => inst1_sdout, -- Data out
      oen         => open, 
      
      -- Filter output signals
      yi          => inst1_yi,
      yq          => inst1_yq,
      xen         => inst1_xen,
      speedup     => inst0_temp(0)
   );
   
-- ----------------------------------------------------------------------------
-- CH A Gain 
-- ----------------------------------------------------------------------------   
   inst7_iqim_gain_corr : entity work.iqim_gain_corr
   port map (
      clk      => clk,
      reset_n  => reset_n,
      en       => inst1_xen,
      bypass   => inst0_gain_cfr0_bypass,

      ypi      => inst1_yi,
      ypq      => inst1_yq,

      gain_ch  => inst0_gain_cfr_A,

      ypi_o    => inst7_ypi_o,
      ypq_o    => inst7_ypq_o 
   );  
   
   -- delayed version of inst1_xen
   proc_xen_reg : process(clk, reset_n)
   begin
      if reset_n = '0' then 
         inst1_xen_reg0 <= '0';
         inst1_xen_reg1 <= '0';
      elsif (clk'event AND clk='1') then 
         inst1_xen_reg0 <= inst1_xen;
         inst1_xen_reg1 <= inst1_xen_reg0;
      end if;
   end process;

   
-- ----------------------------------------------------------------------------
-- CH B filter
-- ---------------------------------------------------------------------------- 
   inst4_gfirhf16mod_bj : entity work.gfirhf16mod_bj 
   port map (  -- RED_FILTRA/2 CLK PERIOD DELAY
      sleep       => inst0_cfr1_sleep,
      clk         => clk,
      reset       => reset_n,
      bypass      => inst0_gfir1_byp,
      xi          => bi_in,
      xq          => bq_in,
      n           => "00000011",
      l           => "111",
      maddressf0  => "000001001", -- donji red
      maddressf1  => "000001010", -- feedback
      mimo_en     => '1',
      sdin        => sdin,
      sclk        => sclk,
      sen         => sen OR (not from_memcfg.mac(1)),
      sdout       => inst4_sdout,
      oen         => open,
      yi          => inst4_yi,
      yq          => inst4_yq,
      xen         => inst4_xen
      );
      
   inst6_fifo_inst : entity work.fifo_inst
   generic map(
      dev_family     => "Cyclone V",
      wrwidth        => 32,
      wrusedw_witdth => 9, 
      rdwidth        => 32,
      rdusedw_width  => 9,
      show_ahead     => "OFF"
  ) 
   port map(
      reset_n  => reset_n,
      wrclk    => clk,
      wrreq    => inst4_xen AND (NOT inst6_wrfull),
      data     => inst4_yq(24 downto 9) & inst4_yi(24 downto 9),
      wrfull   => inst6_wrfull,
      wrempty  => open,
      wrusedw  => open,
      rdclk    => clk,
      rdreq    => inst2_xen AND (NOT inst6_rdempty),
      q        => inst6_q,
      rdempty  => inst6_rdempty,
      rdusedw  => open  
   );   
-- ----------------------------------------------------------------------------
-- CH B CFR
-- ----------------------------------------------------------------------------
inst2_cfir_bj : entity work.cfir_bj
   generic map(
      nd => 20
      )
   port map(
      -- Clock related inputs
      sleep       => inst0_cfr1_sleep, -- Sleep signal
      clk         => clk,     -- Clock
      reset       => reset_n, -- Reset
      bypass      => inst0_cfr1_bypass, --  Bypass
   
      -- Data input signals
--      xi          => inst6_q(15 downto 0),
--      xq          => inst6_q(31 downto 16),
      xi          => inst4_yi(24 downto 9),
      xq          => inst4_yq(24 downto 9),
   
      -- Filter configuration
      half_order  => '0' & inst0_cfr1_half_order(7 downto 1),
      threshold   => inst0_cfr1_threshold,
   
      n           => "00000011", -- Clock division ratio = n+1
      l           => "111", -- Number of taps is 5*(l+1)
      
      -- Coeffitient memory interface
      maddressf0  => "000000111",
      maddressf1  => "000001000",
   
      mimo_en     => '1',
      sdin        => sdin, -- Data in
      sclk        => sclk, -- Data clock
      sen         => sen OR (not from_memcfg.mac(1)),  -- Enable signal (active low)
      sdout       => inst2_sdout, -- Data out
      oen         => open, 
      
      -- Filter output signals
      yi          => inst2_yi,
      yq          => inst2_yq,
      xen         => inst2_xen,
      speedup     => inst0_temp(0)
   );  
   
-- ----------------------------------------------------------------------------
-- CH B Gain 
-- ----------------------------------------------------------------------------   
   inst8_iqim_gain_corr : entity work.iqim_gain_corr
   port map (
      clk      => clk,
      reset_n  => reset_n,
      en       => inst2_xen,
      bypass   => inst0_gain_cfr1_bypass,

      ypi      => inst2_yi,
      ypq      => inst2_yq,

      gain_ch  => inst0_gain_cfr_B,

      ypi_o    => inst8_ypi_o,
      ypq_o    => inst8_ypq_o  
);    
-- ----------------------------------------------------------------------------
-- Output ports
-- ----------------------------------------------------------------------------
sdout       <= inst0_sdout OR inst1_sdout OR inst2_sdout OR inst3_sdout OR inst4_sdout;
data_req    <= inst1_xen;
-- data_valid is delayed version of inst1_xen, because gain adds one 2 cycle delay for data
data_valid  <= inst1_xen_reg1;

diq_out     <= inst8_ypq_o & inst8_ypi_o & inst7_ypq_o & inst7_ypi_o;

  
end arch;   


