-- ----------------------------------------------------------------------------	
-- FILE: 	wfm_player_x2_top.vhd
-- DESCRIPTION:	describe
-- DATE:	June 20, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.FIFO_PACK.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity wfm_player_x2_top is
	generic(
			dev_family				   : string  := "Cyclone V GX"; 
			--DDR2 controller parameters
			cntrl_rate				   : integer := 1; --1 - full rate, 2 - half rate
			cntrl_bus_size			   : integer := 32;
			cntrl_addr_size		   : integer := 14;
			cntrl_ba_size			   : integer := 3;
         --multiport front end parameters
         mpfe_0_addr_size        : integer := 27;
         mpfe_0_bus_size         : integer := 32;
         mpfe_0_burst_length     : integer := 2;
         
         mpfe_1_addr_size        : integer := 26;
         mpfe_1_bus_size         : integer := 64;
         mpfe_1_burst_length     : integer := 2;
         
			--addr_size				   : integer := 24;
			--lcl_bus_size			   : integer := 32;
			--lcl_burst_length      : integer := 2;
         
			cmd_fifo_size			   : integer := 9;
			--WFM0 player parameters
			wfm0_infifo_size		   : integer := 11;
			wfm0_outfifo_size		   : integer := 11;
			wfm0_data_width		   : integer := 32;
			wfm0_iq_width			   : integer := 12;
			wfm0_dcmpr_infifo_size	: integer := 10;
         wfm0_dcmpr_outfifo_size	: integer := 10;
			--WFM1 player parameters
			wfm1_infifo_size		   : integer := 11;
			wfm1_outfifo_size		   : integer := 11;
			wfm1_data_width		   : integer := 32;
			wfm1_iq_width			   : integer := 12;
			wfm1_dcmpr_infifo_size	: integer := 10;
         wfm1_dcmpr_outfifo_size	: integer := 10;
			--outfifo buffer size
			outfifo_size_0			   : integer := 10;  -- outfifo buffer size
			outfifo_size_1			   : integer := 10  -- outfifo buffer size
			
);
  port (
      --input ports
		reset_n					: in std_logic;
		pll_ref_clk				: in std_logic;
	 
		wfm_load					: in std_logic_vector(1 downto 0);
		wfm_play_stop			: in std_logic_vector(1 downto 0); -- 1- play, 0- stop
		
		--WFM port 0
		wfm0_wcmd_clk			: in std_logic;
		wfm0_rcmd_clk			: in std_logic;

		wfm0_data				: in std_logic_vector(wfm0_data_width-1 downto 0);
		wfm0_wr					: in std_logic;
		wfm0_rdy					: out std_logic;
		wfm0_infifo_wrusedw 	: out std_logic_vector(wfm0_infifo_size-1 downto 0);
		
		wfm0_sample_width    : in std_logic_vector(1 downto 0); -- "00"-16bit, "01"-14bit, "10"-12bit
		wfm0_fr_start			: in std_logic;
		wfm0_ch_en				: in std_logic_vector(1 downto 0);
      wfm0_mimo_en			: in std_logic;
      wfm0_intrlv_dis      : in std_logic; -- 0 - interleaved data, 1 - paralel data

		wfm0_iq_clk				: in std_logic;
		wfm0_xen					: in std_logic; -- wfm 0 data read enable
		wfm0_Aiq_h				: out std_logic_vector(wfm0_iq_width downto 0);
		wfm0_Aiq_l				: out std_logic_vector(wfm0_iq_width downto 0);
		wfm0_Biq_h				: out std_logic_vector(wfm0_iq_width downto 0);
		wfm0_Biq_l				: out std_logic_vector(wfm0_iq_width downto 0);
--		wfm0_dd_iq_h_uns_0	: out std_logic_vector(15 downto 0);
--		wfm0_dd_iq_l_uns_0	: out std_logic_vector(15 downto 0);


		--WFM port 1
		wfm1_wcmd_clk			: in std_logic;
		wfm1_rcmd_clk			: in std_logic;

		wfm1_data				: in std_logic_vector(wfm1_data_width-1 downto 0);
		wfm1_wr					: in std_logic;
		wfm1_rdy					: out std_logic;
		wfm1_infifo_wrusedw 	: out std_logic_vector(wfm1_infifo_size-1 downto 0);
		
		wfm1_sample_width    : in std_logic_vector(1 downto 0); -- "00"-16bit, "01"-14bit, "10"-12bit
		wfm1_fr_start			: in std_logic;
		wfm1_ch_en				: in std_logic_vector(1 downto 0);
      wfm1_mimo_en			: in std_logic;
      wfm1_intrlv_dis      : in std_logic; -- 0 - interleaved data, 1 - paralel data

		wfm1_iq_clk				: in std_logic;
		wfm1_xen					: in std_logic; --wfm 1 data read enable
		wfm1_Aiq_h				: out std_logic_vector(wfm1_iq_width downto 0);
		wfm1_Aiq_l				: out std_logic_vector(wfm1_iq_width downto 0);
		wfm1_Biq_h				: out std_logic_vector(wfm1_iq_width downto 0);
		wfm1_Biq_l				: out std_logic_vector(wfm1_iq_width downto 0);
--		wfm1_dd_iq_h_uns		: out std_logic_vector(15 downto 0);
--		wfm1_dd_iq_l_uns		: out std_logic_vector(15 downto 0);

		--DDR2 external memory signals	
		--External memory signals
		mem_a                : out   std_logic_vector(13 downto 0);                    --             memory.mem_a
		mem_ba               : out   std_logic_vector(2 downto 0);                     --                   .mem_ba
		mem_ck               : out   std_logic_vector(0 downto 0);                     --                   .mem_ck
		mem_ck_n             : out   std_logic_vector(0 downto 0);                     --                   .mem_ck_n
		mem_cke              : out   std_logic_vector(0 downto 0);                     --                   .mem_cke
		mem_cs_n             : out   std_logic_vector(0 downto 0);                     --                   .mem_cs_n
		mem_dm               : out   std_logic_vector(3 downto 0);                     --                   .mem_dm
		mem_ras_n            : out   std_logic_vector(0 downto 0);                     --                   .mem_ras_n
		mem_cas_n            : out   std_logic_vector(0 downto 0);                     --                   .mem_cas_n
		mem_we_n             : out   std_logic_vector(0 downto 0);                     --                   .mem_we_n
		mem_reset_n          : out   std_logic;                                        --                   .mem_reset_n
		mem_dq               : inout std_logic_vector(31 downto 0); --                   .mem_dq
		mem_dqs              : inout std_logic_vector(3 downto 0); --                   .mem_dqs
		mem_dqs_n            : inout std_logic_vector(3 downto 0); --                   .mem_dqs_n
		mem_odt              : out   std_logic_vector(0 downto 0);                
		phy_clk					: out std_logic;
		oct_rzqin            : in    std_logic                     := '0';             --                oct.rzqin
		--aux_full_rate_clk	: out std_logic;
		--aux_half_rate_clk	: out std_logic;
		--reset_request_n		: out std_logic;
		begin_test				: in std_logic;
		insert_error			: in std_logic;
		pnf_per_bit         	: out std_logic_vector(31 downto 0);   
		pnf_per_bit_persist 	: out std_logic_vector(31 downto 0);
		pass                	: out std_logic;
		fail                	: out std_logic; 
		test_complete       	: out std_logic
		
        
        );
end wfm_player_x2_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of wfm_player_x2_top is
--declare signals,  components here

--WFM0 inst0 signals
signal inst0_wcmd_addr		: std_logic_vector(mpfe_0_addr_size-1 downto 0);
signal inst0_wcmd_wr			: std_logic;
signal inst0_wcmd_brst_en	: std_logic;
signal inst0_wcmd_data		: std_logic_vector(mpfe_0_bus_size-1 downto 0);
signal inst0_rcmd_addr		: std_logic_vector(mpfe_0_addr_size-1 downto 0);
signal inst0_rcmd_wr			: std_logic;
signal inst0_rcmd_brst_en 	: std_logic;
signal inst0_wcmd_reset_n	: std_logic;
signal inst0_rcmd_reset_n	: std_logic;

--WFM1 inst1 signals
signal inst1_wcmd_addr		: std_logic_vector(mpfe_1_addr_size-1 downto 0);
signal inst1_wcmd_wr			: std_logic;
signal inst1_wcmd_brst_en	: std_logic;
signal inst1_wcmd_data		: std_logic_vector(mpfe_1_bus_size-1 downto 0);
signal inst1_rcmd_addr		: std_logic_vector(mpfe_1_addr_size-1 downto 0);
signal inst1_rcmd_wr			: std_logic;
signal inst1_rcmd_brst_en 	: std_logic;
signal inst1_wcmd_reset_n	: std_logic;
signal inst1_rcmd_reset_n	: std_logic;

--DDR3 controller inst3 signals
signal inst3_reset_n					: std_logic;
signal inst3_wcmd_rdy_0				: std_logic;
signal inst3_rcmd_rdy_0				: std_logic;		
signal inst3_local_ready_0			: std_logic;
signal inst3_local_rdata_0			: std_logic_vector(mpfe_0_bus_size-1 downto 0);
signal inst3_local_rdata_valid_0	: std_logic;
signal inst3_wcmd_rdy_1				: std_logic;
signal inst3_rcmd_rdy_1				: std_logic;
signal inst3_local_ready_1			: std_logic;
signal inst3_local_rdata_1			: std_logic_vector(mpfe_1_bus_size-1 downto 0);
signal inst3_local_rdata_valid_1	: std_logic;
signal inst3_local_init_done		: std_logic;             
signal inst3_phy_clk					: std_logic;

--inst4 signals
signal inst4_wusedw					: std_logic_vector(wfm0_dcmpr_infifo_size-1 downto 0);
signal inst4_reset_n					: std_logic;


--inst5 signals
signal inst5_wusedw					: std_logic_vector(wfm1_dcmpr_infifo_size-1 downto 0);
signal inst5_reset_n					: std_logic;

--general signals
signal wfm_load_int					: std_logic;
signal wfm_load_int_reg				: std_logic_vector(2 downto 0);
signal wfm0_load_sync				: std_logic_vector(2 downto 0);
signal wfm1_load_sync				: std_logic_vector(2 downto 0);



component DDR3_avmm_2x32_ctrl is
		generic(
			dev_family	     	   : string  := "Cyclone V GX";
			cntrl_rate			   : integer := 1; --1 - full rate, 2 - half rate
			cntrl_addr_size	   : integer := 14;
			cntrl_ba_size		   : integer := 3;
			cntrl_bus_size		   : integer := 32;
         --multiport front end parameters
         mpfe_0_addr_size     : integer := 27;
         mpfe_0_bus_size      : integer := 32;
         mpfe_0_burst_length  : integer := 2;         
         mpfe_1_addr_size     : integer := 26;
         mpfe_1_bus_size      : integer := 64;
         mpfe_1_burst_length  : integer := 2;
         
--			addr_size			   : integer := 27;
--			lcl_bus_size		   : integer := 32;
--			lcl_burst_length	   : integer := 2;
			cmd_fifo_size		   : integer := 9;
			outfifo_size_0		   : integer := 10;  -- outfifo buffer size
			outfifo_size_1		   : integer := 10  -- outfifo buffer size
		);
		port (

      pll_ref_clk       	   : in std_logic;
      global_reset_n   		   : in std_logic;
		soft_reset_n			   : in std_logic;
		--Port 0    
		wcmd_clk_0				   : in std_logic;
		wcmd_reset_n_0			   : in  std_logic;
		wcmd_rdy_0				   : out std_logic;
		wcmd_addr_0				   : in std_logic_vector(mpfe_0_addr_size-1 downto 0);
		wcmd_wr_0				   : in std_logic;
		wcmd_brst_en_0			   : in std_logic; --1- writes in burst, 0- single write
		wcmd_data_0				   : in std_logic_vector(mpfe_0_bus_size-1 downto 0);
		rcmd_clk_0				   : in std_logic;
		rcmd_reset_n_0			   : in  std_logic;
		rcmd_rdy_0				   : out std_logic;
		rcmd_addr_0				   : in std_logic_vector(mpfe_0_addr_size-1 downto 0);
		rcmd_wr_0				   : in std_logic;
		rcmd_brst_en_0			   : in std_logic; --1- reads in burst, 0- single read
		outbuf_wrusedw_0		   : in std_logic_vector(outfifo_size_0-1 downto 0);
         
		local_ready_0			   : out std_logic;
		local_rdata_0			   : out std_logic_vector(mpfe_0_bus_size-1 downto 0);
		local_rdata_valid_0	   : out std_logic;
		
		--Port 1 
		wcmd_clk_1				   : in std_logic;
		wcmd_reset_n_1			   : in  std_logic;
		wcmd_rdy_1				   : out std_logic;
		wcmd_addr_1				   : in std_logic_vector(mpfe_1_addr_size-1 downto 0);
		wcmd_wr_1				   : in std_logic;
		wcmd_brst_en_1			   : in std_logic; --1- writes in burst, 0- single write
		wcmd_data_1				   : in std_logic_vector(mpfe_1_bus_size-1 downto 0);
		rcmd_clk_1				   : in std_logic;
		rcmd_reset_n_1			   : in  std_logic;
		rcmd_rdy_1				   : out std_logic;
		rcmd_addr_1				   : in std_logic_vector(mpfe_1_addr_size-1 downto 0);
		rcmd_wr_1				   : in std_logic;
		rcmd_brst_en_1			   : in std_logic; --1- reads in burst, 0- single read
		outbuf_wrusedw_1		   : in std_logic_vector(outfifo_size_0-1 downto 0);
   
		local_ready_1			   : out std_logic;
		local_rdata_1			   : out std_logic_vector(mpfe_1_bus_size-1 downto 0);
		local_rdata_valid_1	   : out std_logic;
		local_init_done		   : out std_logic;

		--External memory signals
		mem_a                   : out   std_logic_vector(13 downto 0);                    --             memory.mem_a
		mem_ba                  : out   std_logic_vector(2 downto 0);                     --                   .mem_ba
		mem_ck                  : out   std_logic_vector(0 downto 0);                     --                   .mem_ck
		mem_ck_n                : out   std_logic_vector(0 downto 0);                     --                   .mem_ck_n
		mem_cke                 : out   std_logic_vector(0 downto 0);                     --                   .mem_cke
		mem_cs_n                : out   std_logic_vector(0 downto 0);                     --                   .mem_cs_n
		mem_dm                  : out   std_logic_vector(3 downto 0);                     --                   .mem_dm
		mem_ras_n               : out   std_logic_vector(0 downto 0);                     --                   .mem_ras_n
		mem_cas_n               : out   std_logic_vector(0 downto 0);                     --                   .mem_cas_n
		mem_we_n                : out   std_logic_vector(0 downto 0);                     --                   .mem_we_n
		mem_reset_n             : out   std_logic;                                        --                   .mem_reset_n
		mem_dq                  : inout std_logic_vector(31 downto 0) := (others => '0'); --                   .mem_dq
		mem_dqs                 : inout std_logic_vector(3 downto 0)  := (others => '0'); --                   .mem_dqs
		mem_dqs_n               : inout std_logic_vector(3 downto 0)  := (others => '0'); --                   .mem_dqs_n
		mem_odt                 : out   std_logic_vector(0 downto 0);                
		phy_clk					   : out std_logic;
		oct_rzqin               : in    std_logic                     := '0';             --                oct.rzqin
		--aux_full_rate_clk	   : out std_logic;
		--aux_half_rate_clk	   : out std_logic;
		--reset_request_n		   : out std_logic;
		begin_test				   : in std_logic;
		insert_error			   : in std_logic;
		pnf_per_bit         	   : out std_logic_vector(31 downto 0);   
		pnf_per_bit_persist 	   : out std_logic_vector(31 downto 0);
		pass                	   : out std_logic;
		fail                	   : out std_logic; 
		test_complete       	   : out std_logic
 
        );
end component;

component wfm_player is
	generic(
		dev_family				: string  := "Cyclone IV E";
      --Parameters for FIFO buffer before external memory
      wfm_infifo_wrwidth   : integer := 32;
      wfm_infifo_wrsize		: integer := 11;
      wfm_infifo_rdwidth   : integer := 32;
      wfm_infifo_rdsize		: integer := 11;      
      --Avalon MM interface of external memory controller parameters 
		avmm_addr_size		   : integer := 24;
		avmm_burst_length		: integer := 2;
		avmm_bus_size			: integer := 32
                 
);
  port (
		ddr2_phy_clk			: in std_logic;
		ddr2_phy_reset_n		: in std_logic;

		wfm_load					: in std_logic;
		wfm_play_stop			: in std_logic; -- 1- play, 0- stop

		wfm_data					: in std_logic_vector(wfm_infifo_wrwidth-1 downto 0);
		wfm_wr					: in std_logic;
		wfm_infifo_wrusedw 	: out std_logic_vector(wfm_infifo_wrsize-1 downto 0);

		wcmd_clk					: in std_logic;
		wcmd_reset_n			: in  std_logic;
		wcmd_rdy					: in std_logic;
		wcmd_addr				: out std_logic_vector(avmm_addr_size-1 downto 0);
		wcmd_wr					: out std_logic;
		wcmd_brst_en			: out std_logic; --1- writes in burst, 0- single write
		wcmd_data				: out std_logic_vector(avmm_bus_size-1 downto 0);
		rcmd_clk					: in std_logic;
		rcmd_reset_n			: in std_logic;
		rcmd_rdy					: in std_logic;
		rcmd_addr				: out std_logic_vector(avmm_addr_size-1 downto 0);
		rcmd_wr					: out std_logic;
		rcmd_brst_en			: out std_logic --1- reads in burst, 0- single read
		
        );
end component;

component decompress_top is
  generic (
			dev_family 	         : string  := "Cyclone V";
			datain_width 	      : integer := 64; --IN data width
         infifo_wrwidth       : integer := 64; --Should be same as datain_width
         infifo_rdwidth       : integer := 64;
			infifo_rsize	      : integer := 9;
			infifo_wsize	      : integer := 9;
         decompr_fifo_wrwidth : integer := 128;
         decompr_fifo_rdwidth : integer := 64;
         decompr_fifo_rsize   : integer := 7;
         decompr_fifo_wsize   : integer := 8;
			iq_width		         : integer := 16
         );
  port (
			--input ports 
			wclk          	: in std_logic;
			rclk          	: in std_logic;
			reset_n       	: in std_logic;
			data_in       	: in std_logic_vector(datain_width-1 downto 0);
			data_in_valid 	: in std_logic; -- data_in leading signal which indicates valid incomong data
			sample_width  	: in std_logic_vector(1 downto 0); -- "00"-16bit, "01"-14bit, "10"-12bit
			xen 				: in std_logic; --data read enable
		   --output ports  
			wusedw        	: out std_logic_vector(infifo_wsize-1 downto 0);
			fr_start  		: in std_logic;
			ch_en				: in std_logic_vector(1 downto 0);
			mimo_en			: in std_logic;
         intrlv_dis     : in std_logic; -- 0 - interleaved data, 1 - paralel data
			A_diq_h			: out std_logic_vector(iq_width downto 0);				
			A_diq_l			: out std_logic_vector(iq_width downto 0);
			B_diq_h			: out std_logic_vector(iq_width downto 0);				
			B_diq_l			: out std_logic_vector(iq_width downto 0)
        );
end component;


begin

wfm_load_int<= wfm_load(0) OR wfm_load(1);
-- ----------------------------------------------------------------------------
--Memory reset signal
-- ----------------------------------------------------------------------------
process (reset_n, pll_ref_clk) is 
begin 
	if reset_n='0' then 
		inst3_reset_n<='1';
		wfm_load_int_reg<=(others=>'0');
	elsif (pll_ref_clk'event and pll_ref_clk='1') then
		wfm_load_int_reg<=wfm_load_int_reg(1 downto 0) & wfm_load_int;
			if wfm_load_int_reg(1)='1' and wfm_load_int_reg(2)='0' then	
				inst3_reset_n<='0';
			else 
				inst3_reset_n<='1';
			end if;
	end if; 		
end process;




-- ----------------------------------------------------------------------------
-- To synchronize inst3_local_init_done signal to wfm0_wcmd_clk
-- ----------------------------------------------------------------------------
sync_reg0 : entity work.sync_reg 
port map(wfm0_wcmd_clk, '1', inst3_local_init_done, inst0_wcmd_reset_n);

wfm0_rdy<=inst0_wcmd_reset_n;

-- ----------------------------------------------------------------------------
-- To synchronize inst3_local_init_done signal to wfm0_rcmd_clk
-- ----------------------------------------------------------------------------
sync_reg1 : entity work.sync_reg 
port map(wfm0_rcmd_clk, '1', inst3_local_init_done, inst0_rcmd_reset_n);


-- ----------------------------------------------------------------------------
-- WFM player inst0
-- ----------------------------------------------------------------------------
wfm_player_inst0 : wfm_player
	generic map (
      dev_family				=> dev_family,
      --Parameters for FIFO
      wfm_infifo_wrwidth   => wfm0_data_width,
      wfm_infifo_wrsize		=> wfm0_infifo_size,
      wfm_infifo_rdwidth   => mpfe_0_bus_size,
      wfm_infifo_rdsize		=> FIFORD_SIZE(wfm0_data_width, 
                              mpfe_0_bus_size, 
                              wfm0_infifo_size),
      --Avalon MM interface
      avmm_addr_size		   => mpfe_0_addr_size,
      avmm_burst_length		=> mpfe_0_burst_length,
      avmm_bus_size			=> mpfe_0_bus_size
)
  port map(

		ddr2_phy_clk			=> inst3_phy_clk,
		ddr2_phy_reset_n		=> inst3_local_init_done,

		wfm_load					=> wfm_load(0),
		wfm_play_stop			=> wfm_play_stop(0),

		wfm_data					=> wfm0_data,
		wfm_wr					=> wfm0_wr,
		wfm_infifo_wrusedw 	=> wfm0_infifo_wrusedw,

		wcmd_clk					=> wfm0_wcmd_clk,
		wcmd_reset_n			=> inst0_wcmd_reset_n,
		wcmd_rdy					=> inst3_wcmd_rdy_0,
		wcmd_addr				=> inst0_wcmd_addr,
		wcmd_wr					=> inst0_wcmd_wr,
		wcmd_brst_en			=> inst0_wcmd_brst_en,
		wcmd_data				=> inst0_wcmd_data,
		rcmd_clk					=> wfm0_rcmd_clk,
		rcmd_reset_n			=> inst0_rcmd_reset_n,
		rcmd_rdy					=> inst3_rcmd_rdy_0,
		rcmd_addr				=> inst0_rcmd_addr,
		rcmd_wr					=> inst0_rcmd_wr,
		rcmd_brst_en			=> inst0_rcmd_brst_en

        );
		  

-- ----------------------------------------------------------------------------
-- To synchronize inst3_local_init_done signal to wfm1_wcmd_clk
-- ----------------------------------------------------------------------------
sync_reg2 : entity work.sync_reg 
port map(wfm1_wcmd_clk, '1', inst3_local_init_done, inst1_wcmd_reset_n);

wfm1_rdy<=inst1_wcmd_reset_n;

-- ----------------------------------------------------------------------------
-- To synchronize inst3_local_init_done signal to wfm1_rcmd_clk
-- ----------------------------------------------------------------------------
sync_reg3 : entity work.sync_reg 
port map(wfm1_rcmd_clk, '1', inst3_local_init_done, inst1_rcmd_reset_n);


-- ----------------------------------------------------------------------------
-- WFM player inst1
-- ----------------------------------------------------------------------------
wfm_player_inst1 : wfm_player
	generic map (
      dev_family				=> dev_family,
      --Parameters for FIFO
      wfm_infifo_wrwidth   => wfm1_data_width,
      wfm_infifo_wrsize		=> wfm1_infifo_size,
      wfm_infifo_rdwidth   => mpfe_1_bus_size,
      wfm_infifo_rdsize		=> FIFORD_SIZE(wfm1_data_width, 
                              mpfe_1_bus_size, 
                              wfm1_infifo_size),
      --Avalon MM interface
      avmm_addr_size		   => mpfe_1_addr_size,
      avmm_burst_length		=> mpfe_1_burst_length,
      avmm_bus_size			=> mpfe_1_bus_size
)
  port map(

		ddr2_phy_clk			=> inst3_phy_clk,
		ddr2_phy_reset_n		=> inst3_local_init_done,

		wfm_load					=> wfm_load(1),
		wfm_play_stop			=> wfm_play_stop(1),

		wfm_data					=> wfm1_data,
		wfm_wr					=> wfm1_wr,
		wfm_infifo_wrusedw 	=> wfm1_infifo_wrusedw,

		wcmd_clk					=> wfm1_wcmd_clk,
		wcmd_reset_n			=> inst1_wcmd_reset_n,
		wcmd_rdy					=> inst3_wcmd_rdy_1,
		wcmd_addr				=> inst1_wcmd_addr,
		wcmd_wr					=> inst1_wcmd_wr,
		wcmd_brst_en			=> inst1_wcmd_brst_en,
		wcmd_data				=> inst1_wcmd_data,
		rcmd_clk					=> wfm1_rcmd_clk,
		rcmd_reset_n			=> inst1_rcmd_reset_n,
		rcmd_rdy					=> inst3_rcmd_rdy_1,
		rcmd_addr				=> inst1_rcmd_addr,
		rcmd_wr					=> inst1_rcmd_wr,
		rcmd_brst_en			=> inst1_rcmd_brst_en

        );	
	

DDR3_avmm_2x32_ctrl_inst3 : DDR3_avmm_2x32_ctrl
		generic map(
			dev_family	     	   => dev_family,
			cntrl_rate			   => cntrl_rate,
			cntrl_addr_size	   => cntrl_addr_size,
			cntrl_ba_size		   => cntrl_ba_size,
			cntrl_bus_size		   => cntrl_bus_size ,
         mpfe_0_addr_size     => mpfe_0_addr_size,
         mpfe_0_bus_size      => mpfe_0_bus_size,
         mpfe_0_burst_length  => mpfe_0_burst_length,        
         mpfe_1_addr_size     => mpfe_1_addr_size,
         mpfe_1_bus_size      => mpfe_1_bus_size,
         mpfe_1_burst_length  => mpfe_1_burst_length,
			cmd_fifo_size		   => cmd_fifo_size,
			outfifo_size_0		   => wfm0_dcmpr_infifo_size,
			outfifo_size_1		   => wfm1_dcmpr_infifo_size
		)
		port map(

      pll_ref_clk       	=> pll_ref_clk,
      global_reset_n   		=> inst3_reset_n,
		soft_reset_n			=> inst3_reset_n,
		--Port 0 
		wcmd_clk_0				=> wfm0_wcmd_clk,
		wcmd_reset_n_0			=> inst0_wcmd_reset_n,
		wcmd_rdy_0				=> inst3_wcmd_rdy_0,
		wcmd_addr_0				=> inst0_wcmd_addr,
		wcmd_wr_0				=> inst0_wcmd_wr,
		wcmd_brst_en_0			=> inst0_wcmd_brst_en,
		wcmd_data_0				=> inst0_wcmd_data,
		rcmd_clk_0				=> wfm0_rcmd_clk,
		rcmd_reset_n_0			=> inst0_rcmd_reset_n,
		rcmd_rdy_0				=> inst3_rcmd_rdy_0,
		rcmd_addr_0				=> inst0_rcmd_addr,
		rcmd_wr_0				=> inst0_rcmd_wr,
		rcmd_brst_en_0			=> inst0_rcmd_brst_en,
		outbuf_wrusedw_0		=> inst4_wusedw,
		
		local_ready_0			=> inst3_local_ready_0,
		local_rdata_0			=> inst3_local_rdata_0,
		local_rdata_valid_0	=> inst3_local_rdata_valid_0,
		
		--Port 1 
		wcmd_clk_1				=> wfm1_wcmd_clk,
		wcmd_reset_n_1			=> inst1_wcmd_reset_n,
		wcmd_rdy_1				=> inst3_wcmd_rdy_1,
		wcmd_addr_1				=> inst1_wcmd_addr,
		wcmd_wr_1				=> inst1_wcmd_wr,
		wcmd_brst_en_1			=> inst1_wcmd_brst_en,
		wcmd_data_1				=> inst1_wcmd_data,
		rcmd_clk_1				=> wfm1_rcmd_clk,
		rcmd_reset_n_1			=> inst1_rcmd_reset_n,
		rcmd_rdy_1				=> inst3_rcmd_rdy_1,
		rcmd_addr_1				=> inst1_rcmd_addr,
		rcmd_wr_1				=> inst1_rcmd_wr,
		rcmd_brst_en_1			=> inst1_rcmd_brst_en,
		outbuf_wrusedw_1		=> inst5_wusedw,

		local_ready_1			=> inst3_local_ready_1,
		local_rdata_1			=> inst3_local_rdata_1,
		local_rdata_valid_1	=> inst3_local_rdata_valid_1,
		local_init_done		=> inst3_local_init_done,

		--External memory signals
		mem_a                => mem_a,								--             memory.mem_a
		mem_ba               => mem_ba,                     	--                   .mem_ba
		mem_ck               => mem_ck,                     	--                   .mem_ck
		mem_ck_n             => mem_ck_n,                     --                   .mem_ck_n
		mem_cke              => mem_cke,                     	--                   .mem_cke
		mem_cs_n             => mem_cs_n,                     --                   .mem_cs_n
		mem_dm              	=> mem_dm,                     	--                   .mem_dm
		mem_ras_n            => mem_ras_n,                    --                   .mem_ras_n
		mem_cas_n            => mem_cas_n,                    --                   .mem_cas_n
		mem_we_n             => mem_we_n,                    	--                   .mem_we_n
		mem_reset_n          => mem_reset_n,                                        --                   .mem_reset_n
		mem_dq               => mem_dq, 								--                   .mem_dq
		mem_dqs             	=> mem_dqs, 							--                   .mem_dqs
		mem_dqs_n            => mem_dqs_n, 							--                   .mem_dqs_n
		mem_odt              => mem_odt,                
		phy_clk					=> inst3_phy_clk,
		oct_rzqin            => oct_rzqin,             			--                oct.rzqin
		--aux_full_rate_clk	=> ,
		--aux_half_rate_clk	=> ,
		--reset_request_n		=> ,
		begin_test				=> begin_test,
		insert_error			=> insert_error,
		pnf_per_bit         	=> pnf_per_bit ,   
		pnf_per_bit_persist 	=> pnf_per_bit_persist,
		pass                	=> pass,
		fail                	=> fail, 
		test_complete       	=> test_complete
 
       );
	

	
-- ----------------------------------------------------------------------------
-- To synchronize wfm_load(0) signal to wfm0_iq_clk
-- ----------------------------------------------------------------------------
process (reset_n, wfm0_iq_clk) is 
begin 
	if reset_n='0' then 
		wfm0_load_sync<=(others=>'0');
	elsif (wfm0_iq_clk'event and wfm0_iq_clk='1') then 
		wfm0_load_sync<=wfm0_load_sync(1 downto 0) & wfm_load(0);
	end if; 		
end process;
	
	
inst4_reset_n<= not wfm0_load_sync(2);
		 
decompress_top_inst4 : decompress_top
  generic map (
         dev_family 	         => dev_family,
			datain_width 	      => mpfe_0_bus_size,
         infifo_wrwidth       => mpfe_0_bus_size,
         infifo_rdwidth       => 64,
         infifo_wsize	      => wfm0_dcmpr_infifo_size,
			infifo_rsize	      => FIFORD_SIZE(mpfe_0_bus_size, 
                                 64, 
                                 wfm0_dcmpr_infifo_size),
         decompr_fifo_wrwidth => 128,
         decompr_fifo_rdwidth => 64,
         decompr_fifo_wsize   => wfm0_dcmpr_infifo_size-1,
         decompr_fifo_rsize   => FIFORD_SIZE(128, 
                                 64, 
                                 wfm0_dcmpr_infifo_size-1),
			iq_width		         => wfm0_iq_width
			)
  port map (
			--input ports 
			wclk          	=> inst3_phy_clk,
			rclk          	=> wfm0_iq_clk,
			reset_n       	=> inst4_reset_n,
			data_in       	=> inst3_local_rdata_0,
			data_in_valid 	=> inst3_local_rdata_valid_0,
			sample_width  	=> wfm0_sample_width,
			xen				=> wfm0_xen,
		   --output ports  
			wusedw        	=> inst4_wusedw,
			fr_start  		=> wfm0_fr_start,
			ch_en				=> wfm0_ch_en,
			mimo_en			=> wfm0_mimo_en,
         intrlv_dis     => wfm0_intrlv_dis,
			A_diq_h			=> wfm0_Aiq_h,
			A_diq_l			=> wfm0_Aiq_l,
			B_diq_h			=> wfm0_Biq_h,
			B_diq_l			=> wfm0_Biq_l 
        );
		  
-- ----------------------------------------------------------------------------
-- To synchronize wfm_load(1) signal to wfm1_iq_clk
-- ----------------------------------------------------------------------------
process (reset_n, wfm1_iq_clk) is 
begin 
	if reset_n='0' then 
		wfm1_load_sync<=(others=>'0');
	elsif (wfm1_iq_clk'event and wfm1_iq_clk='1') then 
		wfm1_load_sync<=wfm1_load_sync(1 downto 0) & wfm_load(1);
	end if; 		
end process;

inst5_reset_n<= not wfm1_load_sync(2);
	
		 
decompress_top_inst5 : decompress_top
  generic map (
         dev_family 	         => dev_family,
			datain_width 	      => mpfe_1_bus_size,
         infifo_wrwidth       => mpfe_1_bus_size,
         infifo_rdwidth       => 64,
         infifo_wsize	      => wfm1_dcmpr_infifo_size,
			infifo_rsize	      => FIFORD_SIZE(mpfe_1_bus_size, 
                                 64, 
                                 wfm1_dcmpr_infifo_size),
         decompr_fifo_wrwidth => 128,
         decompr_fifo_rdwidth => 64,
         decompr_fifo_wsize   => wfm1_dcmpr_infifo_size-1,
         decompr_fifo_rsize   => FIFORD_SIZE(128, 
                                 64, 
                                 wfm1_dcmpr_infifo_size-1),
			iq_width		         => wfm1_iq_width
			)
  port map (
			--input ports 
			wclk          	=> inst3_phy_clk,
			rclk          	=> wfm1_iq_clk,
			reset_n       	=> inst5_reset_n,
			data_in       	=> inst3_local_rdata_1,
			data_in_valid 	=> inst3_local_rdata_valid_1,
			sample_width  	=> wfm1_sample_width,
			xen				=> wfm1_xen,
		   --output ports  
			wusedw        	=> inst5_wusedw,
			fr_start  		=> wfm1_fr_start,
			ch_en				=> wfm1_ch_en,
			mimo_en			=> wfm1_mimo_en,
         intrlv_dis     => wfm1_intrlv_dis,
			A_diq_h			=> wfm1_Aiq_h,
			A_diq_l			=> wfm1_Aiq_l,
			B_diq_h			=> wfm1_Biq_h,
			B_diq_l			=> wfm1_Biq_l 
        );

phy_clk<=inst3_phy_clk;
	

end arch;   
