library ieee;
use ieee.std_logic_1164.all;

entity Parity_Checker_TB is
    
end entity;
    
architecture test of Parity_Checker_TB is
    constant clk_period : time := 8 ns;
        
    component Parity_Checker
        generic(
            PC_TYPE : positive := 2;    -- 1 odd parity, 2 even parity, 3 no parity
            PC_SIZE : positive := 8
        );
        port(
            x_pc : in std_logic_vector(PC_SIZE - 1 downto 0);
            parity_pc : in std_logic;
            valid_pc : out std_logic
        );
    end component;
    
    signal clk_ext : std_logic := '0';
    signal x_ext : std_logic_vector(7 downto 0);
    signal parity_ext : std_logic := '0';
    signal valid_even_ext : std_logic;
    signal valid_odd_ext : std_logic;
    signal valid_none_ext : std_logic;
    signal testing : boolean := true;
    
    begin
        clk_ext <= not clk_ext after clk_period / 2 when testing else '0';
    
        g_pc_even: Parity_Checker
            generic map(
                PC_TYPE => 2,
                PC_SIZE => 8
            )
            port map(
                x_pc => x_ext,
                parity_pc => parity_ext,
                valid_pc => valid_even_ext
            );

        g_pc_odd: Parity_Checker
            generic map(
                PC_TYPE => 1,
                PC_SIZE => 8
            )
            port map(
                x_pc => x_ext,
                parity_pc => parity_ext,
                valid_pc => valid_odd_ext
            );

        g_pc_none: Parity_Checker
            generic map(
                PC_TYPE => 3,
                PC_SIZE => 8
            )
            port map(
                x_pc => x_ext,
                parity_pc => parity_ext,
                valid_pc => valid_none_ext
            );
    
        p_STIMULUS: process begin
            -- test even parity --
            x_ext <= "01001010";
            parity_ext <= '1';
            wait for 20 ns;
            assert valid_even_ext = '1' report "wrong output" severity FAILURE;

            parity_ext <= '0';
            wait for 20 ns;
            assert valid_even_ext = '0' report "wrong output" severity FAILURE;


            x_ext <= "01011010";
            parity_ext <= '1';
            wait for 20 ns;
            assert valid_even_ext = '0' report "wrong output" severity FAILURE;

            parity_ext <= '0';
            wait for 20 ns;
            assert valid_even_ext = '1' report "wrong output" severity FAILURE;
            --------------------

            -- test odd parity --
            x_ext <= "00011010";
            parity_ext <= '0';
            wait for 20 ns;
            assert valid_odd_ext = '1' report "wrong output" severity FAILURE;

            parity_ext <= '1';
            wait for 20 ns;
            assert valid_odd_ext = '0' report "wrong output" severity FAILURE;


            x_ext <= "11010100";
            parity_ext <= '1';
            wait for 20 ns;
            assert valid_odd_ext = '1' report "wrong output" severity FAILURE;

            parity_ext <= '0';
            wait for 20 ns;
            assert valid_odd_ext = '0' report "wrong output" severity FAILURE;
            --------------------

            -- test none parity --
            x_ext <= "00011010";
            parity_ext <= '0';
            wait for 20 ns;
            assert valid_none_ext = '1' report "wrong output" severity FAILURE;

            parity_ext <= '1';
            wait for 20 ns;
            assert valid_none_ext = '1' report "wrong output" severity FAILURE;


            x_ext <= "11010100";
            parity_ext <= '1';
            wait for 20 ns;
            assert valid_none_ext = '1' report "wrong output" severity FAILURE;

            parity_ext <= '0';
            wait for 20 ns;
            assert valid_none_ext = '1' report "wrong output" severity FAILURE;
            --------------------

            testing <= false;
            wait until rising_edge(clk_ext);
        end process;
    end architecture;