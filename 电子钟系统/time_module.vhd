LIBRARY IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY time_module IS
	port(
		clk_1hz:IN STD_LOGIC;
		clk_clock:IN STD_LOGIC;
		clock_en:IN STD_LOGIC;--x
		set: in std_logic;
		en:in std_logic;
		ctr:in STD_LOGIC_vector(1 DOWNTO 0);
		ctr_time:in STD_LOGIC_vector(3 DOWNTO 0);
		ctr_en:in STD_LOGIC;
		add_min:IN STD_LOGIC;--0
		add_hour:IN STD_LOGIC;--0ÊÖ¶¯Ìí¼ÓµÄÐ¡Ê±
		rst_sec:IN STD_LOGIC;--0
		hour_upper:OUT STD_LOGIC_VECTOR(3 downto 0);
		hour_lower:OUT STD_LOGIC_VECTOR(3 downto 0);
		min_upper:OUT STD_LOGIC_VECTOR(3 downto 0);
		min_lower:OUT STD_LOGIC_VECTOR(3 downto 0);
		sec_upper:OUT STD_LOGIC_VECTOR(3 downto 0);
		sec_lower:OUT STD_LOGIC_VECTOR(3 downto 0);
		alarm_ring:out STD_LOGIC--À®°ÈÐÅºÅ£¬ÏìÁåÂö³å
	);
END time_module;

ARCHITECTURE arch OF time_module IS
	COMPONENT counter_24 
    port(
        clk: in std_logic;
        rst: in std_logic;
        en: in std_logic;
        co:out STD_LOGIC; 
        cnt_0: out std_logic_vector(3 downto 0);
        cnt_1:out std_logic_vector(3 downto 0)
    );
    END COMPONENT;
    COMPONENT counter_60 
    port(
        clk: in std_logic;
        rst: in std_logic;
        en: in std_logic;
        co:out STD_LOGIC; 
        cnt_0: out std_logic_vector(3 downto 0);
        cnt_1:out std_logic_vector(3 downto 0)
    );
    END COMPONENT;
    
    COMPONENT alarm  
	port(
		clk_clock:IN STD_LOGIC;
		clock_en:in std_logic;
		ctr:in STD_LOGIC_vector(1 DOWNTO 0);
		ctr_time:in STD_LOGIC_vector(3 DOWNTO 0);
		ctr_en:in STD_LOGIC;
		co_hour:IN STD_LOGIC;
		clock_now:IN STD_LOGIC;
		alarm_ring:out STD_LOGIC--À®°ÈÐÅºÅ£¬ÏìÁåÂö³å
		);
	END COMPONENT;
	
    SIGNAL clk_sec,clk_min,clk_hour,
		   co_min,co_hour,
		   sig_clock_now,sig_clock_hour:STD_LOGIC;
    
    SIGNAL 	sig_hour_upper,
			sig_hour_lower,
			sig_min_upper,
			sig_min_lower,
			sig_sec_upper,
			sig_sec_lower: STD_LOGIC_vector(3 downto 0);
			
	SIGNAL	sig_clock_min1:STD_LOGIC_vector(3 downto 0);
	SIGNAL	sig_clock_min2:STD_LOGIC_vector(3 downto 0);
	SIGNAL	sig_clock_hour1:STD_LOGIC_vector(3 downto 0);
	SIGNAL  sig_clock_hour2:STD_LOGIC_vector(3 downto 0);
	
	SIGNAL	sig_tmp_min1:STD_LOGIC_vector(3 downto 0);
	SIGNAL	sig_tmp_min2:STD_LOGIC_vector(3 downto 0);
	SIGNAL	sig_tmp_hour1:STD_LOGIC_vector(3 downto 0);
	SIGNAL  sig_tmp_hour2:STD_LOGIC_vector(3 downto 0);

			
			
			
	BEGIN
		clk_sec<=clk_1hz;
		clk_min<=(co_min OR add_min);                   
		clk_hour<=(co_hour OR add_hour);		
		com_sec: counter_60 PORT MAP(clk=>clk_sec,rst=>rst_sec,en=>en,cnt_0=>sig_sec_lower,cnt_1=>sig_sec_upper,co=>co_min);
		com_min: counter_60 PORT MAP(clk=>clk_min,rst=>rst_sec,en=>'0', cnt_0=>sig_min_lower,cnt_1=>sig_min_upper,co=>co_hour);
		com_hour: counter_24 PORT MAP(clk=>clk_hour,rst=>rst_sec,en=>'0', cnt_0=>sig_hour_lower,cnt_1=>sig_hour_upper);	
		
--		com_alarm: alarm PORT MAP(clk=>clk2,clock_en=>clock_en,co_min=>co_min,co_hour=>co_hour,	
--									alarm_ring=>alarm_ring,
--									ctr=>ctr,ctr_time=>ctr_time,ctr_en=>ctr_en,
--									clock_min1=>sig_clock_min1,clock_min2=>sig_clock_min2,
--									clock_hour1=>sig_clock_hour1,clock_hour2=>sig_clock_hour2,
--									clock_now=>sig_clock_now);	
		com_alarm: alarm PORT MAP(clk_clock=>clk_clock,clock_en=>clock_en,co_hour=>sig_clock_hour,	
									alarm_ring=>alarm_ring,
									ctr=>ctr,ctr_time=>ctr_time,ctr_en=>ctr_en,
									clock_now=>sig_clock_now
									);	

		
		process(clk_1hz,clock_en)  --set present time
		begin
			if(clock_en='1')then 
				sec_upper<="0000";
				sec_lower<="0000";
				min_lower<=sig_clock_min1;
				min_upper<=sig_clock_min2;
				hour_lower<=sig_clock_hour1;
				hour_upper<=sig_clock_hour2;
			else
				sec_upper<=sig_sec_upper;
				sec_lower<=sig_sec_lower;
				min_lower<=sig_min_lower;
				min_upper<=sig_min_upper;
				hour_lower<=sig_hour_lower;
				hour_upper<=sig_hour_upper;	
			end if;
		end process;
		
		process(clk_1hz) --judge if alarm
		begin
			if(sig_min_lower=sig_clock_min1 and 
			sig_min_upper=sig_clock_min2 and 
			sig_hour_lower=sig_clock_hour1 and 
			sig_hour_upper=sig_clock_hour2 and
			sig_sec_upper<"0010" and en='0')then
				sig_clock_now<='1';
			else
				sig_clock_now<='0';
			end if;
		end process;
		
		process(clk_1hz)
		begin
			if(sig_min_upper="0000"and
			sig_min_lower="0000"and
			sig_sec_upper<"0010" and en='0')then
				sig_clock_hour<='1';
			else
				sig_clock_hour<='0';	
			end if;
		end process;	
		
		process(set,clk_1hz) --set clock
		begin
			if(clock_en='1')then
					case(ctr)is
					when"00"=>
						sig_tmp_min1<=ctr_time;
					when"01"=>
						sig_tmp_min2<=ctr_time;
					when"11"=>
						sig_tmp_hour1<=ctr_time;
					when others=>
						sig_tmp_hour2<=ctr_time;
					end case;
				if(set'event and set='1')then
					case(ctr)is
					when"00"=> 
						sig_clock_min1<=sig_tmp_min1;
					when"01"=>
						sig_clock_min2<=sig_tmp_min2;
					when"11"=>
						sig_clock_hour1<=sig_tmp_hour1;
					when others=>
						sig_clock_hour2<=sig_tmp_hour2;
					end case;
				end if;
			end if;				
		end process;
--		
--		process(sig_clock_hour,sig_clock_now)
--		begin
--		if(ctr_en='0')then
--			if(sig_clock_now='1'or sig_clock_hour='1')then--¿ªÊ¼ÏìÁå×´Ì¬
--				alarm_ring<=clk_clock;
--			else 
--				alarm_ring<='0';
--			end if;
--		end if;
--		end process;		
	
END arch;

















