library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Accumulator_TB is
    
end entity;

architecture test of Accumulator_TB is
    constant clk_period : time := 100 ns;
    constant N : positive := 8;

    component Accumulator
        generic(
            ACC_SIZE : positive := 8
        );
        port(
            d_acc : in std_logic_vector(ACC_SIZE - 1 downto 0);
            cin_acc : in std_logic;
            mode_acc : in std_logic;
            enable_acc : in std_logic;
            resetn_acc : in std_logic;
            clk_acc : in std_logic;
            out_acc : out std_logic_vector(ACC_SIZE - 1 downto 0)
        );
    end component;

    signal clk : std_logic := '0';
    signal d_ext : std_logic_vector(N - 1 downto 0) := (others => '0');
    signal cin_ext : std_logic;
    signal mode_ext : std_logic;
    signal enable_ext : std_logic;
    signal resetn_ext : std_logic;
    signal out_ext : std_logic_vector(N - 1 downto 0);
    signal testing : boolean := true;

begin
    clk <= not clk after clk_period / 2 when testing else '0';

    i_DUT: Accumulator
        generic map (
            ACC_SIZE => N
        )
        port map(
            d_acc => d_ext,
            cin_acc => cin_ext,
            mode_acc => mode_ext,
            enable_acc => enable_ext,
            resetn_acc => resetn_ext,
            clk_acc => clk,
            out_acc => out_ext
        );
    
    p_STIMULUS: process begin
        -- init --
        d_ext <= "00000000";
        cin_ext <= '0';
        enable_ext <= '1';
        resetn_ext <= '1';
        mode_ext <= '0';
        wait until rising_edge(clk);
        wait until falling_edge(clk);

        -- reset --
        resetn_ext <= '0';
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        resetn_ext <= '1';
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        assert out_ext = "00000000" report "wrong reset" severity FAILURE;

        -- test data input: d_acc = 0 for one clock cycle --
        resetn_ext <= '1';
        enable_ext <= '1';
        d_ext <= "00000000";
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        assert out_ext = "00000000" report "wrong output 1" severity FAILURE;

        -- test data input: d_acc = 1 for two clock cycle --
        d_ext <= "00000001";
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        assert out_ext = "00000001" report "wrong output 2" severity FAILURE;
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        assert out_ext = "00000010" report "wrong output 3" severity FAILURE;

        -- test data input: d_acc = 2 for two clock cycle --
        d_ext <= "00000010";
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        assert out_ext = "00000100" report "wrong output 4" severity FAILURE;
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        assert out_ext = "00000110" report "wrong output 5" severity FAILURE;

        -- test data input: overflow --
        d_ext <= "11111001";
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        assert out_ext = "11111111" report "wrong output 6" severity FAILURE;
        d_ext <= "00000010";
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        assert out_ext = "00000001" report "wrong output 7" severity FAILURE;

        -- test reset --
        d_ext <= "11111110";
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        assert out_ext = "11111111" report "wrong output 8" severity FAILURE;
        d_ext <= "00000000";
        resetn_ext <= '0';
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        assert out_ext = "00000000" report "wrong output 9" severity FAILURE;

        -- test cin --
        resetn_ext <= '1';
        cin_ext <= '1';
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        assert out_ext = "00000001" report "wrong output 10" severity FAILURE;
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        assert out_ext = "00000010" report "wrong output 11" severity FAILURE;
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        assert out_ext = "00000011" report "wrong output 12" severity FAILURE;

        -- test memory mode --
        d_ext <= "10101010";
        mode_ext <= '1';
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        assert out_ext = "10101010" report "wrong output 13" severity FAILURE;

        wait for 50 ns;
        testing <= false;
        wait until rising_edge(clk);
    end process;
end architecture;