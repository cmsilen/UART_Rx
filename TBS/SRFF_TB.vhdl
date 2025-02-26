library ieee;
use ieee.std_logic_1164.all;

entity SRFF_TB is
    
end entity;
    
architecture test of SRFF_TB is
    constant clk_period : time := 8 ns;
        
    component SRFF
        port(
            s_srff : in std_logic;
            r_srff : in std_logic;
            clk_srff : in std_logic;
            q_srff : out std_logic
        );
    end component;
    
    signal clk_ext : std_logic := '0';
    signal s_ext : std_logic := '0';
    signal r_ext : std_logic := '0';
    signal q_ext : std_logic;
    signal testing : boolean := true;
    
    begin
        clk_ext <= not clk_ext after clk_period / 2 when testing else '0';
    
        g_dff: SRFF
            port map(
                s_srff => s_ext,
                r_srff => r_ext,
                clk_srff => clk_ext,
                q_srff => q_ext
            );
    
        p_STIMULUS: process begin
            -- test reset --
            r_ext <= '1';
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            assert q_ext = '0' report "wrong output" severity FAILURE;
            r_ext <= '0';
            --------------------

            -- test set --
            s_ext <= '1';
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            assert q_ext = '1' report "wrong output" severity FAILURE;
            s_ext <= '0';
            --------------------

            -- test priority on reset --
            s_ext <= '1';
            r_ext <= '1';
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            assert q_ext = '0' report "wrong output" severity FAILURE;
            s_ext <= '0';
            r_ext <= '0';
            --------------------

            testing <= false;
            wait until rising_edge(clk_ext);
        end process;
    end architecture;