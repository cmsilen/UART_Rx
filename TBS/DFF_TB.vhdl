library ieee;
use ieee.std_logic_1164.all;

entity DFF_TB is
    
end entity;
    
architecture test of DFF_TB is
    constant clk_period : time := 8 ns;
        
    component DFF
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
    end component;
    
    signal clk_ext : std_logic := '0';
    signal enable_ext : std_logic := '0';
    signal reset_ext : std_logic := '1';
    signal d_ext : std_logic_vector(7 downto 0) := (others => '0');
    signal q_ext :  std_logic_vector(7 downto 0) := (others => '0');
    signal testing : boolean := true;
    
    begin
        clk_ext <= not clk_ext after clk_period / 2 when testing else '0';
    
        g_dff: DFF
            generic map(
                SIZE => 8
            )
            port map(
                d_dff => d_ext,
                enable_dff => enable_ext,
                resetn_dff => reset_ext,
                clk_dff => clk_ext,
                q_dff => q_ext
            );
    
        p_STIMULUS: process begin
            -- initialization --
            reset_ext <= '1';
            d_ext <= (others =>'0');
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            reset_ext <= '0';
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            reset_ext <= '1';
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            assert q_ext = "00000000" report "wrong reset" severity FAILURE;
            -------------------

            -- test --
            enable_ext <= '1';
            d_ext <= "11111111";
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            assert q_ext = "11111111" report "wrong output" severity FAILURE;

            d_ext <= "01010101";
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            assert q_ext = "01010101" report "wrong output" severity FAILURE;

            d_ext <= "10101010";
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            assert q_ext = "10101010" report "wrong output" severity FAILURE;
            ----------

            testing <= false;
            wait until rising_edge(clk_ext);
        end process;
    end architecture;