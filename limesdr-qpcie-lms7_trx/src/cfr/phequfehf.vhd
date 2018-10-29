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

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ------------------------------------ ---------------------------------------
entity phequfehf_bj is
	port (
		x: in std_logic_vector(24 downto 0);	-- Input signal

		-- Filter configuration
		h0, h1, h2, h3, h4, h5, h6, h7, h8, h9: in std_logic_vector(15 downto 0);
		a: in std_logic_vector(1 downto 0);  --BJ
		xen, ien: in std_logic;

		-- Clock related inputs
		sleep: in std_logic;			-- Sleep signal
		clk: in std_logic;			-- Clock
		reset: in std_logic;			-- Reset
		
		y: out std_logic_vector(24 downto 0);	-- Filter output
		xo: out std_logic_vector(24 downto 0)	-- DRAM output
	);
end phequfehf_bj;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture phequfehf_arch_bj of phequfehf_bj is

	-- Signals
	signal x0, x1, x2, x3, x4, x5, x6, x7, x8, x9: std_logic_vector(24 downto 0);

	signal s0, c0: std_logic_vector(25 downto 0);
	signal s1, c1: std_logic_vector(25 downto 0);
	signal s2, c2: std_logic_vector(25 downto 0);
	signal s3, c3: std_logic_vector(25 downto 0);
	signal s4, c4: std_logic_vector(25 downto 0);
	signal s5, c5: std_logic_vector(25 downto 0);
	signal s6, c6: std_logic_vector(25 downto 0);
	signal s7, c7: std_logic_vector(25 downto 0);
	signal s8, c8: std_logic_vector(25 downto 0);
	signal s9, c9: std_logic_vector(25 downto 0);
	
	signal y1, y2, y1p, y2p, y3p: std_logic_vector(24 downto 0);
	
	signal en: std_logic;
		
	-- Logic constants
	signal zero: std_logic;
	
	-- Component declarations
	use work.components.dmem4x25;
	use work.components.accu10x26mac;
	--use work.components.ba26x16x26mac;
	use work.components.ba16x16x26mac;
	
	for all:dmem4x25 use entity work.dmem4x25(dmem4x25_arch);  --BJ
	
	for all:accu10x26mac use entity work.accu10x26mac(accu10x26mac_arch);
	--for all:ba26x16x26mac use entity work.ba26x16x26mac(ba26x16x26mac_arch);
	for all:ba16x16x26mac use entity work.ba16x16x26mac(ba16x16x26mac_arch);

        component adder is
		generic ( 
			res_n: natural:=18;  -- broj bitova rezultata
			op_n: natural:=18;   -- broj bitova operanda
			addi: natural:=1);   -- sabiranje addi==1
		port(
			dataa		: in std_logic_vector (op_n-1 downto 0);
			datab		: in std_logic_vector (op_n-1 downto 0);
			res		: out std_logic_vector (res_n-1 downto 0)
		);
	end component  Adder;
	
begin			     
				    
	zero <= '0';
	en <= not sleep;

	-- Data memory modules
	dmem0: dmem4x25 port map(x => x, clk => clk, reset => reset, en => xen,
				a => a, d => x0);

	dmem1: dmem4x25 port map(x => x0, clk => clk, reset => reset, en => xen,
				a => a, d => x1);

	dmem2: dmem4x25 port map(x => x1, clk => clk, reset => reset, en => xen,
				a => a, d => x2);

	dmem3: dmem4x25 port map(x => x2, clk => clk, reset => reset, en => xen,
				a => a, d => x3);

	dmem4: dmem4x25 port map(x => x3, clk => clk, reset => reset, en => xen,
				a => a, d => x4);
				
	dmem5: dmem4x25 port map(x => x4, clk => clk, reset => reset, en => xen,
				a => a, d => x5);

	dmem6: dmem4x25 port map(x => x5, clk => clk, reset => reset, en => xen,
				a => a, d => x6);

	dmem7: dmem4x25 port map(x => x6, clk => clk, reset => reset, en => xen,
				a => a, d => x7);

	dmem8: dmem4x25 port map(x => x7, clk => clk, reset => reset, en => xen,
				a => a, d => x8);

	dmem9: dmem4x25 port map(x => x8, clk => clk, reset => reset, en => xen,
				a => a, d => x9);
				
	-- Booth arrays
	barray0: ba16x16x26mac
		port map(x => x0(24 downto 9), 
			y => h0, c => c0, s => s0, clk => clk, 
			en => en, reset => reset);

	barray1: ba16x16x26mac
		port map(x => x1(24 downto 9), 
			y => h1, c => c1, s => s1, clk => clk, 
			en => en, reset => reset);

	barray2: ba16x16x26mac
		port map(x => x2(24 downto 9), 
			y => h2, c => c2, s => s2, clk => clk, 
			en => en, reset => reset);

	barray3: ba16x16x26mac
		port map(x => x3(24 downto 9), 
			y => h3, c => c3, s => s3, clk => clk, 
			en => en, reset => reset);

	barray4: ba16x16x26mac
		port map(x => x4(24 downto 9), 
			y => h4, c => c4, s => s4, clk => clk, 
			en => en, reset => reset);
			
	barray5: ba16x16x26mac
		port map(x => x5(24 downto 9), 
			y => h5, c => c5, s => s5, clk => clk, 
			en => en, reset => reset);

	barray6: ba16x16x26mac
		port map(x => x6(24 downto 9), 
			y => h6, c => c6, s => s6, clk => clk, 
			en => en, reset => reset);

	barray7: ba16x16x26mac
		port map(x => x7(24 downto 9), 
			y => h7, c => c7, s => s7, clk => clk, 
			en => en, reset => reset);

	barray8: ba16x16x26mac
		port map(x => x8(24 downto 9), 
			y => h8, c => c8, s => s8, clk => clk, 
			en => en, reset => reset);

	barray9: ba16x16x26mac
		port map(x => x9(24 downto 9), 
			y => h9, c => c9, s => s9, clk => clk, 
			en => en, reset => reset);

	-- Accumulator
	accu1: accu10x26mac port map(x1 => s0, x2 => c0, x3 => s1, x4 => c1,
				 x5 => s2, x6 => c2, x7 => s3, x8 => c3,
				 x9 => s4, x10 => c4, ien => ien, oen => xen, 
				 en => en, clk => clk, reset => reset, y => y1);
				 
				 
	accu2: accu10x26mac port map(x1 => s5, x2 => c5, x3 => s6, x4 => c6,
				 x5 => s7, x6 => c7, x7 => s8, x8 => c8,
				 x9 => s9, x10 => c9, ien => ien, oen => xen, 
				 en => en, clk => clk, reset => reset, y => y2);
				 
	-- jos 2* CLK_PERIOD
	process (reset, clk) is
        begin
        	if reset='0' then 
					y1p<=(others=>'0');
					y2p<=(others=>'0');
					y<=(others=>'0');
       		elsif clk'event and clk='1' then  -- 1 CLK PERIOD DELAY
                   if (en='1') then       
						y1p<=y1;
						y2p<=y2;
						y<=y3p;
                   end if;
        	end if;
	end process;
				 
	
	
	Adder0: adder  generic map(res_n=> 25, op_n=> 25, addi=> 1) port map (dataa=>y1p, datab=>y2p, res=>y3p);
	
	
	--xo <= x4;
	xo <= x9;  -- BJ
				 		       
end phequfehf_arch_bj;
