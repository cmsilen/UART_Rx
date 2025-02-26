library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real."ceil";
use ieee.math_real."log2";
use ieee.numeric_std.all;

-- Component that handles the oversampling and decides the received bit value:
-- OVERSAMPLING_FACTOR defines how many samples it must get. It's necessary to have a correctly dimensioned clock period because
-- after OVERSAMPLING_FACTOR clocks it assumes that the following samples are from another bit.
--
-- The decision logic is that the bit value that appears more often inside a bit time is the one transmitted, for example:
-- if for 3 clock cycles the samples are 0 and for 5 clock cycles are 1, then the received bit will be 1.
-- In case of same number of samples for both values, an error is asserted in output since it can't decide what bit to output

entity Sampler is
    generic(
        OVERSAMPLING_FACTOR : positive := 8     -- number of samples per bit time
    );
    port(
        line_sa : in std_logic;                 -- line to sample
        enable_sa : in std_logic;
        clk_sa : in std_logic;
        resetn_sa : in std_logic;
        data_out_sa : out std_logic;            -- bit received from line_sa
        data_valid_sa : out std_logic;          -- output validity
        error_sa : out std_logic                -- error in trying to decide the received bit value
    );
end entity;

architecture default of Sampler is
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

    component Demux
        port(
            x_de : in std_logic;
            sel_de : in std_logic;
            y0_de : out std_logic;
            y1_de : out std_logic
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

    constant REGISTER_SIZE : positive := integer(ceil(log2(real(OVERSAMPLING_FACTOR)))) + 1;

    signal sample : std_logic;
    signal inner_enable : std_logic;
    signal is0_bit : std_logic;
    signal is1_bit : std_logic;
    signal is0 : std_logic_vector(REGISTER_SIZE - 1 downto 0);
    signal is1 : std_logic_vector(REGISTER_SIZE - 1 downto 0);
    signal zero_amount : std_logic_vector(REGISTER_SIZE - 1 downto 0);
    signal one_amount : std_logic_vector(REGISTER_SIZE - 1 downto 0);
    signal sampling_error : std_logic;
    signal data_out_int : std_logic;
    signal data_valid_int : std_logic;
    signal error_int : std_logic;
    signal status : std_logic_vector(REGISTER_SIZE - 1 downto 0);
    signal end_sampling : std_logic;
    
begin
    -- DFF for sampling the input line
    DFF_Sampler: DFF
        generic map(
            SIZE => 1
        )
        port map(
            d_dff(0) => line_sa,
            enable_dff => '1',
            resetn_dff => resetn_sa,
            clk_dff => clk_sa,
            q_dff(0) => sample
        );

    -- DFF for synchronizing the components with enable signal
    DFF_enable: DFF
        generic map(
            SIZE => 1
        )
        port map(
            d_dff(0) => enable_sa,
            enable_dff => '1',
            resetn_dff => resetn_sa,
            clk_dff => clk_sa,
            q_dff(0) => inner_enable
        );

    -- selects if we must add 1 to the zero counter or one counter
    Demux1: Demux
        port map(
            x_de => '1',
            sel_de => sample,
            y0_de => is0_bit,
            y1_de => is1_bit
        );

    -- counts how many times zero appears as a sample
    Zero_Counter: Accumulator
        generic map(
            ACC_SIZE => REGISTER_SIZE
        )
        port map(
            d_acc => is0,
            cin_acc => '0',
            mode_acc => end_sampling,
            enable_acc => inner_enable,
            resetn_acc => resetn_sa,
            clk_acc => clk_sa,
            out_acc => zero_amount
        );

    -- counts how many times one appears as a sample
    One_Counter: Accumulator
        generic map(
            ACC_SIZE => REGISTER_SIZE
        )
        port map(
            d_acc => is1,
            cin_acc => '0',
            mode_acc => end_sampling,
            enable_acc => inner_enable,
            resetn_acc => resetn_sa,
            clk_acc => clk_sa,
            out_acc => one_amount
        );

    -- decides the final value for all samples: if we received more zeros than one the final value is zero and viceversa
    -- if the counters are equal than we don't know the final value, so we are in an error condition and the value is discarded
    Decision_Logic : Comparator
        generic map(
            COM_SIZE => REGISTER_SIZE
        )
        port map(
            a_co => zero_amount,
            b_co => one_amount,
            a_less_b_co => data_out_int,
            a_equal_b_co => sampling_error
        );

    -- keeps track of how many sample we have taken
    STAR: Accumulator
        generic map(
            ACC_SIZE => REGISTER_SIZE
        )
        port map(
            d_acc => (0 => '1', others => '0'),
            cin_acc => '0',
            mode_acc => end_sampling,
            enable_acc => inner_enable,
            resetn_acc => resetn_sa,
            clk_acc => clk_sa,
            out_acc => status
        );

    -- computes if we concluded the sampling cycle
    End_Sampling_Logic: Comparator
        generic map(
            COM_SIZE => REGISTER_SIZE
        )
        port map(
            a_co => status,
            b_co => std_logic_vector(to_unsigned(OVERSAMPLING_FACTOR, REGISTER_SIZE)),
            a_equal_b_co => end_sampling
        );

    -- dff barrier for output
    DFF_data_out: DFF
        generic map(
            SIZE => 1
        )
        port map(
            d_dff(0) => data_out_int,
            enable_dff => '1',
            resetn_dff => resetn_sa,
            clk_dff => clk_sa,
            q_dff(0) => data_out_sa
        );

    -- dff barrier for output
    DFF_data_valid: DFF
        generic map(
            SIZE => 1
        )
        port map(
            d_dff(0) => data_valid_int,
            enable_dff => '1',
            resetn_dff => resetn_sa,
            clk_dff => clk_sa,
            q_dff(0) => data_valid_sa
        );
    
    -- dff barrier for output
    DFF_error: DFF
        generic map(
            SIZE => 1
        )
        port map(
            d_dff(0) => error_int,
            enable_dff => '1',
            resetn_dff => resetn_sa,
            clk_dff => clk_sa,
            q_dff(0) => error_sa
        );

    is0 <= (0 => is0_bit, others => '0');
    is1 <= (0 => is1_bit, others => '0');
    data_valid_int <= end_sampling and (not sampling_error);
    error_int <= end_sampling and sampling_error;
end architecture;