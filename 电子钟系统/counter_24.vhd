LIBRARY IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY counter_24 IS
    port(
        clk: in std_logic;
        rst: in std_logic;
        en: in std_logic;
        co:out STD_LOGIC; 
        cnt_0: out std_logic_vector(3 downto 0);
        cnt_1:out std_logic_vector(3 downto 0)
    );
end counter_24;

architecture arch of counter_24 is
    signal cnt_l: std_logic_vector(3 downto 0);
    signal cnt_h: std_logic_vector(3 downto 0);
    Begin
    process(clk, rst)
    begin
        if rst = '0' then
            cnt_l <= (others => '0');
            cnt_h <= (others => '0');
        elsif rising_edge(clk) then
            if en = '0' then
                if (cnt_l = "0011"AND cnt_h = "0010") then
                    cnt_l <= "0000";
                    cnt_h <= "0000";
                    co <= '1';
                else if(cnt_l="1001")THEN
					cnt_l <= "0000";
					cnt_h <= cnt_h + 1;
                else 
                    cnt_l <= cnt_l + 1;
                    co <= '0';
                end if;
            end if;
        end if;
        END IF;
    end process;
    cnt_0 <= cnt_l;
    cnt_1 <= cnt_h;
end arch;