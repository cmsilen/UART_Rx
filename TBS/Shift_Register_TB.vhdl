library ieee;
use ieee.std_logic_1164.all;

entity Shift_Register_TB is
    
end entity;
    
architecture test of Shift_Register_TB is
    constant clk_period : time := 8 ns;
        
    component Shift_Register
        generic(
            SR_DEPTH : positive := 8
        );
        port(
            x_sr : in std_logic;
            enable_sr : in std_logic;
            resetn_sr : in std_logic;
            clk_sr : in std_logic;
            y_sr : out std_logic_vector(SR_DEPTH - 1 downto 0)
        );
    end component;
    
    signal x_ext : std_logic := '0';
    signal enable_ext : std_logic := '0';
    signal resetn_ext : std_logic := '1';
    signal clk_ext : std_logic := '0';
    signal y_ext :  std_logic_vector(7 downto 0);
    signal testing : boolean := true;
    
    begin
        clk_ext <= not clk_ext after clk_period / 2 when testing else '0';
    
        g_sr: Shift_Register
            generic map(
                SR_DEPTH => 8
            )
            port map(
                x_sr => x_ext,
                enable_sr => enable_ext,
                resetn_sr => resetn_ext,
                clk_sr => clk_ext,
                y_sr => y_ext
            );
    
        p_STIMULUS: process begin
            -- initialization --
            resetn_ext <= '1';
            x_ext <= '0';
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            resetn_ext <= '0';
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            resetn_ext <= '1';
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            assert y_ext = "00000000" report "wrong reset" severity FAILURE;
            -------------------

            -- test --
            enable_ext <= '1';
            x_ext <= '1';
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            assert y_ext = "00000001" report "wrong output" severity FAILURE;

            x_ext <= '1';
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            assert y_ext = "00000011" report "wrong output" severity FAILURE;

            x_ext <= '0';
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            assert y_ext = "00000110" report "wrong output" severity FAILURE;

            x_ext <= '1';
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            assert y_ext = "00001101" report "wrong output" severity FAILURE;

            x_ext <= '0';
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            assert y_ext = "00011010" report "wrong output" severity FAILURE;

            x_ext <= '1';
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            assert y_ext = "00110101" report "wrong output" severity FAILURE;

            x_ext <= '0';
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            assert y_ext = "01101010" report "wrong output" severity FAILURE;

            x_ext <= '1';
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            assert y_ext = "11010101" report "wrong output" severity FAILURE;
            ----------

            -- test enable --
            enable_ext <= '0';
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            assert y_ext = "11010101" report "wrong output" severity FAILURE;
            ----------

            --wait for 50000 ns;
            testing <= false;
            wait until rising_edge(clk_ext);
        end process;
    end architecture;