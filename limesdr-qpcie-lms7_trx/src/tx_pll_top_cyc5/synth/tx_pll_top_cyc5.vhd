----------------------------------------------------------------------------
-- FILE: tx_pll_top_cyc5.vhd
-- DESCRIPTION:top file for tx_pll modules
-- DATE:Jan 27, 2016
-- AUTHOR(s):Lime Microsystems
-- REVISIONS:
----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

LIBRARY altera_mf;
USE altera_mf.all;
USE altera_mf.altera_mf_components.all;
library altera; 
use altera.altera_primitives_components.all;

----------------------------------------------------------------------------
-- Entity declaration
----------------------------------------------------------------------------
entity tx_pll_top_cyc5 is
   generic(
      intended_device_family  : STRING    := "Cyclone V GX";
      drct_c0_ndly            : integer   := 1;
      drct_c1_ndly            : integer   := 2;
      cntsel_width            : integer   := 5
   );
   port (
   free_running_clk  : in std_logic;
   --PLL input 
   pll_inclk         : in std_logic;
   pll_areset        : in std_logic;
   pll_logic_reset_n : in std_logic;
   inv_c0            : in std_logic;
   c0                : out std_logic; --muxed clock output
   c1                : out std_logic; --muxed clock output
   pll_locked        : out std_logic;
   --Bypass control
   clk_ena           : in std_logic_vector(1 downto 0); --clock output enable
   drct_clk_en       : in std_logic_vector(1 downto 0); --1- Direct clk, 0 - PLL clocks 
   --Reconfiguration ports
   rcnfg_to_pll      : in std_logic_vector(63 downto 0);
   rcnfg_from_pll    : out std_logic_vector(63 downto 0);
   --Dynamic phase shift ports
   dynps_mode        : in std_logic; -- 0 - manual, 1 - auto
   dynps_areset_n    : in std_logic;
   dynps_en          : in std_logic;
   dynps_tst         : in std_logic;
   dynps_dir         : in std_logic;
   dynps_cnt_sel     : in std_logic_vector(cntsel_width-1 downto 0);
   -- max phase steps in auto mode, phase steps to shift in manual mode 
   dynps_phase       : in std_logic_vector(9 downto 0);
   dynps_step_size   : in std_logic_vector(9 downto 0);
   dynps_busy        : out std_logic;
   dynps_done        : out std_logic;
   dynps_status      : out std_logic;
   --signals from sample compare module (required for automatic phase searching)
   smpl_cmp_en       : out std_logic;
   smpl_cmp_done     : in std_logic;
   smpl_cmp_error    : in std_logic
   
   );
end tx_pll_top_cyc5;

----------------------------------------------------------------------------
-- Architecture
----------------------------------------------------------------------------
architecture arch of tx_pll_top_cyc5 is
--declare signals,  components here

signal pll_areset_n              : std_logic;
signal pll_inclk_global          : std_logic;

signal c0_global                 : std_logic;
signal c1_global                 : std_logic;
  
signal rcnfig_en_sync            : std_logic;
signal rcnfig_data_sync          : std_logic_vector(143 downto 0);

signal dynps_areset_n_sync       : std_logic;
signal dynps_en_sync             : std_logic;
signal dynps_dir_sync            : std_logic;
signal dynps_cnt_sel_sync        : std_logic_vector(cntsel_width-1 downto 0);
signal dynps_phase_sync          : std_logic_vector(9 downto 0);
signal dynps_step_size_sync      : std_logic_vector(9 downto 0);
signal rcnfig_en_sync_scanclk    : std_logic;
signal dynps_mode_sync           : std_logic;
signal dynps_tst_sync            : std_logic;

signal smpl_cmp_done_sync        : std_logic; 
signal smpl_cmp_error_sync       : std_logic;
      
--inst0     
signal inst0_pll_inclk_global    : std_logic;
--inst1
signal inst1_outclk_0            : std_logic;
signal inst1_outclk_1            : std_logic;
signal inst1_locked              : std_logic;
signal inst1_locked_scanclk      : std_logic;
signal inst1_phase_done          : std_logic;
-- inst2
signal inst2_c0_pol_h            : std_logic_vector(0 downto 0);
signal inst2_c0_pol_l            : std_logic_vector(0 downto 0);
signal inst2_dataout             : std_logic_vector(0 downto 0);

signal drct_c0_dly_chain         : std_logic_vector(drct_c0_ndly-1 downto 0);
signal drct_c1_dly_chain         : std_logic_vector(drct_c1_ndly-1 downto 0);

--inst5
signal inst5_ps_busy                : std_logic;         
signal inst5_ps_done                : std_logic; 
signal inst5_ps_status              : std_logic; 
signal inst5_pll_phasecounterselect : std_logic_vector(cntsel_width-1 downto 0); 
signal inst5_pll_phaseupdown        : std_logic; 
signal inst5_pll_phasestep          : std_logic; 
signal inst5_pll_reset_req          : std_logic; 

signal c0_mux, c1_mux            : std_logic;
signal locked_mux                : std_logic;

COMPONENT clkctrl_c5 is
	port (
		inclk  : in  std_logic := '0'; --  altclkctrl_input.inclk
		ena    : in  std_logic := '0'; --                  .ena
		outclk : out std_logic         -- altclkctrl_output.outclk
	);
end COMPONENT;


COMPONENT tx_pll is
	port (
		refclk            : in  std_logic                     := '0';             --            refclk.clk
		rst               : in  std_logic                     := '0';             --             reset.reset
		outclk_0          : out std_logic;                                        --           outclk0.clk
		outclk_1          : out std_logic;                                        --           outclk1.clk
		locked            : out std_logic;                                        --            locked.export
		phase_en          : in  std_logic                     := '0';             --          phase_en.phase_en
		updn              : in  std_logic                     := '0';             --              updn.updn
		cntsel            : in  std_logic_vector(4 downto 0)  := (others => '0'); --            cntsel.cntsel
		phase_done        : out std_logic;                                        --        phase_done.phase_done
		reconfig_to_pll   : in  std_logic_vector(63 downto 0) := (others => '0'); --   reconfig_to_pll.reconfig_to_pll
		reconfig_from_pll : out std_logic_vector(63 downto 0)                     -- reconfig_from_pll.reconfig_from_pll
	);
end COMPONENT;

component lpm_mux1 IS
	PORT
	(
		data0		: IN STD_LOGIC ;
		data1		: IN STD_LOGIC ;
		sel		: IN STD_LOGIC ;
		result		: OUT STD_LOGIC 
	);
END component;

begin
   
pll_areset_n   <= not pll_areset;

----------------------------------------------------------------------------
-- Synchronization registers
----------------------------------------------------------------------------  
 sync_reg0 : entity work.sync_reg 
 port map(free_running_clk, pll_logic_reset_n, dynps_en, dynps_en_sync); 
 
 sync_reg1 : entity work.sync_reg 
 port map(free_running_clk, pll_logic_reset_n, dynps_dir, dynps_dir_sync); 
 
 sync_reg2 : entity work.sync_reg 
 port map(free_running_clk, pll_logic_reset_n, dynps_mode, dynps_mode_sync);
 
 sync_reg3 : entity work.sync_reg 
 port map(free_running_clk, pll_logic_reset_n, smpl_cmp_done, smpl_cmp_done_sync);

 sync_reg4 : entity work.sync_reg 
 port map(free_running_clk, pll_logic_reset_n, smpl_cmp_error, smpl_cmp_error_sync);
 
 sync_reg5 : entity work.sync_reg 
 port map(free_running_clk, pll_logic_reset_n, dynps_areset_n, dynps_areset_n_sync);
 
 sync_reg6 : entity work.sync_reg 
 port map(free_running_clk, pll_logic_reset_n, dynps_tst, dynps_tst_sync);
 
 sync_reg7 : entity work.sync_reg 
 port map(free_running_clk, pll_logic_reset_n, inst1_locked, inst1_locked_scanclk);
 
 
 bus_sync_reg0 : entity work.bus_sync_reg
 generic map (cntsel_width) 
 port map(free_running_clk, pll_logic_reset_n, dynps_cnt_sel, dynps_cnt_sel_sync);
 
 bus_sync_reg1 : entity work.bus_sync_reg
 generic map (10) 
 port map(free_running_clk, pll_logic_reset_n, dynps_phase, dynps_phase_sync);
 
 bus_sync_reg2 : entity work.bus_sync_reg
 generic map (10) 
 port map(free_running_clk, pll_logic_reset_n, dynps_step_size, dynps_step_size_sync);
 
----------------------------------------------------------------------------
-- Global clock controll block
----------------------------------------------------------------------------
clkctrl_c5_inst0 : clkctrl_c5
	port map(
		inclk  => pll_inclk,
		ena    => '1',
		outclk => pll_inclk_global
	);
 
----------------------------------------------------------------------------
-- PLL instance
---------------------------------------------------------------------------- 
tx_pll_inst1 : tx_pll
	port map(
		refclk            => pll_inclk_global, 
		rst               => pll_areset,
		outclk_0          => inst1_outclk_0,
		outclk_1          => inst1_outclk_1,
		locked            => inst1_locked,
      phase_en          => inst5_pll_phasestep,     
      updn              => inst5_pll_phaseupdown,
      cntsel            => inst5_pll_phasecounterselect,
      phase_done        => inst1_phase_done,
		reconfig_to_pll   => rcnfg_to_pll,
		reconfig_from_pll => rcnfg_from_pll
	); 
   
pll_ps_top_inst5 : entity work.pll_ps_top
   generic map(
      cntsel_width            => cntsel_width
   )
   port map(

      clk                     => free_running_clk,
      reset_n                 => dynps_areset_n_sync,
      --module control ports
      ps_en                   => dynps_en_sync,
      ps_mode                 => dynps_mode_sync,
      ps_tst                  => dynps_tst_sync,
      ps_cnt                  => dynps_cnt_sel_sync,
      ps_updwn                => dynps_dir_sync,
      ps_phase                => dynps_phase_sync,
      ps_step_size            => dynps_step_size_sync,
      ps_busy                 => inst5_ps_busy,
      ps_done                 => inst5_ps_done,
      ps_status               => inst5_ps_status,
      --pll ports
      pll_phasecounterselect  => inst5_pll_phasecounterselect,
      pll_phaseupdown         => inst5_pll_phaseupdown, 
      pll_phasestep           => inst5_pll_phasestep,        
      pll_phasedone           => inst1_phase_done,      
      pll_locked              => inst1_locked_scanclk,
      pll_reconfig            => rcnfig_en_sync_scanclk,
      pll_reset_req           => inst5_pll_reset_req,
      --sample compare module
      smpl_cmp_en             => smpl_cmp_en,
      smpl_cmp_done           => smpl_cmp_done_sync,
      smpl_cmp_error          => smpl_cmp_error_sync
            
      );
-- ----------------------------------------------------------------------------
-- c0 direct output lcell delay chain 
-- ----------------------------------------------------------------------------   
--c0_dly_instx_gen : 
--for i in 0 to drct_c0_ndly-1 generate
--   --first lcell instance
--   first : if i = 0 generate 
--   lcell0 : lcell 
--      port map (
--         a_in  => pll_inclk_global,
--         a_out => drct_c0_dly_chain(i)
--         );
--   end generate first;
--   --rest of the lcell instance
--   rest : if i > 0 generate
--   lcellx : lcell 
--      port map (
--         a_in  => drct_c0_dly_chain(i-1),
--         a_out => drct_c0_dly_chain(i)
--         );
--   end generate rest;
--end generate c0_dly_instx_gen;


-- ----------------------------------------------------------------------------
-- c1 direct output lcell delay chain 
-- ----------------------------------------------------------------------------   
--c1_dly_instx_gen : 
--for i in 0 to drct_c1_ndly-1 generate
--   --first lcell instance
--   first : if i = 0 generate 
--   lcell0 : lcell 
--      port map (
--         a_in  => pll_inclk_global,
--         a_out => drct_c1_dly_chain(i)
--         );
--   end generate first;
--   --rest of the lcell instance
--   rest : if i > 0 generate
--   lcellx : lcell 
--      port map (
--         a_in  => drct_c1_dly_chain(i-1),
--         a_out => drct_c1_dly_chain(i)
--         );
--   end generate rest;
--end generate c1_dly_instx_gen;

-- ----------------------------------------------------------------------------
-- c0 clk MUX
-- ----------------------------------------------------------------------------
--c0_mux <=   inst1_outclk_0 when drct_clk_en(0)='0' else 
--            drct_c0_dly_chain(drct_c0_ndly-1);
 
--c0_mux_inst : lpm_mux1
--	PORT MAP
--	(
--		data0		=> inst1_outclk_0,
--		data1		=> pll_inclk_global,
--		sel		=> drct_clk_en(0),
--		result	=> c0_mux
--	);
 
--c0_mux <=   inst1_outclk_0 when drct_clk_en(0)='0' else 
--            pll_inclk_global;   

-- ----------------------------------------------------------------------------
-- c1 clk MUX
-- ----------------------------------------------------------------------------
--c1_mux <=   inst1_outclk_1 when drct_clk_en(1)='0' else 
--            drct_c1_dly_chain(drct_c1_ndly-1);
            
--c1_mux <=   inst1_outclk_1 when drct_clk_en(1)='0' else 
--            pll_inclk_global;
            
            
--c1_mux_inst : lpm_mux1
--	PORT MAP
--	(
--		data0		=> inst1_outclk_1,
--		data1		=> pll_inclk_global,
--		sel		=> drct_clk_en(1),
--		result	=> c1_mux
--	);


--locked_mux <=  pll_areset_n when (drct_clk_en(0)='1' OR drct_clk_en(1)='1') else
--               inst1_locked;

inst2_c0_pol_h(0) <= not inv_c0;
inst2_c0_pol_l(0) <= inv_c0;

-- ----------------------------------------------------------------------------
-- DDR output buffer 
-- ----------------------------------------------------------------------------
ALTDDIO_OUT_component_int2 : ALTDDIO_OUT
GENERIC MAP (
   extend_oe_disable       => "OFF",
   intended_device_family  => intended_device_family,
   invert_output           => "OFF",
   lpm_hint                => "UNUSED",
   lpm_type                => "altddio_out",
   oe_reg                  => "UNREGISTERED",
   power_up_high           => "OFF",
   width                   => 1
)
PORT MAP (
   aclr           => '0',
   datain_h       => inst2_c0_pol_h,
   datain_l       => inst2_c0_pol_l,
   --outclock       => c0_global,
   outclock       => inst1_outclk_0,
   dataout        => inst2_dataout
);

-- ----------------------------------------------------------------------------
-- Clock control buffers 
-- ----------------------------------------------------------------------------
--clkctrl_c5_inst3 : clkctrl_c5
--	port map(
--		inclk  => c0_mux,
--		ena    => clk_ena(0),
--		outclk => c0_global
--	);

--	global_buff0 : GLOBAL
--	port map (
--               a_in => c0_mux, 
--               a_out => c0_global
--            );

--c0_global <= c0_mux;
--c0_global <= inst1_outclk_0;

  
--clkctrl_c5_inst4 : clkctrl_c5
--	port map(
--		inclk  => c1_mux,
--		ena    => clk_ena(1),
--		outclk => c1_global
--	);

--	global_buff1 : GLOBAL
--	port map (
--               a_in => c1_mux, 
--               a_out => c1_global
--            );

--c1_global <= c1_mux;
--c1_global <= inst1_outclk_1;

-- ----------------------------------------------------------------------------
-- To output ports
-- ----------------------------------------------------------------------------
--c0             <= inst2_dataout(0);
--c1             <= c1_global;
--pll_locked     <= locked_mux;

c0             <= inst2_dataout(0);
c1             <= inst1_outclk_1;
pll_locked     <= inst1_locked;
  
end arch;   





