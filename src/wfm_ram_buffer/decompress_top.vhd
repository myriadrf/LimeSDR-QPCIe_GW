-- ----------------------------------------------------------------------------	
-- FILE: 	decompress_top.vhd
-- DESCRIPTION:	data decompressor
-- DATE:	Oct 13, 2015
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
LIBRARY altera_mf;
USE altera_mf.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity decompress_top is
  generic (
			dev_family 	: string  := "Cyclone IV E";
			data_width 	: integer := 32;
			data_rwidth	: integer := 64;
			fifo_rsize	: integer := 9;
			fifo_wsize	: integer := 10);
  port (
			--input ports 
			wclk          	: in std_logic;
			rclk          	: in std_logic;
			reset_n       	: in std_logic;
			data_in       	: in std_logic_vector(data_width-1 downto 0);
			data_in_valid 	: in std_logic; -- data_in leading signal which indicates valid incomong data
			sample_width  	: in std_logic_vector(1 downto 0); -- "00"-16bit, "01"-14bit, "10"-12bit
			xen				: in std_logic; -- data read enable
		   --output ports  
			wusedw        	: out std_logic_vector(fifo_wsize-1 downto 0);
			fr_start  		: in std_logic;
			ch_en				: in std_logic_vector(1 downto 0);
			mimo_en			: in std_logic;
			A_diq_h			: out std_logic_vector(15 downto 0);				
			A_diq_l			: out std_logic_vector(15 downto 0);
			B_diq_h			: out std_logic_vector(15 downto 0);				
			B_diq_l			: out std_logic_vector(15 downto 0)

     
        );
end decompress_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of decompress_top is
		
--inst0 signals	
signal inst0_rdempty 		: std_logic;
signal inst0_decmpr_data 	: std_logic_vector(data_rwidth-1 downto 0);
--inst1 signals
signal inst1_fifo_read 		: std_logic;
signal inst1_diq_h			: std_logic_vector(12 downto 0);
signal inst1_diq_l			: std_logic_vector(12 downto 0);
signal inst1_fifo_q			: std_logic_vector(47 downto 0);

--inst2 
signal xen_div					: std_logic;

signal A_diq_h_reg			: std_logic_vector(15 downto 0);				
signal A_diq_l_reg			: std_logic_vector(15 downto 0);
signal B_diq_h_reg			: std_logic_vector(15 downto 0);				
signal B_diq_l_reg		   : std_logic_vector(15 downto 0);



component decompress is
  generic (
			dev_family 		: string  := "Cyclone IV E";
			data_width 		: integer := 31;
			data_rwidth		: integer := 32;
			fifo_rsize		: integer := 9 ;
			fifo_wsize		: integer := 10
			);
  port (
        --input ports 
			wclk          : in std_logic;
			rclk          : in std_logic;
			reset_n       : in std_logic;
			data_in       : in std_logic_vector(data_width-1 downto 0);
			data_in_valid : in std_logic; -- data_in leading signal which indicates valid incomong data
			sample_width  : in std_logic_vector(1 downto 0); -- "00"-16bit, "01"-14bit, "10"-12bit
			rdreq         : in std_logic;
			rdempty       : out std_logic;
			rdusedw       : out std_logic_vector(fifo_rsize-1 downto 0);
			wfull         : out std_logic;
			wusedw        : out std_logic_vector(fifo_wsize-1 downto 0);
			dataout_valid : out std_logic;
			decmpr_data   : out std_logic_vector(data_rwidth-1 downto 0)    
        );
end component;


component rd_tx_fifo_v2 is
  generic(sampl_width : integer:=12);
  port (
        --input ports 
      clk			: in std_logic;
      reset_n		: in std_logic;
      fr_start  	: in std_logic;
      ch_en			: in std_logic_vector(1 downto 0);
      mimo_en		: in std_logic;
      fifo_empty	: in std_logic;
      fifo_data	: in std_logic_vector(63 downto 0);
		xen			: in std_logic; --data read enable
		--output ports 
      fifo_read	: out std_logic;
      diq_h			: out std_logic_vector(15 downto 0);
      diq_l			: out std_logic_vector(15 downto 0)
        );
end component;

begin

-- ----------------------------------------------------------------------------
-- Payload decompress module
-- ----------------------------------------------------------------------------	 
decompress_inst0 :  decompress 
  generic map  (
					dev_family => dev_family,
					data_width => data_width,
					data_rwidth=> data_rwidth,
               fifo_rsize => fifo_rsize,
					fifo_wsize => fifo_wsize
					)
  port map(
        --input ports 
        wclk          => wclk,  
        rclk          => rclk, 
        reset_n       => reset_n, 
        data_in       => data_in, 
        data_in_valid => data_in_valid, 
        sample_width  => sample_width,
        rdreq         => inst1_fifo_read,
        rdempty       => inst0_rdempty,
        rdusedw       => open, 
        wfull         => open, 
        wusedw        => wusedw,
        dataout_valid => open,  
        decmpr_data   => inst0_decmpr_data    
        );	
		 
-- ----------------------------------------------------------------------------
-- Read and form samples from decompress fifo
-- ----------------------------------------------------------------------------			
--rd_tx_fifo_ins1 : rd_tx_fifo_v2 
--  generic map (sampl_width =>12)
--  port map (
--      clk			=> rclk,
--      reset_n		=> reset_n, 
--      fr_start  	=> fr_start, 
--      ch_en			=> "11",
--      mimo_en		=> mimo_en,
--      fifo_empty	=> inst0_rdempty,
--      fifo_data	=> inst0_decmpr_data,
--		xen 			=> xen, 
--      fifo_read	=> inst1_fifo_read, 
--      diq_h			=> inst1_diq_h, 
--      diq_l			=> inst1_diq_l
--        );
	

inst1_fifo_q <=  inst0_decmpr_data(27 downto 16) & inst0_decmpr_data(11 downto 0) & inst0_decmpr_data(59 downto 48) & inst0_decmpr_data(43 downto 32);
	
inst1_diq2fifo : entity work.fifo2diq
	generic map( 
      dev_family				=> "Cyclone V GX",
      iq_width					=> 12
	)
	port map (
      clk            => rclk,
      reset_n        => reset_n ,
      mode			   => '0',
		trxiqpulse	   => '0',
		ddr_en 		   => '1',
		mimo_en		   => mimo_en,
		ch_en			   => "11",
		fidm			   => fr_start,
      xen            => xen,--xen_div,
      DIQ		 	   => open,
		fsync	 	      => open,
		DIQ_H				=> inst1_diq_h,
		DIQ_L				=> inst1_diq_l,
      fifo_rdempty   => inst0_rdempty,
      fifo_rdreq     => inst1_fifo_read,
      fifo_q         => inst1_fifo_q
     
        ); 
		  
		  
inst2_pulse_div : entity work.pulse_div
port map (
      clk       => rclk,
      reset_n   => reset_n,
      pulse_in  => xen,
      pulse_div => xen_div
);
		 
--process(rclk, reset_n)begin
--	if(reset_n = '0')then
--		A_diq_h_reg<=(others=>'0');
--		A_diq_l_reg<=(others=>'0');
--	elsif(rclk'event and rclk = '1')then 
--		if ch_en = "01" then 
--			A_diq_h_reg<=inst1_diq_h;
--			A_diq_l_reg<=inst1_diq_l;
--		elsif ch_en = "11" then
--			if inst1_diq_h(12) = fr_start then 
--				A_diq_h_reg<=inst1_diq_h;
--				A_diq_l_reg<=inst1_diq_l;
--			else 
--				A_diq_h_reg<=A_diq_h_reg;
--				A_diq_l_reg<=A_diq_l_reg;
--			end if;
--		else
--			A_diq_h_reg<=(others=>'0');
--			A_diq_l_reg<=(others=>'0');
--		end if;			
--	end if;	
--end process;

--process(rclk, reset_n)begin
--	if(reset_n = '0')then
--		B_diq_h_reg<=(others=>'0');
--		B_diq_l_reg<=(others=>'0');
--	elsif(rclk'event and rclk = '1')then 
--		if ch_en = "10" then 
--			B_diq_h_reg<=inst1_diq_h;
--			B_diq_l_reg<=inst1_diq_l;
--		elsif ch_en = "11" then
--			if inst1_diq_h(12) /= fr_start then 
--				B_diq_h_reg<=inst1_diq_h;
--				B_diq_l_reg<=inst1_diq_l;
--			else 
--				B_diq_h_reg<=B_diq_h_reg;
--				B_diq_l_reg<=B_diq_l_reg;
--			end if;
--		else
--			B_diq_h_reg<=(others=>'0');
--			B_diq_l_reg<=(others=>'0');
--		end if;			
--	end if;	
--end process;	

A_diq_h <= "000" & inst1_diq_h;				
A_diq_l <= "000" & inst1_diq_l;
B_diq_h <= (others=>'0');				
B_diq_l <= (others=>'0');	
	

end arch;   

