library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Demux_TB is
    
end entity;

architecture test of Demux_TB is
    constant clk_period : time := 100 ns;

    component Demux
        port(
            x_de : in std_logic;
            sel_de : in std_logic;
            y0_de : out std_logic;
            y1_de : out std_logic
        );
    end component;

    signal clk : std_logic := '0';
    signal x_ext : std_logic := '0';
    signal sel_ext : std_logic := '0';
    signal y0_ext : std_logic;
    signal y1_ext : std_logic;
    signal testing : boolean := true;

begin
    clk <= not clk after clk_period / 2 when testing else '0';

    i_DUT: Demux
        port map(
            x_de => x_ext,
            sel_de => sel_ext,
            y0_de => y0_ext,
            y1_de => y1_ext
        );
    
    p_STIMULUS: process begin
        -- idle test --
        x_ext <= '0';
        sel_ext <= '0';
        wait for 20 ns;
        assert y0_ext = '0' report "wrong idle state y0" severity FAILURE;
        assert y1_ext = '0' report "wrong idle state y1" severity FAILURE;

        -- test sel_de = 0 --
        x_ext <= '0';
        sel_ext <= '0';
        wait for 20 ns;
        assert y0_ext = '0' report "wrong output y0 1" severity FAILURE;
        assert y1_ext = '0' report "wrong output y1 1" severity FAILURE;

        x_ext <= '1';
        wait for 20 ns;
        assert y0_ext = '1' report "wrong output y0 2" severity FAILURE;
        assert y1_ext = '0' report "wrong output y1 2" severity FAILURE;

        -- test sel_de = 1 --
        x_ext <= '0';
        sel_ext <= '1';
        wait for 20 ns;
        assert y0_ext = '0' report "wrong output y0 3" severity FAILURE;
        assert y1_ext = '0' report "wrong output y1 3" severity FAILURE;

        x_ext <= '1';
        wait for 20 ns;
        assert y0_ext = '0' report "wrong output y0 4" severity FAILURE;
        assert y1_ext = '1' report "wrong output y1 4" severity FAILURE;

        wait for 50 ns;
        testing <= false;
        wait until rising_edge(clk);
    end process;
end architecture;