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


-- uradjeno je preko Alterinih mnozaca
-- usteda u povrsini

library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_unsigned.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ------------------------------------ ---------------------------------------
entity phequfehf_bj2 is
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
end phequfehf_bj2;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture phequfehf_arch_bj of phequfehf_bj2 is

	-- Signals
	signal x0, x1, x2, x3, x4, x5, x6, x7, x8, x9: std_logic_vector(24 downto 0);	
	signal y1:  std_logic_vector(24 downto 0); -- y1, y2, y3, y1p, y2pp	
	signal en:  std_logic;
		
	-- Logic constants
	signal zero: std_logic;
	
	-- Component declarations
	use work.components.dmem4x25;
	use work.components.accu10x26mac;

	for all:dmem4x25 use entity work.dmem4x25(dmem4x25_arch);  --BJ	
	for all:accu10x26mac use entity work.accu10x26mac(accu10x26mac_arch);

       component Multiplier2 IS
		PORT
			(
			dataa		: IN STD_LOGIC_VECTOR (17 DOWNTO 0);
			datab		: IN STD_LOGIC_VECTOR (17 DOWNTO 0);
			result		: OUT STD_LOGIC_VECTOR (35 DOWNTO 0)
			);
	end component Multiplier2;

        signal h0prim, h1prim, h2prim, h3prim, h4prim, h5prim, h6prim, h7prim, h8prim, h9prim: std_logic_vector(17 downto 0); 
        signal x0prim, x1prim, x2prim, x3prim, x4prim, x5prim, x6prim, x7prim, x8prim, x9prim: std_logic_vector(17 downto 0); 
	signal res0, res1, res2, res3, res4, res5, res6, res7, res8, res9: std_logic_vector(35 downto 0);
        signal res, res0prim, res1prim, res2prim, res3prim, res4prim, res5prim, res6prim, res7prim, res8prim, res9prim: std_logic_vector(25 downto 0); 
        signal res0sec, res1sec, res2sec, res3sec, res4sec, res5sec, res6sec, res7sec, res8sec, res9sec: std_logic_vector(25 downto 0);
        signal xensec: std_logic;
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


        h0prim <= h0&"00"; -- 18 bit
        x0prim <= x0(24 downto 7);
        Mult0:  multiplier2  port map (dataa=>x0prim, datab=>h0prim, result=>res0);       

        h1prim <= h1&"00"; -- 18 bit
        x1prim <= x1(24 downto 7); 
        Mult1:  multiplier2  port map (dataa=>x1prim, datab=>h1prim, result=>res1);        

        h2prim <= h2&"00"; -- 18 bit
        x2prim <= x2(24 downto 7); 
        Mult2:  multiplier2  port map (dataa=>x2prim, datab=>h2prim, result=>res2);      

        h3prim <= h3&"00"; -- 18 bit
        x3prim <= x3(24 downto 7); 
        Mult3:  multiplier2  port map (dataa=>x3prim, datab=>h3prim, result=>res3);       

        h4prim <= h4&"00"; -- 18 bit
        x4prim <= x4(24 downto 7); 
        Mult4:  multiplier2  port map (dataa=>x4prim, datab=>h4prim, result=>res4);       

        h5prim <= h5&"00"; -- 18 bit
        x5prim <= x5(24 downto 7); 
        Mult5:  multiplier2  port map (dataa=>x5prim, datab=>h5prim, result=>res5);        

        h6prim <= h6&"00"; -- 18 bit
        x6prim <= x6(24 downto 7); 
        Mult6:  multiplier2  port map (dataa=>x6prim, datab=>h6prim, result=>res6);        

        h7prim <= h7&"00"; -- 18 bit
        x7prim <= x7(24 downto 7); 
        Mult7:  multiplier2  port map (dataa=>x7prim, datab=>h7prim, result=>res7);        

        h8prim <= h8&"00"; -- 18 bit
        x8prim <= x8(24 downto 7); 
        Mult8:  multiplier2  port map (dataa=>x8prim, datab=>h8prim, result=>res8);       

        h9prim <= h9&"00"; -- 18 bit
        x9prim <= x9(24 downto 7);
        Mult9:  multiplier2  port map (dataa=>x9prim, datab=>h9prim, result=>res9);

        res0prim<=res0(35 downto 10);
        res1prim<=res1(35 downto 10);
        res2prim<=res2(35 downto 10); 
        res3prim<=res3(35 downto 10);
        res4prim<=res4(35 downto 10); 
        res5prim<=res5(35 downto 10); 
        res6prim<=res6(35 downto 10);  
        res7prim<=res7(35 downto 10);
        res8prim<=res8(35 downto 10);
        res9prim<=res9(35 downto 10);   

	process (reset, clk) is
        begin
        	if reset='0' then 

			 y<=(others=>'0');
                         res0sec<=(others=>'0');
                         res1sec<=(others=>'0');
                         res2sec<=(others=>'0');
                         res3sec<=(others=>'0');
                         res4sec<=(others=>'0');
                         res5sec<=(others=>'0');
                         res6sec<=(others=>'0');
                         res7sec<=(others=>'0');
                         res8sec<=(others=>'0');
                         res9sec<=(others=>'0');
                         xensec<='0';
					
       		elsif clk'event and clk='1' then  -- 1 CLK PERIOD DELAY
                   if (en='1') then   

                         res0sec<=res0prim;
                         res1sec<=res1prim;
                         res2sec<=res2prim;
                         res3sec<=res3prim;
                         res4sec<=res4prim;
                         res5sec<=res5prim;
                         res6sec<=res6prim;
                         res7sec<=res7prim;
                         res8sec<=res8prim;
                         res9sec<=res9prim;
                         y<= y1;
                         xensec<=xen;

                   end if;
        	end if;
	end process;

	accu1: accu10x26mac port map(x1 => res0sec, x2 => res1sec, x3 => res2sec, x4 => res3sec,
				     x5 => res4sec, x6 => res5sec, x7 => res6sec, x8 => res7sec,
			             x9 => res8sec, x10 => res9sec, 
                                     ien => ien, oen => xensec, 
				     en => en, clk => clk, reset => reset, y => y1);
        


	xo <= x9;  -- BJ
				 		       
end phequfehf_arch_bj;
