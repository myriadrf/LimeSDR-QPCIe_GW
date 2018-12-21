library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.math_real.all;
use ieee.std_logic_arith.all;



-- ----------------------------------------------------------------------------
-- Entity declaration
-- ------------------------------------ ---------------------------------------
entity cfir_bj is
        generic (nd : natural:=20);
	port (
		-- Clock related inputs
		sleep: in std_logic;			-- Sleep signal
		clk: in std_logic;				-- Clock
		reset: in std_logic;			-- Reset
		bypass: in std_logic;			--  Bypass

		-- Data input signals
		xi: in std_logic_vector(15 downto 0);
		xq: in std_logic_vector(15 downto 0);

		-- Filter configuration
        half_order: in std_logic_vector(7 downto 0);
 		threshold: in std_logic_vector(15 downto 0);

		n: in std_logic_vector(7 downto 0);	-- Clock division ratio = n+1
		l: in std_logic_vector(2 downto 0); -- Number of taps is 5*(l+1)
		
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
		yi: out std_logic_vector(15 downto 0);
		yq: out std_logic_vector(15 downto 0);
		xen: out std_logic;
		speedup: in std_logic
	);
end cfir_bj;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture struct of cfir_bj is

	component gfirhf16mod_bj is
	port (
		-- Clock related inputs
		sleep: in std_logic;			-- Sleep signal
		clk: in std_logic;				-- Clock
		reset: in std_logic;			-- Reset
		bypass: in std_logic;			--  Bypass

		-- Data input signals
		xi: in std_logic_vector(15 downto 0);
		xq: in std_logic_vector(15 downto 0);

		-- Filter configuration
		n: in std_logic_vector(7 downto 0);	-- Clock division ratio = n+1
		l: in std_logic_vector(2 downto 0); -- Number of taps is 5*(l+1)
		
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
	end component gfirhf16mod_bj;

	component multiplier2 is
		port	(
			dataa		: IN STD_LOGIC_VECTOR (17 downto 0);
			datab		: IN STD_LOGIC_VECTOR (17 downto 0);
			result		: OUT STD_LOGIC_VECTOR (35 downto 0)
		);
	end component multiplier2;
	
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

	component sqroot is 	
	 	generic(mul_n: natural:=18; root: boolean); 
	 	port(
	  	 	clk, reset_n, data_valid: in std_logic;
		 	A_in :  in STD_LOGIC_VECTOR(35 downto 0);
		 	B_out : out STD_LOGIC_VECTOR(17 downto 0)	 
		);
	end component sqroot;

	component division is 	
	 	generic(mul_n: natural:=18); 
	 	port(
	  	 	clk, reset_n, data_valid: in std_logic;
		 	A_in : in STD_LOGIC_VECTOR(17 downto 0);
		 	B_in : in STD_LOGIC_VECTOR(17 downto 0);
                 	Z_out: out STD_LOGIC_VECTOR(17 DOWNTO 0));
	end component division;


        signal xi1, xq1, one, zero, threshold1, sig7, sig8, e, c, sig9, sig10, f, y, o, b, b1, b2, xq2, xi2 :  std_logic_vector (17 downto 0);
        signal sig1, sig2, sig3, sig4, sig5, sig6, sig11, sig12 :  std_logic_vector (35 downto 0);

	type array1 is array (0 to 10) of std_logic;
        signal sign, sleep1 : array1;

        type array2 is array (0 to nd+32) of std_logic_vector(17 downto 0);
        signal xi_reg, xq_reg : array2;

	signal xen1, data_valid: std_logic;
	signal o1, f1 :  std_logic_vector (24 downto 0);

	--signal eprim:real;
	--signal selsig: std_logic_vector(7 downto 0);
	
    signal cnt1b: std_logic;
    signal xen2, sleepX: std_logic;

begin

    
	process (reset, clk) is
    begin
        	if reset='0' then	cnt1b<='0';
       	elsif clk'event and clk='1' then  -- 1 CLK PERIOD DELAY               
					if (cnt1b='0') then cnt1b<='1';
					else cnt1b<='0';
					end if;					
        	end if;
	end process;	
	xen2<=cnt1b;	
	threshold1<="00"&threshold;
	

   -- ovo ovde menjam

	--data_valid<=xen1;  // bad
	data_valid<=xen1 when speedup='0' else xen2;
	
   --sleepX<=sleep; // bad
   sleepX<=sleep or speedup;		
	
  
	xen<=xen1;

   one<="01"&x"0000";
	zero<=(others=>'0');

         --e  = XI*XI + XQ*XQ; e/= am*am; e  = sqrt(e); // envelope

       
        process (reset, clk) is
        begin
        	if reset='0' then 
			xi1<=(others=>'0');
			xq1<=(others=>'0');
       		elsif clk'event and clk='1' then  -- 1 CLK PERIOD DELAY
                	if (data_valid='1') then  
                        	   xi1<=xi(15)&xi&'0'; -- format jedinice: 2 cifre (bitovi 17 i 16) pa tacka
				   xq1<=xq(15)&xq&'0'; 
                        end if;
        	end if;
	end process;

        -- FS: xx.xx..
             
        MultI2: multiplier2 port map (dataa=>xi1, datab=>xi1, result=>sig1);
	MultQ2: multiplier2 port map (dataa=>xq1, datab=>xq1, result=>sig2);

	--sig3(17 downto 0)<=sig1(33 downto 16);  -- FS: xx.xx... 	
	--sig4(17 downto 0)<=sig2(33 downto 16);  -- FS: xx.xx...

	sig3(35 downto 0)<=sig1(33 downto 0)&"00";  -- FS: xx.xx... 	
	sig4(35 downto 0)<=sig2(33 downto 0)&"00";  -- FS: xx.xx...
	
	Adder1: adder  generic map(res_n=> 36, op_n=> 36, addi=> 1) port map (dataa=>sig3, datab=>sig4, res=>sig5);  -- zbir kvadrata

        process (reset, clk) is
        begin
        	if reset='0' then 
			sig6<=(others=>'0');
       		elsif clk'event and clk='1' then  -- 1 CLK PERIOD DELAY
                   if (data_valid='1') then       
			sig6<=sig5;
                   end if;
        	end if;
	end process;
	
	
        Sqroot1: sqroot generic map (mul_n=> 18, root=>true) port map(clk=>clk, reset_n=>reset, data_valid=>data_valid, A_in => sig6, B_out => e);
        -- 10 CLK PERIOD DELAY       
        
	-- e: FS = xx.xx...
        
        -- if (e>threshold) c= threshold/e;   else c=1.0;
        Adder2: adder  generic map(res_n=> 18, op_n=> 18, addi=> 0) port map (dataa=>e, datab=>threshold1, res=>sig7); 
        sign(0)<=sig7(17);  -- ako je nula, tada je  e>threshold

	Div1: division generic map (mul_n => 18) port map( clk=>clk, reset_n=>reset, data_valid => data_valid, A_in => threshold1, B_in => e, Z_out => sig8);  
        --  sig8: FS = xx.xx...
  
    --    sleep1(0)<=sleep;
	sleep1(0)<=sleepX;
	lab0: for i in 1 to 10 generate 
        	process (reset, clk) is
        	begin
        		if reset='0' then 
				 sign(i)<='0';
				 sleep1(i)<='1';
       			elsif clk'event and clk='1' then  -- 10 CLK PERIOD DELAY
                              if (data_valid='1') then  
                        	 sign(i)<=sign(i-1);
 				 sleep1(i)<=sleep1(i-1);
                              end if;
        		end if;
		end process;
        end generate;

        c<=sig8 when (sign(10)='0' and sleep1(10)='0') else one;

	--  c: FS = xx.xx...

 	Adder3: adder  generic map(res_n=> 18, op_n=> 18, addi=> 0) port map (dataa=>one, datab=>c, res=>sig9);
	Adder4: adder  generic map(res_n=> 18, op_n=> 18, addi=> 0) port map (dataa=>sig9, datab=>f, res=>sig10);
 --zero umesto f

        process (reset, clk) is
        begin
        	if reset='0' then 
			         y<=(others=>'0');
       		elsif clk'event and clk='1' then  -- 1 CLK PERIOD DELAY
                	if (data_valid='1') then 
                        	if  (sig10(17)='0') then y<=sig10;
                                else y<=zero; 
				end if;
                        end if;
        	end if;
	end process;
 	
	 
	-- 1-c-f > 0, y=1-c-f, else y= 0
	
	gfir: gfirhf16mod_bj port map (  -- RED_FILTRA/2 CLK PERIOD DELAY
		sleep => sleepX,
		clk => clk,	
		reset => reset,	
		bypass => '0',
		xi => y(17 downto 2),
		xq => y(17 downto 2),
		n => n,
		l => l,	
		maddressf0 => maddressf0, -- donji red
		maddressf1 => maddressf1, -- feedback
		mimo_en => mimo_en,
		sdin => sdin,
		sclk => sclk,
		sen => sen,
		sdout => sdout,
		oen => oen,
		yi=> o1,
		yq=> f1,
		xen=>xen1);

       o <= o1(24 downto 7);
       f <= f1(24 downto 7);

       --  o,f: FS = xx.xx...

	
       Adder5: adder  generic map(res_n=> 18, op_n=> 18, addi=> 0) port map (dataa=>one, datab=>o, res=>b);

 	--process (reset, clk) is
        --begin
        --	if reset='0' then 
			--b<=(others=>'0');
			--b2<=(others=>'0');
       	--	elsif clk'event and clk='1' then  -- 1 CLK PERIOD DELAY
         --          if (data_valid='1') then       
			--b2<=b1;
			--b<=b1;
        --           end if;
		--	
       -- 	end if;
	--end process;

       --  b: FS = xx.xx...

	xi_reg(0)<=xi1;
	xq_reg(0)<=xq1;

        --  xi1, xq1: FS = xx.xx...

        lab1: for i in 1 to nd+32 generate 
        	process (reset, clk) is
        	begin
        		if reset='0' then 
				xi_reg(i)<=(others=>'0');
				xq_reg(i)<=(others=>'0');
       			elsif clk'event and clk='1' then
                              if (data_valid='1') then  
                        	xi_reg(i)<=xi_reg(i-1);
				xq_reg(i)<=xq_reg(i-1);
                              end if;
        		end if;
		end process;
         end generate;
         
	-- selsig<="001"& half_order(4 downto 0);

   --      mux: process (xi_reg, xq_reg, selsig) is
	-- begin
   --         xi2 <= xi_reg(conv_integer(selsig));
 	--    xq2 <= xq_reg(conv_integer(selsig));
   --      end process mux;
   
    mux: process (xi_reg, xq_reg, half_order) is
	 begin
         xi2 <= xi_reg(conv_integer(half_order)+30);  --  was 32 when Booth Mult are used
			xq2 <= xq_reg(conv_integer(half_order)+30);  --  30 is with MUltiplier2
    end process mux;
         
--eprim <= sqrt((real(conv_integer(signed(xi2)))*real(conv_integer(signed(xi2)))+real(conv_integer(signed(xq2)))*real(conv_integer(signed(xq2))))/(2.0**32.0));


         MultIb: multiplier2 port map (dataa=>xi2, datab=>b, result=>sig11);
	 MultQb: multiplier2 port map (dataa=>xq2, datab=>b, result=>sig12);

	 process (reset, clk) is
         begin
        	if reset='0' then 
			yi<=(others=>'0');
			yq<=(others=>'0');
       		elsif clk'event and clk='1' then
		
                      if (data_valid='1') then 
                        if bypass='0' then 
	                        yi<=sig11(32 downto 17); 
				yq<=sig12(32 downto 17); 
			else
				yi<=xi2(16 downto 1); 
				yq<=xq2(16 downto 1);
			end if;
		      end if;  
        	end if;
	 end process;


	--  yi, yq: FS = .xx...

end architecture struct;