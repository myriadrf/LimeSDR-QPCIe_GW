library IEEE;
use IEEE.STD_LOGIC_1164.all;


entity regis is 	
	 generic(n: natural:=16); 
	 port(
	  	 clk, reset_n, data_valid: in std_logic;
		 D :  in STD_LOGIC_VECTOR(n-1 downto 0);
		 Q :  out STD_LOGIC_VECTOR(n-1 downto 0));
end regis;

architecture beh of regis is 

begin


      aa: process (clk, reset_n) is
		begin			
			if reset_n='0' then			
				Q <= (others=>'0');			
			elsif clk'event and clk='1' then			
				if data_valid='1' then				
				  Q  <= D;              			
				end if;
			end if;
		end process aa;	


end architecture beh;