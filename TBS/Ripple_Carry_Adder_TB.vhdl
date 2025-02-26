library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Ripple_Carry_Adder_TB is
    
end entity;

architecture test of Ripple_Carry_Adder_TB is
    constant clk_period : time := 100 ns;
    constant N : positive := 8;

    component Ripple_Carry_Adder
        generic(
            Nbit : positive
        );
        port (
            a : in std_logic_vector(Nbit - 1 downto 0);
            b : in std_logic_vector(Nbit - 1 downto 0);
            cin : in std_logic;
            s : out std_logic_vector(Nbit - 1 downto 0);
            cout : out std_logic
        );
    end component;

    signal clk : std_logic := '0';
    signal a_ext : std_logic_vector(N - 1 downto 0) := (others => '0');
    signal b_ext : std_logic_vector(N - 1 downto 0) := (others => '0');
    signal cin_ext : std_logic := '0';
    signal s_ext : std_logic_vector(N - 1 downto 0) := (others => '0');
    signal cout_ext : std_logic;
    signal testing : boolean := true;

begin
    clk <= not clk after clk_period / 2 when testing else '0';

    i_DUT: Ripple_Carry_Adder
        generic map (
            Nbit => N
        )
        port map(
            a => a_ext,
            b => b_ext,
            cin => cin_ext,
            s => s_ext,
            cout => cout_ext
        );
    
    p_STIMULUS: process begin
        a_ext <= (others => '0');
        b_ext <= (others => '0');
        cin_ext <= '0';
        wait for 20 ns;
        assert s_ext = "00000000" report "wrong result" severity FAILURE;
        assert cout_ext = '0' report "wrong cout" severity FAILURE;

        a_ext <= "10101010";
        b_ext <= "00000010";
        cin_ext <= '0';
        wait for 20 ns;
        assert s_ext = "10101100" report "wrong result" severity FAILURE;
        assert cout_ext = '0' report "wrong cout" severity FAILURE;

        a_ext <= "00000010";
        b_ext <= "10101010";
        cin_ext <= '0';
        wait for 20 ns;
        assert s_ext = "10101100" report "wrong result" severity FAILURE;
        assert cout_ext = '0' report "wrong cout" severity FAILURE;

        a_ext <= "11111111";
        b_ext <= "00000001";
        cin_ext <= '0';
        wait for 20 ns;
        assert s_ext = "00000000" report "wrong result" severity FAILURE;
        assert cout_ext = '1' report "wrong cout" severity FAILURE;

        a_ext <= "00000001";
        b_ext <= "00000001";
        cin_ext <= '1';
        wait for 20 ns;
        assert s_ext = "00000011" report "wrong result" severity FAILURE;
        assert cout_ext = '0' report "wrong cout" severity FAILURE;

        a_ext <= "01010101";
        b_ext <= "10101010";
        cin_ext <= '1';
        wait for 20 ns;
        assert s_ext = "00000000" report "wrong result" severity FAILURE;
        assert cout_ext = '1' report "wrong cout" severity FAILURE;

        wait for 50 ns;
        testing <= false;
        wait until rising_edge(clk);
    end process;
    end architecture;