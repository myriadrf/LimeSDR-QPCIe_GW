-- ----------------------------------------------------------------------------	
-- FILE:          wfm_player.vhd
-- DESCRIPTION:   wfm player module
-- DATE:          June 20, 2016
-- AUTHOR(s):     Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity wfm_player is
   generic(
      dev_family           : string  := "Cyclone IV E";
      --Parameters for FIFO buffer before external memory
      wfm_infifo_wrwidth   : integer := 32;
      wfm_infifo_wrsize    : integer := 11;
      wfm_infifo_rdwidth   : integer := 32;
      wfm_infifo_rdsize    : integer := 11;      
      --Avalon MM interface of external memory controller parameters 
      avmm_addr_size       : integer := 24;
      avmm_burst_length    : integer := 2;
      avmm_bus_size        : integer := 32    
);
   port (
      wfm_load             : in std_logic;
      wfm_play_stop        : in std_logic; -- 1- play, 0- stop

      wfm_infifo_wrclk     : in std_logic;
      wfm_infifo_reset_n   : in std_logic;
      wfm_infifo_data      : in std_logic_vector(wfm_infifo_wrwidth-1 downto 0);
      wfm_infifo_wrreq     : in std_logic;
      wfm_infifo_wrusedw   : out std_logic_vector(wfm_infifo_wrsize-1 downto 0);
      wfm_infifo_wfull     : out std_logic; 
      
      wcmd_clk             : in std_logic;
      wcmd_reset_n         : in  std_logic;
      wcmd_rdy             : in std_logic;
      wcmd_addr            : out std_logic_vector(avmm_addr_size-1 downto 0);
      wcmd_wr              : out std_logic;
      wcmd_brst_en         : out std_logic; --1- writes in burst, 0- single write
      wcmd_data            : out std_logic_vector(avmm_bus_size-1 downto 0);
      rcmd_clk             : in std_logic;
      rcmd_reset_n         : in std_logic;
      rcmd_rdy             : in std_logic;
      rcmd_addr            : out std_logic_vector(avmm_addr_size-1 downto 0);
      rcmd_wr              : out std_logic;
      rcmd_brst_en         : out std_logic --1- reads in burst, 0- single read
        );
end wfm_player;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of wfm_player is
--declare signals,  components here

signal wfm_infifo_rdusedw 	            : std_logic_vector(wfm_infifo_rdsize-1 downto 0);
signal wfm_infifo_rdreq		            : std_logic;
signal wfm_infifo_q			            : std_logic_vector(avmm_bus_size-1 downto 0);
signal wfm_infifo_rdempty	            : std_logic;

signal wfm_load_wcmd_clk               : std_logic;
signal wfm_load_wcmd                   : std_logic;

signal wfm_load_rcmd_clk               : std_logic;

signal wcmd_last_addr                  : std_logic_vector(avmm_addr_size-1 downto 0);
signal rcmd_last_addr                  : std_logic_vector(avmm_addr_size-1 downto 0);

signal wfm_play_stop_sync_rcmd_clk     : std_logic;

signal sync_reg1_reset_n               : std_logic;

begin

sync_reg0 : entity work.sync_reg 
port map(wcmd_clk, '1', wfm_load, wfm_load_wcmd_clk);

sync_reg1 : entity work.sync_reg 
port map(rcmd_clk, sync_reg1_reset_n, wfm_play_stop, wfm_play_stop_sync_rcmd_clk);

sync_reg1_reset_n <= not wfm_load_rcmd_clk;

sync_reg2 : entity work.sync_reg 
port map(rcmd_clk, '1', wfm_load_wcmd, wfm_load_rcmd_clk);

bus_sync_reg0 : entity work.bus_sync_reg
generic map(avmm_addr_size)
port map(rcmd_clk, '1', wcmd_last_addr, rcmd_last_addr);

-- ----------------------------------------------------------------------------
-- WFM data buffer
-- ----------------------------------------------------------------------------
wfm_in_fifo	: entity work.fifo_inst 
generic map (
		dev_family			=> dev_family,
		wrwidth				=> wfm_infifo_wrwidth,
		wrusedw_witdth		=> wfm_infifo_wrsize, --9=256 words 
		rdwidth				=> wfm_infifo_rdwidth,
		rdusedw_width		=> wfm_infifo_rdsize,
		show_ahead			=> "ON"
)
port map (
      reset_n       		=> wfm_infifo_reset_n, 
      wrclk         		=> wfm_infifo_wrclk, 
      wrreq         		=> wfm_infifo_wrreq, 
      data          		=> wfm_infifo_data, 
      wrfull        		=> wfm_infifo_wfull, 
		wrempty		  		=> open, 
      wrusedw       		=> wfm_infifo_wrusedw, 
      rdclk 	     		=> wcmd_clk, 
      rdreq         		=> wfm_infifo_rdreq, 
      q             		=> wfm_infifo_q, 
      rdempty      		=> wfm_infifo_rdempty, 
      rdusedw       		=> wfm_infifo_rdusedw   
);

wcmd_data <= wfm_infifo_q;


-- ----------------------------------------------------------------------------
-- Make sure that wfm_load_wcmd goes low only when wfm_infifo is empty
-- ----------------------------------------------------------------------------
process(wcmd_clk, wcmd_reset_n)
begin
   if wcmd_reset_n = '0' then 
      wfm_load_wcmd <= '0';
   elsif (wcmd_clk'event AND wcmd_clk = '1') then 
      if wfm_load_wcmd_clk = '1' then 
         wfm_load_wcmd <= '1';
      elsif wfm_load_wcmd_clk = '0' AND wfm_infifo_rdempty = '1' then 
         wfm_load_wcmd <= '0';
      else 
         wfm_load_wcmd <= wfm_load_wcmd;
      end if;
   end if;
end process;


-- ----------------------------------------------------------------------------
-- WFM player write command FSM
-- ----------------------------------------------------------------------------
wfm_wcmd_fsm_inst : entity work.wfm_wcmd_fsm 
	generic map(
		dev_family				=> dev_family,  
		wfm_infifo_size		=> wfm_infifo_rdsize, 
		addr_size				=> avmm_addr_size, 
		lcl_burst_length		=> avmm_burst_length
)
	port map (
		wcmd_clk					=> wcmd_clk, 
		wcmd_reset_n			=> wcmd_reset_n, 
		wcmd_rdy					=> wcmd_rdy, 
		wcmd_addr				=> wcmd_addr, 
		wcmd_wr					=> wcmd_wr, 
		wcmd_brst_en			=> wcmd_brst_en,
		wcmd_last_addr			=> wcmd_last_addr,

		wfm_load					=> wfm_load_wcmd,

		wfm_infifo_rd			=> wfm_infifo_rdreq, 
		wfm_infifo_rdusedw 	=> wfm_infifo_rdusedw     
        );
       
-- ----------------------------------------------------------------------------
-- WFM player read command FSM
-- ----------------------------------------------------------------------------
wfm_rcmd_fsm_inst : entity work.wfm_rcmd_fsm 
	generic map(
			dev_family			=> dev_family,
			addr_size			=> avmm_addr_size,
			lcl_burst_length	=> avmm_burst_length
)
  port map(
      --input ports 
		rcmd_clk					=> rcmd_clk,
		rcmd_reset_n			=> rcmd_reset_n,
		rcmd_rdy					=> rcmd_rdy,
		rcmd_addr				=> rcmd_addr,
		rcmd_wr					=> rcmd_wr,
		rcmd_brst_en			=> rcmd_brst_en,

		wcmd_last_addr			=> rcmd_last_addr,
 
		wfm_load					=> wfm_load_rcmd_clk,
		wfm_play_stop			=> wfm_play_stop_sync_rcmd_clk
        
        );
 
end arch;   






