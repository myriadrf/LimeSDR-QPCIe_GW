-- ----------------------------------------------------------------------------	
-- FILE: 	nios_cpu.vhd
-- DESCRIPTION:	NIOS CPU top level
-- DATE:	Mar 24, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity nios_cpu_top is
  port (
			clk100					: in std_logic;
			nrst						: out std_logic; --NOT CONNECTED			
			fpga_spi0_MISO				: in std_logic;
			fpga_spi0_MOSI      	: out std_logic;
			fpga_spi0_SCLK      	: out std_logic;
			fpga_spi0_SS_n      	: out std_logic_vector(8 downto 0);
			pllcfg_MISO      		: in  std_logic;
			pllcfg_MOSI      		: out std_logic;
			pllcfg_SCLK      		: out std_logic;
			pllcfg_SS_n      		: out std_logic;
			gpi0                	: in  std_logic_vector(7 downto 0);
			gpio0		            : out std_logic_vector(7 downto 0);
			pll_cmd					: in  std_logic_vector(3 downto 0);
			pll_stat					: out std_logic_vector(7 downto 0);
         pll_err              : out std_logic_vector(7 downto 0);
         pll_lock             : in std_logic_vector(7 downto 0);
			pll_recfg_from_pll0 	: in  std_logic_vector(63 downto 0) := (others => '0');
			pll_recfg_to_pll0   	: out std_logic_vector(63 downto 0);
			pll_recfg_from_pll1 	: in  std_logic_vector(63 downto 0) := (others => '0');
			pll_recfg_to_pll1   	: out std_logic_vector(63 downto 0);
			pll_recfg_from_pll2 	: in  std_logic_vector(63 downto 0) := (others => '0');
			pll_recfg_to_pll2   	: out std_logic_vector(63 downto 0);
			pll_recfg_from_pll3 	: in  std_logic_vector(63 downto 0) := (others => '0');
			pll_recfg_to_pll3   	: out std_logic_vector(63 downto 0);
			pll_recfg_from_pll4 	: in  std_logic_vector(63 downto 0) := (others => '0');
			pll_recfg_to_pll4   	: out std_logic_vector(63 downto 0);
			pll_recfg_from_pll5 	: in  std_logic_vector(63 downto 0) := (others => '0');
			pll_recfg_to_pll5   	: out std_logic_vector(63 downto 0);
			pll_rst					: out std_logic_vector(31 downto 0);
			exfifo_if_d				: in std_logic_vector(31 downto 0);
			exfifo_if_rd			: out std_logic;
			exfifo_if_rdempty		: in std_logic;
			exfifo_of_d				: out std_logic_vector(31 downto 0);
			exfifo_of_wr			: out std_logic;
			exfifo_of_wrfull		: in std_logic;
			exfifo_rst				: out std_logic;
			scl                  : inout std_logic;
			sda                  : inout std_logic;
         smpl_cmp_status      : in std_logic_vector(3 downto 0);
         smpl_cmp_en          : out std_logic_vector(1 downto 0)

        );
end nios_cpu_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of nios_cpu_top is
--declare signals,  components here

	signal dac_spi1_SS_int: std_logic;
	signal fpga_spi0_MOSI_int, fpga_spi0_SCLK_int: std_logic;
	signal dac_spi1_MOSI_int, dac_spi1_SCLK_int: std_logic;
   
   signal smpl_cmp_status_sync   : std_logic_vector(3 downto 0);
   signal smpl_cmp_status_mux    : std_logic_vector(1 downto 0);
   signal smpl_cmp_en_int        : std_logic_vector(1 downto 0);
   
   signal pll_lock_sync          : std_logic_vector(7 downto 0);
		
	component nios_cpu is
		port (
			clk_clk                                : in    std_logic                     := 'X';             -- clk
			dac_spi1_MISO                          : in    std_logic                     := 'X';             -- MISO
			dac_spi1_MOSI                          : out   std_logic;                                        -- MOSI
			dac_spi1_SCLK                          : out   std_logic;                                        -- SCLK
			dac_spi1_SS_n                          : out   std_logic;                                        -- SS_n
			exfifo_if_d_export                     : in    std_logic_vector(31 downto 0) := (others => 'X'); -- export
			exfifo_if_rd_export                    : out   std_logic;                                        -- export
			exfifo_if_rdempty_export               : in    std_logic                     := 'X';             -- export
			exfifo_of_d_export                     : out   std_logic_vector(31 downto 0);                    -- export
			exfifo_of_wr_export                    : out   std_logic;                                        -- export
			exfifo_of_wrfull_export                : in    std_logic                     := 'X';             -- export
			exfifo_rst_export                      : out   std_logic;                                        -- export
			fpga_spi0_MISO                         : in    std_logic                     := 'X';             -- MISO
			fpga_spi0_MOSI                         : out   std_logic;                                        -- MOSI
			fpga_spi0_SCLK                         : out   std_logic;                                        -- SCLK
			fpga_spi0_SS_n                         : out   std_logic_vector(7 downto 0);                     -- SS_n
			gpi0_export                            : in    std_logic_vector(7 downto 0)  := (others => 'X'); -- export
			gpio0_export                           : out   std_logic_vector(7 downto 0);                     -- export
			pll_recfg_from_pll_0_reconfig_from_pll : in    std_logic_vector(63 downto 0) := (others => 'X'); -- reconfig_from_pll
			pll_recfg_from_pll_1_reconfig_from_pll : in    std_logic_vector(63 downto 0) := (others => 'X'); -- reconfig_from_pll
			pll_recfg_from_pll_2_reconfig_from_pll : in    std_logic_vector(63 downto 0) := (others => 'X'); -- reconfig_from_pll
			pll_recfg_from_pll_3_reconfig_from_pll : in    std_logic_vector(63 downto 0) := (others => 'X'); -- reconfig_from_pll
			pll_recfg_from_pll_4_reconfig_from_pll : in    std_logic_vector(63 downto 0) := (others => 'X'); -- reconfig_from_pll
			pll_recfg_from_pll_5_reconfig_from_pll : in    std_logic_vector(63 downto 0) := (others => 'X'); -- reconfig_from_pll
			pll_recfg_to_pll_0_reconfig_to_pll     : out   std_logic_vector(63 downto 0);                    -- reconfig_to_pll
			pll_recfg_to_pll_1_reconfig_to_pll     : out   std_logic_vector(63 downto 0);                    -- reconfig_to_pll
			pll_recfg_to_pll_2_reconfig_to_pll     : out   std_logic_vector(63 downto 0);                    -- reconfig_to_pll
			pll_recfg_to_pll_3_reconfig_to_pll     : out   std_logic_vector(63 downto 0);                    -- reconfig_to_pll
			pll_recfg_to_pll_4_reconfig_to_pll     : out   std_logic_vector(63 downto 0);                    -- reconfig_to_pll
			pll_recfg_to_pll_5_reconfig_to_pll     : out   std_logic_vector(63 downto 0);                    -- reconfig_to_pll
			pll_rst_export                         : out   std_logic_vector(31 downto 0);                    -- export
			pllcfg_cmd_export                      : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- export
			pllcfg_err_external_connection_export  : out   std_logic_vector(7 downto 0);
         pll_lock_external_connection_export    : in    std_logic_vector(7 downto 0);
         pllcfg_spi_MISO                        : in    std_logic                     := 'X';             -- MISO
			pllcfg_spi_MOSI                        : out   std_logic;                                        -- MOSI
			pllcfg_spi_SCLK                        : out   std_logic;                                        -- SCLK
			pllcfg_spi_SS_n                        : out   std_logic;                                        -- SS_n
			pllcfg_stat_export                     : out   std_logic_vector(7 downto 0);                     -- export
			scl_export                             : inout std_logic                     := 'X';             -- export
			sda_export                             : inout std_logic                     := 'X';              -- export
         smpl_cmp_en_external_connection_export : out std_logic_vector(1 downto 0);
         smpl_cmp_status_external_connection_export : in std_logic_vector(1 downto 0)
		);
	end component nios_cpu;



begin

bus_sync_reg0 : entity work.bus_sync_reg
generic map (4)
port map(clk100, '1', smpl_cmp_status, smpl_cmp_status_sync);

bus_sync_reg1 : entity work.bus_sync_reg
generic map (8)
port map(clk100, '1', pll_lock, pll_lock_sync);


	u0 : component nios_cpu
		port map (
			clk_clk                                      => clk100,
			dac_spi1_MISO                                => fpga_spi0_MISO,
			dac_spi1_MOSI                                => dac_spi1_MOSI_int,
			dac_spi1_SCLK                                => dac_spi1_SCLK_int,
			dac_spi1_SS_n                                => dac_spi1_SS_int,
			exfifo_if_d_export                           => exfifo_if_d,
			exfifo_if_rd_export                          => exfifo_if_rd,
			exfifo_if_rdempty_export                     => exfifo_if_rdempty,
			exfifo_of_d_export                           => exfifo_of_d,
			exfifo_of_wr_export                          => exfifo_of_wr,
			exfifo_of_wrfull_export                      => exfifo_of_wrfull,
			exfifo_rst_export                            => exfifo_rst,
			fpga_spi0_MISO                               => fpga_spi0_MISO,
			fpga_spi0_MOSI                               => fpga_spi0_MOSI_int,
			fpga_spi0_SCLK                               => fpga_spi0_SCLK_int,
			fpga_spi0_SS_n                               => fpga_spi0_SS_n(7 downto 0),
			gpi0_export										      => gpi0,
			gpio0_export                                 => gpio0,
			pll_recfg_from_pll_0_reconfig_from_pll       => pll_recfg_from_pll0,
			pll_recfg_to_pll_0_reconfig_to_pll           => pll_recfg_to_pll0,
			pll_recfg_from_pll_1_reconfig_from_pll       => pll_recfg_from_pll1,
			pll_recfg_to_pll_1_reconfig_to_pll           => pll_recfg_to_pll1,
			pll_recfg_from_pll_2_reconfig_from_pll       => pll_recfg_from_pll2,
			pll_recfg_to_pll_2_reconfig_to_pll           => pll_recfg_to_pll2,
			pll_recfg_from_pll_3_reconfig_from_pll       => pll_recfg_from_pll3,
			pll_recfg_to_pll_3_reconfig_to_pll           => pll_recfg_to_pll3,
			pll_recfg_from_pll_4_reconfig_from_pll       => pll_recfg_from_pll4,
			pll_recfg_to_pll_4_reconfig_to_pll           => pll_recfg_to_pll4,
			pll_recfg_from_pll_5_reconfig_from_pll       => pll_recfg_from_pll5,
			pll_recfg_to_pll_5_reconfig_to_pll           => pll_recfg_to_pll5,
			pll_rst_export                               => pll_rst,
			pllcfg_cmd_export								      => pll_cmd,
         pllcfg_err_external_connection_export        => pll_err,
			pllcfg_stat_export							      => pll_stat,
         pll_lock_external_connection_export          => pll_lock_sync,
			pllcfg_spi_MISO                              => pllcfg_MISO,
			pllcfg_spi_MOSI                              => pllcfg_MOSI,
			pllcfg_spi_SCLK                              => pllcfg_SCLK, 
			pllcfg_spi_SS_n                              => pllcfg_SS_n,
			scl_export                                   => scl,
			sda_export                                   => sda,
         smpl_cmp_en_external_connection_export       => smpl_cmp_en_int,
         smpl_cmp_status_external_connection_export   => smpl_cmp_status_mux
		);
		
	nrst<='0';
	
	-- SPI MUX
	fpga_spi0_SS_n(8) <= dac_spi1_SS_int;
	fpga_spi0_MOSI <= fpga_spi0_MOSI_int when dac_spi1_SS_int = '1' else dac_spi1_MOSI_int;
	fpga_spi0_SCLK <= fpga_spi0_SCLK_int when dac_spi1_SS_int = '1' else dac_spi1_SCLK_int;
   
   smpl_cmp_en <= smpl_cmp_en_int;
   smpl_cmp_status_mux <=  smpl_cmp_status_sync(1 downto 0) when smpl_cmp_en_int(0) = '1' else 
                           smpl_cmp_status_sync(3 downto 2);


end arch;   




