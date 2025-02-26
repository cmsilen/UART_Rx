library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Comparator_TB is
    
end entity;

architecture test of Comparator_TB is
    constant clk_period : time := 100 ns;
    constant N : positive := 8;

    component Comparator is
        generic(
            COM_SIZE : positive := 8
        );
        port(
            a_co : in std_logic_vector(COM_SIZE - 1 downto 0);
            b_co : in std_logic_vector(COM_SIZE - 1 downto 0);
            a_less_b_co : out std_logic;
            a_equal_b_co : out std_logic
        );
    end component;

    signal clk : std_logic := '0';
    signal a_ext : std_logic_vector(N - 1 downto 0) := (others => '0');
    signal b_ext : std_logic_vector(N - 1 downto 0) := (others => '0');
    signal a_less_b_ext : std_logic;
    signal a_equal_b_ext : std_logic;
    signal testing : boolean := true;

begin
    clk <= not clk after clk_period / 2 when testing else '0';

    i_DUT: Comparator
        generic map (
            COM_SIZE => N
        )
        port map(
            a_co => a_ext,
            b_co => b_ext,
            a_less_b_co => a_less_b_ext,
            a_equal_b_co => a_equal_b_ext
        );
    
    p_STIMULUS: process begin
        -- test a > b --
        a_ext <= "00000100";
        b_ext <= "00000001";
        wait for 20 ns;
        assert a_less_b_ext = '0' report "wrong a_less_b_ext 1" severity FAILURE;
        assert a_equal_b_ext = '0' report "wrong a_equal_b_ext 1" severity FAILURE;

        -- test a = b --
        a_ext <= "10000000";
        b_ext <= "10000000";
        wait for 20 ns;
        assert a_less_b_ext = '0' report "wrong a_less_b_ext 2" severity FAILURE;
        assert a_equal_b_ext = '1' report "wrong a_equal_b_ext 2" severity FAILURE;

        -- test a < b --
        a_ext <= "00000000";
        b_ext <= "00010000";
        wait for 20 ns;
        assert a_less_b_ext = '1' report "wrong a_less_b_ext 3" severity FAILURE;
        assert a_equal_b_ext = '0' report "wrong a_equal_b_ext 3" severity FAILURE;

        wait for 50 ns;
        testing <= false;
        wait until rising_edge(clk);
    end process;
end architecture;