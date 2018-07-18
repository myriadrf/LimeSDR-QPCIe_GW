-- ----------------------------------------------------------------------------
-- FILE:          cfg_top.vhd
-- DESCRIPTION:   Wrapper file for SPI configuration memories
-- DATE:          11:09 AM Friday, May 11, 2018
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
--NOTES:
-- ----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fpgacfg_pkg.all;
use work.pllcfg_pkg.all;
use work.tstcfg_pkg.all;
use work.periphcfg_pkg.all;
use work.tamercfg_pkg.all;
use work.gnsscfg_pkg.all;
use work.memcfg_pkg.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity cfg_top is
   generic(
      -- CFG_START_ADDR has to be multiple of 32, because there are 32 addresses
      FPGACFG_START_ADDR   : integer := 0;
      PLLCFG_START_ADDR    : integer := 32;
      TSTCFG_START_ADDR    : integer := 64;
      PERIPHCFG_START_ADDR : integer := 192;
      TAMERCFG_START_ADDR  : integer := 224;
      GNSSCFG_START_ADDR   : integer := 256;
      MEMCFG_START_ADDR    : integer := 65504
      );
   port (
      -- Serial port IOs
      sdin                 : in  std_logic;   -- Data in
      sclk                 : in  std_logic;   -- Data clock
      sen                  : in  std_logic;   -- Enable signal (active low)
      sdout                : out std_logic;  -- Data out      
      -- Signals coming from the pins or top level serial interface
      lreset               : in  std_logic;   -- Logic reset signal, resets logic cells only  (use only one reset)
      mreset               : in  std_logic;   -- Memory reset signal, resets configuration memory only (use only one reset)
      to_fpgacfg_0         : in  t_TO_FPGACFG;
      from_fpgacfg_0       : out t_FROM_FPGACFG;
      to_fpgacfg_1         : in  t_TO_FPGACFG;
      from_fpgacfg_1       : out t_FROM_FPGACFG;
      to_fpgacfg_2         : in  t_TO_FPGACFG;
      from_fpgacfg_2       : out t_FROM_FPGACFG;
      to_pllcfg            : in  t_TO_PLLCFG;
      from_pllcfg          : out t_FROM_PLLCFG;
      to_tstcfg            : in  t_TO_TSTCFG;
      to_tstcfg_from_rxtx  : in  t_TO_TSTCFG_FROM_RXTX;
      from_tstcfg          : out t_FROM_TSTCFG;
      to_periphcfg         : in  t_TO_PERIPHCFG;
      from_periphcfg       : out t_FROM_PERIPHCFG;
      to_tamercfg          : in  t_TO_TAMERCFG;
      from_tamercfg        : out t_FROM_TAMERCFG;
      to_gnsscfg           : in  t_TO_GNSSCFG;
      from_gnsscfg         : out t_FROM_GNSSCFG
   );
end cfg_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of cfg_top is
--declare signals,  components here
--inst0
signal inst0_sen     : std_logic; 
signal inst0_sdout   : std_logic;

--inst1
signal inst1_sen     : std_logic;
signal inst1_sdout   : std_logic;

--inst2
signal inst2_sen     : std_logic;
signal inst2_sdout   : std_logic;

--inst3
signal inst3_sdoutA  : std_logic;

--inst4
signal inst4_sdout   : std_logic;

--inst5
signal inst5_sdout   : std_logic;

--inst6
signal inst6_sdout   : std_logic;

--inst7
signal inst7_sdout   : std_logic;

--inst8
signal inst8_sdout         : std_logic;
signal inst8_to_memcfg     : t_TO_MEMCFG;
signal inst8_from_memcfg   : t_FROM_MEMCFG;

begin

-- ----------------------------------------------------------------------------
-- fpgacfg instance
-- ----------------------------------------------------------------------------
   inst0_sen <= sen when inst8_from_memcfg.mac(0)='1' else '1';

      
   inst0_fpgacfg : entity work.fpgacfg
   port map(
      -- Address and location of this module
      -- Will be hard wired at the top level
      maddress    => std_logic_vector(to_unsigned(FPGACFG_START_ADDR/32,10)),
      mimo_en     => '1',   
      -- Serial port IOs
      sdin        => sdin,
      sclk        => sclk,
      sen         => inst0_sen,
      sdout       => inst0_sdout,  
      -- Signals coming from the pins or top level serial interface
      lreset      => lreset,   -- Logic reset signal, resets logic cells only  (use only one reset)
      mreset      => mreset,   -- Memory reset signal, resets configuration memory only (use only one reset)      
      oen         => open,
      stateo      => open,      
      to_fpgacfg  => to_fpgacfg_0,
      from_fpgacfg=> from_fpgacfg_0
   );
   
   
   inst1_sen <= sen when inst8_from_memcfg.mac(1)='1' else '1';
   
   inst1_fpgacfg : entity work.fpgacfg
   port map(
      -- Address and location of this module
      -- Will be hard wired at the top level
      maddress    => std_logic_vector(to_unsigned(FPGACFG_START_ADDR/32,10)),
      mimo_en     => '1',   
      -- Serial port IOs
      sdin        => sdin,
      sclk        => sclk,
      sen         => inst1_sen,
      sdout       => inst1_sdout,  
      -- Signals coming from the pins or top level serial interface
      lreset      => lreset,   -- Logic reset signal, resets logic cells only  (use only one reset)
      mreset      => mreset,   -- Memory reset signal, resets configuration memory only (use only one reset)      
      oen         => open,
      stateo      => open,      
      to_fpgacfg  => to_fpgacfg_1,
      from_fpgacfg=> from_fpgacfg_1
   );
   
   inst2_sen <= sen when inst8_from_memcfg.mac(2)='1' else '1';
   
   inst2_fpgacfg : entity work.fpgacfg
   port map(
      -- Address and location of this module
      -- Will be hard wired at the top level
      maddress    => std_logic_vector(to_unsigned(FPGACFG_START_ADDR/32,10)),
      mimo_en     => '1',   
      -- Serial port IOs
      sdin        => sdin,
      sclk        => sclk,
      sen         => inst2_sen,
      sdout       => inst2_sdout,  
      -- Signals coming from the pins or top level serial interface
      lreset      => lreset,   -- Logic reset signal, resets logic cells only  (use only one reset)
      mreset      => mreset,   -- Memory reset signal, resets configuration memory only (use only one reset)      
      oen         => open,
      stateo      => open,      
      to_fpgacfg  => to_fpgacfg_2,
      from_fpgacfg=> from_fpgacfg_2
   );
   
-- ----------------------------------------------------------------------------
-- pllcfg instance
-- ----------------------------------------------------------------------------  
   inst3_pllcfg : entity work.pllcfg
   port map(
      -- Address and location of this module
      -- Will be hard wired at the top level
      maddress       => std_logic_vector(to_unsigned(PLLCFG_START_ADDR/32,10)),
      mimo_en        => '1',      
      -- Serial port A IOs
      sdinA          => sdin,
      sclkA          => sclk,
      senA           => sen,
      sdoutA         => inst3_sdoutA,    
      oenA           => open,     
      -- Serial port B IOs
      sdinB          => '0',
      sclkB          => '0',
      senB           => '1',
      sdoutB         => open,    
      oenB           => open,       
      -- Signals coming from the pins or top level serial interface
      lreset         => lreset, -- Logic reset signal, resets logic cells only  (use only one reset)
      mreset         => mreset,-- Memory reset signal, resets configuration memory only (use only one reset)      
      to_pllcfg      => to_pllcfg,
      from_pllcfg    => from_pllcfg
   );
   
-- ----------------------------------------------------------------------------
-- tstcfg instance
-- ----------------------------------------------------------------------------    
   inst4_tstcfg : entity work.tstcfg
   port map(
      -- Address and location of this module
      -- Will be hard wired at the top level
      maddress             => std_logic_vector(to_unsigned(TSTCFG_START_ADDR/32,10)),
      mimo_en              => '1',   
      -- Serial port IOs
      sdin                 => sdin,
      sclk                 => sclk,
      sen                  => sen,
      sdout                => inst4_sdout,  
      -- Signals coming from the pins or top level serial interface
      lreset               => lreset,   -- Logic reset signal, resets logic cells only  (use only one reset)
      mreset               => mreset,   -- Memory reset signal, resets configuration memory only (use only one reset)      
      oen                  => open,
      stateo               => open,    
      to_tstcfg            => to_tstcfg,
      to_tstcfg_from_rxtx  => to_tstcfg_from_rxtx,
      from_tstcfg          => from_tstcfg
   );

   
-- ----------------------------------------------------------------------------
-- tstcfg instance
-- ----------------------------------------------------------------------------    
   inst5_periphcfg : entity work.periphcfg
   port map(
      -- Address and location of this module
      -- Will be hard wired at the top level
      maddress    => std_logic_vector(to_unsigned(PERIPHCFG_START_ADDR/32,10)),
      mimo_en     => '1',   
      -- Serial port IOs
      sdin        => sdin,
      sclk        => sclk,
      sen         => sen,
      sdout       => inst5_sdout,  
      -- Signals coming from the pins or top level serial interface
      lreset      => lreset,   -- Logic reset signal, resets logic cells only  (use only one reset)
      mreset      => mreset,   -- Memory reset signal, resets configuration memory only (use only one reset)      
      oen         => open,
      stateo      => open,    
      to_periphcfg   => to_periphcfg,
      from_periphcfg => from_periphcfg
   );
   
-- ----------------------------------------------------------------------------
-- tamercfg instance
-- ----------------------------------------------------------------------------    
   inst6_tamercfg : entity work.tamercfg
   port map(
      -- Address and location of this module
      -- Will be hard wired at the top level
      maddress    => std_logic_vector(to_unsigned(TAMERCFG_START_ADDR/32,10)),
      mimo_en     => '1',   
      -- Serial port IOs
      sdin        => sdin,
      sclk        => sclk,
      sen         => sen,
      sdout       => inst6_sdout,  
      -- Signals coming from the pins or top level serial interface
      lreset      => lreset,   -- Logic reset signal, resets logic cells only  (use only one reset)
      mreset      => mreset,   -- Memory reset signal, resets configuration memory only (use only one reset)      
      oen         => open,
      stateo      => open,    
      to_tamercfg    => to_tamercfg,
      from_tamercfg  => from_tamercfg
   );
   
-- ----------------------------------------------------------------------------
-- gnsscfg instance
-- ----------------------------------------------------------------------------    
   inst7_gnsscfg : entity work.gnsscfg
   port map(
      -- Address and location of this module
      -- Will be hard wired at the top level
      maddress    => std_logic_vector(to_unsigned(GNSSCFG_START_ADDR/32,10)),
      mimo_en     => '1',   
      -- Serial port IOs
      sdin        => sdin,
      sclk        => sclk,
      sen         => sen,
      sdout       => inst7_sdout,  
      -- Signals coming from the pins or top level serial interface
      lreset      => lreset,   -- Logic reset signal, resets logic cells only  (use only one reset)
      mreset      => mreset,   -- Memory reset signal, resets configuration memory only (use only one reset)      
      oen         => open,
      stateo      => open,    
      to_gnsscfg     => to_gnsscfg,
      from_gnsscfg   => from_gnsscfg
   );
   
-- ----------------------------------------------------------------------------
-- memcfg instance
-- ----------------------------------------------------------------------------     
   inst8_memcfg : entity work.memcfg
   port map(
      -- Address and location of this module
      -- Will be hard wired at the top level
      maddress    => std_logic_vector(to_unsigned(MEMCFG_START_ADDR/32,10)),
      mimo_en     => '1',   
      -- Serial port IOs
      sdin        => sdin,
      sclk        => sclk,
      sen         => sen,
      sdout       => inst8_sdout,  
      -- Signals coming from the pins or top level serial interface
      lreset      => lreset,   -- Logic reset signal, resets logic cells only  (use only one reset)
      mreset      => mreset,   -- Memory reset signal, resets configuration memory only (use only one reset)      
      oen         => open,
      stateo      => open,      
      to_memcfg   => inst8_to_memcfg,
      from_memcfg => inst8_from_memcfg
   );
-- ----------------------------------------------------------------------------
-- Output ports
-- ----------------------------------------------------------------------------    
   sdout <= inst0_sdout OR inst1_sdout OR inst3_sdoutA OR inst4_sdout OR 
            inst5_sdout OR inst6_sdout OR inst7_sdout OR inst8_sdout;
  
end arch;   


