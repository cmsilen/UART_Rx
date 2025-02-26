library ieee;
use ieee.std_logic_1164.all;

-- Combinational logic for checking the parity:
-- in x_pc goes the string of bits on which the parity is computed
-- in parity_pc goes the received parity bit
-- if the computed parity bit is different than parity_pc then it's not valid
-- if no parity is selected, then it will always result valid_pc = 1

entity Parity_Checker is
    generic(
        PC_TYPE : positive := 2;    -- 1 odd parity, 2 even parity, 3 no parity
        PC_SIZE : positive := 8
    );
    port(
        x_pc : in std_logic_vector(PC_SIZE - 1 downto 0);
        parity_pc : in std_logic;
        valid_pc : out std_logic
    );
end entity;

architecture default of Parity_Checker is
    signal inner_xor : std_logic_vector(PC_SIZE - 1 downto 1);
begin
    g_xor: for i in 1 to PC_SIZE - 1 generate
        g_first: if i = 1 generate
            inner_xor(1) <= x_pc(0) xor x_pc(1);
        end generate;

        g_other: if i > 1 generate
            inner_xor(i) <= x_pc(i) xor inner_xor(i - 1);
        end generate;
    end generate;

    p_pc: process(x_pc, parity_pc, inner_xor)
    begin
        if PC_TYPE = 3 then
            valid_pc <= '1';
        elsif PC_TYPE = 1 and parity_pc = not inner_xor(PC_SIZE - 1) then
            valid_pc <= '1';
        elsif PC_TYPE = 2 and parity_pc = inner_xor(PC_SIZE - 1) then
            valid_pc <= '1';
        else
            valid_pc <= '0';
        end if;
    end process;
end architecture;