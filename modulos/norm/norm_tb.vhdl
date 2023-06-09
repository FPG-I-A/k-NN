library ieee;
use ieee.fixed_pkg.all;
use std.env.finish;
use ieee.math_real.all;

library work;
use work.pacote_aux.all;
entity norm_tb is
end norm_tb;

architecture sim of norm_tb is

    -- portas do componente
    signal i_clk       : bit := '0';
    signal i_init      : bit := '0';
    signal i_reset     : bit := '0';
    signal o_ocupado   : bit;
    signal i_x         : vec_s_fixo(n_caracteristicas - 1 downto 0);
    signal o_x_norm    : vec_s_fixo(n_caracteristicas - 1 downto 0);

    -- contador de ciclos de clock
    signal contador            : integer := 0;


begin

    UUT : entity work.norm
        generic map(
            gen_n_caracteristicas => n_caracteristicas
        )
        port map
        (
            i_clk       => i_clk,
            i_init      => i_init,
            i_reset     => i_reset,
            o_ocupado   => o_ocupado,
            i_x         => i_x,
            i_min_x     => menor_por_caracteristica,
            i_max_x     => maior_por_caracteristica,
            o_x_norm    => o_x_norm
        );

    clock : process
    begin
        i_clk <= not i_clk;
        wait for 400 ns; -- 50Mhz
    end process clock;

    inicia : process
        -- Variáveis do gerador de números aleatórios
        variable seed1 : positive := 15646526;
        variable seed2 : positive := 54612348;
        variable rand  : real;
    begin

        -- popula vetor de entradas
        for i in n_caracteristicas - 1 downto 0 loop
            uniform(seed1, seed2, rand);
            i_x(i) <= resize(rand * maior_por_caracteristica(i) + menor_por_caracteristica(i), i_x(i)); -- quase sempre entre menor e maior
            wait for 10 ns;
        end loop;

        i_init <= '1';
        wait for 1 us;
        i_init <= '0';
        wait for 2 us;
        finish;
    end process inicia;


    process (o_ocupado, i_clk)
    begin
        if falling_edge(o_ocupado) or rising_edge(o_ocupado) then
            contador <= 0;
        elsif rising_edge(i_clk) then
            contador <= contador + 1;
        end if;

    end process;

end architecture sim;
