library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

entity norm is
generic (
    gen_parte_inteira     : integer;
    gen_parte_fracionaria : integer;
    gen_max_x  : in  sfixed(gen_parte_inteira downto gen_parte_fracionaria);
    gen_min_x  : in  sfixed(gen_parte_inteira downto gen_parte_fracionaria)

);
port (
    i_x      : in  sfixed(gen_parte_inteira downto gen_parte_fracionaria);
    o_x_norm : out sfixed(gen_parte_inteira downto gen_parte_fracionaria)
);
end norm;

architecture min_max of norm is
begin
    calcula: process(i_x) begin
        o_x_norm <= resize(arg=>(i_x - gen_min_x) / (gen_max_x - gen_min_x), size_res=>o_x_norm);
    end process calcula;
end min_max;
