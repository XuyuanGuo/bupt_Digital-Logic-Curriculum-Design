library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity fillpills is 
	port(
		input : in std_logic_vector(3 downto 0);	--used to input data
		input_control : in std_logic_vector(1 downto 0);	--used to define input mode
		mode : in std_logic;	--'0' indicates setting mode, '1'incicetes counting mode
		working : in STD_LOGIC; -- 0 pause ,1 working 
		display_mode : in std_logic; 	--'0' indicates total number, '1' indicates current bottles and pills
		clr : in std_logic;		--zeroing
		qd : in std_logic;
		clk,clk_buzzer : in std_logic;		--10Hz clock signal and 100Hz clock signal
		lg2,lg3,lg4,lg5,lg6 : out std_logic_vector(3 downto 0);	--used to control seven segment display transistor
		red_light,green_light : out std_logic;	--red light indicates there is an error,or the fillng process has finished
												--green light indicates the counter is working properly
		buzzer : out std_logic
		);
end fillpills;

architecture arc of fillpills is
	signal start : STD_LOGIC;
	signal temp,buzzer_count: integer range 0 to 4; 
	signal clk_1hz : std_logic;			--use fractionalfrequency to create 1hz signal
	signal finish : std_logic := '0';	--'0' indicates the counting process hasn't finished
	signal error : std_logic := '0';	--'0' indicates there isn't any error
	signal npo,npt : std_logic_vector(3 downto 0);	--the predetermined num of pills in one bottle
	signal nbo,nbt : std_logic_vector(3 downto 0);	--the predetermined num of bottles
	signal tpo,tpt,tph,tpth : std_logic_vector(3 downto 0);	--total num of pills
	signal cbo,cbt : std_logic_vector(3 downto 0);	--current num of bottles
	signal cpo,cpt : std_logic_vector(3 downto 0);  --current number of pills
	signal cocpt, cocbo,cocbt,cotpo,cotpt,cotph,cotpth,cpo_rst,cpt_rst,b_rst,clk_in:STD_LOGIC;
	
	COMPONENT counter_10
    port(
        clk: in std_logic;
        rst: in std_logic;
        en: in std_logic;
        co:out STD_LOGIC; 
        cnt:out std_logic_vector(3 downto 0)
    );
    END COMPONENT;
begin
	--counter needed 
	--current pill counters
	cnt_cpo:counter_10 PORT MAP(clk=>clk_in,rst=>cpo_rst,en=>start,co=>cocpt,cnt=>cpo);
	cnt_cpt:counter_10 PORT MAP(clk=>cocpt,rst=>cpt_rst,en=>start,cnt=>cpt);
	-- current bottle counters
	cnt_bo:counter_10 PORT MAP(clk=>cocbo,rst=>b_rst,en=>start,co=>cocbt,cnt=>cbo);
	cnt_bt:counter_10 PORT MAP(clk=>cocbt,rst=>b_rst,en=>start,cnt=>cbt);
	--total pill counters 
	cnt_tpo:counter_10 PORT MAP(clk=>clk_in,rst=>clr,en=>start,co=>cotpt,cnt=>tpo);
	cnt_tpt:counter_10 PORT MAP(clk=>cotpt,rst=>clr,en=>start,co=>cotph,cnt=>tpt);
	cnt_tph:counter_10 PORT MAP(clk=>cotph,rst=>clr,en=>start,co=>cotpth,cnt=>tph);
	cnt_tpth:counter_10 PORT MAP(clk=>cotpth,rst=>clr,en=>start,cnt=>tpth);
	
	--fractional frequency
	process(clk)
	begin
		if(clk'event and clk='1') then
			if(temp=4) then
				temp<=0;
				clk_1hz<=not clk_1hz;
			else
				temp<=temp+1;
			end if;
		end if;
	end process;
	
	--setting mode
	process(qd)
	begin
		if(qd'event and qd='1'and mode = '0')then
			if(input>"1001") then
				error<='1';
			else
				error<='0';
				case input_control is
					when "00" => npo<=input;	--set the ones place of "num_of_pill"
					when "01" => npt<=input;	--set the tens place of "num_of_pill"
					when "10" => nbo<=input;	--set the ones place of "num_of_bottle"
					when "11" => nbt<=input;	--set the tens place of "num_of_bottle"
				end case;
			end if;
		end if;
	end process;
	
	--counting mode
	process(clk)
	begin
		if(mode = '1' AND finish = '0')then
			 clk_in <= clk;
		end if;
		
		if((cpo = npo) AND (cpt = npt))then
			cpo_rst<='0' and clr;
			cpt_rst<='0' and clr;
			cocbo <= '1';
		else 
			cpo_rst<='1' and clr ;
			cpt_rst<='1' and clr;
			cocbo <= '0';
		end if;
		
		if((nbo = cbo )and (nbt = cbt))then
			b_rst<= clr;
			b_rst<= clr;
			finish <= '1';
		else 
			b_rst<=clr;
			b_rst<=clr;
			finish <= '0';
		end if;
		if(clr = '0')then
			finish <= '0';
		end if;
	end process;
	
	
	--display, setting mode and counting mode
	process(mode,display_mode,start,clk)
		begin
		if(mode='1') then
			if(display_mode='0') then
					lg6<=cpt;
					lg5<=cpo;
					lg4<=cbt;
					lg3<=cbo;
					lg2<="ZZZZ";
			else
				lg6<=tpth;
				lg5<=tph;
				lg4<=tpt;
				lg3<=tpo;
				lg2<="ZZZZ";
			end if;
		else
			if(input_control = "00")Then
				if(clk_1hz = '1')Then
					lg5<=npo;
				ELSE
					lg5<="ZZZZ";
				END IF;
				lg6<=npt;
				lg4<=nbt;
				lg3<=nbo;
				lg2<="ZZZZ";
			elsif(input_control = "01")Then
				if(clk_1hz = '1')Then
					lg6<=npt;
				ELSE
					lg6<="ZZZZ";
				END IF;
				lg5<=npo;
				lg4<=nbt;
				lg3<=nbo;
				lg2<="ZZZZ";
			elsif(input_control = "10")Then
				if(clk_1hz = '1')Then
					lg3<=nbo;
				ELSE
					lg3<="ZZZZ";
				END IF;
				lg6<=npt;
				lg4<=nbt;
				lg5<=npo;
				lg2<="ZZZZ";
			else
				if(clk_1hz = '1')Then
					lg4<=nbt;
				ELSE
					lg4<="ZZZZ";
				END IF;
				lg6<=npt;
				lg5<=npo;
				lg3<=nbo;
				lg2<="ZZZZ";
			END IF;			
		end if;
	end process;
	
	process(clk_1hz)
		begin
		if(clk_1hz'event and clk_1hz='1') then
			if(finish='1') then
				if(buzzer_count<=3) then
					buzzer_count<=buzzer_count+1;
				end if;
			else
				buzzer_count<=0;
			end if;
		end if;
		if(error='1') then
			buzzer<=clk_buzzer and clk_1hz;
		elsif(finish='1' and buzzer_count<=3) then
			buzzer<=clk_buzzer and clk_1hz;
		else
			buzzer<='0';
		end if;
		
	end process;
	
	red_light<=(error or finish);
	green_light<=NOT(error or finish);
	start<= working AND mode;
end arc;
