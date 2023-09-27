LIBRARY IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity alarm is
	port(
		clk_clock:IN STD_LOGIC;
		clock_en:in std_logic;--set clock
		ctr:in STD_LOGIC_vector(1 DOWNTO 0);
		ctr_time:in STD_LOGIC_vector(3 DOWNTO 0);
		ctr_en:in STD_LOGIC;--enable/disable clock
		--set:in STD_LOGIC;
		co_hour:IN STD_LOGIC;
		clock_now:IN STD_LOGIC;
		alarm_ring:out STD_LOGIC--À®°ÈÐÅºÅ£¬ÏìÁåÂö³å
		);
END alarm;
	
architecture func of alarm is
	begin
		process(co_hour,clock_now)
		begin
		if(ctr_en='0')then
			if(clock_now='1'or co_hour='1')then--¿ªÊ¼ÏìÁå×´Ì¬
				alarm_ring<=clk_clock;
			else 
				alarm_ring<='0';
			end if;
		end if;
		end process;	

end func ;