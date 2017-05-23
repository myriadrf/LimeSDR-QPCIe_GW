----------------------------------------------------------------------------
-- FILE: rx_pll_top_cyc5.vhd
-- DESCRIPTION:top file for rx_pll modules
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

----------------------------------------------------------------------------
-- Entity declaration
----------------------------------------------------------------------------
entity rx_pll_top_cyc5 is
   generic(
      intended_device_family  : STRING    := "Cyclone V GX";
      drct_c0_ndly            : integer   := 1;
      drct_c1_ndly            : integer   := 2
   );
   port (
   --PLL input 
   pll_inclk         : in std_logic;
   pll_areset        : in std_logic;
   inv_c0            : in std_logic;
   c0                : out std_logic; --muxed clock output
   c1                : out std_logic; --muxed clock output
   pll_locked        : out std_logic;
   --Bypass control
   clk_ena           : in std_logic_vector(1 downto 0); --clock output enable
   drct_clk_en       : in std_logic_vector(1 downto 0); --1- Direct clk, 0 - PLL clocks 
   --Reconfiguration ports
   rcnfg_to_pll      : in std_logic_vector(63 downto 0);
   rcnfg_from_pll    : out std_logic_vector(63 downto 0)
   
   );
end rx_pll_top_cyc5;

----------------------------------------------------------------------------
-- Architecture
----------------------------------------------------------------------------
architecture arch of rx_pll_top_cyc5 is
--declare signals,  components here

signal pll_areset_n              : std_logic;
signal pll_inclk_global          : std_logic;

signal c0_global                 : std_logic;
signal c1_global                 : std_logic;
      
signal rcnfig_en_sync            : std_logic;
signal rcnfig_data_sync          : std_logic_vector(143 downto 0);

signal dynps_en_sync             : std_logic;
signal dynps_dir_sync            : std_logic;
signal dynps_cnt_sel_sync        : std_logic_vector(2 downto 0);
signal dynps_phase_sync          : std_logic_vector(9 downto 0);
signal rcnfig_en_sync_scanclk    : std_logic;

      
--inst0     
signal inst0_pll_inclk_global    : std_logic;
--inst1
signal inst1_outclk_0            : std_logic;
signal inst1_outclk_1            : std_logic;
signal inst1_locked              : std_logic;
-- inst2
signal inst2_c0_pol_h            : std_logic_vector(0 downto 0);
signal inst2_c0_pol_l            : std_logic_vector(0 downto 0);
signal inst2_dataout             : std_logic_vector(0 downto 0);

signal drct_c0_dly_chain         : std_logic_vector(drct_c0_ndly-1 downto 0);
signal drct_c1_dly_chain         : std_logic_vector(drct_c1_ndly-1 downto 0);


signal c0_mux, c1_mux            : std_logic;
signal locked_mux                : std_logic;




COMPONENT clkctrl_c5 is
	port (
		inclk  : in  std_logic := '0'; --  altclkctrl_input.inclk
		ena    : in  std_logic := '0'; --                  .ena
		outclk : out std_logic         -- altclkctrl_output.outclk
	);
end COMPONENT;


COMPONENT rx_pll is
	port (
		refclk            : in  std_logic                     := '0';             --            refclk.clk
		rst               : in  std_logic                     := '0';             --             reset.reset
		outclk_0          : out std_logic;                                        --           outclk0.clk
		outclk_1          : out std_logic;                                        --           outclk1.clk
		locked            : out std_logic;                                        --            locked.export
		reconfig_to_pll   : in  std_logic_vector(63 downto 0) := (others => '0'); --   reconfig_to_pll.reconfig_to_pll
		reconfig_from_pll : out std_logic_vector(63 downto 0)                     -- reconfig_from_pll.reconfig_from_pll
	);
end COMPONENT;

begin
   
pll_areset_n   <= not pll_areset;
 
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
rx_pll_inst1 : rx_pll
	port map(
		refclk            => pll_inclk_global, 
		rst               => pll_areset,
		outclk_0          => inst1_outclk_0,
		outclk_1          => inst1_outclk_1,
		locked            => inst1_locked,
		reconfig_to_pll   => rcnfg_to_pll,
		reconfig_from_pll => rcnfg_from_pll
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
            
--c0_mux <=   inst1_outclk_0 when drct_clk_en(0)='0' else 
--            pll_inclk_global;            
            
            

-- ----------------------------------------------------------------------------
-- c1 clk MUX
-- ----------------------------------------------------------------------------
--c1_mux <=   inst1_outclk_1 when drct_clk_en(1)='0' else 
--            drct_c1_dly_chain(drct_c1_ndly-1);
            
--c1_mux <=   inst1_outclk_1 when drct_clk_en(1)='0' else 
--            pll_inclk_global;
            
            
            


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

--c0_global <= c0_mux;

--c0_global <= inst1_outclk_0;
  
--clkctrl_c5_inst4 : clkctrl_c5
--	port map(
--		inclk  => c1_mux,
--		ena    => clk_ena(1),
--		outclk => c1_global
--	);

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





