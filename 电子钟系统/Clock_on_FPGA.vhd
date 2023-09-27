LIBRARY IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Clock_on_FPGA IS
	port(
		clk_in:in STD_LOGIC;--输入的10000hz脉冲
		clk_in_100:in STD_LOGIC;--输入的100hz脉冲
		
		set:in STD_LOGIC;--没有用到的开关K0
		switch:in STD_LOGIC_VECTOR(1 DOWNTO 0);--K3K2 电子钟的状态，00为清零模式，01为设置分模式，10为设置时模式，11为设置闹钟模式
		state:in STD_LOGIC;--K1电子钟的状态，0位正常行走，1为设置模式
		
		ctr:in STD_LOGIC_vector(1 DOWNTO 0);--K5K4 控制设置闹钟的位，00为分低位，01为分高位，11为时低位，10为时高位
		ctr_time:in STD_LOGIC_vector(3 DOWNTO 0);--K9K8K7K6 设置闹钟的具体数值，为8421码
		ctr_en:in STD_LOGIC;--K10 闹钟和整点报时有效开关，0时响铃有效，1时禁用响铃
		
		sec_lower_7:OUT STD_LOGIC_VECTOR(6 downto 0);--秒的低位
		hour_lower:OUT STD_LOGIC_VECTOR(3 downto 0);--时的低位
		min_upper:OUT STD_LOGIC_VECTOR(3 downto 0);--分的高位
		min_lower:OUT STD_LOGIC_VECTOR(3 downto 0);--分的低位
		sec_upper:OUT STD_LOGIC_VECTOR(3 downto 0);--秒的高位
		hour_upper:OUT STD_LOGIC_VECTOR(3 downto 0);--时的高位
		intcout:out INTEGER RANGE 1 TO 6;--
		alarm_ring:out STD_LOGIC--给扬声器的响铃脉冲
	);
END Clock_on_FPGA;

ARCHITECTURE arch OF Clock_on_FPGA IS
	COMPONENT ctr_module
		port(
			intcout:out INTEGER RANGE 1 TO 6;
			clk_in:in STD_LOGIC;
			clk_in_100:in STD_LOGIC;
			
			set:in STD_LOGIC;
			switch:in STD_LOGIC_VECTOR(1 DOWNTO 0);
			state:in STD_LOGIC;
			
			clk_out:out STD_LOGIC;
			clk_out1:out STD_LOGIC;
			
			add_min:out STD_LOGIC;
			add_hour:out STD_LOGIC;
			rst_sec:out STD_LOGIC;
			
			time_en:out STD_LOGIC;
			clock_en:out STD_LOGIC
		);
	END COMPONENT;
	COMPONENT time_module
		port(
			clk_1hz:IN STD_LOGIC;
			clk_clock:IN STD_LOGIC;
			
			clock_en:in STD_LOGIC;
			en:in std_logic;
			set:in std_logic;
			ctr:in STD_LOGIC_vector(1 DOWNTO 0);
			ctr_time:in STD_LOGIC_vector(3 DOWNTO 0);
			ctr_en:in STD_LOGIC;
			
			add_min:IN STD_LOGIC;
			add_hour:IN STD_LOGIC;
			rst_sec:IN STD_LOGIC;
			
			hour_upper:OUT STD_LOGIC_VECTOR(3 downto 0);
			hour_lower:OUT STD_LOGIC_VECTOR(3 downto 0);
			min_upper:OUT STD_LOGIC_VECTOR(3 downto 0);
			min_lower:OUT STD_LOGIC_VECTOR(3 downto 0);
			sec_upper:OUT STD_LOGIC_VECTOR(3 downto 0);
			sec_lower:OUT STD_LOGIC_VECTOR(3 downto 0);
			
			alarm_ring:out STD_LOGIC--喇叭信号，响铃脉冲
		);
	END COMPONENT;
	COMPONENT output  
	port(
		hour_upper_in:IN STD_LOGIC_VECTOR(3 downto 0);
		hour_lower_in:IN STD_LOGIC_VECTOR(3 downto 0);
		min_upper_in:IN STD_LOGIC_VECTOR(3 downto 0);
		min_lower_in:IN STD_LOGIC_VECTOR(3 downto 0);
		sec_upper_in:IN STD_LOGIC_VECTOR(3 downto 0);
		sec_lower_in:IN STD_LOGIC_VECTOR(3 downto 0);
		
		switch:in STD_LOGIC_VECTOR(1 DOWNTO 0);
		state:IN STD_LOGIC;
		ctr:in STD_LOGIC_VECTOR(1 DOWNTO 0);
		clk:in std_logic;
		
		sec_lower_7_out:OUT STD_LOGIC_VECTOR(6 downto 0);
		hour_lower_out:OUT STD_LOGIC_VECTOR(3 downto 0);
		min_upper_out:OUT STD_LOGIC_VECTOR(3 downto 0);
		min_lower_out:OUT STD_LOGIC_VECTOR(3 downto 0);
		sec_upper_out:OUT STD_LOGIC_VECTOR(3 downto 0);
		hour_upper_out:OUT STD_LOGIC_VECTOR(3 downto 0)
		);
	END COMPONENT;
	
	SIGNAL 	sig_clk,
			sig_clk1,
			sig_add_min,
			sig_add_hour,
			sig_rst_sec,
			sig_set,
			sig_alarm_ring,
			sig_time_en,
			sig_clock_en:std_logic;
	SIGNAL 	sig_hour_upper,
			sig_hour_lower,
			sig_min_upper,
			sig_min_lower,
			sig_sec_upper,
			sig_sec_lower:STD_LOGIC_VECTOR(3 downto 0);
	BEGIN
	

	com_ctr_module:ctr_module PORT MAP(
		clk_in=>clk_in,
		clk_in_100=>clk_in_100,
		set=>set,
		switch=>switch,
		state=>state,
		clk_out=>sig_clk,
		clk_out1=>sig_clk1,
		add_min=>sig_add_min,
		add_hour=>sig_add_hour,
		rst_sec=>sig_rst_sec,
		time_en=>sig_time_en,
		clock_en=>sig_clock_en,--x,
		intcout=>intcout
		);
		
	com_time_module:time_module PORT MAP(
		clk_1hz=>sig_clk,
		clk_clock=>sig_clk1,
		clock_en=>sig_clock_en,
		en=>sig_time_en,
		set=>set,
		ctr=>ctr,
		ctr_time=>ctr_time,
		ctr_en=>ctr_en,
		add_min=>sig_add_min,
		add_hour=>sig_add_hour,
		rst_sec=>sig_rst_sec,
		hour_upper=>sig_hour_upper,
		hour_lower=>sig_hour_lower,
		min_upper=>sig_min_upper,
		min_lower=>sig_min_lower,
		sec_upper=>sig_sec_upper,
		sec_lower=>sig_sec_lower,
		alarm_ring=>alarm_ring--喇叭信号，响铃脉冲
		);
		
	com_output:output PORT MAP(
		hour_upper_in=>sig_hour_upper,
		hour_lower_in=>sig_hour_lower,
		min_upper_in=>sig_min_upper,
		min_lower_in=>sig_min_lower,
		sec_upper_in=>sig_sec_upper,
		sec_lower_in=>sig_sec_lower,
		clk=>sig_clk,
		state=>state,
		switch=>switch,
		ctr=>ctr,
		sec_lower_7_out=>sec_lower_7,
		hour_lower_out=>hour_lower,
		hour_upper_out=>hour_upper,
		min_upper_out=>min_upper,
		min_lower_out=>min_lower,
		sec_upper_out=>sec_upper
	);
END arch;