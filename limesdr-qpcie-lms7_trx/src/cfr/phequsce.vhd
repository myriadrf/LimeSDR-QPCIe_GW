-- ----------------------------------------------------------------------------	
-- FILE: 	phequce.vhd
-- DESCRIPTION:	Configuration engine for the phase equaliser, serial interface.
-- DATE:	Sep 04, 2001
-- AUTHOR(s):	Microelectronic Centre Design Team
--		MUMEC
--		Bounds Green Road
--		N11 2NQ London
-- REVISIONS:
--		Nov 23, 2001:	Sleep signal latched at the input. See dmuce.vhd
--				comments for details. REMOVED.
--		Nov 29, 2001:	Memory interface changed.
--		Aug 21, 2012: External memoty interface changed to SPI.
-- ----------------------------------------------------------------------------	

library ieee;
use ieee.std_logic_1164.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ------------------------------------ ---------------------------------------											
entity phequsce_bj is
	port (	 
		-- Filter configuration
		-- BJ  l:=7, za broj tapova 40
		l: in std_logic_vector(2 downto 0);	-- Number of taps is 5*(l+1)
		
		--  Clock related inputs
		--  n:=3 za  clock div ratio 4
		n: in std_logic_vector(7 downto 0);	-- Clock division ratio = n+1
		sleep: in std_logic;			-- Sleep signal
		clk: in std_logic;			-- Clock
		reset: in std_logic;			-- Reset
		
		-- Memory interface
		maddress: in std_logic_vector(8 downto 0);
		mimo_en: in std_logic; 	--
		sdin: in std_logic; 	-- Data in
		sclk: in std_logic; 	-- Data clock
		sen: in std_logic;	-- Enable signal (active low)
		sdout: out std_logic; 	-- Data out
		oen: out std_logic;
		
		-- Outputs
		h0, h1, h2, h3, h4, h5, h6, h7, h8, h9: out std_logic_vector(15 downto 0);	-- Coefficients  BJ
		
		a: out std_logic_vector(1 downto 0);	-- Address to data memory  BJ
		xen, ien: out std_logic			-- Control signals
	);
end phequsce_bj;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture phequsce_arch_bj of phequsce_bj is

	-- Signals
	--signal we0, we1, we2, we3, we4: std_logic;
	--signal oe0, oe1, oe2, oe3, oe4: std_logic;
	--signal edo0, edo1, edo2, edo3, edo4: std_logic_vector(15 downto 0);
	signal ai: std_logic_vector(7 downto 0);
	signal xeni, nsleep, ieni, covfl: std_logic;
		
	-- Logic constants
	signal zero, one: std_logic;
	signal zeroes: std_logic_vector(4 downto 0);
	
	-- Component declarations
	use work.components.counter8;
	use work.components.clkdiv;
	use work.components.fircms_bj;
	for all:counter8 use entity work.counter8(counter8_arch);
	for all:clkdiv use entity work.clkdiv(clkdiv_arch);
	for all:fircms_bj use entity work.fircms_bj(fircms_arch_bj);

begin			     
	
	-- Logic constants
	zero <= '0';
	one <= '1';
	zeroes <= "00000";

	nsleep <= not sleep;
	
	a <= ai(1 downto 0);  --BJ
	xen <= xeni;
	ien <= ieni;

	-- Clock division
	clkd: clkdiv port map( n => n, sleep => sleep, clk => clk, 
				reset => reset, en => xeni);
	-- Counter	
	countera: counter8 port map (n(7 downto 3) => zeroes, n(2 downto 0) => "011", 
			updown => one, ssr => xeni, clk => clk,
			en => nsleep, reset => reset, q => ai, ovfl => covfl);

	-- Construct integrator enable signal
	ienl: process(clk, reset)
	begin
		if reset = '0' then
			ieni <= '0';
		elsif clk'event and clk = '1' then
			if xeni = '1' and covfl = '1' then
				ieni <= '1';
			elsif xeni = '0' and covfl = '1' then
				ieni <= '0';
			end if;
		end if;
	end process ienl;
	
	-- Coefficients memory 
	spic: fircms_bj port map( maddress => maddress, mimo_en => mimo_en, sdin => sdin, sclk => sclk,
				sen => sen, sdout => sdout, hreset => reset, oen => oen,
				ai => ai(1 downto 0), di0 => h0, di1 => h1, di2 => h2, di3 => h3, di4 => h4,
				di5 => h5, di6 => h6, di7 => h7, di8 => h8, di9 => h9);

end phequsce_arch_bj;
