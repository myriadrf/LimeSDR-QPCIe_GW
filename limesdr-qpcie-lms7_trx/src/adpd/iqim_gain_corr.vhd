library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;



-- gain_ch je u opsegu od -4 do 4
-- gain_ch 001.000...00 (13 nula iza)

entity iqim_gain_corr is
	
	port(		
		clk 			: in std_logic;
		reset_n, en, bypass : in std_logic;		
		
		ypi			: in std_logic_vector( 15 downto 0 );
		ypq			: in std_logic_vector( 15 downto 0 );		
		
		gain_ch	   : in std_logic_vector( 15 downto 0 );		
		
		ypi_o		: out std_logic_vector( 15 downto 0 );
		ypq_o		: out std_logic_vector( 15 downto 0 )
		
);
end entity iqim_gain_corr;

architecture iqim_gain_corr_rtl of iqim_gain_corr is 

	component Multiplier2 IS
		port
			(
			dataa		: IN STD_LOGIC_VECTOR (17 DOWNTO 0);
			datab		: IN STD_LOGIC_VECTOR (17 DOWNTO 0);
			result	: OUT STD_LOGIC_VECTOR (35 DOWNTO 0)
	);
	end component Multiplier2;
	
	constant N : natural:= 18; -- Multiplier word length
	
	signal ypi_prim		: std_logic_vector(N - 1 downto 0);
	signal ypq_prim 		: std_logic_vector(N - 1 downto 0);	
	signal gain_prim		: std_logic_vector(N - 1 downto 0);
   signal ypi_sec		: std_logic_vector( 15 downto 0 );
	signal ypq_sec		: std_logic_vector( 15 downto 0 );
	signal sig1, sig2 : std_logic_vector(2*N - 1 downto 0);
	

	
begin

   ypi_prim <= ypi(15) & ypi & '0'; -- 18 bits
	ypq_prim <= ypq(15) & ypq & '0';	 
	gain_prim<=gain_ch & "00" ; -- 18 bits
	
-- gain_prim je u opsegu od -4 do 4
-- gain_prim 001.000...00 (15 nula iza)
-- ypq_prim jedinica je 0100..000 (16 nula iza)
	
	Mul_chA_i: Multiplier2 
	port map (dataa=> ypi_prim, datab => gain_prim, result=> sig1);
	
	
	Mul_chA_q: Multiplier2 
	port map (dataa=> ypq_prim, datab => gain_prim, result=> sig2);
	
	
	WRITE_OUTPUT: process (clk) is  -- , reset_n
	begin
		--if reset_n='0' then			  
		--	  ypi_sec <= (others=>'0');
		--	  ypq_sec  <= (others=>'0');		
		--els
		if (clk'event and clk='1') then
		   if en='1' then
			
	        ypi_sec <=  sig1(31 downto 16);
		     ypq_sec <=  sig2(31 downto 16);
           
			 if 	bypass='0' then		  
			   ypi_o <= ypi_sec;
	         ypq_o <= ypq_sec;
			 else
			   ypi_o <= ypi;
				ypq_o <= ypq;
			end if;
			
		  end if;	  
		end if;			
	end process WRITE_OUTPUT;
	
	
	
	
end architecture iqim_gain_corr_rtl;

