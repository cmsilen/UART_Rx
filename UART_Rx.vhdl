library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real."ceil";
use ieee.math_real."log2";
use ieee.numeric_std.all;

entity UART_Rx is
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
end entity;

architecture default of UART_Rx is
    component SRFF
        port(
            s_srff : in std_logic;
            r_srff : in std_logic;
            clk_srff : in std_logic;
            q_srff : out std_logic
        );
    end component;

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

    component Comparator
        generic(
            COM_SIZE : positive := 8
        );
        port(
            a_co : in std_logic_vector(COM_SIZE - 1 downto 0);
            b_co : in std_logic_vector(COM_SIZE - 1 downto 0);
            a_less_b_co : out std_logic;
            a_equal_b_co : out std_logic
        );
    end component;

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

    constant PARITY_BIT_NUM : integer := (P mod 3) - (3 mod P);                         -- 1 bit if there is the parity check, 0 otherwise
    constant RX_BIT_NUM : positive := 1 + W + PARITY_BIT_NUM;                           -- 1 start bit, W data bits, 1 or 0 parity bit
    constant CONTROLLER_SIZE : positive := integer(ceil(log2(real(RX_BIT_NUM)))) + 1;   -- how many bits for containing up to W number

    signal rx_start : std_logic;
    signal started : std_logic;
    signal srff_reset : std_logic;
    signal received_bit : std_logic;
    signal bit_valid : std_logic;
    signal bit_error : std_logic;
    signal done_sampling : std_logic;
    signal current_data : std_logic_vector(RX_BIT_NUM - 1 downto 0);
    signal data_valid : std_logic;
    signal rx_valid : std_logic;
    signal rx_end : std_logic;
    signal current_status : std_logic_vector(CONTROLLER_SIZE - 1 downto 0);
    signal error_state : std_logic;
    signal internal_reset : std_logic;
    signal valid : std_logic;
    signal sampler_rst : std_logic;
    signal internal_rx : std_logic;

begin
    -- the receiving procedure must start when rx = 0
    rx_start <= not rx;

    -- sampler reset when reset signal is asserted or internal_reset is asserted
    sampler_rst <= reset and not internal_reset;

    -- DFF for avoiding first sample loss by the time the sampler activates
    SampleTimer: DFF
        generic map(
            SIZE => 1
        )
        port map(
            d_dff(0) => rx,
            enable_dff => '1',
            resetn_dff => reset,
            clk_dff => clk,
            q_dff(0) => internal_rx
        );

    -- for detecting the transmission start
    Starter: SRFF
        port map(
            s_srff => rx_start,
            r_srff => srff_reset,
            clk_srff => clk,
            q_srff => started
        );

    -- for sampling line
    Sampler1: Sampler
        generic map(
            OVERSAMPLING_FACTOR => OVERSAMPLING
        )
        port map(
            line_sa => internal_rx,
            enable_sa => started,
            clk_sa => clk,
            resetn_sa => sampler_rst,
            data_out_sa => received_bit,
            data_valid_sa => bit_valid,
            error_sa => bit_error
        );

    -- the sampling cycle finishes when there is an error or a valid bit at sampler output
    done_sampling <= bit_valid or bit_error;

    -- containing received data
    Shift_Register1: Shift_Register
        generic map(
            SR_DEPTH => RX_BIT_NUM
        )
        port map(
            x_sr => received_bit,
            enable_sr => bit_valid,
            resetn_sr => reset,
            clk_sr => clk,
            y_sr => current_data
        );

    -- for validating the parity
    Parity_Checker1: Parity_Checker
        generic map(
            PC_TYPE => P,
            PC_SIZE => W
        )
        port map(
            x_pc => current_data(RX_BIT_NUM - 2 downto PARITY_BIT_NUM),     -- always remove the start bit, remove the parity bit when exists
            parity_pc => current_data(0),                                   -- if parity bit exists then goes here, otherwise it will always be valid
            valid_pc => data_valid
        );

    -- DFF barrier for y
    y_DFF: DFF
        generic map(
            SIZE => W
        )
        port map(
            d_dff => current_data(RX_BIT_NUM - 2 downto PARITY_BIT_NUM),
            enable_dff => '1',
            resetn_dff => reset,
            clk_dff => clk,
            q_dff => y
        );

    -- data is valid when the parity is correct and the receiving process is valid
    valid <= data_valid and rx_valid;

    -- DFF barrier for y_valid
    y_valid_DFF: DFF
        generic map(
            SIZE => 1
        )
        port map(
            d_dff(0) => valid,
            enable_dff => '1',
            resetn_dff => reset,
            clk_dff => clk,
            q_dff(0) => y_valid
        );

    -- Accumulator that counts how many bits are received
    EndController: Accumulator
        generic map(
            ACC_SIZE => CONTROLLER_SIZE
        )
        port map(
            d_acc => (others => '0'),
            cin_acc => done_sampling,
            mode_acc => rx_end,
            enable_acc => '1',
            resetn_acc => reset,
            clk_acc => clk,
            out_acc => current_status
        );

    -- to track when the uart frame finishes
    End_Sampling_Logic: Comparator
        generic map(
            COM_SIZE => CONTROLLER_SIZE
        )
        port map(
            a_co => current_status,
            b_co => std_logic_vector(to_unsigned(RX_BIT_NUM, CONTROLLER_SIZE)),
            a_equal_b_co => rx_end
        );

    -- the receiving process is valid if the frame ended and there were no errors during sampling
    rx_valid <= rx_end and (not error_state);

    -- DFF that keeps track when the internal reset must take place
    InternalReset: DFF
        generic map(
            SIZE => 1
        )
        port map(
            d_dff(0) => rx_end,
            enable_dff => '1',
            resetn_dff => reset,
            clk_dff => clk,
            q_dff(0) => internal_reset
        );

    -- the SRFFs must reset when is issued the internal or external reset
    srff_reset <= internal_reset or not reset;

    -- SRFF that detects if any sampling errors take place
    ErrorDetector: SRFF
        port map(
            s_srff => bit_error,
            r_srff => srff_reset,
            clk_srff => clk,
            q_srff => error_state
        );
end architecture;