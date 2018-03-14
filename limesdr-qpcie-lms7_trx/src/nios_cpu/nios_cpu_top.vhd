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
      clk100               : in std_logic;
      nrst                 : out std_logic; --NOT CONNECTED			
      fpga_spi0_MISO       : in std_logic;
      fpga_spi0_MOSI       : out std_logic;
      fpga_spi0_SCLK       : out std_logic;
      fpga_spi0_SS_n       : out std_logic_vector(8 downto 0);
      pllcfg_MISO          : in  std_logic;
      pllcfg_MOSI          : out std_logic;
      pllcfg_SCLK          : out std_logic;
      pllcfg_SS_n          : out std_logic;
      gpi0                 : in  std_logic_vector(7 downto 0);
      gpio0                : out std_logic_vector(7 downto 0);
      pll_cmd              : in  std_logic_vector(3 downto 0);
      pll_stat             : out  std_logic_vector(9 downto 0);
      pll_recfg_from_pll0  : in  std_logic_vector(63 downto 0) := (others => '0');
      pll_recfg_to_pll0    : out std_logic_vector(63 downto 0);
      pll_recfg_from_pll1  : in  std_logic_vector(63 downto 0) := (others => '0');
      pll_recfg_to_pll1    : out std_logic_vector(63 downto 0);
      pll_recfg_from_pll2  : in  std_logic_vector(63 downto 0) := (others => '0');
      pll_recfg_to_pll2    : out std_logic_vector(63 downto 0);
      pll_recfg_from_pll3  : in  std_logic_vector(63 downto 0) := (others => '0');
      pll_recfg_to_pll3    : out std_logic_vector(63 downto 0);
      pll_recfg_from_pll4  : in  std_logic_vector(63 downto 0) := (others => '0');
      pll_recfg_to_pll4    : out std_logic_vector(63 downto 0);
      pll_recfg_from_pll5  : in  std_logic_vector(63 downto 0) := (others => '0');
      pll_recfg_to_pll5    : out std_logic_vector(63 downto 0);
      pll_rst              : out std_logic_vector(31 downto 0);
      exfifo_if_d          : in std_logic_vector(31 downto 0);
      exfifo_if_rd         : out std_logic;
      exfifo_if_rdempty    : in std_logic;
      exfifo_of_d          : out std_logic_vector(31 downto 0);
      exfifo_of_wr         : out std_logic;
      exfifo_of_wrfull     : in std_logic;
      exfifo_rst           : out std_logic;
      scl                  : inout std_logic;
      sda                  : inout std_logic;
      avmm_s0_address      : in    std_logic_vector(8 downto 0) := (others => 'X');  -- address
      avmm_s0_read         : in    std_logic                     := 'X';             -- read
      avmm_s0_readdata     : out   std_logic_vector(31 downto 0);                    -- readdata
      avmm_s0_write        : in    std_logic                     := 'X';             -- write
      avmm_s0_writedata    : in    std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
      avmm_s0_waitrequest  : out   std_logic;                                        -- waitrequest
      avmm_s1_address      : in    std_logic_vector(8 downto 0) := (others => 'X');  -- address
      avmm_s1_read         : in    std_logic                     := 'X';             -- read
      avmm_s1_readdata     : out   std_logic_vector(31 downto 0);                    -- readdata
      avmm_s1_write        : in    std_logic                     := 'X';             -- write
      avmm_s1_writedata    : in    std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
      avmm_s1_waitrequest  : out   std_logic;                                        -- waitrequest
      vctcxo_tune_en       : in    std_logic;
      vctcxo_irq           : in    std_logic;
      avmm_m0_address      : out   std_logic_vector(7 downto 0);                     -- avmm_m0.address
      avmm_m0_read         : out   std_logic;                                        --       .read
      avmm_m0_waitrequest  : in    std_logic                     := '0';             --       .waitrequest
      avmm_m0_readdata     : in    std_logic_vector(7 downto 0)  := (others => '0'); --       .readdata
      avmm_m0_write        : out   std_logic;                                        --       .write
      avmm_m0_writedata    : out   std_logic_vector(7 downto 0);                     --       .writedata
      avmm_m0_clk_clk      : out   std_logic;                                        -- avm_m0_clk.clk
      avmm_m0_reset_reset  : out   std_logic 

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
   
   signal avmm_s0_address_int : std_logic_vector(31 downto 0);
   signal avmm_s1_address_int : std_logic_vector(31 downto 0);
   
   signal vctcxo_tune_en_sync : std_logic;
   signal vctcxo_irq_sync     : std_logic;
   
   signal vctcxo_tamer_0_irq_out_irq   : std_logic;
   signal vctcxo_tamer_0_ctrl_export   : std_logic_vector(3 downto 0);

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
         pllcfg_spi_MISO                        : in    std_logic                     := 'X';             -- MISO
         pllcfg_spi_MOSI                        : out   std_logic;                                        -- MOSI
         pllcfg_spi_SCLK                        : out   std_logic;                                        -- SCLK
         pllcfg_spi_SS_n                        : out   std_logic;                                        -- SS_n
         pllcfg_stat_export                     : out   std_logic_vector(9 downto 0);                     -- export
         scl_export                             : inout std_logic                     := 'X';             -- export
         sda_export                             : inout std_logic                     := 'X';              -- export
         avmm_s0_address                        : in    std_logic_vector(31 downto 0) := (others => 'X'); -- address
         avmm_s0_read                           : in    std_logic                     := 'X';             -- read
         avmm_s0_readdata                       : out   std_logic_vector(31 downto 0);                    -- readdata
         avmm_s0_write                          : in    std_logic                     := 'X';             -- write
         avmm_s0_writedata                      : in    std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
         avmm_s0_waitrequest                    : out   std_logic;                                        -- waitrequest
         avmm_s1_address                        : in    std_logic_vector(31 downto 0) := (others => 'X'); -- address
         avmm_s1_read                           : in    std_logic                     := 'X';             -- read
         avmm_s1_readdata                       : out   std_logic_vector(31 downto 0);                    -- readdata
         avmm_s1_write                          : in    std_logic                     := 'X';             -- write
         avmm_s1_writedata                      : in    std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
         avmm_s1_waitrequest                    : out   std_logic;                                        -- waitrequest
         vctcxo_tamer_0_ctrl_export             : in    std_logic_vector(3 downto 0)  := (others=>'0');   -- vctcxo_tamer_0_irq_in.export
         avmm_m0_address                        : out   std_logic_vector(7 downto 0);                     --                avm_m0.address
         avmm_m0_read                           : out   std_logic;                                        --                      .read
         avmm_m0_waitrequest                    : in    std_logic                     := '0';             --                      .waitrequest
         avmm_m0_readdata                       : in    std_logic_vector(7 downto 0)  := (others => '0'); --                      .readdata
         avmm_m0_write                          : out   std_logic;                                        --                      .write
         avmm_m0_writedata                      : out   std_logic_vector(7 downto 0);                     --                      .writedata
         avmm_m0_clk_clk                        : out   std_logic;                                        --            avm_m0_clk.clk
         avmm_m0_reset_reset                    : out   std_logic  
      );
   end component nios_cpu;



begin
   -- byte oriented address is shifted to be word aligned
   avmm_s0_address_int <=  "00000000000000000000000" & 
                           avmm_s0_address(8) & 
                           avmm_s0_address(5 downto 0) & 
                           "00"; -- address range   0 - 1FF
   avmm_s1_address_int <=  "00000000000000000000001" & 
                           avmm_s1_address(8) & 
                           avmm_s1_address(5 downto 0) & 
                           "00"; -- address range 200 - 3FF
   

   sync_reg0 : entity work.sync_reg 
   port map(clk100, '1', vctcxo_tune_en, vctcxo_tune_en_sync);
   
   sync_reg1 : entity work.sync_reg 
   port map(clk100, '1', vctcxo_irq, vctcxo_irq_sync);
   
   u0 : component nios_cpu
      port map (
         clk_clk                                => clk100,
         dac_spi1_MISO                          => fpga_spi0_MISO,
         dac_spi1_MOSI                          => dac_spi1_MOSI_int,
         dac_spi1_SCLK                          => dac_spi1_SCLK_int,
         dac_spi1_SS_n                          => dac_spi1_SS_int,
         exfifo_if_d_export                     => exfifo_if_d,
         exfifo_if_rd_export                    => exfifo_if_rd,
         exfifo_if_rdempty_export               => exfifo_if_rdempty,
         exfifo_of_d_export                     => exfifo_of_d,
         exfifo_of_wr_export                    => exfifo_of_wr,
         exfifo_of_wrfull_export                => exfifo_of_wrfull,
         exfifo_rst_export                      => exfifo_rst,
         fpga_spi0_MISO                         => fpga_spi0_MISO,
         fpga_spi0_MOSI                         => fpga_spi0_MOSI_int,
         fpga_spi0_SCLK                         => fpga_spi0_SCLK_int,
         fpga_spi0_SS_n                         => fpga_spi0_SS_n(7 downto 0),
         gpi0_export                            => gpi0,
         gpio0_export                           => gpio0,
         pll_recfg_from_pll_0_reconfig_from_pll => pll_recfg_from_pll0,
         pll_recfg_to_pll_0_reconfig_to_pll     => pll_recfg_to_pll0,
         pll_recfg_from_pll_1_reconfig_from_pll => pll_recfg_from_pll1,
         pll_recfg_to_pll_1_reconfig_to_pll     => pll_recfg_to_pll1,
         pll_recfg_from_pll_2_reconfig_from_pll => pll_recfg_from_pll2,
         pll_recfg_to_pll_2_reconfig_to_pll     => pll_recfg_to_pll2,
         pll_recfg_from_pll_3_reconfig_from_pll => pll_recfg_from_pll3,
         pll_recfg_to_pll_3_reconfig_to_pll     => pll_recfg_to_pll3,
         pll_recfg_from_pll_4_reconfig_from_pll => pll_recfg_from_pll4,
         pll_recfg_to_pll_4_reconfig_to_pll     => pll_recfg_to_pll4,
         pll_recfg_from_pll_5_reconfig_from_pll => pll_recfg_from_pll5,
         pll_recfg_to_pll_5_reconfig_to_pll     => pll_recfg_to_pll5,
         pll_rst_export                         => pll_rst,
         pllcfg_cmd_export                      => pll_cmd,
         pllcfg_stat_export                     => pll_stat,
         pllcfg_spi_MISO                        => pllcfg_MISO,
         pllcfg_spi_MOSI                        => pllcfg_MOSI,
         pllcfg_spi_SCLK                        => pllcfg_SCLK, 
         pllcfg_spi_SS_n                        => pllcfg_SS_n,
         scl_export                             => scl,
         sda_export                             => sda,
         avmm_s0_address                        => avmm_s0_address_int,    
         avmm_s0_read                           => avmm_s0_read,       
         avmm_s0_readdata                       => avmm_s0_readdata,   
         avmm_s0_write                          => avmm_s0_write,      
         avmm_s0_writedata                      => avmm_s0_writedata,  
         avmm_s0_waitrequest                    => avmm_s0_waitrequest,
         avmm_s1_address                        => avmm_s1_address_int,    
         avmm_s1_read                           => avmm_s1_read,       
         avmm_s1_readdata                       => avmm_s1_readdata,   
         avmm_s1_write                          => avmm_s1_write,      
         avmm_s1_writedata                      => avmm_s1_writedata,  
         avmm_s1_waitrequest                    => avmm_s1_waitrequest,
         vctcxo_tamer_0_ctrl_export             => vctcxo_tamer_0_ctrl_export,
         avmm_m0_address                        => avmm_m0_address,
         avmm_m0_read                           => avmm_m0_read,
         avmm_m0_waitrequest                    => avmm_m0_waitrequest,
         avmm_m0_readdata                       => avmm_m0_readdata,
         avmm_m0_write                          => avmm_m0_write,
         avmm_m0_writedata                      => avmm_m0_writedata,
         avmm_m0_clk_clk                        => avmm_m0_clk_clk,
         avmm_m0_reset_reset                    => avmm_m0_reset_reset

      );

   nrst<='0';
   
   -- SPI MUX
   fpga_spi0_SS_n(8) <= dac_spi1_SS_int;
   fpga_spi0_MOSI <= fpga_spi0_MOSI_int when dac_spi1_SS_int = '1' else dac_spi1_MOSI_int;
   fpga_spi0_SCLK <= fpga_spi0_SCLK_int when dac_spi1_SS_int = '1' else dac_spi1_SCLK_int;

   vctcxo_tamer_0_ctrl_export(0) <= vctcxo_tune_en_sync;
   vctcxo_tamer_0_ctrl_export(1) <= vctcxo_irq_sync;
   vctcxo_tamer_0_ctrl_export(2) <= '0';
   vctcxo_tamer_0_ctrl_export(3) <= '0';
   
end arch;   




