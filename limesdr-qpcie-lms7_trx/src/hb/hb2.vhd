-- ----------------------------------------------------------------------------	
-- FILE: 	hb2.vhd
-- DESCRIPTION:	HB2 implemented as interleaved polyphase filter
--		with programmable clock rate.
-- DATE:	July 25, 2001
-- AUTHOR(s):	Microelectronic Centre Design Team
--		MUMEC
--		Bounds Green Road
--		N11 2NQ London
-- TO DO:	Change enable signal generation circuitry by clkdev module.
-- REVISIONS:	Sep 12, 2001:	Clock division circuitry substituted by
--				clkdiv module.
-- ----------------------------------------------------------------------------	

library IEEE;
use IEEE.std_logic_1164.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity hb2 is
    port (
   xi1: in std_logic_vector(17 downto 0); 	-- I input signal
   xq1: in std_logic_vector(17 downto 0); 	-- Q input signal
	n: in std_logic_vector(7 downto 0);	-- Clock division ratio is 2^n
	sleep: in std_logic;			-- Sleep mode control
	clk: in std_logic;			-- Clock and reset
	reset: in std_logic;
	xen: out std_logic;
	yi1: out std_logic_vector(17 downto 0); 	-- I output signal
	yq1: out std_logic_vector(17 downto 0);	-- Q output signal
	
	delay: in std_logic
    );
end hb2;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture hb2_arch of hb2 is

	signal x:   std_logic_vector(24 downto 0); -- Multiplexed xi and xq
	signal xe:  std_logic_vector(24 downto 0); -- Even input
	signal xo:  std_logic_vector(24 downto 0); -- Odd input
	signal ye:  std_logic_vector(24 downto 0); -- Even output
	signal yo:  std_logic_vector(24 downto 0); -- Odd output
	signal yia: std_logic_vector(24 downto 0); -- Advanced yi
		    
	-- Enable and MUX select signal
	signal en, sel: std_logic;

	-- Component declarations
	use work.components.hb2e;
	use work.components.hb2o;
	for all:hb2e use entity work.hb2e(hb2e_arch);
	for all:hb2o use entity work.hb2o(hb2o_arch);

	use work.components.clkdiv;
	for all:clkdiv use entity work.clkdiv(clkdiv_arch);
	
	signal xi: std_logic_vector(24 downto 0); 	-- I input signal
   signal xq: std_logic_vector(24 downto 0); 	-- Q input signal
	
	signal yi: std_logic_vector(24 downto 0); 	-- I output signal
	signal yq: std_logic_vector(24 downto 0); 	-- Q output signal
	
	signal  yqprim,  yqsec: std_logic_vector(17 downto 0);
	
	
begin


    --- Borko

   delayl: process(clk)
	begin
		if clk'event and clk = '1' then
		
		  yqprim<=yq(24 downto 7);
		  yqsec<=yqprim;
		
		end if;
	end process delayl;

   --yq1<=yq(24 downto 7) when delay='0' else yqsec;
	
	
	-- yq1<=yq(24 downto 7);
	--- Borko


   xi<=xi1(17 downto 0)&"0000000";	
	xq<=xq1(17 downto 0)&"0000000";
	
	--yi1<=yi(24 downto 7);
	 
	 
	-- Clock division
	clkd: clkdiv port map(n => n, clk => clk, reset => reset, 
		sleep => sleep,	en => en);

	-- MUX select signal
	dff: process(clk, reset)
	begin
		if reset = '0' then
			--sel <= '0';
			sel <= '1';
		elsif clk'event and clk = '1' then
			if en = '1' then
				sel <= not sel;
			end if;
		end if;
	end process dff;
	
	xen <= sel;

	-- Multiplex xi and xq
	x <= xi when sel = '1' else xq;

	-- Latch La
	la: process(clk, reset)
	begin
		if reset = '0' then
			xe <= (others => '0');
		elsif clk'event and clk = '1' then
			if en = '1' then
				xe <= x;
			end if;
		end if;
	end process la;

 	-- Latch Lb
	lb: process(clk, reset)
	begin
		if reset = '0' then
			xo <= (others => '0');
		elsif clk'event and clk = '1' then
			if en = '1' then
				xo <= xe;
			end if;
		end if;
	end process lb;

	-- Even HB2 filter
	even: hb2e
		port map( x => xe, clk => clk, en => en, reset => reset, y => ye);

	-- Odd HB2 filter
	odd: hb2o
		port map( x => xo, clk => clk, en => en, reset => reset, y => yo);

	-- Multiplex ye and yo to construct yia and yq
	yia  <= ye when sel = '1' else yo;
	yq   <= ye when sel = '0' else yo;

	-- Delay yia one clock cycle to align it with ya
	le: process(clk, reset)
	begin
		if reset = '0' then
			yi <= (others => '0');
		elsif clk'event and clk = '1' then
			if en = '1' then
				yi <= yia;
			end if;
		end if;
	end process le;
	
		-- Delay  both  I, Q
	latch: process(clk, reset)
	begin
		if reset = '0' then
			 yi1 <= (others => '0');
          yq1 <= (others => '0');
		elsif clk'event and clk = '1' then			
         if en = '1' then
				   yi1<=yi(24 downto 7);
					
					if delay='0' then yq1<=yq(24 downto 7);
				   else	yq1<= yqsec;
				   end if;	
			end if;
		end if;
	end process latch;
	
end hb2_arch;
