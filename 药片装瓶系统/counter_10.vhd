LIBRARY IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity counter_10 is
    port(
        clk: in std_logic;
        rst: in std_logic;
        en: in std_logic;
        cnt: out std_logic_vector(3 downto 0);
        co: out STD_LOGIC
    );
end counter_10;

architecture arc of counter_10 is
    signal cnt_l: std_logic_vector(3 downto 0);
    begin
    process(clk, rst)
    begin
        if rst = '0' then
            cnt_l <= (others => '0');
            --co <= '0';
        elsif rising_edge(clk) then
            if en = '0' then
                if (cnt_l = "1001") then
                    cnt_l <= "0000";
                    co <= '1';
                else 
                    cnt_l <= cnt_l + 1;
                    co <= '0';
                end if;
            end if;
        end if;
    end process;
    cnt <= cnt_l;
end arc;