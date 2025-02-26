library ieee;
use ieee.std_logic_1164.all;

entity UART_Rx_NoParity_TB is
    
end entity;
    
architecture test of UART_Rx_NoParity_TB is
    constant BAUD : positive := 115200;
    constant OVERSAMPLING_FACTOR : positive := 8;
    constant S : positive := 2;

    constant clk_period : time := (1000000000 ns / (BAUD * OVERSAMPLING_FACTOR));
    constant bit_time : time := (1000000000 ns / BAUD);
        
    component UART_Rx
        generic(
            W : positive := 7;          -- number of bits per word
            P : positive := 2;          -- 1 odd parity, 2 even parity, 3 no parity
            OVERSAMPLING : positive := 8
        );
        port(
            clk : in std_logic;
            reset : in std_logic;
            rx : in std_logic;
            y : out std_logic_vector(W - 1 downto 0);
            y_valid : out std_logic
        );
    end component;
    
    signal clk_ext : std_logic := '0';
    signal reset_ext : std_logic := '1';
    signal rx_ext : std_logic := '1';
    signal y_ext : std_logic_vector(6 downto 0);
    signal y_valid_ext : std_logic;
    signal testing : boolean := true;
    
    begin
        clk_ext <= not clk_ext after clk_period / 2 when testing else '0';
    
        g_uartrx: UART_Rx
            generic map(
                W => 7,
                P => 3,
                OVERSAMPLING => OVERSAMPLING_FACTOR
            )
            port map(
                clk => clk_ext,
                reset => reset_ext,
                rx => rx_ext,
                y => y_ext,
                y_valid => y_valid_ext
            );
    
        p_STIMULUS: process begin
            -- test reset --
            reset_ext <= '0';
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            assert y_ext = "0000000" report "wrong y at reset" severity FAILURE;
            assert y_valid_ext = '0' report "wrong y_valid at reset" severity FAILURE;
            reset_ext <= '1';
            --------------------

            -- test transmission of all zeros --
            rx_ext <= '0';
            wait for (bit_time * 8);                            -- start bit + data
            rx_ext <= '1';
            wait until y_valid_ext = '1' for (bit_time * S);    -- stop bits or result
            assert y_ext = "0000000" report "wrong y" severity FAILURE;
            assert y_valid_ext = '1' report "wrong y_valid" severity FAILURE;
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            --------------------

            -- test transmission of all ones --
            rx_ext <= '0';
            wait for (bit_time * 1);                            -- start bit
            rx_ext <= '1';
            wait for (bit_time * 7);                            -- data
            rx_ext <= '1';
            wait until y_valid_ext = '1' for (bit_time * S);    -- stop bits or result
            assert y_ext = "1111111" report "wrong y" severity FAILURE;
            assert y_valid_ext = '1' report "wrong y_valid" severity FAILURE;
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            --------------------

            -- test transmission of 1010101 --
            rx_ext <= '0';
            wait for (bit_time * 1);                            -- start bit

            rx_ext <= '1';
            wait for (bit_time);
            rx_ext <= '0';
            wait for (bit_time);
            rx_ext <= '1';
            wait for (bit_time);
            rx_ext <= '0';
            wait for (bit_time);
            rx_ext <= '1';
            wait for (bit_time);
            rx_ext <= '0';
            wait for (bit_time);
            rx_ext <= '1';
            wait for (bit_time);


            rx_ext <= '1';
            wait until y_valid_ext = '1' for (bit_time * S);    -- stop bits or result
            assert y_ext = "1010101" report "wrong y" severity FAILURE;
            assert y_valid_ext = '1' report "wrong y_valid" severity FAILURE;
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            --------------------

            -- test transmission of 0101010 --
            rx_ext <= '0';
            wait for (bit_time * 1);                            -- start bit

            rx_ext <= '0';
            wait for (bit_time);
            rx_ext <= '1';
            wait for (bit_time);
            rx_ext <= '0';
            wait for (bit_time);
            rx_ext <= '1';
            wait for (bit_time);
            rx_ext <= '0';
            wait for (bit_time);
            rx_ext <= '1';
            wait for (bit_time);
            rx_ext <= '0';
            wait for (bit_time);


            rx_ext <= '1';
            wait until y_valid_ext = '1' for (bit_time * S);    -- stop bits or result
            assert y_ext = "0101010" report "wrong y" severity FAILURE;
            assert y_valid_ext = '1' report "wrong y_valid" severity FAILURE;
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            --------------------

            -- test transmission of 0000111 --
            rx_ext <= '0';
            wait for (bit_time * 1);                            -- start bit

            rx_ext <= '0';
            wait for (bit_time);
            rx_ext <= '0';
            wait for (bit_time);
            rx_ext <= '0';
            wait for (bit_time);
            rx_ext <= '0';
            wait for (bit_time);
            rx_ext <= '1';
            wait for (bit_time);
            rx_ext <= '1';
            wait for (bit_time);
            rx_ext <= '1';
            wait for (bit_time);


            rx_ext <= '1';
            wait until y_valid_ext = '1' for (bit_time * S);    -- stop bits or result
            assert y_ext = "0000111" report "wrong y" severity FAILURE;
            assert y_valid_ext = '1' report "wrong y_valid" severity FAILURE;
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            --------------------

            -- test transmission of 1111000 --
            rx_ext <= '0';
            wait for (bit_time * 1);                            -- start bit

            rx_ext <= '1';
            wait for (bit_time);
            rx_ext <= '1';
            wait for (bit_time);
            rx_ext <= '1';
            wait for (bit_time);
            rx_ext <= '1';
            wait for (bit_time);
            rx_ext <= '0';
            wait for (bit_time);
            rx_ext <= '0';
            wait for (bit_time);
            rx_ext <= '0';
            wait for (bit_time);


            rx_ext <= '1';
            wait until y_valid_ext = '1' for (bit_time * S);    -- stop bits or result
            assert y_ext = "1111000" report "wrong y" severity FAILURE;
            assert y_valid_ext = '1' report "wrong y_valid" severity FAILURE;
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            --------------------

            
            -- test transmission of inconsistent bit--
            rx_ext <= '0';
            wait for (bit_time * 1);                            -- start bit

            -- inconsistent bit inside a bit time
            rx_ext <= '0';
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            rx_ext <= '1';
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            rx_ext <= '0';
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            rx_ext <= '1';
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            rx_ext <= '0';
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            rx_ext <= '1';
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            rx_ext <= '0';
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            rx_ext <= '1';
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);

            -- consistent bits
            rx_ext <= '1';
            wait for (bit_time);
            rx_ext <= '0';
            wait for (bit_time);
            rx_ext <= '1';
            wait for (bit_time);
            rx_ext <= '0';
            wait for (bit_time);
            rx_ext <= '1';
            wait for (bit_time);
            rx_ext <= '0';
            wait for (bit_time);


            rx_ext <= '1';
            wait until y_valid_ext = '1' for (bit_time * S);    -- stop bits or result
            assert y_valid_ext = '0' report "wrong y_valid" severity FAILURE;
            wait until rising_edge(clk_ext);
            wait until falling_edge(clk_ext);
            --------------------

            testing <= false;
            wait until rising_edge(clk_ext);
        end process;
end architecture;