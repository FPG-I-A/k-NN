library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;

library work;
use work.pacote_aux.all;

entity norm is
generic (
    gen_max_x  : in  s_fixo;
    gen_min_x  : in  s_fixo

);
port (
    i_x      : in  s_fixo;
    o_x_norm : out s_fixo
);
end norm;

architecture min_max of norm is
begin
    calcula: process(i_x) begin
        o_x_norm <= resize(arg=>(i_x - gen_min_x) / (gen_max_x - gen_min_x), size_res=>o_x_norm);
    end process calcula;
end min_max;
