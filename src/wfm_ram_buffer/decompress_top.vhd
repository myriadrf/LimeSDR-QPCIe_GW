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
			dev_family 	         : string  := "Cyclone V";
			datain_width 	      : integer := 64; --IN data width
         infifo_wrwidth       : integer := 64; --Should be same as datain_width
         infifo_rdwidth       : integer := 64;
         infifo_wsize	      : integer := 9;
			infifo_rsize	      : integer := 9;
         decompr_fifo_wrwidth : integer := 128;
         decompr_fifo_rdwidth : integer := 64;
         decompr_fifo_wsize   : integer := 8;
         decompr_fifo_rsize   : integer := 7;
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
			xen				: in std_logic; -- data read enable
         wfm_play       : in std_logic;
		   --output ports  
			wusedw        	: out std_logic_vector(infifo_wsize-1 downto 0);
			fr_start  		: in std_logic;
			ch_en				: in std_logic_vector(1 downto 0);
			mimo_en			: in std_logic;
         par_mode_en    : in std_logic; -- 0 - interleaved data, 1 - paralel data
			A_diq_h			: out std_logic_vector(iq_width downto 0);				
			A_diq_l			: out std_logic_vector(iq_width downto 0);
			B_diq_h			: out std_logic_vector(iq_width downto 0);				
			B_diq_l			: out std_logic_vector(iq_width downto 0)

     
        );
end decompress_top;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of decompress_top is

signal xen_sync				: std_logic;
		
--inst0 signals
signal inst0_wrusedw			: std_logic_vector(infifo_wsize-1 downto 0);
signal inst0_rdusedw			: std_logic_vector(infifo_rsize-1 downto 0);
signal inst0_q					: std_logic_vector(63 downto 0);
	
--inst1 signals
signal isnt1_bulk_size		: std_logic_vector(15 downto 0);
signal isnt1_bulk_size_2x	: std_logic_vector(15 downto 0);
signal inst1_bulk_buff_rdy : std_logic;
signal isnt1_fifo_rdreq		: std_logic;

signal inst1_fifo_read 		: std_logic;
signal inst1_diq_h			: std_logic_vector(iq_width downto 0);
signal inst1_diq_l			: std_logic_vector(iq_width downto 0);
signal inst1_fifo_q			: std_logic_vector(iq_width*4-1 downto 0);

--inst2 
signal xen_div					: std_logic;
signal inst2_data_in_valid	: std_logic;
signal isnt2_data_out		: std_logic_vector(127 downto 0);
signal isnt2_data_out_valid: std_logic;

--inst3
signal inst3_wrusedw			: std_logic_vector(decompr_fifo_wsize-1 downto 0);
signal inst3_wrusedw_max	: std_logic_vector(decompr_fifo_wsize-1 downto 0);
signal inst3_wrusedw_limit	: unsigned(decompr_fifo_wsize-1 downto 0);
signal inst3_q					: std_logic_vector(63 downto 0);
signal inst3_rdempty			: std_logic;
signal inst3_fifo_rdreq_mux: std_logic;
--isnt4
signal inst4_reset_n			: std_logic;
signal inst4_diqab_h			: std_logic_vector(iq_width downto 0);
signal inst4_diqab_l			: std_logic_vector(iq_width downto 0);
signal inst4_diqb_h			: std_logic_vector(iq_width downto 0);
signal inst4_diqb_l			: std_logic_vector(iq_width downto 0);
signal inst4_fifo_rdreq		: std_logic;
signal inst4_fifo_q			: std_logic_vector(iq_width*4-1 downto 0);

signal A_diq_h_reg			: std_logic_vector(iq_width downto 0);				
signal A_diq_l_reg			: std_logic_vector(iq_width downto 0);
signal B_diq_h_reg			: std_logic_vector(iq_width downto 0);				
signal B_diq_l_reg		   : std_logic_vector(iq_width downto 0);

signal intrlv_dis_sync     : std_logic;
signal par_mode_en_sync    : std_logic;

signal reset_n_sync_wclk   : std_logic;
signal reset_n_sync_rclk   : std_logic;

begin


sync_reg0 : entity work.sync_reg 
port map(rclk, '1', wfm_play, inst4_reset_n);

sync_reg1 : entity work.sync_reg 
port map(rclk, '1', par_mode_en, par_mode_en_sync);

sync_reg2 : entity work.sync_reg 
port map(rclk, '1', reset_n, reset_n_sync_rclk);

sync_reg3 : entity work.sync_reg 
port map(wclk, '1', reset_n, reset_n_sync_wclk);



isnt1_bulk_size <= x"0003" when sample_width = "10" else 
						 x"0007" when sample_width = "01" else 
						 x"0002";
						 
isnt1_bulk_size_2x <= isnt1_bulk_size(14 downto 0) & '0';

inst3_wrusedw_max <= ((decompr_fifo_wsize-1)=>'1', others=>'0');

process(rclk, reset_n) 
begin 
	if reset_n = '0' then 
		inst3_wrusedw_limit <= (others=>'0');
		inst1_bulk_buff_rdy <='0';
	elsif (rclk'event AND rclk = '1') then 
		inst3_wrusedw_limit <= unsigned(inst3_wrusedw_max) - To_integer(unsigned(isnt1_bulk_size_2x));
		if unsigned(inst3_wrusedw) < inst3_wrusedw_limit then
			inst1_bulk_buff_rdy <= '1';
		else 
			inst1_bulk_buff_rdy <= '0';
		end if;
	end if;
end process;

fifo_inst_inst0 : entity work.fifo_inst
  generic map(
		dev_family	    => dev_family,
		wrwidth         => infifo_wrwidth,
		wrusedw_witdth  => infifo_wsize,  
		rdwidth         => infifo_rdwidth,
		rdusedw_width   => infifo_rsize,
		show_ahead      => "OFF"
  ) 
  port map(
      --input ports 
      reset_n       => reset_n_sync_wclk,
      wrclk         => wclk,
      wrreq         => data_in_valid,
      data          => data_in,
      wrfull        => open,
		wrempty		  => open,
      wrusedw       => inst0_wrusedw,
      rdclk 	     => rclk,
      rdreq         => isnt1_fifo_rdreq,
      q             => inst0_q,
      rdempty       => open,
      rdusedw       => inst0_rdusedw    
        );
		  
wusedw <= inst0_wrusedw;


fifo_bulk_read_inst1 : entity work.fifo_bulk_read
   generic map(
      fifo_rd_size   => infifo_rsize
   )
   port map(

      clk            => rclk,
      reset_n        => reset_n,
      bulk_size      => isnt1_bulk_size,
      bulk_buff_rdy  => inst1_bulk_buff_rdy,
      fifo_rdusedw   => inst0_rdusedw,
      fifo_rdreq     => isnt1_fifo_rdreq
        );
		  
process(rclk, reset_n) 
begin 
	if reset_n = '0' then 
		inst2_data_in_valid <= '0';
	elsif (rclk'event AND rclk = '1') then 
		inst2_data_in_valid <= isnt1_fifo_rdreq;
	end if;
end process;
		  
bit_unpack_64_inst2 : entity work.bit_unpack_64
  port map(
        clk             => rclk,
        reset_n         => reset_n,
        data_in         => inst0_q,
        data_in_valid   => inst2_data_in_valid,
        sample_width    => sample_width,
        data_out        => isnt2_data_out,
        data_out_valid  => isnt2_data_out_valid
        );
		  
		  
fifo_inst_inst3 : entity work.fifo_inst
  generic map(
		dev_family	    => dev_family,
		wrwidth         => decompr_fifo_wrwidth,
		wrusedw_witdth  => decompr_fifo_wsize,  
		rdwidth         => decompr_fifo_rdwidth,
		rdusedw_width   => decompr_fifo_rsize,
		show_ahead      => "OFF"
  ) 
  port map(
      --input ports 
      reset_n       => reset_n_sync_rclk,
      wrclk         => rclk,
      wrreq         => isnt2_data_out_valid,
      data          => isnt2_data_out,
      wrfull        => open,
		wrempty		  => open,
      wrusedw       => inst3_wrusedw,
      rdclk 	     => rclk,
      rdreq         => inst4_fifo_rdreq,
      q             => inst3_q,
      rdempty       => inst3_rdempty,
      rdusedw       => open    
        ); 
        
--  inst3_fifo_rdreq_mux <= inst4_fifo_rdreq when intrlv_dis = '0' else not inst3_rdempty;
		  
		  
inst4_fifo_q <=   inst3_q(63 downto 64-iq_width) & 
                  inst3_q(47 downto 48-iq_width) &
                  inst3_q(31 downto 32-iq_width) & 
                  inst3_q(15 downto 16-iq_width);
	
diq2fifo_inst4 : entity work.fifo2diq
	generic map( 
      dev_family				=> "Cyclone V",
      iq_width					=> iq_width
	)
	port map (
      clk            => rclk,
      reset_n        => inst4_reset_n ,
      en             => xen, 
      mode			   => '0',
		trxiqpulse	   => '0',
		ddr_en 		   => '1',
		mimo_en		   => mimo_en,
		ch_en			   => "11",
		fidm			   => fr_start,
      par_mode_en    => par_mode_en_sync,
      DIQ		 	   => open,
		fsync	 	      => open,
		DIQA_h		   => inst4_diqab_h,
		DIQA_l		   => inst4_diqab_l,
      DIQB_h         => inst4_diqb_h,
      DIQB_l         => inst4_diqb_l,
      fifo_rdempty   => inst3_rdempty,
      fifo_rdreq     => inst4_fifo_rdreq,
      fifo_q         => inst4_fifo_q
     
        ); 
        
        
--process(rclk, reset_n)
--begin
--   if reset_n = '0' then 
--      A_diq_h_reg <= (others=>'0');
--      A_diq_l_reg <= (others=>'0');
--      B_diq_h_reg <= (others=>'0');
--      B_diq_l_reg <= (others=>'0');
--   elsif (rclk'event AND rclk='1') then 
--      if intrlv_dis_sync = '0' then 
--         A_diq_h_reg <= inst4_diq_h;
--         A_diq_l_reg <= inst4_diq_l;
--         B_diq_h_reg <= (others=>'0');
--         B_diq_l_reg <= (others=>'0');
--      else 
--         A_diq_h_reg <= '0' & inst3_q(15 downto 16-iq_width);
--         A_diq_l_reg <= '0' & inst3_q(31 downto 32-iq_width);
--         B_diq_h_reg <= '1' & inst3_q(47 downto 48-iq_width);
--         B_diq_l_reg <= '1' & inst3_q(63 downto 64-iq_width);
--      end if;
--   end if;
--end process;        



A_diq_h <= inst4_diqab_h;			
A_diq_l <= inst4_diqab_l;
B_diq_h <= inst4_diqb_h;				
B_diq_l <= inst4_diqb_l;	
	

end arch;   

