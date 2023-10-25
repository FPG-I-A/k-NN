library ieee;
use ieee.fixed_pkg.all;
use std.textio.all;
use std.env.finish;

library work;
use work.pacote_aux.all;
entity knn_tb is
end knn_tb;

architecture sim of knn_tb is

    -- portas do componente
    signal i_clk       : bit := '0';
    signal i_init      : bit := '0';
    signal i_reset     : bit := '0';
    signal o_ocupado   : bit;
    signal i_infere    : vec_s_fixo(n_caracteristicas - 1 downto 0);
    signal o_resultado : integer;

    -- contador de ciclos de clock
    signal contador : integer := 0;

    -- Escrita no arquivo de saída
    file fptr : text;

begin

    UUT : entity work.knn
        generic map(
            gen_n_amostras        => amostras_treino,
            gen_n_caracteristicas => n_caracteristicas,
            gen_n_classes         => n_classes,
            gen_k                 => 5
        )
        port map(
            i_clk       => i_clk,
            i_init      => i_init,
            i_reset     => i_reset,
            o_ocupado   => o_ocupado,
            i_x_treino  => x_treino,
            i_y_treino  => y_treino,
            i_infere    => i_infere,
            o_resultado => o_resultado
        );

    primeiro : process(contador) begin
        if contador >= amostras_teste then
            finish;
        end if;
        for i in n_caracteristicas - 1 downto 0 loop
            i_infere(i) <= x_teste(contador, i);
        end loop;
    end process primeiro;

        
    clock : process
    begin
        i_clk    <= not i_clk;
        wait for 400 ns; -- 50Mhz

        -- Encerra simulação após max_iter ciclos de clock
        if contador = amostras_teste + 1 then
            wait for 10 ns;
            finish;
        end if;

    end process clock;

    -- Inicia novo cálculo após finalização do último
    inicia : process (i_clk)
    begin
        if rising_edge(i_clk) then
            if o_ocupado = '0' then
                i_init <= '1';
            else
                i_init <= '0';
            end if;
        end if;
    end process inicia;

    -- Salva resultados no arquivo .csv quando finalizado
    salva : process (o_ocupado)
        variable fstatus   : file_open_status;
        variable file_line : line;
    begin
        if falling_edge(o_ocupado) then

            if contador = 0 then
                file_open(fstatus, fptr, "knn.csv", write_mode);
                write(file_line, string'("rotulo;predito"), left, 14);
                writeline(fptr, file_line);
            end if;

            write(file_line, y_teste(contador), left, 1);
            write(file_line, string'(";"), left, 1);
            write(file_line, o_resultado, left, 1);
            writeline(fptr, file_line);

            contador <= contador + 1;
            
        end if;
    end process salva;

end architecture sim;
