-- ----------------------------------------------------------------------------	
-- FILE: 	pcie_top.vhd
-- DESCRIPTION:	top module of PCIE 
-- DATE:	 Nov 08, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity pcie_top is
	generic(
		dev_family				: string  := "Cyclone V GX";
		pcie_ctrl0_dataw		: integer := 32; --xillybus_control0 bus width
		pcie_strm0_dataw		: integer := 32; --xillybus_stream0 bus width
		pcie_strm1_dataw		: integer := 32; --xillybus_stream1 bus width
		pcie_strm2_dataw		: integer := 32  --xillybus_stream1 bus width
		);
	port (
		--PCIE external pins
		pcie_perstn 			: IN std_logic;
		pcie_refclk 			: IN std_logic;
		pcie_rx 					: IN std_logic_vector(3 DOWNTO 0);
		pcie_tx 					: OUT std_logic_vector(3 DOWNTO 0);
		--pcie internal data clock
		pcie_bus_clk			: out std_logic;
		--Control 0 data fifo (PC -> FPGA) 
		ctrl0_IN_rdclk			: in std_logic;
		ctrl0_IN_aclr_n		: in std_logic;
		ctrl0_IN_rdempty		: out std_logic;
		ctrl0_IN_rdusedw		: out std_logic_vector(8 downto 0);
		ctrl0_IN_rdreq			: in std_logic;
		ctrl0_IN_q				: out std_logic_vector(31 downto 0);
		--Control 0 data fifo (FPGA -> PC) 
		ctrl0_OUT_wrclk		: in std_logic;
		ctrl0_OUT_aclr_n		: in std_logic;
		ctrl0_OUT_wrfull		: out std_logic;
		ctrl0_OUT_wrusedw		: out std_logic_vector(8 downto 0);
		ctrl0_OUT_wrreq		: in std_logic;
		ctrl0_OUT_data			: in std_logic_vector(31 downto 0);
		--Stream 0 data fifo (PC -> FPGA) 
		strm0_IN_rdclk			: in std_logic;
		strm0_IN_rdempty		: out std_logic;
		strm0_IN_rdusedw		: out std_logic_vector(8 downto 0);
		strm0_IN_rdreq			: in std_logic;
		strm0_IN_q				: out std_logic_vector(31 downto 0);
		strm0_IN_ext_q_valid	: out std_logic;
		strm0_IN_ext_rdy		: in std_logic;
		--Stream 0 data fifo (FPGA -> PC) 
		strm0_OUT_SW			: in std_logic;
		strm0_OUT_wrclk		: in std_logic;
		strm0_OUT_aclr_n		: in std_logic;
		strm0_OUT_wrfull		: out std_logic;
		strm0_OUT_wrusedw		: out std_logic_vector(11 downto 0);
		strm0_OUT_wrreq		: in std_logic;
		strm0_OUT_data			: in std_logic_vector(63 downto 0);
		strm0_OUT_EXT_rdreq	: out std_logic;
		strm0_OUT_EXT_rdempty: in std_logic;
		strm0_OUT_EXT_q		: in std_logic_vector(31 downto 0);		
		--Stream 1 data fifo (PC -> FPGA) 
		strm1_IN_rdclk			: in std_logic;
		strm1_IN_rdempty		: out std_logic;
		strm1_IN_rdusedw		: out std_logic_vector(8 downto 0);
		strm1_IN_rdreq			: in std_logic;
		strm1_IN_q				: out std_logic_vector(31 downto 0);
		strm1_IN_ext_q_valid	: out std_logic;
		strm1_IN_ext_rdy		: in std_logic;
		--Stream 1 data fifo (FPGA -> PC) 
		strm1_OUT_SW			: in std_logic;
		strm1_OUT_wrclk		: in std_logic;
		strm1_OUT_aclr_n		: in std_logic;
		strm1_OUT_wrfull		: out std_logic;
		strm1_OUT_wrusedw		: out std_logic_vector(11 downto 0);
		strm1_OUT_wrreq		: in std_logic;
		strm1_OUT_data			: in std_logic_vector(63 downto 0);
		strm1_OUT_EXT_rdreq	: out std_logic;
		strm1_OUT_EXT_rdempty: in std_logic;
		strm1_OUT_EXT_q		: in std_logic_vector(31 downto 0);
		--Stream 2 data fifo (PC -> FPGA) 
		strm2_IN_rdclk			: in std_logic;
		strm2_IN_rdempty		: out std_logic;
		strm2_IN_rdusedw		: out std_logic_vector(8 downto 0);
		strm2_IN_rdreq			: in std_logic;
		strm2_IN_q				: out std_logic_vector(31 downto 0);
		strm2_IN_ext_q_valid	: out std_logic;
		strm2_IN_ext_rdy		: in std_logic;
		--Stream 2 data fifo (FPGA -> PC) 
		strm2_OUT_SW			: in std_logic;
		strm2_OUT_wrclk		: in std_logic;
		strm2_OUT_aclr_n		: in std_logic;
		strm2_OUT_wrfull		: out std_logic;
		strm2_OUT_wrusedw		: out std_logic_vector(11 downto 0);
		strm2_OUT_wrreq		: in std_logic;
		strm2_OUT_data			: in std_logic_vector(63 downto 0);
		strm2_OUT_EXT_rdreq	: out std_logic;
		strm2_OUT_EXT_rdempty: in std_logic;
		strm2_OUT_EXT_q		: in std_logic_vector(31 downto 0)
		
		
	);
end pcie_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of pcie_top is
--declare signals,  components here
signal my_sig_name : std_logic_vector (7 downto 0); 


component xillybus
    port (
		pcie_perstn 						: IN std_logic;
      pcie_refclk 						: IN std_logic;
      pcie_rx 								: IN std_logic_vector(3 DOWNTO 0);
      bus_clk 								: OUT std_logic;
      pcie_tx 								: OUT std_logic_vector(3 DOWNTO 0);
      quiesce 								: OUT std_logic;
      user_led 							: OUT std_logic_vector(3 DOWNTO 0);
      user_r_control0_read_32_rden 	: OUT std_logic;
      user_r_control0_read_32_empty : IN std_logic;
      user_r_control0_read_32_data 	: IN std_logic_vector(31 DOWNTO 0);
      user_r_control0_read_32_eof 	: IN std_logic;
      user_r_control0_read_32_open 	: OUT std_logic;
      user_w_control0_write_32_wren : OUT std_logic;
      user_w_control0_write_32_full : IN std_logic;
      user_w_control0_write_32_data : OUT std_logic_vector(31 DOWNTO 0);
      user_w_control0_write_32_open : OUT std_logic;
      user_r_mem_8_rden	 				: OUT std_logic;
      user_r_mem_8_empty 				: IN std_logic;
      user_r_mem_8_data 				: IN std_logic_vector(7 DOWNTO 0);
      user_r_mem_8_eof 					: IN std_logic;
      user_r_mem_8_open 				: OUT std_logic;
      user_w_mem_8_wren 				: OUT std_logic;
      user_w_mem_8_full 				: IN std_logic;
      user_w_mem_8_data 				: OUT std_logic_vector(7 DOWNTO 0);
      user_w_mem_8_open 				: OUT std_logic;
      user_mem_8_addr 					: OUT std_logic_vector(4 DOWNTO 0);
      user_mem_8_addr_update 			: OUT std_logic;
      user_r_stream0_read_32_rden 	: OUT std_logic;
      user_r_stream0_read_32_empty 	: IN std_logic;
      user_r_stream0_read_32_data 	: IN std_logic_vector(31 DOWNTO 0);
      user_r_stream0_read_32_eof 	: IN std_logic;
      user_r_stream0_read_32_open 	: OUT std_logic;
      user_w_stream0_write_32_wren 	: OUT std_logic;
      user_w_stream0_write_32_full 	: IN std_logic;
      user_w_stream0_write_32_data 	: OUT std_logic_vector(31 DOWNTO 0);
      user_w_stream0_write_32_open 	: OUT std_logic;
      user_r_stream1_read_32_rden 	: OUT std_logic;
      user_r_stream1_read_32_empty 	: IN std_logic;
      user_r_stream1_read_32_data 	: IN std_logic_vector(31 DOWNTO 0);
      user_r_stream1_read_32_eof 	: IN std_logic;
      user_r_stream1_read_32_open 	: OUT std_logic;
      user_w_stream1_write_32_wren 	: OUT std_logic;
      user_w_stream1_write_32_full 	: IN std_logic;
      user_w_stream1_write_32_data 	: OUT std_logic_vector(31 DOWNTO 0);
      user_w_stream1_write_32_open 	: OUT std_logic;
	   user_r_stream2_read_32_rden 	: OUT std_logic;
      user_r_stream2_read_32_empty 	: IN std_logic;
      user_r_stream2_read_32_data 	: IN std_logic_vector(31 DOWNTO 0);
      user_r_stream2_read_32_eof 	: IN std_logic;
      user_r_stream2_read_32_open 	: OUT std_logic;
      user_w_stream2_write_32_wren 	: OUT std_logic;
      user_w_stream2_write_32_full 	: IN std_logic;
      user_w_stream2_write_32_data 	: OUT std_logic_vector(31 DOWNTO 0);
      user_w_stream2_write_32_open 	: OUT std_logic		
		);
  end component;
  
  
  component fifo_inst is
  generic(dev_family	     : string  := "Cyclone IV E";
          wrwidth         : integer := 24;
          wrusedw_witdth  : integer := 12; --12=2048 words 
          rdwidth         : integer := 48;
          rdusedw_width   : integer := 11;
          show_ahead      : string  := "ON"
  );  
  port (
      --input ports 
      reset_n       : in std_logic;
      wrclk         : in std_logic;
      wrreq         : in std_logic;
      data          : in std_logic_vector(wrwidth-1 downto 0);
      wrfull        : out std_logic;
		wrempty		  : out std_logic;
      wrusedw       : out std_logic_vector(wrusedw_witdth-1 downto 0);
      rdclk 	     : in std_logic;
      rdreq         : in std_logic;
      q             : out std_logic_vector(rdwidth-1 downto 0);
      rdempty       : out std_logic;
      rdusedw       : out std_logic_vector(rdusedw_width-1 downto 0)     
        
        );
end component;

  type demo_mem is array(0 TO 31) of std_logic_vector(7 DOWNTO 0);
  signal demoarray : demo_mem;
  
  signal bus_clk :  std_logic;
  signal quiesce : std_logic;

  signal control0_reset_32 : std_logic;
  signal stream0_reset_32 : std_logic;
  signal stream1_reset_32 : std_logic;

  signal ram_addr : integer range 0 to 31;
  
  signal user_r_control0_read_32_rden 		:  std_logic;
  signal user_r_control0_read_32_empty 	:  std_logic;
  signal user_r_control0_read_32_data 		:  std_logic_vector(pcie_ctrl0_dataw-1 DOWNTO 0);
  signal user_r_control0_read_32_eof 		:  std_logic;
  signal user_r_control0_read_32_open 		:  std_logic;
  signal user_w_control0_write_32_wren 	:  std_logic;
  signal user_w_control0_write_32_full 	:  std_logic;
  signal user_w_control0_write_32_data 	:  std_logic_vector(pcie_ctrl0_dataw-1 DOWNTO 0);
  signal user_w_control0_write_32_open 	:  std_logic;
  signal user_r_mem_8_rden 					:  std_logic;
  signal user_r_mem_8_empty 					:  std_logic;
  signal user_r_mem_8_data 					:  std_logic_vector(7 DOWNTO 0);
  signal user_r_mem_8_eof 						:  std_logic;
  signal user_r_mem_8_open 					:  std_logic;
  signal user_w_mem_8_wren 					:  std_logic;
  signal user_w_mem_8_full 					:  std_logic;
  signal user_w_mem_8_data 					:  std_logic_vector(7 DOWNTO 0);
  signal user_w_mem_8_open 					:  std_logic;
  signal user_mem_8_addr 						:  std_logic_vector(4 DOWNTO 0);
  signal user_mem_8_addr_update 				:  std_logic;
  signal user_r_stream0_read_32_rden 		:  std_logic;
  signal user_r_stream0_read_32_empty 		:  std_logic;
  signal user_r_stream0_read_32_data 		:  std_logic_vector(31 DOWNTO 0);
  signal user_r_stream0_read_32_eof 		:  std_logic;
  signal user_r_stream0_read_32_open 		:  std_logic;
  signal user_w_stream0_write_32_wren 		:  std_logic;
  signal user_w_stream0_write_32_full 		:  std_logic;
  signal user_w_stream0_write_32_data 		:  std_logic_vector(31 DOWNTO 0);
  signal user_w_stream0_write_32_open 		:  std_logic;
  signal user_r_stream1_read_32_rden 		:  std_logic;
  signal user_r_stream1_read_32_empty 		:  std_logic;
  signal user_r_stream1_read_32_data 		:  std_logic_vector(31 DOWNTO 0);
  signal user_r_stream1_read_32_eof 		:  std_logic;
  signal user_r_stream1_read_32_open 		:  std_logic;
  signal user_w_stream1_write_32_wren 		:  std_logic;
  signal user_w_stream1_write_32_full 		:  std_logic;
  signal user_w_stream1_write_32_data 		:  std_logic_vector(31 DOWNTO 0);
  signal user_w_stream1_write_32_open 		:  std_logic;  
  signal user_r_stream2_read_32_rden 		:  std_logic;
  signal user_r_stream2_read_32_empty 		:  std_logic;
  signal user_r_stream2_read_32_data 		:  std_logic_vector(31 DOWNTO 0);
  signal user_r_stream2_read_32_eof 		:  std_logic;
  signal user_r_stream2_read_32_open 		:  std_logic;
  signal user_w_stream2_write_32_wren 		:  std_logic;
  signal user_w_stream2_write_32_full 		:  std_logic;
  signal user_w_stream2_write_32_data 		:  std_logic_vector(31 DOWNTO 0);
  signal user_w_stream2_write_32_open 		:  std_logic;  

  signal user_led_sign			: std_logic_vector(3 downto 0);
  
  
  --inst2 signals
  signal inst2_reset_n 							: std_logic;
  signal inst3_reset_n 							: std_logic;
  
  --inst5 signals
  signal inst5_rdreq		: std_logic;
  signal inst5_q 			: std_logic_vector(31 downto 0);
  signal inst5_rdempty	: std_logic;
  
  --inst7 signals
  signal inst7_rdreq		: std_logic;
  signal inst7_q 			: std_logic_vector(31 downto 0);
  signal inst7_rdempty	: std_logic;
  
  --inst9 signals
  signal inst9_rdreq		: std_logic;
  signal inst9_q 			: std_logic_vector(31 downto 0);
  signal inst9_rdempty	: std_logic;
  
begin

	user_r_stream0_read_32_data	<= inst5_q 								when strm0_OUT_SW='1' else strm0_OUT_EXT_q;
	user_r_stream0_read_32_empty	<= inst5_rdempty 						when strm0_OUT_SW='1' else strm0_OUT_EXT_rdempty;
	strm0_OUT_EXT_rdreq				<= user_r_stream0_read_32_rden 	when strm0_OUT_SW='0' else '0';
	
	user_r_stream1_read_32_data	<= inst7_q 								when strm1_OUT_SW='1' else strm1_OUT_EXT_q;
	user_r_stream1_read_32_empty	<= inst7_rdempty 						when strm1_OUT_SW='1' else strm1_OUT_EXT_rdempty;
	strm1_OUT_EXT_rdreq				<= user_r_stream1_read_32_rden 	when strm1_OUT_SW='0' else '0';
	
	--only external data currently is connected
	user_r_stream2_read_32_data	<= inst9_q								when strm2_OUT_SW='1' else strm2_OUT_EXT_q;
	user_r_stream2_read_32_empty	<= inst9_rdempty 						when strm2_OUT_SW='1' else strm2_OUT_EXT_rdempty;
	strm2_OUT_EXT_rdreq				<= user_r_stream2_read_32_rden 	when strm2_OUT_SW='0' else '0';

  inst1_xillybus : xillybus
    port map (
	 
      -- Ports related to /dev/xillybus_control0_read_32
      -- FPGA to CPU signals:
      user_r_control0_read_32_rden 		=> user_r_control0_read_32_rden,
      user_r_control0_read_32_empty 	=> user_r_control0_read_32_empty,
      user_r_control0_read_32_data 		=> user_r_control0_read_32_data,
      user_r_control0_read_32_eof 		=> user_r_control0_read_32_eof,
      user_r_control0_read_32_open 		=> user_r_control0_read_32_open,

      -- Ports related to /dev/xillybus_control0_write_32
      -- CPU to FPGA signals:
      user_w_control0_write_32_wren 	=> user_w_control0_write_32_wren,
      user_w_control0_write_32_full 	=> user_w_control0_write_32_full,
      user_w_control0_write_32_data 	=> user_w_control0_write_32_data,
      user_w_control0_write_32_open 	=> user_w_control0_write_32_open,

      -- Ports related to /dev/xillybus_mem_8
      -- FPGA to CPU signals:
      user_r_mem_8_rden 		=> user_r_mem_8_rden,
      user_r_mem_8_empty 		=> user_r_mem_8_empty,
      user_r_mem_8_data 		=> user_r_mem_8_data,
      user_r_mem_8_eof 			=> user_r_mem_8_eof,
      user_r_mem_8_open 		=> user_r_mem_8_open,
      -- CPU to FPGA signals:
      user_w_mem_8_wren => user_w_mem_8_wren,
      user_w_mem_8_full => user_w_mem_8_full,
      user_w_mem_8_data => user_w_mem_8_data,
      user_w_mem_8_open => user_w_mem_8_open,
      -- Address signals:
      user_mem_8_addr 			=> user_mem_8_addr,
      user_mem_8_addr_update 	=> user_mem_8_addr_update,

      -- Ports related to /dev/xillybus_stream0_read_32
      -- FPGA to CPU signals:
      user_r_stream0_read_32_rden 	=> user_r_stream0_read_32_rden,
      user_r_stream0_read_32_empty 	=> user_r_stream0_read_32_empty,
      user_r_stream0_read_32_data 	=> user_r_stream0_read_32_data,
      user_r_stream0_read_32_eof 	=> user_r_stream0_read_32_eof,
      user_r_stream0_read_32_open 	=> user_r_stream0_read_32_open,

      -- Ports related to /dev/xillybus_stream0_write_32
      -- CPU to FPGA signals:
      user_w_stream0_write_32_wren => user_w_stream0_write_32_wren,
      user_w_stream0_write_32_full => user_w_stream0_write_32_full,
      user_w_stream0_write_32_data => user_w_stream0_write_32_data,
      user_w_stream0_write_32_open => user_w_stream0_write_32_open,

      -- Ports related to /dev/xillybus_stream1_read_32
      -- FPGA to CPU signals:
      user_r_stream1_read_32_rden 	=> user_r_stream1_read_32_rden,
      user_r_stream1_read_32_empty 	=> user_r_stream1_read_32_empty,
      user_r_stream1_read_32_data 	=> user_r_stream1_read_32_data,
      user_r_stream1_read_32_eof 	=> user_r_stream1_read_32_eof,
      user_r_stream1_read_32_open 	=> user_r_stream1_read_32_open,

      -- Ports related to /dev/xillybus_stream1_write_32
      -- CPU to FPGA signals:
      user_w_stream1_write_32_wren => user_w_stream1_write_32_wren,
      user_w_stream1_write_32_full => user_w_stream1_write_32_full,
      user_w_stream1_write_32_data => user_w_stream1_write_32_data,
      user_w_stream1_write_32_open => user_w_stream1_write_32_open,
		
		-- Ports related to /dev/xillybus_stream2_read_32
      -- FPGA to CPU signals:
      user_r_stream2_read_32_rden 	=> user_r_stream2_read_32_rden,
      user_r_stream2_read_32_empty 	=> user_r_stream2_read_32_empty,
      user_r_stream2_read_32_data 	=> user_r_stream2_read_32_data,
      user_r_stream2_read_32_eof 	=> user_r_stream2_read_32_eof,
      user_r_stream2_read_32_open 	=> user_r_stream2_read_32_open,

      -- Ports related to /dev/xillybus_stream2_write_32
      -- CPU to FPGA signals:
      user_w_stream2_write_32_wren => user_w_stream2_write_32_wren,
      user_w_stream2_write_32_full => user_w_stream2_write_32_full,
      user_w_stream2_write_32_data => user_w_stream2_write_32_data,
      user_w_stream2_write_32_open => user_w_stream2_write_32_open,

      -- General signals
      pcie_perstn 	=> pcie_perstn,
      pcie_refclk 	=> pcie_refclk,
      pcie_rx 			=> pcie_rx,
      bus_clk 			=> bus_clk,
      pcie_tx 			=> pcie_tx,
      quiesce 			=> quiesce,
      user_led 		=> user_led_sign 
      );
		
		
	pcie_bus_clk<=bus_clk;
		
		
--  A simple inferred RAM

  ram_addr <= to_integer(unsigned(user_mem_8_addr));
  
  process (bus_clk)
  begin
    if (bus_clk'event and bus_clk = '1') then
      if (user_w_mem_8_wren = '1') then 
        demoarray(ram_addr) <= user_w_mem_8_data;
      end if;
      if (user_r_mem_8_rden = '1') then
        user_r_mem_8_data <= demoarray(ram_addr);
      end if;
    end if;
  end process;

  user_r_mem_8_empty <= '0';
  user_r_mem_8_eof <= '0';
  user_w_mem_8_full <= '0';		

--ctrl0_IN fifo


inst2_reset_n <= user_w_control0_write_32_open AND ctrl0_IN_aclr_n;
		
inst2 : fifo_inst
GENERIC MAP(
			dev_family 		=> dev_family,
			rdusedw_width 	=> 9,
			rdwidth 			=> 32,
			show_ahead 		=> "OFF",
			wrusedw_witdth => 9,
			wrwidth 			=> pcie_ctrl0_dataw
			)
PORT MAP(
			reset_n 			=> inst2_reset_n,
			wrclk 			=> bus_clk,
			wrreq 			=> user_w_control0_write_32_wren,
			data 				=> user_w_control0_write_32_data,
			rdclk 			=> ctrl0_IN_rdclk,
			rdreq 			=> ctrl0_IN_rdreq,
			wrfull 			=> user_w_control0_write_32_full,
			wrempty			=> open,
			wrusedw			=> open, 
			q 					=> ctrl0_IN_q,
			rdempty 			=> ctrl0_IN_rdempty,
			rdusedw 			=> ctrl0_IN_rdusedw
			);
			
			
inst3_reset_n <= user_r_control0_read_32_open AND ctrl0_OUT_aclr_n;

--ctrl0_OUT fifo		
inst3 : fifo_inst
GENERIC MAP(
			dev_family 		=> dev_family,
			rdusedw_width 	=> 9,
			rdwidth 			=> 32,
			show_ahead 		=> "OFF",
			wrusedw_witdth => 9,
			wrwidth 			=> pcie_ctrl0_dataw
			)
PORT MAP(
			reset_n 			=> inst3_reset_n,
			wrclk 			=> ctrl0_OUT_wrclk,
			wrreq 			=> ctrl0_OUT_wrreq,
			data 				=> ctrl0_OUT_data,
			rdclk 			=> bus_clk,
			rdreq 			=> user_r_control0_read_32_rden,
			wrfull 			=> ctrl0_OUT_wrfull,
			wrempty			=> open,
			wrusedw			=> ctrl0_OUT_wrusedw, 
			q 					=> user_r_control0_read_32_data,
			rdempty 			=> user_r_control0_read_32_empty,
			rdusedw 			=> open
			);
			
user_r_control0_read_32_eof <= '0';			

--strm0_IN fifo
--currently fifo is not used, data is written to external buffer		
--inst4 : fifo_inst
--GENERIC MAP(
--			dev_family 		=> dev_family,
--			rdusedw_width 	=> 9,
--			rdwidth 			=> 32,
--			show_ahead 		=> "OFF",
--			wrusedw_witdth => 9,
--			wrwidth 			=> pcie_strm0_dataw
--			)
--PORT MAP(
--			reset_n 			=> user_w_stream0_write_32_open,
--			wrclk 			=> bus_clk,
--			wrreq 			=> user_w_stream0_write_32_wren,
--			data 				=> user_w_stream0_write_32_data,
--			rdclk 			=> strm0_IN_rdclk,
--			rdreq 			=> strm0_IN_rdreq,
--			wrfull 			=> user_w_stream0_write_32_full,
--			wrempty			=> open,
--			wrusedw			=> open, 
--			q 					=> strm0_IN_q,
--			rdempty 			=> strm0_IN_rdempty,
--			rdusedw 			=> strm0_IN_rdusedw
--			);	

strm0_IN_ext_q_valid				<= user_w_stream0_write_32_wren;		
strm0_IN_q 							<= user_w_stream0_write_32_data;
user_w_stream0_write_32_full	<= not strm0_IN_ext_rdy;

--strm0_OUT fifo		
inst5 : fifo_inst
GENERIC MAP(
			dev_family 		=> dev_family,
			rdusedw_width 	=> 13,
			rdwidth 			=> pcie_strm0_dataw,
			show_ahead 		=> "OFF",
			wrusedw_witdth => 12,
			wrwidth 			=> 64
			)
PORT MAP(
			reset_n 			=> strm0_OUT_aclr_n,
			wrclk 			=> strm0_OUT_wrclk,
			wrreq 			=> strm0_OUT_wrreq,
			data 				=> strm0_OUT_data,
			rdclk 			=> bus_clk,
			rdreq 			=> inst5_rdreq, --user_r_stream0_read_32_rden,
			wrfull 			=> strm0_OUT_wrfull,
			wrempty			=> open,
			wrusedw			=> strm0_OUT_wrusedw, 
			q 					=> inst5_q, --user_r_stream0_read_32_data,
			rdempty 			=> inst5_rdempty, --user_r_stream0_read_32_empty,
			rdusedw 			=> open
			);	

inst5_rdreq <= user_r_stream0_read_32_rden when strm0_OUT_SW='1' else '0';

user_r_stream0_read_32_eof	 <= '0';				
		

--strm1_IN fifo	
--currently fifo is not used, data is written to external buffer		
--inst6 : fifo_inst
--GENERIC MAP(
--			dev_family 		=> dev_family,
--			rdusedw_width 	=> 9,
--			rdwidth 			=> 32,
--			show_ahead 		=> "OFF",
--			wrusedw_witdth => 9,
--			wrwidth 			=> pcie_strm1_dataw
--			)
--PORT MAP(
--			reset_n 			=> user_w_stream1_write_32_open,
--			wrclk 			=> bus_clk,
--			wrreq 			=> user_w_stream1_write_32_wren,
--			data 				=> user_w_stream1_write_32_data,
--			rdclk 			=> strm1_IN_rdclk,
--			rdreq 			=> strm1_IN_rdreq,
--			wrfull 			=> user_w_stream1_write_32_full,
--			wrempty			=> open,
--			wrusedw			=> open, 
--			q 					=> strm1_IN_q,
--			rdempty 			=> strm1_IN_rdempty,
--			rdusedw 			=> strm1_IN_rdusedw
--			);	

strm1_IN_ext_q_valid				<= user_w_stream1_write_32_wren;		
strm1_IN_q 							<= user_w_stream1_write_32_data;
user_w_stream1_write_32_full	<= not strm1_IN_ext_rdy;	

	
--strm1_OUT fifo		
inst7 : fifo_inst
GENERIC MAP(
			dev_family 		=> dev_family,
			rdusedw_width 	=> 13,
			rdwidth 			=> pcie_strm1_dataw,
			show_ahead 		=> "OFF",
			wrusedw_witdth => 12,
			wrwidth 			=> 64
			)
PORT MAP(
			reset_n 			=> strm1_OUT_aclr_n,
			wrclk 			=> strm1_OUT_wrclk,
			wrreq 			=> strm1_OUT_wrreq,
			data 				=> strm1_OUT_data,
			rdclk 			=> bus_clk,
			rdreq 			=> inst7_rdreq, --user_r_stream1_read_32_rden,
			wrfull 			=> strm1_OUT_wrfull,
			wrempty			=> open,
			wrusedw			=> strm1_OUT_wrusedw, 
			q 					=> inst7_q, --user_r_stream1_read_32_data,
			rdempty 			=> inst7_rdempty, --user_r_stream1_read_32_empty,
			rdusedw 			=> open
			);
		
inst7_rdreq <= user_r_stream1_read_32_rden when strm1_OUT_SW='1' else '0';	
		
user_r_stream1_read_32_eof	 <= '0';	



--strm2_IN fifo	
--currently fifo is not used, data is written to external buffer		
--inst8 : fifo_inst
--GENERIC MAP(
--			dev_family 		=> dev_family,
--			rdusedw_width 	=> 9,
--			rdwidth 			=> 32,
--			show_ahead 		=> "OFF",
--			wrusedw_witdth => 9,
--			wrwidth 			=> pcie_strm2_dataw
--			)
--PORT MAP(
--			reset_n 			=> user_w_stream2_write_32_open,
--			wrclk 			=> bus_clk,
--			wrreq 			=> user_w_stream2_write_32_wren,
--			data 				=> user_w_stream2_write_32_data,
--			rdclk 			=> strm2_IN_rdclk,
--			rdreq 			=> strm2_IN_rdreq,
--			wrfull 			=> user_w_stream2_write_32_full,
--			wrempty			=> open,
--			wrusedw			=> open, 
--			q 					=> strm2_IN_q,
--			rdempty 			=> strm2_IN_rdempty,
--			rdusedw 			=> strm2_IN_rdusedw
--			);	

strm2_IN_ext_q_valid				<= user_w_stream2_write_32_wren;		
strm2_IN_q 							<= user_w_stream2_write_32_data;
user_w_stream2_write_32_full	<= not strm2_IN_ext_rdy;	

	
--strm2_OUT fifo		
inst9 : fifo_inst
GENERIC MAP(
			dev_family 		=> dev_family,
			rdusedw_width 	=> 13,
			rdwidth 			=> pcie_strm2_dataw,
			show_ahead 		=> "OFF",
			wrusedw_witdth => 12,
			wrwidth 			=> 64
			)
PORT MAP(
			reset_n 			=> strm2_OUT_aclr_n,
			wrclk 			=> strm2_OUT_wrclk,
			wrreq 			=> strm2_OUT_wrreq,
			data 				=> strm2_OUT_data,
			rdclk 			=> bus_clk,
			rdreq 			=> inst9_rdreq, --user_r_stream2_read_32_rden,
			wrfull 			=> strm2_OUT_wrfull,
			wrempty			=> open,
			wrusedw			=> strm2_OUT_wrusedw, 
			q 					=> inst9_q, --user_r_stream1_read_32_data,
			rdempty 			=> inst9_rdempty, --user_r_stream1_read_32_empty,
			rdusedw 			=> open
			);
		
inst9_rdreq <= user_r_stream2_read_32_rden when strm2_OUT_SW='1' else '0';	
		
user_r_stream2_read_32_eof	 <= '0';
		
end arch;





