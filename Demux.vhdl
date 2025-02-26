library ieee;
use ieee.std_logic_1164.all;

-- Demux with one bit input:
-- sel_de = 0 ---> y0_de = x_de, y1_de = 0
-- sel_de = 1 ---> y0_de = 0, y1_de = x_de

entity Demux is
    port(
        x_de : in std_logic;
        sel_de : in std_logic;
        y0_de : out std_logic;
        y1_de : out std_logic
    );
end entity;

architecture default of Demux is
begin
    y0_de <= x_de and (not sel_de);
    y1_de <= x_de and sel_de;
end architecture;