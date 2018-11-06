library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity bypass is
    
	 generic (N: natural:=18); 	
	 port(d: in std_logic_vector(N-1 downto 0);
		   q: out std_logic_vector(N-1 downto 0));
			
end entity bypass;

architecture beh of bypass is	
begin

 q<=d; 

end architecture beh;
