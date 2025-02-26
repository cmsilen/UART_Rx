library ieee;
use ieee.std_logic_1164.all;

-- Set Reset Flip Flop: 
-- if s_srff = 1 ---> q_srff = 1
-- if r_srff = 1 ---> q_srff = 0
-- if both inputs are at 1 it prioritizes the reset ---> q_srff = 0

entity SRFF is
    port(
        s_srff : in std_logic;
        r_srff : in std_logic;
        clk_srff : in std_logic;
        q_srff : out std_logic
    );
end entity;

architecture default of SRFF is
begin
    p_srff: process(clk_srff)
    begin
        if rising_edge(clk_srff) then
            if s_srff = '1' and r_srff = '0' then
                q_srff <= '1';
            elsif r_srff = '1' then
                q_srff <= '0';
            end if;
        end if;
    end process;
end architecture;