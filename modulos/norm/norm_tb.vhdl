library ieee;
use ieee.fixed_pkg.all;
use std.textio.all;
use std.env.finish;

library work;
use work.pacote_aux.all;
entity norm_tb is
end norm_tb;

architecture sim of norm_tb is
    signal entrada_ponto_fixo : s_fixo := s_fixo_min;

    -- portas do componente
    signal resultado : s_fixo;


begin

    UUT : entity work.norm
        generic map(
            gen_max_x => s_fixo_max,
            gen_min_x => s_fixo_min
        )
        port map(
            i_x      => entrada_ponto_fixo,
            o_x_norm => resultado
        );

    clock : process
    begin
        entrada_ponto_fixo <= resize(arg => entrada_ponto_fixo + s_fixo_lsb,
            size_res                         => entrada_ponto_fixo);
        wait for 1 ns;
        if entrada_ponto_fixo = s_fixo_max then
            finish;
        end if;
    end process clock;
end architecture sim;
