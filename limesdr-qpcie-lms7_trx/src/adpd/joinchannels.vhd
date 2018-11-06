library IEEE;
use IEEE.std_logic_1164.all;

entity joinchannels is
	generic ( N : natural := 14 );
	port(
		clk 			: in std_logic;
		reset_n 		: in std_logic;
		sel_chA 		: in std_logic;
		xAi			: in std_logic_vector( N-1 downto 0 );
		xAq			: in std_logic_vector( N-1 downto 0 );	
		xBi			: in std_logic_vector( N-1 downto 0 );
		xBq			: in std_logic_vector( N-1 downto 0 );	
		yi			   : out std_logic_vector( N-1 downto 0 );
		yq			   : out std_logic_vector( N-1 downto 0 )
	);	
	
end entity joinchannels;

architecture beh of joinchannels is 

begin

   WRITE_OUTPUT: process (clk, reset_n) is
	begin
		if reset_n='0' then			
			yi <= (others=>'0');
			yq  <= (others=>'0');
		elsif (clk'event and clk='1') then
	     
		  if (sel_chA='1') then 
		      yi <=  xAi;
				yq <=  xAq;           				
		  else 
		      yi <=  xBi;
				yq <=  xBq; 
		  end if;
		  
		end if;			
	end process WRITE_OUTPUT;

end architecture beh;