library ieee;
use ieee.std_logic_1164.all;

-- Wrapper for letting Vivado evaluate the register logic register paths:
-- adds only a DFF for the rx input because the outputs have already a register barrier.
-- this register is added because the input rx has a path with an inverter without a register barrier
-- the DFF added at reset will assume 1 as value because 1 must be the idle value

entity UART_Rx_Wrapper is
    port(
        clk_w : in std_logic;
        reset_w : in std_logic;
        rx_w : in std_logic;
        y_w : out std_logic_vector(6 downto 0);
        y_valid_w : out std_logic
    );
end entity;

architecture default of UART_Rx_Wrapper is
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

    component DFF_Rx
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

    signal inner_rx : std_logic;

begin
    reg: DFF_Rx
        generic map(
            SIZE => 1
        )
        port map(
            d_dff(0) => rx_w,
            enable_dff => '1',
            resetn_dff => reset_w,
            clk_dff => clk_w,
            q_dff(0) => inner_rx
        );

    Receiver: UART_Rx
        generic map(
            W => 7,
            P => 2,
            OVERSAMPLING => 8
        )
        port map(
            clk => clk_w,
            reset => reset_w,
            rx => inner_rx,
            y => y_w,
            y_valid => y_valid_w
        );
end architecture;