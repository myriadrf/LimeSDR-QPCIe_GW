library ieee;
use ieee.std_logic_1164.all;

entity clk_div2 is
    port (
		clk: in std_logic;			-- Clock and reset
	   rst_n: in std_logic;
	   en: out std_logic			   -- Output enable signal
    );
end clk_div2;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture clk_div2 of clk_div2 is

	signal q: std_logic;
	
begin

	labX: process (clk, rst_n) is
	begin
		if rst_n='0' then  
				q<='0';
		elsif (clk'event and clk='1') then 
				q<= not q;			
		end if;			
	end process;
	
	en<=q;
	
end architecture  clk_div2;
