-- ----------------------------------------------------------------------------	
-- FILE: 	avmm_arb_v2.vhd
-- DESCRIPTION:	Avalon Memory Master arbiter module
-- DATE:	Nov 25, 2016
-- AUTHOR(s):	Lime Microsystems
-- REVISIONS:
-- ----------------------------------------------------------------------------	
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ----------------------------------------------------------------------------
-- Entity declaration
-- ----------------------------------------------------------------------------
entity avmm_arb_v2 is
	generic(
		cntrl_rate			: integer := 1; --1 - full rate, 2 - half rate
		cntrl_bus_size		: integer := 16;
		addr_size			: integer := 24;
		lcl_bus_size		: integer := 63;
		lcl_burst_length	: integer := 2;
		cmd_fifo_size		: integer := 9;
		outfifo_size		: integer :=10
		);
  port (
      clk       			: in std_logic;
      reset_n   			: in std_logic;

		wcmd_fifo_wraddr	: in std_logic_vector(addr_size downto 0);
		wcmd_fifo_wrdata	: in std_logic_vector(lcl_bus_size-1 downto 0);
		wcmd_fifo_rdusedw	: in std_logic_vector(cmd_fifo_size-1 downto 0);
		wcmd_fifo_rdempty	: in std_logic;
		wcmd_fifo_rdreq	: out std_logic;
		rcmd_fifo_rdaddr	: in std_logic_vector(addr_size downto 0);
		rcmd_fifo_rdusedw	: in std_logic_vector(cmd_fifo_size-1 downto 0);
		rcmd_fifo_rdempty	: in std_logic;
		rcmd_fifo_rdreq	: out std_logic;
		outbuf_wrusedw		: in std_logic_vector(outfifo_size-1 downto 0);
		
		local_ready			: in std_logic;
		local_addr			: out std_logic_vector(addr_size-1 downto 0);
		local_write_req	: out std_logic;
		local_read_req		: out std_logic;
		local_burstbegin	: out std_logic;
		local_wdata			: out std_logic_vector(lcl_bus_size-1 downto 0);
		local_be				: out std_logic_vector(lcl_bus_size/8*cntrl_rate-1 downto 0);
		local_size			: out std_logic_vector(1 downto 0)	
        );
end avmm_arb_v2;

-- ----------------------------------------------------------------------------
-- Architecture
-- ----------------------------------------------------------------------------
architecture arch of avmm_arb_v2 is
--declare signals,  components here
type state_type is (idle, check_wcmd_burst_len, burst_wr_begin, burst_wr, wr, hold_wr);
signal current_state, next_state : state_type;

--wcmd signals
signal burst_wr_cnt           : unsigned(1 downto 0);

signal local_size_int         : std_logic_vector(1 downto 0);
signal local_burstbegin_int   : std_logic;

  
begin
   
process(clk, reset_n)
begin
   if reset_n = '0' then 
      local_burstbegin_int <= '0';
   elsif (clk'event AND clk='1') then
      if current_state = burst_wr_begin and local_ready = '1' then 
         local_burstbegin_int <= '1';
      else 
         local_burstbegin_int <= '0';
      end if;
   end if;
end process;
   
   
process(clk, reset_n)
begin
   if reset_n = '0' then 
      burst_wr_cnt <= (others=>'0');
   elsif (clk'event AND clk='1') then 
      if local_ready = '1' and (current_state = burst_wr OR current_state = burst_wr_begin) then 
         burst_wr_cnt <= burst_wr_cnt + 1;
      else 
         burst_wr_cnt <= (others=>'0');
      end if;
   end if;
end process;   

-- ----------------------------------------------------------------------------
--state machine
-- ----------------------------------------------------------------------------
fsm_f : process(clk, reset_n)begin
	if(reset_n = '0')then
		current_state <= idle;
	elsif(clk'event and clk = '1')then 
		current_state <= next_state;
	end if;	
end process;

-- ----------------------------------------------------------------------------
--state machine combo
-- ----------------------------------------------------------------------------
fsm : process(current_state,wcmd_fifo_rdempty, burst_wr_cnt) begin
	next_state <= current_state;
	case current_state is
	  
		when idle => 						--idle state, waiting for command
         if wcmd_fifo_rdempty = '0' then
            if unsigned(wcmd_fifo_rdusedw) > lcl_burst_length*2 then 
               next_state <= burst_wr_begin;
            else 
               next_state <= wr;
            end if;
         else 
            next_state <= idle;
         end if;
         
      when burst_wr_begin =>        -- burst begin transfer 
         if local_ready = '1' then 
            next_state <= burst_wr;
         else 
            next_state <= burst_wr_begin;
         end if;
         
      when burst_wr =>
         if burst_wr_cnt = lcl_burst_length-1 AND local_ready = '1' then
            next_state <= idle;
         else 
            next_state <= burst_wr;
         end if;
      
      when wr =>
         if local_ready = '1' then
            next_state <= idle;
         else 
            next_state <= hold_wr;
         end if;
      
      when hold_wr => 
      
         
 
		when others => 
			next_state<=idle;

	end case;
end process;


local_burstbegin <= local_burstbegin_int;




  
end arch;   






