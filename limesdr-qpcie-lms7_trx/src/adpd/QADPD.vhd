
-- 
--  ovaj je ispravljen
---
-- ----------------------------------------------------------------------------	
-- FILE: 	QADPD.vhd
-- DESCRIPTION:	Quadrature predistorter model
-- DATE:	Aug 28, 2018
-- AUTHOR(s):	Borisav Jovanovic, Lime Microsystems

------------------------------------------------------------------------------	
--  opseg koeficijenata je od [-16, 16],
--  prikazivanje u potp. komplementu, 18 bitova
--  aaaaa. bbbb bbbb bbbb b
--  jedinica je 0x 0000 1000 0000 0000 0
------------------------------------------------------------------------------	
--  korisceni su samo mnozaci tipa multiplier2 i u realnom i u kompleksnom delu
--  frekvenija rada je 122.88 MHz

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;	 
use ieee.std_logic_arith.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity QADPD is
	
	generic (
		n: natural:=4; -- memory depth
		m: natural:=2; -- nonlinearity
		mul_n: natural:=18); -- multiplier precision
	port (
		clk, sclk   : in std_logic;
		reset_n   	: in std_logic;
		data_valid	: in std_logic;
		xpi       	: in std_logic_vector(13 downto 0); 
		xpq       	: in std_logic_vector(13 downto 0);
		
		-- izmena
		ypi       	: out std_logic_vector(17 downto 0);  -- bilo 13  
		ypq       	: out std_logic_vector(17 downto 0);  -- bilo 13
		
		spi_ctrl  	: in std_logic_vector(15 downto 0); 
		spi_data  	: in std_logic_vector(15 downto 0);
		inp: in std_logic;
		outp: out std_logic);
	
end entity QADPD;

architecture structure of QADPD is
	
	component Multiplier2 IS
		PORT
			(
			dataa		: IN STD_LOGIC_VECTOR (17 DOWNTO 0);
			datab		: IN STD_LOGIC_VECTOR (17 DOWNTO 0);
			result		: OUT STD_LOGIC_VECTOR (35 DOWNTO 0)
			);
	END component Multiplier2;
	
	component adder is
		generic ( 
			res_n: natural:=18;  -- broj bitova rezultata
			op_n: natural:=18;   -- broj bitova operanda
			addi: natural:=1);   -- sabiranje addi==1
		port(
			dataa		: in std_logic_vector (op_n-1 downto 0);
			datab		: in std_logic_vector (op_n-1 downto 0);
			res		: out std_logic_vector (res_n-1 downto 0));
	end component  Adder;
	
	type cols is array (M downto 0) of std_logic_vector(mul_n-1 downto 0);
	type matr is array (N downto 0) of cols;
	type matr4 is array (M downto 0) of cols;
	
	type cols2 is array (M downto 0) of std_logic_vector(2*mul_n-1 downto 0);
	type matr2 is array (N downto 0) of cols2;	
	
	type cols3 is array (M downto 0) of std_logic_vector(mul_n+12 downto 0);  
	type matr3 is array (N downto 0) of cols3;	
	
	signal epprim: cols; 
	
	constant extens: std_logic_vector(mul_n-18 downto 0):=(others=>'0'); 
	signal XIp, XQp, XIpp, XQpp: std_logic_vector(mul_n-1 downto 0);	
	signal sig1, sig2: std_logic_vector(2*mul_n-1 downto 0);
	signal sig3, sig4, ep, epp: std_logic_vector(mul_n-1 downto 0);
	
	signal xIep, xQep : matr;
	signal xIep_z, xQep_z : matr4;
	
	signal xIep_s, xQep_s : cols2; 

	signal res1, res2, res3, res4: matr2;	
	signal res1_s, res2_s, res2_sprim, res3_s, res4_s, res4_sprim: matr3; 
	
	
	signal ijYpI, ijYpQ, ijYpI_s,ijYpQ_s: matr2;   
	
	type row2 is array (N downto 0) of std_logic_vector(2*mul_n-1 downto 0);
	
	signal iYpI, iYpQ : row2;
	signal YpI_s2, YpQ_s2 : std_logic_vector(2*mul_n-1 downto 0);
	
	signal a, ap, b, bp, mul5a, mul5b, mul6a, mul6b: matr; 
	constant zer: std_logic_vector(mul_n-17 downto 0):=(others=>'0');  

	constant all_zeros: std_logic_vector(mul_n-5 downto 0):=(others=>'0'); --[-16, 16]
	constant all_ones: std_logic_vector(mul_n-5 downto 0):=(others=>'1');  --[-16, 16]	
	signal sigI, sigQ: std_logic_vector(mul_n-5 downto 0); --[-16, 16]

	signal	ypi_s, ypq_s: std_logic_vector(17 downto 0); -- bilo 13
	
	--signal inpp: std_logic_vector(2*(N+M+5) downto 0); -- linija za kasnjenje
	signal address_i, address_j: std_logic_vector(4 downto 0);  -- bj: was 3
	
	
	type short_cols is array (0 downto 0) of std_logic_vector(mul_n-1 downto 0);
	type short_matr is array (N downto 0) of short_cols;	
	signal  c, d, cp, dp, mul7a, mul7b, mul8a, mul8b: short_matr;
	
	--type op_array is array (1 downto 0) of std_logic_vector(mul_n-1 downto 0);
	--signal op : op_array;
	
	--signal oi, oq: std_logic_vector(mul_n-1 downto 0);
	
	type short_cols2 is array (0 downto 0) of std_logic_vector(2*mul_n-1 downto 0);
	type short_matr2 is array (N downto 0) of short_cols2;
	signal res5, res6, res7, res8, iIQpI, iIQpQ, iIQpI_s, iIQpQ_s: short_matr2;
	
	
	type short_cols3 is array (0 downto 0) of std_logic_vector(mul_n+12 downto 0);
	type short_matr3 is array (N downto 0) of short_cols3;
	signal res5_s, res6_s, res6_sprim, res7_s, res8_s, res8_sprim : short_matr3;
	
	
begin   
	
	
	address_i<='0'&spi_ctrl(7 downto 4);
	address_j<='0'&spi_ctrl(3 downto 0);
	

	
	process(reset_n, sclk) is
	begin	
		if reset_n='0' then	
			
			for i in 0 to n loop				
				for j in 0 to m loop
					a(i)(j)<=(others=>'0');
					ap(i)(j)<=(others=>'0');
					b(i)(j)<=(others=>'0');
					bp(i)(j)<=(others=>'0');	
				end loop;
				
				for j in 0 to 0 loop
					c(i)(j)<=(others=>'0');
					d(i)(j)<=(others=>'0');
					cp(i)(j)<=(others=>'0');
					dp(i)(j)<=(others=>'0');
				end loop;
				
			end loop;
			
			a(0)(0)<=x"0800"&zer;  -- jedinicni koef., [-16, 16]
			ap(0)(0)<=x"0800"&zer;
			
			-- for DC offset
			--oi<=(others=>'0');
			--op(0)<=(others=>'0');
         
			--oq<=(others=>'0');
			--op(1)<=(others=>'0');
			
			--a(0)(0)<=x"1000"&zer;  -- jedinicni koef., [-8, 8]
			--ap(0)(0)<=x"1000"&zer;
			
		elsif (sclk'event and sclk='1') then
		
			if (spi_ctrl(15 downto 12)="0001") then  -- a coeff				
				ap(CONV_INTEGER(address_i))(CONV_INTEGER(address_j))<= spi_data&spi_ctrl(9 downto 8);
			elsif  (spi_ctrl(15 downto 12)= "0010") then -- b coeff					
				bp(CONV_INTEGER(address_i))(CONV_INTEGER(address_j))<= spi_data&spi_ctrl(9 downto 8);
			elsif (spi_ctrl(15 downto 12)="0011") then	-- c coeff				
				cp(CONV_INTEGER(address_i))(0)<= spi_data&spi_ctrl(9 downto 8);  -- CONV_INTEGER(address_j)
			elsif  (spi_ctrl(15 downto 12)= "0100") then -- d coeff					
				dp(CONV_INTEGER(address_i))(0)<= spi_data&spi_ctrl(9 downto 8);  -- CONV_INTEGER(address_j)
			-- elsif  (spi_ctrl(15 downto 12)= "0101") then -- oi - 0, oj - 1              
			--	op(CONV_INTEGER(address_i))<= spi_data&spi_ctrl(9 downto 8);		 		
			elsif	(spi_ctrl(15 downto 12)= "1111") then -- update a and b coeff				
				for i in 0 to n loop
					
					for j in 0 to m loop
						a(i)(j)<=ap(i)(j);
						b(i)(j)<=bp(i)(j);	
					end loop;
					
					for j in 0 to 0 loop  -- bilo 1
						c(i)(j)<=cp(i)(j);
						d(i)(j)<=dp(i)(j);
					end loop;
					
				end loop;

            --oi<=op(0);
            --oq<=op(1);	
				
			end if;		  
		end if;
	end process; 	

	lab4: process (clk, reset_n) is
	begin
		if reset_n='0' then			
			ypi<=(others=>'0');
			ypq<=(others=>'0');
		elsif (clk'event and clk='1') then	-- pipeline				
			if (data_valid='1') then
				ypi <=  ypi_s;
				ypq <=  ypq_s;
			end if;
		end if;			
	end process;	
	
	
	
	
	lab_IN: process (clk, reset_n) is
	begin	
		if reset_n='0' then	
			XIp<= (others=>'0');
			XQp<= (others=>'0');
		elsif   (clk'event and clk='1') then
			outp<=inp; 
			
			if data_valid='1' then		
			  XIp<=xpi(13)&xpi(13)&xpi(13)&xpi&extens;   --xpi,xpq 14-bitni brojevi, pripadaju opsegu[-8191,8192]
			  XQp<=xpq(13)&xpq(13)&xpq(13)&xpq&extens;
         end if;			
		end if;
	end process;
	
	-- 00010...000=1.0 (tri nule ispred)  2**14	(OK)
	
	Mult1: multiplier2 
	port map (dataa=>XIp, datab=>XIp, result=>sig1);
	sig3(mul_n-1 downto 0)<=sig1(2*mul_n-5 downto mul_n-4);  -- normalizovano u odnosu na FS	 
	-- sig3:00010..000 = 1.0	   2**14
	
	Mult2: multiplier2 
	port map (dataa=>XQp, datab=>XQp, result=>sig2);
	sig4(mul_n-1 downto 0)<=sig2(2*mul_n-5 downto mul_n-4);  -- normalizovan u odnosu na FS	
	-- sig4:00010..000 = 1.0	  2**14	
	-- ep: 00010..000 = 1.0		  2**14
	
	Adder1: adder  generic map( res_n=> mul_n, op_n=> mul_n, addi=> 1) 
	port map (dataa=>sig3, datab=>sig4, res=>ep);  -- zbir kvadrata	 
	
	-- kasnjenje 2 takta
	labX0: process (clk, reset_n) is
	begin
		if reset_n='0' then  
			xIpp<=(others=>'0');
			xQpp<=(others=>'0');
			epp<=(others=>'0');
		elsif (clk'event and clk='1') then -- pipeline
			if (data_valid='1') then   
				xIpp<=xIp;
				xQpp<=xQp;
				epp<=ep;
			end if;			
		end if;			
	end process; 	
	
	-- kasnjenje M*2= 3*2=6 taktova
	xIep_z(0)(0)<=XIpp;  
	xQep_z(0)(0)<=XQpp;  
	epprim(0)<=epp;	
	
	lab5: for j in 1 to M generate
		
		Mult3:  multiplier2 
		port map (dataa=>xIep_z(j-1)(j-1), datab=>epprim(j-1), result=>xIep_s(j-1));	 -- bilo ep	
		Mult4:  multiplier2 
		port map (dataa=>xQep_z(j-1)(j-1), datab=>epprim(j-1), result=>xQep_s(j-1));	-- bilo ep
		
		lab6: process (clk, reset_n) is
		begin
			if reset_n='0' then  
				xIep_z(j)(j)<=(others=>'0');
				xQep_z(j)(j)<=(others=>'0');
				epprim(j)<=(others=>'0');
			elsif (clk'event and clk='1') then -- pipeline
				if (data_valid='1') then   
					xIep_z(j)(j)<=xIep_s(j-1)(2*mul_n-5 downto mul_n-4);
					xQep_z(j)(j)<=xQep_s(j-1)(2*mul_n-5 downto mul_n-4);
					epprim(j)<=epprim(j-1);
				end if;			
			end if;			
		end process;				
		-- 00010..000 = 1.0	  2**14			
		labX1: for k in 0 to j-1 generate			
			labX2: process (clk, reset_n) is
			begin
				if reset_n='0' then  
					xIep_z(j)(k)<=(others=>'0');
					xQep_z(j)(k)<=(others=>'0');
				elsif (clk'event and clk='1') then -- pipeline
					if (data_valid='1') then   
						xIep_z(j)(k)<=xIep_z(j-1)(k); 
						xQep_z(j)(k)<=xQep_z(j-1)(k);					
					end if;			
				end if;			
			end process;               	
		end generate;
	end generate;
	
	labX3: for j in 0 to M generate -- nelinearnost		
		xIep(0)(j)<=xIep_z(M)(j); 
		xQep(0)(j)<=xQep_z(M)(j);		
	end generate;
	
	-- kasnjenje 2*N=2*3=6 taktova
	lab1: for i in N downto 1 generate
		lab2: for j in 0 to M generate			
			lab3: process (clk, reset_n) is
			begin
				if reset_n='0' then  
					xIep(i)(j)<=(others=>'0');
					xQep(i)(j)<=(others=>'0');
				elsif (clk'event and clk='1') then
					if (data_valid='1') then
						xIep(i)(j) <= xIep(i-1)(j);
						xQep(i)(j) <= xQep(i-1)(j);	
					end if;
				end if;			
			end process;		
		end generate;
	end generate;
	----------------------------------------------------  	
	-- koeficijenti su u granici od [-16, 16]
	-- 16 bitne vrednosti  
	-- 8192*[-4, 4]=[-32768, 32767]
	-- 000010....00=1.0
	
	
	-- kasnjenje 2+2+2=6 taktova
	lab7: for i in 0 to N generate 	
		lab8: for j in 0 to M generate
			
			--    YpI  += a[i][j]* xIep[i][j] - b[i][j]* xQep[i][j]; // 19.11.2015
			--    YpQ  += a[i][j]* xQep[i][j] + b[i][j]* xIep[i][j]; // 19.11.2015 
			
			-- 00010..000 = 1.0	  2**14  xIep
			-- 0000 1000 0000 0000 00 = 1.0	  2**13	 koeficijent
			
			
			
			------ (problem)  
			mul5a(i)(j)<=a(i)(j) when data_valid='1' else b(i)(j);
			mul5b(i)(j)<=xIep(i)(j) when data_valid='1' else xQep(i)(j);
			
			Mult5:  multiplier2 port map (dataa=>mul5a(i)(j), datab=>mul5b(i)(j), result=>res1(i)(j));			
			lab14: process (clk, reset_n) is
			begin
			if reset_n='0' then
				   res1_s(i)(j)<=	(others=>'0');
				   res2_s(i)(j)<=	(others=>'0');
                                   res2_sprim(i)(j)<=	(others=>'0');				
				elsif (clk'event and clk='1') then  -- pipeline
					if (data_valid='1') then
						res1_s(i)(j)<=res1(i)(j)(2*mul_n-1 downto mul_n-13);   -- a(i)(j)*xIep(i)(j)
                                                res2_sprim(i)(j)<=res2_s(i)(j);
					else
						res2_s(i)(j)<=res1(i)(j)(2*mul_n-1 downto mul_n-13); 	--	b(i)(j)*xQep(i)(j)			
					end if;
				end if;
			end process;			
			
			Adder2: adder generic map (res_n=>2*mul_n, op_n=>mul_n+13, addi=>0)  -- subtraction
			port map (dataa=>res1_s(i)(j), datab=>res2_sprim(i)(j), res=>ijYpI(i)(j));			
			----- (problem) 
		        -- a(i)(j)*xIep(i)(j) - b(i)(j)*x Qep(i)(j)	
			
			

			
			----- (problem)  // start
		        mul6a(i)(j)<=a(i)(j) when data_valid='1' else b(i)(j);
			mul6b(i)(j)<=xQep(i)(j) when data_valid='1' else xIep(i)(j);
			Mult6:  multiplier2 port map (dataa=>mul6a(i)(j), datab=>mul6b(i)(j), result=>res3(i)(j));	
			
			lab15: process (clk, reset_n) is
			begin
				if reset_n='0' then
					res3_s(i)(j)<=	(others=>'0');
					res4_s(i)(j)<=	(others=>'0');
                                        res4_sprim(i)(j)<= (others=>'0');					
				elsif (clk'event and clk='1') then  -- pipeline
					if (data_valid='1') then
						res3_s(i)(j)<=res3(i)(j)(2*mul_n-1 downto mul_n-13); --a(i)(j)*xQep(i)(j)
                                                res4_sprim(i)(j)<=res4_s(i)(j);
					else
						res4_s(i)(j)<=res3(i)(j)(2*mul_n-1 downto mul_n-13); --b(i)(j)*xIep(i)(j)					
					end if;
				end if;
			end process;			
			Adder3: adder generic map (res_n=>2*mul_n, op_n=>mul_n+13, addi=>1) -- addition
			port map (dataa=>res3_s(i)(j), datab=>res4_sprim(i)(j), res=>ijYpQ(i)(j)); 
		         -----  (problem)  // end	
			--a(i)(j)*xQep(i)(j)+b(i)(j)*xIep(i)(j)
			
			
			lab9: process (clk, reset_n) is
			begin
				if reset_n='0' then  
					ijYpI_s(i)(j)<=(others=>'0');
					ijYpQ_s(i)(j)<=(others=>'0');
				elsif (clk'event and clk='1') then  -- pipeline
					if (data_valid='1') then
						ijYpI_s(i)(j)<=ijYpI(i)(j); 
						ijYpQ_s(i)(j)<=ijYpQ(i)(j);	 
					end if;
				end if;			
			end process;			
		end generate;
		
		
		
		
		----------------------------------
      -- konjugovano kompleksni deo		
		
		labX3: for j in 0 to 0 generate -- nelinearnost
		
						
			------ new one (problem)  // start
			mul7a(i)(j)<=c(i)(j) when data_valid='1' else d(i)(j);
			mul7b(i)(j)<=xIep(i)(j) when data_valid='1' else xQep(i)(j);		
			Mult7:  multiplier2 port map (dataa=>mul7a(i)(j), datab=>mul7b(i)(j), result=>res5(i)(j));	
			
			mul8a(i)(j)<=d(i)(j) when data_valid='1' else c(i)(j);
			mul8b(i)(j)<=xIep(i)(j) when data_valid='1' else xQep(i)(j);		
			Mult8:  multiplier2 port map (dataa=>mul8a(i)(j), datab=>mul8b(i)(j), result=>res7(i)(j));		
			
			labX1: process (clk, reset_n) is
			begin
				if reset_n='0' then
					res5_s(i)(j)<=	(others=>'0');
					res6_s(i)(j)<=	(others=>'0');	
					res7_s(i)(j)<=	(others=>'0');
					res8_s(i)(j)<=	(others=>'0');	

                                        res6_sprim(i)(j)<= (others=>'0');
                                        res8_sprim(i)(j)<= (others=>'0');
						
				elsif (clk'event and clk='1') then  -- pipeline
					
					if (data_valid='1') then
						res5_s(i)(j)<=res5(i)(j)(2*mul_n-1 downto mul_n-13); --  c[i][j])* xIep[i][j]
						res7_s(i)(j)<=res7(i)(j)(2*mul_n-1 downto mul_n-13); --  d[i][j])* xIep[i][j]

                                                res6_sprim(i)(j)<=  res6_s(i)(j);
                                                res8_sprim(i)(j)<=  res8_s(i)(j);
                                                						
					else
						res6_s(i)(j)<=res5(i)(j)(2*mul_n-1 downto mul_n-13); --	d[i][j])* xQep[i][j]
						res8_s(i)(j)<=res7(i)(j)(2*mul_n-1 downto mul_n-13); --	c[i][j])* xQep[i][j]						
					end if;
				end if;
			end process;
        	
			AdderX1: adder generic map (res_n=>2*mul_n, op_n=>mul_n+13, addi=>1) -- addition 
			port map (dataa=>res5_s(i)(j), datab=>res6_sprim(i)(j), res=>iIQpI(i)(j)); 
			------- c[i][j])* xIep[i][j] + d[i][j])* xQep[i][j]
		        AdderX2: adder generic map (res_n=>2*mul_n, op_n=>mul_n+13, addi=>0) -- subtraction 
		        port map (dataa=>res7_s(i)(j), datab=>res8_sprim(i)(j), res=>iIQpQ(i)(j));	
			------- d[i][j])* xIep[i][j] - c[i][j])* xQep[i][j]
			------ new one (problem)  // end


         labX2: process (clk, reset_n) is
			begin
				if reset_n='0' then  
					iIQpI_s(i)(j)<=(others=>'0');
					iIQpQ_s(i)(j)<=(others=>'0');
				elsif (clk'event and clk='1') then  -- pipeline
					if (data_valid='1') then
						iIQpI_s(i)(j)<=iIQpI(i)(j); 
						iIQpQ_s(i)(j)<=iIQpQ(i)(j);	 
					end if;
				end if;			
			end process;
		
		end generate;	-- labX3: for j in 0 to 0 generate
		----------------------------------
		
		lab10: process (clk, reset_n) is
			variable iYpI_s,iYpQ_s: std_logic_vector(2*mul_n-1 downto 0);
		begin
			if reset_n='0' then  
				iYpI_s:=(others=>'0');
				iYpQ_s:=(others=>'0');
				
			elsif (clk'event and clk='1') then	-- pipeline
				if (data_valid='1') then
					
					
					iYpI_s:=(others=>'0'); -- inicijalizacija	
					iYpQ_s:=(others=>'0');					
					
					
					for j in 0 to M loop  --nelinearnost 0, 1, 2
						iYpI_s:=iYpI_s + ijYpI_s(i)(j); 
						iYpQ_s:=iYpQ_s + ijYpQ_s(i)(j);
					end loop;
					
					iYpI_s:=iYpI_s + iIQpI_s(i)(0);  -- dodao sam ovo
					iYpQ_s:=iYpQ_s + iIQpQ_s(i)(0);  -- dodaje se konjugovano kompleksni deo
					
				end if;				
			end if;
			
			iYpI(i)<=iYpI_s;
			iYpQ(i)<=iYpQ_s;
			
		end process;
	end generate;
	
	lab11: process (clk, reset_n) is
		variable YpI_s,YpQ_s: std_logic_vector(2*mul_n-1 downto 0);
	begin
		if reset_n='0' then  
			YpI_s:=(others=>'0');
			YpQ_s:=(others=>'0');
		elsif (clk'event and clk='1') then	 -- pipeline
			if (data_valid='1') then
				YpI_s:=(others=>'0');
				YpQ_s:=(others=>'0');	---memorija					
				for i in 0 to N loop
					YpI_s:=YpI_s + iYpI(i); 
					YpQ_s:=YpQ_s + iYpQ(i);
				end loop;
			end if;			  
		end if;
		YpI_s2<=YpI_s;
		YpQ_s2<=YpQ_s;  		   
	end process;

	sigI<= YpI_s2(2*mul_n-1 downto mul_n+4);  -- [-16, 16]
	sigQ<= YpQ_s2(2*mul_n-1 downto mul_n+4);
	
	comp_I: process (YpI_s2, sigI)is
	begin		
		if 	(sigI= all_zeros) then

			ypi_s<=YpI_s2(mul_n+4 downto mul_n-13); -- [-16, 16]
		
		elsif  (sigI= all_ones) then
			ypi_s<=YpI_s2(mul_n+4 downto mul_n-13); -- [-16, 16] 
		elsif sigI(mul_n-5)='0' then -- [-16, 16]
		   ypi_s<=(17=>'0', others=>'1'); 
		else
			ypi_s<=(17=>'1', others=>'0'); 
		end if;
		
	end process;
	
	-- YpQ_s2, YpI_s2   (mul_n+6 downto 0)
	-- var: YpI_s,YpQ_s  (mul_n+6 downto 0)
	
	-- iYpI(i), iYpQ(i)  (mul_n+6 downto 0)
	-- ijYpI_s(i)(j), ijYpQ_s(i)(j), iIQpI_s(i)(0), iIQpQ_s(i)(0)  (mul_n+6 downto 0)
	
	comp_Q: process (YpQ_s2, sigQ)is
	begin		
		if 	(sigQ= all_zeros) then
			ypq_s<=YpQ_s2(mul_n+4 downto mul_n-13); -- [-16, 16] 		
		elsif  (sigQ= all_ones)  then			
			ypq_s<=YpQ_s2(mul_n+4 downto mul_n-13); -- [-16, 16]		
		elsif sigQ(mul_n-5)='0'  then -- [-16, 16]		
			ypq_s<=(17=>'0', others=>'1'); 
		else
			ypq_s<=(17=>'1', others=>'0'); 
		end if;		
	end process;	
	
end architecture structure;