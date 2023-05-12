library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;
use std.textio.all;
use std.env.finish;

library work;
use work.pacote_knn.all;


entity sqrt_tb is
end sqrt_tb;

architecture sim of sqrt_tb is
    
    -- |----------------------------------------------------------------------------------|
    -- |                                          ATENÇÃO                                 |
    -- | Sempre que `parte_inteira`, `parte_fracionaria` ou `iteracoes` mudar, o valor de |
    -- | `max_iter` deve ser recalculado utilizando a fórmula:                            |
    -- | $$                                                                               |
    -- | max_iter = 2^(parte_inteira - parte_fracionaria) * (iteracoes + 3)               |
    -- | $$                                                                               |
    -- |----------------------------------------------------------------------------------|
    constant iteracoes         : integer := 7;
    constant max_iter          : integer := 327680;
    signal   entrada_ponto_fixo : sfixed(parte_inteira downto parte_fracionaria) := s_fixo_zero;

    -- portas do componente
    signal resultado          : sfixed(parte_inteira downto parte_fracionaria);
    signal i_clk              : bit := '0';
    signal i_init             : bit := '0';
    signal i_reset            : bit := '0';
    signal o_ocupado          : bit;

    -- contador de ciclos de clock
    signal contador : integer := 0;

    -- Escrita no arquivo de saída
    file fptr: text;

begin 

    UUT: entity work.sqrt
        generic map(
            gen_parte_inteira=>parte_inteira,
            gen_parte_fracionaria=>parte_fracionaria,
            gen_iteracoes=>iteracoes
        )
        port map(
            i_clk=>i_clk,
            i_init=>i_init,
            i_reset=>i_reset,
            i_x=>entrada_ponto_fixo,
            o_sqrt_x=>resultado,
            o_ocupado=>o_ocupado
        );
    
    clock:  process
    begin
        i_clk <= not i_clk;
        contador <= contador + 1;
        wait for 400 ns; -- 50Mhz

        -- Encerra simulação após max_iter ciclos de clock
        if contador = max_iter then
            finish;
        end if;

    end process clock;

    -- Inicia novo cálculo após finalização do último
    inicia: process(i_clk)
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
    incremento: process(o_ocupado)
    variable fstatus       :file_open_status;
    variable file_line     :line;
    begin
        if falling_edge(o_ocupado) then
            -- Escreve o cabeçalho
            if (entrada_ponto_fixo = s_fixo_zero) then
                file_open(fstatus, fptr, "sqrt.csv", write_mode);
                write(file_line, string'("x;sqrt(x)"), left, 9);
                writeline(fptr, file_line);
            end if;
            
            write(file_line, entrada_ponto_fixo, left, 16);
            write(file_line, string'(";"), left, 1);
            write(file_line, resultado, left, 16);
            writeline(fptr, file_line);
            
            -- Atualiza x
            entrada_ponto_fixo <= resize(arg=>entrada_ponto_fixo+s_fixo_lsb, size_res=>entrada_ponto_fixo);
        end if;
    end process incremento;
    

end architecture sim;
