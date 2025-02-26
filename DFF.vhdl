library ieee;
use ieee.std_logic_1164.all;

-- D positive edge triggered Flip Flop with synchronous reset
entity DFF is
    generic(
        SIZE : positive := 1
    );
    port(
        d_dff : in std_logic_vector(SIZE - 1 downto 0);
        enable_dff : in std_logic;
        resetn_dff : in std_logic;
        clk_dff : in std_logic;
        q_dff : out std_logic_vector(SIZE - 1 downto 0)
    );
end entity;

architecture default of DFF is
begin
    p_dff: process(clk_dff, resetn_dff)
    begin
        if rising_edge(clk_dff) then

            if resetn_dff = '0' then
                q_dff <= (others => '0');
            end if;

            if enable_dff = '1' and resetn_dff = '1' then
                q_dff <= d_dff;
            end if;
        end if;
    end process;
    
end architecture;