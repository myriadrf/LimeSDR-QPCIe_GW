-- ----------------------------------------------------------------------------	
-- FILE: 	data_cap_buffer.vhd
-- DESCRIPTION:	captures number of samples 
-- DATE:	Dec 14, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity data_cap_buffer is
	port (
		wclk0					: in std_logic;
		wclk1					: in std_logic;
		wclk2					: in std_logic;
		wclk3					: in std_logic;
		wclk4					: in std_logic;
		rdclk					: in std_logic;
		clk					: in std_logic;
		reset_n				: in std_logic;
		--capture data
		XP_valid				: in std_logic;		
		XPI					: in std_logic_vector(15 downto 0);
		XPQ					: in std_logic_vector(15 downto 0);
		YP_valid				: in std_logic;
		YPI					: in std_logic_vector(15 downto 0);
		YPQ					: in std_logic_vector(15 downto 0);
		X_valid				: in std_logic;
		XI						: in std_logic_vector(15 downto 0);
		XQ						: in std_logic_vector(15 downto 0);
		XP_1_valid			: in std_logic;		
		XPI_1					: in std_logic_vector(15 downto 0);
		XPQ_1					: in std_logic_vector(15 downto 0);
		YP_1_valid			: in std_logic;
		YPI_1					: in std_logic_vector(15 downto 0);
		YPQ_1					: in std_logic_vector(15 downto 0);
		--capture controll signals
		cap_en				: in std_logic;
		cap_cont_en			: in std_logic;
		cap_size				: in std_logic_vector(15 downto 0);
		cap_done				: out std_logic;
		--external fifo signals
		fifo_rdreq      	: in std_logic;
		fifo_q				: out std_logic_vector(31 downto 0);
		fifo_rdempty		: out std_logic;
		test_data_en		: in std_logic
        );
end data_cap_buffer;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of data_cap_buffer is
--declare signals,  components here

--inst0 signals 
signal inst0_reset_n			: std_logic;
signal inst0_cap_en 			: std_logic;
signal inst0_cap_cont_en	: std_logic;
signal inst0_cap_done 		: std_logic;
signal inst0_fifo_wrreq		: std_logic;

--inst1 signals 
signal inst1_reset_n			: std_logic;
signal inst1_cap_en 			: std_logic;
signal inst1_cap_cont_en	: std_logic;
signal inst1_cap_done 		: std_logic;
signal inst1_fifo_wrreq		: std_logic;

--inst2 signals 
signal inst2_reset_n			: std_logic;
signal inst2_cap_en 			: std_logic;
signal inst2_cap_cont_en	: std_logic;
signal inst2_cap_done 		: std_logic;
signal inst2_fifo_wrreq		: std_logic;

--inst3 signals 
signal inst3_reset_n			: std_logic;
signal inst3_cap_en 			: std_logic;
signal inst3_cap_cont_en	: std_logic;
signal inst3_cap_done 		: std_logic;
signal inst3_fifo_wrreq		: std_logic;

--inst4 signals 
signal inst4_reset_n			: std_logic;
signal inst4_cap_en 			: std_logic;
signal inst4_cap_cont_en	: std_logic;
signal inst4_cap_done 		: std_logic;
signal inst4_fifo_wrreq		: std_logic;	

--inst5 signals
signal inst5_fifo_0_data		: std_logic_vector(31 downto 0);
signal inst5_fifo_0_wrfull		: std_logic;
signal inst5_fifo_0_wrempty 	: std_logic;	
signal inst5_fifo_1_data		: std_logic_vector(31 downto 0);
signal inst5_fifo_1_wrfull		: std_logic;
signal inst5_fifo_1_wrempty	: std_logic;
signal inst5_fifo_2_data		: std_logic_vector(31 downto 0);
signal inst5_fifo_2_wrfull		: std_logic;
signal inst5_fifo_2_wrempty	: std_logic;
signal inst5_fifo_3_data		: std_logic_vector(31 downto 0);
signal inst5_fifo_3_wrfull		: std_logic;
signal inst5_fifo_3_wrempty	: std_logic;
signal inst5_fifo_4_data		: std_logic_vector(31 downto 0);
signal inst5_fifo_4_wrfull		: std_logic;
signal inst5_fifo_4_wrempty	: std_logic;
signal inst5_fifo_rdempty		: std_logic;

	

--general signals
signal wclk0_reset_n_sync			: std_logic_vector(1 downto 0);
signal wclk1_reset_n_sync			: std_logic_vector(1 downto 0);
signal wclk2_reset_n_sync			: std_logic_vector(1 downto 0);
signal wclk3_reset_n_sync			: std_logic_vector(1 downto 0);
signal wclk4_reset_n_sync			: std_logic_vector(1 downto 0);
signal rdclk_reset_n_sync			: std_logic_vector(1 downto 0);

type state_type is (idle, capture, capture_done, wait_cap_en_low);
signal current_state, next_state : state_type;

signal cap_en_sync_clk					: std_logic_vector(1 downto 0);
signal cap_cont_en_sync_clk			: std_logic_vector(1 downto 0);
signal cap_done_int						: std_logic;
signal cap_done_int_sync_clk			: std_logic_vector(1 downto 0);
signal cap_done_all_inst				: std_logic;
signal cap_done_all_inst_sync_rdclk	: std_logic_vector(1 downto 0);

component data_cap is
  port (
			clk					: in std_logic;
			reset_n				: in std_logic;
			--capture signalas
			data_valid			: in std_logic;
			cap_en				: in std_logic;
			cap_cont_en			: in std_logic;
			cap_size				: in std_logic_vector(15 downto 0);
			cap_done				: out std_logic;
        --external fifo signalas
			fifo_wrreq      	: out std_logic;
			fifo_wfull			: in std_logic;
			fifo_wrempty		: in std_logic      
        );
end component;


component fifo_buff is
  generic(dev_family	     : string  := "Cyclone IV E";
          wrwidth         : integer := 32;
          wrusedw_witdth  : integer := 15; --15=32768 words 
          rdwidth         : integer := 32;
          rdusedw_width   : integer := 15;
          show_ahead      : string  := "OFF"
  );  

  port (
      --fifo 0 ports
      fifo_0_reset_n       : in std_logic;
      fifo_0_wrclk         : in std_logic;
      fifo_0_wrreq         : in std_logic;
      fifo_0_data          : in std_logic_vector(wrwidth-1 downto 0);
      fifo_0_wrfull        : out std_logic;
		fifo_0_wrempty		  	: out std_logic;
		--fifo 1 ports
      fifo_1_reset_n       : in std_logic;
      fifo_1_wrclk         : in std_logic;
      fifo_1_wrreq         : in std_logic;
      fifo_1_data          : in std_logic_vector(wrwidth-1 downto 0);
      fifo_1_wrfull        : out std_logic;
		fifo_1_wrempty		  	: out std_logic;
      --fifo 2 ports
      fifo_2_reset_n       : in std_logic;
      fifo_2_wrclk         : in std_logic;
      fifo_2_wrreq         : in std_logic;
      fifo_2_data          : in std_logic_vector(wrwidth-1 downto 0);
      fifo_2_wrfull        : out std_logic;
		fifo_2_wrempty		  	: out std_logic;
      --fifo 3 ports
      fifo_3_reset_n       : in std_logic;
      fifo_3_wrclk         : in std_logic;
      fifo_3_wrreq         : in std_logic;
      fifo_3_data          : in std_logic_vector(wrwidth-1 downto 0);
      fifo_3_wrfull        : out std_logic;
		fifo_3_wrempty		  	: out std_logic;
      --fifo 4 ports
      fifo_4_reset_n       : in std_logic;
      fifo_4_wrclk         : in std_logic;
      fifo_4_wrreq         : in std_logic;
      fifo_4_data          : in std_logic_vector(wrwidth-1 downto 0);
      fifo_4_wrfull        : out std_logic;
		fifo_4_wrempty		  	: out std_logic;		
		--rd port for all fifo
      fifo_rdclk 	    		: in std_logic;
		fifo_rdclk_reset_n	: in std_logic;
		fifo_cap_size			: in std_logic_vector(15 downto 0);
      fifo_rdreq         	: in std_logic;
      fifo_q             	: out std_logic_vector(rdwidth-1 downto 0);
      fifo_rdempty       	: out std_logic 

        );
end component;

begin

--indicates when all buffers are collected and data all data has been read from buffers
cap_done_int		<= inst0_cap_done AND inst1_cap_done AND inst2_cap_done AND inst3_cap_done AND inst4_cap_done AND
							inst5_fifo_0_wrempty AND inst5_fifo_1_wrempty AND inst5_fifo_2_wrempty AND inst5_fifo_3_wrempty AND inst5_fifo_4_wrempty;

--indicates when all data_capture instances are finished collecting buffer
cap_done_all_inst <= inst0_cap_done AND inst1_cap_done AND inst2_cap_done AND inst3_cap_done AND inst4_cap_done;

cap_done<=cap_done_int;

-- ----------------------------------------------------------------------------
-- to synchronize signals to clk domain
-- ----------------------------------------------------------------------------
process(clk, reset_n)begin
	if(reset_n = '0')then
		cap_en_sync_clk 		<= (others=>'0');
		cap_cont_en_sync_clk <= (others=>'0');
		cap_done_int_sync_clk<= (others=>'0');
	elsif(clk'event and clk = '1')then 
		cap_en_sync_clk 			<= cap_en_sync_clk(0) & cap_en;
		cap_cont_en_sync_clk		<= cap_cont_en_sync_clk(0) & cap_cont_en;
		cap_done_int_sync_clk	<= cap_done_int_sync_clk(0) & cap_done_int;
	end if;	
end process;

-- ----------------------------------------------------------------------------
-- to synchronize signals to rdclk domain
-- ----------------------------------------------------------------------------
process(rdclk, reset_n)begin
	if(reset_n = '0')then
		cap_done_all_inst_sync_rdclk <= (others=>'0');
	elsif(rdclk'event and rdclk = '1')then 
		cap_done_all_inst_sync_rdclk <= cap_done_all_inst_sync_rdclk(0) & cap_done_all_inst;
	end if;	
end process;


-- ----------------------------------------------------------------------------
--state machine for controlling capture signal
-- ----------------------------------------------------------------------------
fsm_f : process(clk, reset_n)begin
	if(reset_n = '0')then
		current_state <= idle;
	elsif(clk'event and clk = '1')then 
		current_state <= next_state;
	end if;	
end process;

-- ----------------------------------------------------------------------------
--state machine combo
-- ----------------------------------------------------------------------------
fsm : process(current_state, cap_en_sync_clk(1), cap_done_int_sync_clk(1), cap_cont_en_sync_clk(1)) begin
	next_state <= current_state;
	case current_state is
	  
		when idle => --idle state 
			if cap_en_sync_clk(1)='1' and cap_done_int_sync_clk(1) = '0' then 
				next_state <= capture;
			else 
				next_state <= idle;
			end if;
		
		when capture => 
			if cap_done_int_sync_clk(1) = '1' then
				next_state <= capture_done;
			else 
				next_state <= capture;
			end if;
			
		when capture_done => 
			if cap_cont_en_sync_clk(1) = '1' then 
				next_state<=idle;
			else 
				next_state <= wait_cap_en_low;
			end if;	

		when wait_cap_en_low => 
			if cap_en_sync_clk(1)='0' then 
				next_state <= idle;
			else 
				next_state <= wait_cap_en_low;
			end if;
			
		when others => 
			next_state<=idle;
	end case;
end process;


-- ----------------------------------------------------------------------------
-- Reset synchronizations
-- ----------------------------------------------------------------------------

--to wclk0 domain
process(wclk0, reset_n)begin
	if(reset_n = '0')then
		wclk0_reset_n_sync <= (others=>'0');
	elsif(wclk0'event and wclk0 = '1')then 
		wclk0_reset_n_sync<= wclk0_reset_n_sync(0) & reset_n;
	end if;	
end process;

--to wclk1 domain
process(wclk1, reset_n)begin
	if(reset_n = '0')then
		wclk1_reset_n_sync <= (others=>'0');
	elsif(wclk1'event and wclk1 = '1')then 
		wclk1_reset_n_sync<= wclk1_reset_n_sync(0) & reset_n;
	end if;	
end process;

--to wclk2 domain
process(wclk2, reset_n)begin
	if(reset_n = '0')then
		wclk2_reset_n_sync <= (others=>'0');
	elsif(wclk2'event and wclk2 = '1')then 
		wclk2_reset_n_sync<= wclk2_reset_n_sync(0) & reset_n;
	end if;	
end process;


--to wclk3 domain
process(wclk3, reset_n)begin
	if(reset_n = '0')then
		wclk3_reset_n_sync <= (others=>'0');
	elsif(wclk3'event and wclk3 = '1')then 
		wclk3_reset_n_sync<= wclk3_reset_n_sync(0) & reset_n;
	end if;	
end process;

--to wclk4 domain
process(wclk4, reset_n)begin
	if(reset_n = '0')then
		wclk4_reset_n_sync <= (others=>'0');
	elsif(wclk4'event and wclk4 = '1')then 
		wclk4_reset_n_sync<= wclk4_reset_n_sync(0) & reset_n;
	end if;	
end process;

--to rdclk domain
process(rdclk, reset_n)begin
	if(reset_n = '0')then
		rdclk_reset_n_sync <= (others=>'0');
	elsif(rdclk'event and rdclk = '1')then 
		rdclk_reset_n_sync<= rdclk_reset_n_sync(0) & reset_n;
	end if;	
end process;



inst0_cap_cont_en<='0';

process(current_state)begin
	if(current_state = capture OR current_state = wait_cap_en_low OR current_state = capture_done )then
		inst0_cap_en<='1';
	else 
		inst0_cap_en<='0';
	end if;
end process;

data_cap_inst0 : data_cap
  port map (
			clk					=> wclk0, 
			reset_n				=> wclk0_reset_n_sync(1),
			data_valid			=> XP_valid,
			--capture signalas
			cap_en				=> inst0_cap_en,
			cap_cont_en			=> inst0_cap_cont_en,
			cap_size				=> cap_size,
			cap_done				=> inst0_cap_done,
        --external fifo signalas
			fifo_wrreq      	=> inst0_fifo_wrreq,
			fifo_wfull			=> inst5_fifo_0_wrfull,
			fifo_wrempty		=> inst5_fifo_0_wrempty    
        );

inst1_cap_cont_en<='0';

process(current_state)begin
	if(current_state = capture OR current_state = wait_cap_en_low OR current_state = capture_done )then
		inst1_cap_en<='1';
	else 
		inst1_cap_en<='0';
	end if;
end process;
	  
data_cap_inst1 : data_cap
  port map (
			clk					=> wclk1, 
			reset_n				=> wclk1_reset_n_sync(1),
			data_valid			=> YP_valid,
			--capture signalas
			cap_en				=> inst1_cap_en,
			cap_cont_en			=> inst1_cap_cont_en,
			cap_size				=> cap_size,
			cap_done				=> inst1_cap_done,
        --external fifo signalas
			fifo_wrreq      	=> inst1_fifo_wrreq,
			fifo_wfull			=> inst5_fifo_1_wrfull,
			fifo_wrempty		=> inst5_fifo_1_wrempty     
        );

		  
inst2_cap_cont_en<='0';

process(current_state)begin
	if(current_state = capture OR current_state = wait_cap_en_low OR current_state = capture_done )then
		inst2_cap_en<='1';
	else 
		inst2_cap_en<='0';
	end if;
end process;
		  
data_cap_inst2 : data_cap
  port map (
			clk					=> wclk2, 
			reset_n				=> wclk2_reset_n_sync(1),
			data_valid			=> X_valid,
			--capture signalas
			cap_en				=> inst2_cap_en,
			cap_cont_en			=> inst2_cap_cont_en,
			cap_size				=> cap_size,
			cap_done				=> inst2_cap_done,
        --external fifo signalas
			fifo_wrreq      	=> inst2_fifo_wrreq,
			fifo_wfull			=> inst5_fifo_2_wrfull,
			fifo_wrempty		=> inst5_fifo_2_wrempty     
        );
		  
		  
inst3_cap_cont_en<='0';

process(current_state)begin
	if(current_state = capture OR current_state = wait_cap_en_low OR current_state = capture_done )then
		inst3_cap_en<='1';
	else 
		inst3_cap_en<='0';
	end if;
end process;
		  
data_cap_inst3 : data_cap
  port map (
			clk					=> wclk3, 
			reset_n				=> wclk3_reset_n_sync(1),
			data_valid			=> XP_1_valid,
			--capture signalas
			cap_en				=> inst3_cap_en,
			cap_cont_en			=> inst3_cap_cont_en,
			cap_size				=> cap_size,
			cap_done				=> inst3_cap_done,
        --external fifo signalas
			fifo_wrreq      	=> inst3_fifo_wrreq,
			fifo_wfull			=> inst5_fifo_3_wrfull,
			fifo_wrempty		=> inst5_fifo_3_wrempty     
        );
		  
inst4_cap_cont_en<='0';

process(current_state)begin
	if(current_state = capture OR current_state = wait_cap_en_low OR current_state = capture_done )then
		inst4_cap_en<='1';
	else 
		inst4_cap_en<='0';
	end if;
end process;
		  
data_cap_inst4 : data_cap
  port map (
			clk					=> wclk4, 
			reset_n				=> wclk4_reset_n_sync(1),
			data_valid			=> YP_1_valid,
			--capture signalas
			cap_en				=> inst4_cap_en,
			cap_cont_en			=> inst4_cap_cont_en,
			cap_size				=> cap_size,
			cap_done				=> inst4_cap_done,
        --external fifo signalas
			fifo_wrreq      	=> inst4_fifo_wrreq,
			fifo_wfull			=> inst5_fifo_4_wrfull,
			fifo_wrempty		=> inst5_fifo_4_wrempty     
        );
		  
--inst5_fifo_0_data <= XPQ & XPI;
--inst5_fifo_1_data <= YPQ & YPI;
--inst5_fifo_2_data <= XQ & XI;	

inst5_fifo_0_data <= (XPQ & XPI) 		when test_data_en='0' else (x"0302" & x"0100");
inst5_fifo_1_data <= (YPQ & YPI) 		when test_data_en='0' else (x"0706" & x"0504");
inst5_fifo_2_data <= (XQ & XI) 			when test_data_en='0' else (x"0B0A" & x"0908");	
inst5_fifo_3_data <= (XPQ_1 & XPI_1) 	when test_data_en='0' else (x"0F0E" & x"0D0C");
inst5_fifo_4_data <= (YPQ_1 & YPI_1) 	when test_data_en='0' else (x"1312" & x"1110");



--inst5_fifo_0_data <= x"0302" & x"0100";
--inst5_fifo_1_data <= x"0706" & x"0504";
--inst5_fifo_2_data <= x"0B0A" & x"0908";		
  
fifo_buff_inst5 : fifo_buff
  generic map(
			dev_family	    => "Cyclone V GX",
			wrwidth         => 32,
			wrusedw_witdth  => 15, --15=32768 words 
			rdwidth         => 32,
			rdusedw_width   => 15,
			show_ahead      => "OFF"
  )

  port map(
      --fifo 0 ports
      fifo_0_reset_n       => wclk0_reset_n_sync(1), 
      fifo_0_wrclk         => wclk0,
      fifo_0_wrreq         => inst0_fifo_wrreq,
      fifo_0_data          => inst5_fifo_0_data,
      fifo_0_wrfull        => inst5_fifo_0_wrfull,
		fifo_0_wrempty		  	=> inst5_fifo_0_wrempty,
		--fifo 1 ports
      fifo_1_reset_n       => wclk1_reset_n_sync(1),
      fifo_1_wrclk         => wclk1,
      fifo_1_wrreq         => inst1_fifo_wrreq,
      fifo_1_data          => inst5_fifo_1_data,
      fifo_1_wrfull        => inst5_fifo_1_wrfull,
		fifo_1_wrempty		  	=> inst5_fifo_1_wrempty,
      --fifo 2 ports
      fifo_2_reset_n       => wclk2_reset_n_sync(1),
      fifo_2_wrclk         => wclk2,
      fifo_2_wrreq         => inst2_fifo_wrreq,
      fifo_2_data          => inst5_fifo_2_data,
      fifo_2_wrfull        => inst5_fifo_2_wrfull,
		fifo_2_wrempty		  	=> inst5_fifo_2_wrempty,
      --fifo 3 ports
      fifo_3_reset_n       => wclk3_reset_n_sync(1),
      fifo_3_wrclk         => wclk3,
      fifo_3_wrreq         => inst3_fifo_wrreq,
      fifo_3_data          => inst5_fifo_3_data,
      fifo_3_wrfull        => inst5_fifo_3_wrfull,
		fifo_3_wrempty		  	=> inst5_fifo_3_wrempty,
      --fifo 4 ports
      fifo_4_reset_n       => wclk4_reset_n_sync(1),
      fifo_4_wrclk         => wclk4,
      fifo_4_wrreq         => inst4_fifo_wrreq,
      fifo_4_data          => inst5_fifo_4_data,
      fifo_4_wrfull        => inst5_fifo_4_wrfull,
		fifo_4_wrempty		  	=> inst5_fifo_4_wrempty,		
		--rd port for all fifo
      fifo_rdclk 	    		=> rdclk,
		fifo_rdclk_reset_n	=> rdclk_reset_n_sync(1),
		fifo_cap_size			=> cap_size,
      fifo_rdreq         	=> fifo_rdreq,
      fifo_q             	=> fifo_q,
      fifo_rdempty       	=> inst5_fifo_rdempty

        );

--to show that fifo is not empty only when all data is captured
fifo_rdempty <= inst5_fifo_rdempty OR (NOT cap_done_all_inst_sync_rdclk(1));		  
		  




end arch; 