library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- format jedinice: 2 cifre (bitovi 17 i 16) pa tacka

entity division is 	
	 generic(mul_n: natural:=18); 
	 port(
	  	 clk, reset_n, data_valid: in std_logic;
		 A_in : in STD_LOGIC_VECTOR(17 downto 0);
		 B_in : in STD_LOGIC_VECTOR(17 downto 0);
                 Z_out: out STD_LOGIC_VECTOR(17 DOWNTO 0));
end division;


architecture struct of division is 

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
   
   type  new_type is array (9 downto 0) of std_logic_vector(19 downto 0);   
   signal ax, bx, cx: new_type; 
   
   type  new_type2 is array (9 downto 0) of std_logic_vector(17 downto 0);   
   signal B,  C: new_type2; 
   
   type  new_type3 is array (9 downto 0) of std_logic_vector(39 downto 0);   
   signal A: new_type3;
   signal data_valid_d: std_logic;  
  
begin


        process (clk, reset_n) is
		begin			
			if reset_n='0' then
				data_valid_d <= '0';
				Z_out<= (others=>'0');
			elsif clk'event and clk='1' then
				data_valid_d <= data_valid;
				if data_valid='1' then
 					Z_out<= C(9);	
				end if;		
			end if;	
		end process;	
      
	A(0)<= A_in(17) & A_in(17)& A_in(17) & A_in & x"0000"& "000";
        B(0)<= B_in;
	C(0)<= (others=>'0');

	lab: for i in 1 to 9 generate		
	   mux: process	(A, B, data_valid) is 
	   begin 
		   if data_valid='1' then
			   ax(i)<= A(i-1)(39 downto 20);
			   bx(i)<= B(i-1)(17)& B(i-1)(17)& B(i-1);
		   else 
			   ax(i)<= A(i)(39 downto 20);
			   bx(i)<= B(i)(17)& B(i)(17)& B(i);
			end if;		   
	   end process;	   
		
	   Adder1: adder  generic map( res_n=> mul_n+2, op_n=> mul_n+2, addi=> 0) 
	   port map (dataa=>ax(i), datab=>bx(i), res=>cx(i));
	
	   process (clk, reset_n) is
		begin			
			if reset_n='0' then
				A(i)<=(others=>'0');
				B(i)<=(others=>'0'); 
				C(i)<=(others=>'0');                             

			elsif clk'event and clk='1' then                               
				if data_valid='1' then
 					B(i)<=B(i-1);
	
					if cx(i)(19)='0' then
						A(i)<=cx(i)(18 downto 0)&A(i-1)(19 downto 0)&'0';
						C(i)<=C(i-1)(16 downto 0)&'1';
					else
						A(i)<=A(i-1)(38 downto 0)&'0';
						C(i)<=C(i-1)(16 downto 0)&'0';
					end if;	
				end if;
				if data_valid_d='1' then
					if cx(i)(19)='0' then
						A(i)<=cx(i)(18 downto 0)&A(i)(19 downto 0)&'0';
						C(i)<=C(i)(16 downto 0)&'1';
					else
						A(i)<=A(i)(38 downto 0)&'0';
						C(i)<=C(i)(16 downto 0)&'0';
					end if;	
				end if;
			end if;	
		end process;	
	end generate;	
	
end struct;