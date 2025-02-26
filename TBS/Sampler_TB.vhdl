library ieee;
use ieee.std_logic_1164.all;

entity Sampler_TB is
    
end entity;
    
architecture test of Sampler_TB is
    constant clk_period : time := 8 ns;
        
    component Sampler
        generic(
            OVERSAMPLING_FACTOR : positive := 8
        );
        port(
            line_sa : in std_logic;
            enable_sa : in std_logic;
            clk_sa : in std_logic;
            resetn_sa : in std_logic;
            data_out_sa : out std_logic;
            data_valid_sa : out std_logic;
            error_sa : out std_logic
        );
    end component;
    
    signal line_ext : std_logic := '1';
    signal enable_ext : std_logic := '0';
    signal clk_ext : std_logic := '0';
    signal resetn_ext : std_logic := '1';
    signal data_out_ext : std_logic;
    signal data_valid_ext : std_logic;
    signal error_ext : std_logic;
    signal testing : boolean := true;
    
    begin
        clk_ext <= not clk_ext after clk_period / 2 when testing else '0';
    
        g_sampler: Sampler
            generic map(
                OVERSAMPLING_FACTOR => 8
            )
            port map(
                line_sa => line_ext,
                enable_sa => enable_ext,
                clk_sa => clk_ext,
                resetn_sa => resetn_ext,
                data_out_sa => data_out_ext,
                data_valid_sa => data_valid_ext,
                error_sa => error_ext
            );
    
        p_STIMULUS: process begin
            -- initialization --
            line_ext <= '1';
            enable_ext <= '0';
            resetn_ext <= '0';
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            assert data_out_ext = '0' report "wrong data_out initialization" severity FAILURE;
            assert data_valid_ext = '0' report "wrong data_ready initialization" severity FAILURE;
            assert error_ext = '0' report "wrong error initialization" severity FAILURE;
            resetn_ext <= '1';

            enable_ext <= '1';
            --------------------

            -- test sampling 0 --
            line_ext <= '0';
            -- first sample
            wait until rising_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            wait until falling_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            -- second sample
            wait until rising_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            wait until falling_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            -- third sample
            wait until rising_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            wait until falling_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            -- fourth sample
            wait until rising_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            wait until falling_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            -- fifth sample
            wait until rising_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            wait until falling_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            -- sixth sample
            wait until rising_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            wait until falling_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            -- seventh sample
            wait until rising_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            wait until falling_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            -- eighth sample
            wait until rising_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            wait until falling_edge(clk_ext);
            
            -- new bit in line, first sample
            line_ext <= '1';
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);

            -- data ready, second sample
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            assert data_out_ext = '0' report "wrong data_out output at sampling end" severity FAILURE;
            assert data_valid_ext = '1' report "wrong data_ready at sampling end" severity FAILURE;
            assert error_ext = '0' report "wrong error at sampling end" severity FAILURE;
            ---------------------

            -- test sampling 1 --
            -- third sample
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            -- fourth sample
            wait until rising_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            wait until falling_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            -- fifth sample
            wait until rising_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            wait until falling_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            -- sixth sample
            wait until rising_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            wait until falling_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            -- seventh sample
            wait until rising_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            wait until falling_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            -- eighth sample
            wait until rising_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            wait until falling_edge(clk_ext);
            
            -- end transmission and first sample
            enable_ext <= '0';
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);

            -- data ready
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            assert data_out_ext = '1' report "wrong data_out output at sampling end" severity FAILURE;
            assert data_valid_ext = '1' report "wrong data_ready at sampling end" severity FAILURE;
            assert error_ext = '0' report "wrong error at sampling end" severity FAILURE;
            ---------------------

            -- synchronization error that doesn't lead to an error --
            -- enabling for next transmission and first sample
            enable_ext <= '1';
            line_ext <= '0';
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);

            -- second sample
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            -- third sample
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;

            line_ext <= '1';
            -- fourth sample
            wait until rising_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            wait until falling_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            -- fifth sample
            wait until rising_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            wait until falling_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            -- sixth sample
            wait until rising_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            wait until falling_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            -- seventh sample
            wait until rising_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            wait until falling_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            -- eighth sample
            wait until rising_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            wait until falling_edge(clk_ext);

            -- end transmission
            enable_ext <= '0';
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);

            -- data ready
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            assert data_out_ext = '1' report "wrong data_out output at sampling end" severity FAILURE;
            assert data_valid_ext = '1' report "wrong data_ready at sampling end" severity FAILURE;
            assert error_ext = '0' report "wrong error at sampling end" severity FAILURE;
            --------------------

            -- synchronization error that leads to an error --
            -- enabling for next transmission and first sample
            enable_ext <= '1';
            line_ext <= '0';
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);

            -- second sample
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            -- third sample
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;

            -- fourth sample
            wait until rising_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            wait until falling_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;

            line_ext <= '1';
            -- fifth sample
            wait until rising_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            wait until falling_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            -- sixth sample
            wait until rising_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            wait until falling_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            -- seventh sample
            wait until rising_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            wait until falling_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            -- eighth sample
            wait until rising_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready during sampling" severity FAILURE;
            assert error_ext = '0' report "wrong error during sampling" severity FAILURE;
            wait until falling_edge(clk_ext);

            -- end transmission
            enable_ext <= '0';
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);

            -- data ready
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            assert data_valid_ext = '0' report "wrong data_ready at sampling end" severity FAILURE;
            assert error_ext = '1' report "wrong error at sampling end" severity FAILURE;
            --------------------

            --wait for 50000 ns;
            testing <= false;
            wait until rising_edge(clk_ext);
        end process;
    end architecture;