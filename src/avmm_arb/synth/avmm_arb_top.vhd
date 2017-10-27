-- ----------------------------------------------------------------------------	
-- FILE: 	avmm_arb.vhd
-- DESCRIPTION:	Avalon Memory Master arbiter module
-- DATE:	Nov 25, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity avmm_arb_top is
	generic(
		dev_family	     	: string  := "Cyclone V GX";
		cntrl_rate			: integer := 1; --1 - full rate, 2 - half rate
		cntrl_bus_size		: integer := 16;
		addr_size			: integer := 24;
		lcl_bus_size		: integer := 63;
		lcl_burst_length	: integer := 2;
		cmd_fifo_size		: integer := 9;
		outfifo_size		: integer :=10 -- outfifo buffer size
		);
  port (
      clk       			: in std_logic;
      reset_n   			: in std_logic;
		--Write command ports
		wcmd_clk				: in std_logic;
		wcmd_reset_n		: in  std_logic;
		wcmd_rdy				: out std_logic;
		wcmd_addr			: in std_logic_vector(addr_size-1 downto 0);
		wcmd_wr				: in std_logic;
		wcmd_brst_en		: in std_logic; --1- writes in burst, 0- single write
		wcmd_data			: in std_logic_vector(lcl_bus_size-1 downto 0);
		--rd command ports
		rcmd_clk				: in std_logic;
		rcmd_reset_n		: in  std_logic;
		rcmd_rdy				: out std_logic;
		rcmd_addr			: in std_logic_vector(addr_size-1 downto 0);
		rcmd_wr				: in std_logic;
		rcmd_brst_en		: in std_logic; --1- reads in burst, 0- single read
		
		outbuf_wrusedw		: in std_logic_vector(outfifo_size-1 downto 0);
		
		local_ready			: in std_logic;
		local_addr			: out std_logic_vector(addr_size-1 downto 0);
		local_write_req	: out std_logic;
		local_read_req		: out std_logic;
		local_burstbegin	: out std_logic;
		local_wdata			: out std_logic_vector(lcl_bus_size-1 downto 0);
		local_be				: out std_logic_vector(lcl_bus_size/8*cntrl_rate-1 downto 0);
		local_size			: out std_logic_vector(1 downto 0)	
        );
end avmm_arb_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of avmm_arb_top is
--declare signals,  components here

--write command fifo signals
signal wcmdfifo_wrfull				: std_logic;
signal wcmdfifo_wrusedw				: std_logic_vector(cmd_fifo_size-1 downto 0);
signal wcmdfifo_rdreq 				: std_logic;
signal wcmdfifo_q						: std_logic_vector((addr_size+1)+lcl_bus_size-1 downto 0); 
signal wcmdfifo_rdusedw				: std_logic_vector(cmd_fifo_size-1 downto 0);
signal wcmdfifo_data					: std_logic_vector((addr_size+1)+lcl_bus_size-1 downto 0);
signal wcmdfifo_rdempty				: std_logic;

--read command fifo signals
signal rcmdfifo_wrfull				: std_logic;
signal rcmdfifo_rdreq				: std_logic; 
signal rcmdfifo_q						: std_logic_vector(addr_size downto 0);
signal rcmdfifo_rdusedw 			: std_logic_vector(cmd_fifo_size-1 downto 0);
signal rcmdfifo_rdempty				: std_logic;
signal rcmdfifo_data 				: std_logic_vector(addr_size downto 0); 

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

begin


-- ---------------------------------------------------------------------------
-- Command fifo instances
-- ---------------------------------------------------------------------------
--writecommand fifo
wcmdfifo_data<=(wcmd_brst_en & wcmd_addr & wcmd_data);
wcmd_rdy		<= '1' when unsigned(wcmdfifo_wrusedw)<252 else '0';

wcmdfifo	: fifo_inst 
generic map (
			dev_family			=> "Cyclone IV E",
			wrwidth				=> (addr_size+1)+lcl_bus_size,
			wrusedw_witdth		=> cmd_fifo_size, --9=256 words 
			rdwidth				=> (addr_size+1)+lcl_bus_size,
			rdusedw_width		=> cmd_fifo_size,
			show_ahead			=> "ON"
)
port map (
      reset_n       => wcmd_reset_n, 
      wrclk         => wcmd_clk, 
      wrreq         => wcmd_wr, 
      data          => wcmdfifo_data, 
      wrfull        => wcmdfifo_wrfull, 
		wrempty		  => open, 
      wrusedw       => wcmdfifo_wrusedw, 
      rdclk 	     => clk, 
      rdreq         => wcmdfifo_rdreq, 
      q             => wcmdfifo_q, 
      rdempty       => wcmdfifo_rdempty, 
      rdusedw       => wcmdfifo_rdusedw   
);


rcmd_rdy		<= not rcmdfifo_wrfull;
rcmdfifo_data	<= rcmd_brst_en & rcmd_addr;

--read command fifo
rcmdfifo	: fifo_inst 
generic map (
			dev_family			=> "Cyclone IV E",
			wrwidth				=> (addr_size+1),
			wrusedw_witdth		=> cmd_fifo_size, --9=256 words 
			rdwidth				=> (addr_size+1),
			rdusedw_width		=> cmd_fifo_size,
			show_ahead			=> "ON"
)
port map (
      reset_n       => rcmd_reset_n, 
      wrclk         => rcmd_clk, 
      wrreq         => rcmd_wr, 
      data          => rcmdfifo_data, 
      wrfull        => rcmdfifo_wrfull, 
		wrempty		  => open, 
      wrusedw       => open, 
      rdclk 	     => clk, 
      rdreq         => rcmdfifo_rdreq, 
      q             => rcmdfifo_q, 
      rdempty       => rcmdfifo_rdempty, 
      rdusedw       => rcmdfifo_rdusedw   
);

-- ---------------------------------------------------------------------------
-- Avalon Memory Master arbitrator instance
-- ---------------------------------------------------------------------------
avmm_arb_inst :  entity work.avmm_arb
	generic map(
		cntrl_rate			=> cntrl_rate, --1 - full rate, 2 - half rate
		cntrl_bus_size		=> cntrl_bus_size,
		addr_size			=> addr_size,
		lcl_bus_size		=> lcl_bus_size,
		lcl_burst_length	=> lcl_burst_length,
		cmd_fifo_size		=> cmd_fifo_size,
		outfifo_size		=> outfifo_size
		)
  port map (
      clk       			=> clk,
      reset_n   			=> reset_n,

		wcmd_fifo_wraddr	=> wcmdfifo_q((addr_size+1)+lcl_bus_size-1 downto lcl_bus_size),
		wcmd_fifo_wrdata	=> wcmdfifo_q(lcl_bus_size-1 downto 0),
		wcmd_fifo_rdusedw	=> wcmdfifo_rdusedw,
		wcmd_fifo_rdempty	=> wcmdfifo_rdempty,
		wcmd_fifo_rdreq	=> wcmdfifo_rdreq,
		rcmd_fifo_rdaddr	=> rcmdfifo_q ,
		rcmd_fifo_rdusedw	=> rcmdfifo_rdusedw,
		rcmd_fifo_rdempty	=> rcmdfifo_rdempty,
		rcmd_fifo_rdreq	=> rcmdfifo_rdreq,
		outbuf_wrusedw		=> outbuf_wrusedw, 

		local_ready			=> local_ready,
		local_addr			=> local_addr,
		local_write_req	=> local_write_req,
		local_read_req		=> local_read_req,
		local_burstbegin	=> local_burstbegin,
		local_wdata			=> local_wdata,
		local_be				=> local_be,
		local_size			=> local_size	
        );

end arch;   






