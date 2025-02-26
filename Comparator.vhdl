library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- compares two unsigned integer:
-- a_less_b_co = 0  ---> a_co > b_co
-- a_less_b_co = 1  ---> a_co < b_co
-- a_equal_b_co = 0 ---> a_co != b_co
-- a_equal_b_co = 1 ---> a_co = b_co


entity Comparator is
    generic(
        COM_SIZE : positive := 8
    );
    port(
        a_co : in std_logic_vector(COM_SIZE - 1 downto 0);
        b_co : in std_logic_vector(COM_SIZE - 1 downto 0);
        a_less_b_co : out std_logic;
        a_equal_b_co : out std_logic
    );
end entity;

architecture default of Comparator is
begin
    p_comp: process(a_co, b_co)
    begin
        if a_co = b_co then
            a_equal_b_co <= '1';
        else
            a_equal_b_co <= '0';
        end if;

        if unsigned(a_co) < unsigned(b_co) then
            a_less_b_co <= '1';
        else
            a_less_b_co <= '0';
        end if;
    end process;
end architecture;