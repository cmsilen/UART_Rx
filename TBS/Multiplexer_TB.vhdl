library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Multiplexer_TB is
    
end entity;

architecture test of Multiplexer_TB is
    constant clk_period : time := 100 ns;
    constant N : positive := 8;

    component Multiplexer
        generic(
            MU_SIZE : positive := 8
        );
        port(
            x0_mu : in std_logic_vector(MU_SIZE - 1 downto 0);
            x1_mu : in std_logic_vector(MU_SIZE - 1 downto 0);
            sel_mu : in std_logic;
            y_mu : out std_logic_vector(MU_SIZE - 1 downto 0)
        );
    end component;

    signal clk : std_logic := '0';
    signal x0_ext : std_logic_vector(N - 1 downto 0);
    signal x1_ext : std_logic_vector(N - 1 downto 0);
    signal sel_ext : std_logic := '0';
    signal y_ext : std_logic_vector(N - 1 downto 0);
    signal testing : boolean := true;

begin
    clk <= not clk after clk_period / 2 when testing else '0';

    i_DUT: Multiplexer
        generic map(
            MU_SIZE => N
        )
        port map(
            x0_mu => x0_ext,
            x1_mu => x1_ext,
            sel_mu => sel_ext,
            y_mu => y_ext
        );
    
    p_STIMULUS: process begin
        -- idle test --
        x0_ext <= (others => '0');
        x1_ext <= (others => '0');
        sel_ext <= '0';
        wait for 20 ns;
        assert y_ext = "00000000" report "wrong idle state y" severity FAILURE;

        -- test sel_de = 0 --
        x0_ext <= "01010101";
        x1_ext <= "10101010";
        sel_ext <= '0';
        wait for 20 ns;
        assert y_ext = "01010101" report "wrong output y 1" severity FAILURE;

        x0_ext <= "10101010";
        x1_ext <= "01010101";
        sel_ext <= '0';
        wait for 20 ns;
        assert y_ext = "10101010" report "wrong output y 2" severity FAILURE;

        -- test sel_de = 1 --
        x0_ext <= "00001111";
        x1_ext <= "10101010";
        sel_ext <= '1';
        wait for 20 ns;
        assert y_ext = "10101010" report "wrong output y 3" severity FAILURE;

        x0_ext <= "10101010";
        x1_ext <= "11110000";
        sel_ext <= '1';
        wait for 20 ns;
        assert y_ext = "11110000" report "wrong output y 4" severity FAILURE;

        wait for 50 ns;
        testing <= false;
        wait until rising_edge(clk);
    end process;
end architecture;