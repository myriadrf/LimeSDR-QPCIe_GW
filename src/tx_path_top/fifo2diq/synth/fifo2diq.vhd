-- ----------------------------------------------------------------------------	
-- FILE: 	fifo2diq.vhd
-- DESCRIPTION:	Writes DIQ data to FIFO, FIFO word size = 4  DIQ samples 
-- DATE:	Jan 13, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity fifo2diq is
   generic( 
      dev_family				: string := "Cyclone IV E";
      iq_width					: integer := 12
      );
   port (
      clk         : in std_logic;
      reset_n     : in std_logic;
      en          : in std_logic;
      --Mode settings
      mode			: in std_logic; -- JESD207: 1; TRXIQ: 0
		trxiqpulse	: in std_logic; -- trxiqpulse on: 1; trxiqpulse off: 0
		ddr_en 		: in std_logic; -- DDR: 1; SDR: 0
		mimo_en		: in std_logic; -- SISO: 1; MIMO: 0
		ch_en			: in std_logic_vector(1 downto 0); --"11" - Ch. A, "10" - Ch. B, "11" - Ch. A and Ch. B. 
		fidm			: in std_logic; -- External Frame ID mode. Frame start at fsync = 0, when 0. Frame start at fsync = 1, when 1.
      par_mode_en : in std_logic; -- 1 - parallel data mode enabled, 0 - disabled
      --Tx interface data 
      DIQ		 	: out std_logic_vector(iq_width-1 downto 0);
		fsync	 	   : out std_logic;
      DIQA_h      : out std_logic_vector(iq_width downto 0);
      DIQA_l      : out std_logic_vector(iq_width downto 0);
      DIQB_h      : out std_logic_vector(iq_width downto 0);
      DIQB_l      : out std_logic_vector(iq_width downto 0);
      --fifo ports 
      fifo_rdempty: in std_logic;
      fifo_rdreq  : out std_logic;
      fifo_q      : in std_logic_vector(iq_width*4-1 downto 0) 

        );
end fifo2diq;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of fifo2diq is
--declare signals,  components here
signal fifo_q_valid        : std_logic;
signal fifo_rdreq_int      : std_logic;


signal inst0_DIQ_h         : std_logic_vector (iq_width downto 0); 
signal inst0_DIQ_l         : std_logic_vector (iq_width downto 0);

signal inst1_reset_n       : std_logic;
signal inst1_fifo_q_valid  : std_logic;
signal inst1_fifo_rdreq    : std_logic;
signal inst1_fifo_q        : std_logic_vector(iq_width downto 0);


signal inst2_reset_n       : std_logic;
signal inst2_DIQ0          : std_logic_vector (iq_width downto 0); 
signal inst2_DIQ1          : std_logic_vector (iq_width downto 0); 
signal inst2_DIQ2          : std_logic_vector (iq_width downto 0); 
signal inst2_DIQ3          : std_logic_vector (iq_width downto 0);
signal inst2_fifo_rdreq    : std_logic;
signal inst2_fifo_q        : std_logic_vector(iq_width downto 0);
  
begin


        
--inst0_lms7002_dout : entity work.lms7002_ddout
--   generic map( 
--      dev_family	=> dev_family,
--      iq_width		=> iq_width
--	)
--	port map(
--      clk       	=> clk,
--      reset_n   	=> reset_n,
--		data_in_h	=> inst0_DIQ_h,
--		data_in_l	=> inst0_DIQ_l,
--		txiq		 	=> DIQ,
--		txiqsel	 	=> fsync
--      );

DIQ <= (others=>'0');
fsync <= '0';


process(clk, reset_n)
begin
   if reset_n = '0' then 
      inst1_reset_n <= '0';
   elsif (clk'event AND clk='1') then
      if par_mode_en = '0' then 
         inst1_reset_n <= '1';
      else 
         inst1_reset_n <= '0';
      end if;
   end if;
end process;

        
        
 inst1_txiq : entity work.txiq
	generic map( 
      dev_family	   => dev_family,
      iq_width			=> iq_width
	)
	port map (
      clk            => clk,
      reset_n        => inst1_reset_n,
      en             => en,
      trxiqpulse     => trxiqpulse,
		ddr_en 		   => ddr_en,
		mimo_en		   => mimo_en,
		ch_en			   => ch_en, 
		fidm			   => fidm,
      DIQ_h		 	   => inst0_DIQ_h,
		DIQ_l          => inst0_DIQ_l,
      fifo_rdempty   => fifo_rdempty,
      fifo_rdreq     => inst1_fifo_rdreq,
      fifo_q_valid   => fifo_q_valid,
      fifo_q         => fifo_q
        );
       
process(clk)
begin 
   if reset_n = '0' then 
      fifo_rdreq_int <= '0';
   elsif (clk'event AND clk = '1') then
      if par_mode_en = '0' then 
         fifo_rdreq_int <= inst1_fifo_rdreq;
      else 
         fifo_rdreq_int <= inst2_fifo_rdreq;
      end if;
   end if;
end process;

fifo_rdreq <= fifo_rdreq_int;
        
process(clk, reset_n)
   begin 
      if reset_n = '0' then 
         fifo_q_valid <= '0';
      elsif (clk'event AND clk = '1') then 
         fifo_q_valid <= fifo_rdreq_int;
      end if;
end process;

process(clk, reset_n)
begin
   if reset_n = '0' then 
      inst2_reset_n <= '0';
   elsif (clk'event AND clk='1') then
      if par_mode_en = '1' then 
         inst2_reset_n <= '1';
      else 
         inst2_reset_n <= '0';
      end if;
   end if;
end process;
        
        
 inst2_txiq_par : entity work.txiq_par
	generic map( 
      dev_family	   => dev_family,
      iq_width			=> iq_width
	)
	port map (
      clk            => clk,
      reset_n        => inst2_reset_n,
      en             => en,
		ch_en			   => ch_en, 
		fidm			   => fidm,
      DIQ0		 	   => inst2_DIQ0,
		DIQ1           => inst2_DIQ1,
      DIQ2		 	   => inst2_DIQ2,
		DIQ3           => inst2_DIQ3,
      fifo_rdempty   => fifo_rdempty,
      fifo_rdreq     => inst2_fifo_rdreq,
      fifo_q_valid   => fifo_q_valid,
      fifo_q         => fifo_q
        );
        
        
process(clk)
begin 
   if (clk'event AND clk = '1' ) then 
      if par_mode_en = '0' then 
         DIQA_h <= inst0_DIQ_h;
         DIQA_l <= inst0_DIQ_l;
         DIQB_h <= (others=> '0');
         DIQB_l <= (others=> '0');
      else 
         DIQA_h <= inst2_DIQ0;
         DIQA_l <= inst2_DIQ1;
         DIQB_h <= inst2_DIQ2;
         DIQB_l <= inst2_DIQ3;
      end if;
   end if;
end process;
        


  
end arch;