library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.textio.all;
use std.env.finish;

library work;
use work.pacote_aux.all;
entity distancias_tb is
end distancias_tb;

architecture sim of distancias_tb is

    constant n_elementos       : integer := 100;
    constant n_caracteristicas : integer := 5;
    constant mult_1 : real := 8192.0;

    -- portas do componente
    signal i_clk       : std_logic := '0';
    signal i_init      : std_logic := '0';
    signal i_reset     : std_logic := '0';
    signal i_elementos : mat_s_fixo(n_elementos - 1 downto 0, n_caracteristicas - 1 downto 0);
    signal i_valor     : vec_s_fixo(n_caracteristicas - 1 downto 0);
    signal o_resultado : vec_s_fixo(n_elementos - 1 downto 0);
    signal o_amostra   : integer;
    signal o_ocupado   : std_logic;

    -- contador de ciclos de clock
    signal contador : integer := 0;

    -- Escrita no arquivo de saída
    file fptr : text;

begin

    UUT : entity work.distancias
        generic map(
            gen_n_amostras        => n_elementos,
            gen_n_caracteristicas => n_caracteristicas
        )
        port map
        (
            i_clk       => i_clk,
            i_init      => i_init,
            i_reset     => i_reset,
            i_elementos => i_elementos,
            i_valor     => i_valor,
            o_resultado => o_resultado,
            o_amostra   => o_amostra,
            o_ocupado   => o_ocupado
        );
    clock : process
    begin
        i_clk <= not i_clk;
        wait for 400 ns; -- 50Mhz

    end process clock;
    inicia : process
        -- Variáveis do gerador de números aleatórios
        variable seed1 : positive := 51374708;
        variable seed2 : positive := 17647597;
        variable rand  : real;
    begin

        -- popula matriz de entradas
        for i in n_elementos - 1 downto 0 loop
            for j in n_caracteristicas - 1 downto 0 loop
                uniform(seed1, seed2, rand);
                i_elementos(i, j) <= to_signed(INTEGER(rand * mult_1), tamanho);
                wait for 10 ns;
            end loop;
        end loop;

        -- popula vetor de referência
        for j in n_caracteristicas - 1 downto 0 loop
            uniform(seed1, seed2, rand);
            i_valor(j) <= to_signed(INTEGER(rand * mult_1), tamanho);
            wait for 10 ns;
        end loop;

        i_init <= '1';
        wait for 1 us;
        i_init <= '0';
        wait for 500 us;
        i_init <= '1';
        wait for 1 us;
        i_init <= '0';
        wait for 500 us;
        finish;
    end process inicia;

    conta : process (o_ocupado, i_clk)
    begin
        if falling_edge(o_ocupado) or rising_edge(o_ocupado) then
            contador <= 0;
        elsif rising_edge(i_clk) then
            contador <= contador + 1;
        end if;

    end process conta;

    gera_csv : process (o_ocupado)
        variable fstatus    : file_open_status;
        variable file_line  : line;
        variable quantidade : integer;
    begin
        if falling_edge(o_ocupado) then
            file_open(fstatus, fptr, "distancias.csv", write_mode);
            -- Escreve cabeçalho
            for j in 0 to n_caracteristicas - 1 loop
                quantidade := ((j - (j mod 10))) / 10;
                write(file_line, string'("x_"), left, 2);
                write(file_line, j, left, quantidade);
                write(file_line, string'(";"), left, 1);
            end loop;
            for j in 0 to n_caracteristicas - 1 loop
                quantidade := ((j - (j mod 10))) / 10;
                write(file_line, string'("y_"), left, 2);
                write(file_line, j, left, quantidade);
                if j /= n_caracteristicas - 1 then
                    write(file_line, string'(";"), left, 1);
                end if;
            end loop;
            writeline(fptr, file_line);

            for i in 0 to n_elementos - 1 loop

                for j in 0 to n_caracteristicas - 1 loop
                    write(file_line, i_valor(j)(tamanho - 1 downto tamanho - 1 - parte_inteira), left, parte_inteira);
                    write(file_line, string'("."), left, 1);
                    write(file_line, i_valor(j)(- parte_fracionaria downto 0), left, - parte_fracionaria);
                    write(file_line, string'(";"), left, 1);
                end loop;

                for j in 0 to n_caracteristicas - 1 loop
                    write(file_line, i_elementos(i, j)(tamanho - 1 downto tamanho - 1 - parte_inteira), left, parte_inteira);
                    write(file_line, string'("."), left, 1);
                    write(file_line, i_elementos(i, j)(- parte_fracionaria downto 0), left, - parte_fracionaria);
                    write(file_line, string'(";"), left, 1);
                end loop;
                
                write(file_line, o_resultado(i)(tamanho - 1 downto tamanho - 1 - parte_inteira), left, parte_inteira);
                write(file_line, string'("."), left, 1);
                write(file_line, o_resultado(i)(- parte_fracionaria downto 0), left, - parte_fracionaria);
                writeline(fptr, file_line);
            end loop;
        finish;
        end if;
    end process gera_csv;

end architecture sim;
