-- ----------------------------------------------------------------------------	
-- FILE: 	phequfe.vhd
-- DESCRIPTION:	Filtering engine of the phase equaliser.
-- DATE:	Sep 04, 2001
-- AUTHOR(s):	Microelectronic Centre Design Team
--		MUMEC
--		Bounds Green Road
--		N11 2NQ London
-- REVISIONS:
-- ----------------------------------------------------------------------------	

library ieee;
use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity gfirhf16mod_bj is
	port (
		-- Clock related inputs
		sleep: in std_logic;			-- Sleep signal
		clk: in std_logic;				-- Clock
		reset: in std_logic;			-- Reset
		bypass: in std_logic;			--

		-- Data input signals
		xi: in std_logic_vector(15 downto 0);
		xq: in std_logic_vector(15 downto 0);

		-- Filter configuration
		n: in std_logic_vector(7 downto 0);	-- Clock division ratio = nd+1
		l: in std_logic_vector(2 downto 0);	-- Number of taps is 3*5*(l+1)
		
		-- Coeffitient memory interface
		maddressf0: in std_logic_vector(8 downto 0);
		maddressf1: in std_logic_vector(8 downto 0);

		mimo_en: in std_logic; 	--
		sdin: in std_logic; 	-- Data in
		sclk: in std_logic; 	-- Data clock
		sen: in std_logic;	-- Enable signal (active low)
		sdout: out std_logic; 	-- Data out
		oen: out std_logic;
		
		-- Filter output signals
		yi: out std_logic_vector(24 downto 0);
		yq: out std_logic_vector(24 downto 0);
		xen: out std_logic
	);
end gfirhf16mod_bj;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture gfirhf16_arch_bj of gfirhf16mod_bj is

	-- Signals
	signal ce0h0, ce0h1, ce0h2, ce0h3, ce0h4, ce0h5, ce0h6, ce0h7, ce0h8, ce0h9: std_logic_vector(15 downto 0);	-- Coefficients
	signal ce1h0, ce1h1, ce1h2, ce1h3, ce1h4, ce1h5, ce1h6, ce1h7, ce1h8, ce1h9: std_logic_vector(15 downto 0);	-- Coefficients
	
	signal ce0a: std_logic_vector(1 downto 0);	-- Address to data memory
	signal ce1a: std_logic_vector(1 downto 0);	-- Address to data memory

	signal ce0xen, ce0ien: std_logic;			-- Control signals
	signal ce1xen, ce1ien: std_logic;			-- Control signals

	signal xii: std_logic_vector(24 downto 0);
	signal xqi: std_logic_vector(24 downto 0);
	signal yii, yim: std_logic_vector(24 downto 0);
	signal yqi, yqm: std_logic_vector(24 downto 0);
	
	signal sdout0: std_logic;
	signal oen0: std_logic;
	signal sdout1: std_logic;
	signal oen1: std_logic;
	
	-- Component declarations
	use work.components.phequfehf_bj2;
	for all:phequfehf_bj2 use entity work.phequfehf_bj2(phequfehf_arch_bj);
	
	use work.components.phequsce_bj;
	for all:phequsce_bj use entity work.phequsce_bj(phequsce_arch_bj);

begin

	xen <= ce0xen;
	xii <= xi & "000000000";
	xqi <= xq & "000000000";

	-- Configuration engines
	ce0: phequsce_bj	port map (l => l, n => n,
					sleep => sleep, clk => clk, reset => reset,
					maddress => maddressf0, mimo_en => mimo_en, sdin => sdin, sclk => sclk, sen => sen, sdout => sdout0, oen => oen0,
					h0 => ce0h0, h1 => ce0h1, h2 => ce0h2, h3 => ce0h3, h4 => ce0h4, h5 => ce0h5, h6 => ce0h6, h7 => ce0h7, h8 => ce0h8, h9 => ce0h9,
					a => ce0a, xen => ce0xen, ien => ce0ien
	);

        ce1: phequsce_bj	port map (l => l, n => n,
					sleep => sleep, clk => clk, reset => reset,
					maddress => maddressf1, mimo_en => mimo_en, sdin => sdin, sclk => sclk, sen => sen, sdout => sdout1, oen => oen1,
					h0 => ce1h0, h1 => ce1h1, h2 => ce1h2, h3 => ce1h3, h4 => ce1h4, h5 => ce1h5, h6 => ce1h6, h7 => ce1h7, h8 => ce1h8, h9 => ce1h9,
					a => ce1a, xen => ce1xen, ien => ce1ien
	);
	
	sdout <= (sdout0 and oen0) or (sdout1 and oen1) ;
	oen <= oen0 or oen1;
	
	
	-- Filtering engines
	fei0: phequfehf_bj2	port map (x => xii,
				h0 => ce0h0, h1 => ce0h1, h2 => ce0h2, h3 => ce0h3, h4 => ce0h4, h5 => ce0h5, h6 => ce0h6, h7 => ce0h7, h8 => ce0h8, h9 => ce0h9,
				a => ce0a, xen => ce0xen, ien => ce0ien,
				sleep => sleep, clk => clk, reset => reset,
				y => yii, xo => open
	);
	
	feq0: phequfehf_bj2	port map (x => xqi,
				h0 => ce1h0, h1 => ce1h1, h2 => ce1h2, h3 => ce1h3, h4 => ce1h4, h5 => ce1h5, h6 => ce1h6, h7 => ce1h7, h8 => ce1h8, h9 => ce1h9,
				a => ce1a, xen => ce1xen, ien => ce1ien,
				sleep => sleep, clk => clk, reset => reset,
				y => yqi, xo => open
	);
	
	-- Bypass MUX'es and registers
	yim <= xii when bypass = '1' else yii;
	yqm <= xqi when bypass = '1' else yqi;
	
	dl: process(clk, reset)
	begin
		if reset = '0' then
			yi <= (others => '0');
			yq <= (others => '0');
		elsif clk'event and clk = '1' then
			if sleep = '0' then
				yi <= yim;
				yq <= yqm;
			end if;
		end if;
	end process dl;
	
				 		       
end gfirhf16_arch_bj;
