library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;
use std.textio.all;
use std.env.finish;


entity sqrt_tb is
end sqrt_tb;

architecture sim of sqrt_tb is
    

    -- parâmetros genêricos da UUT
    constant parte_inteira     : integer := 1;
    constant parte_fracionaria : integer := -14;
    constant iteracoes         : integer := 7;
    
    -- _____________________________________________________________________________________________
    -- |                                          ATENÇÃO                                          |
    -- | Sempre que houver modificação em `parte_inteira`ou em `parte_fracionaria` os valores de   |
    -- | `lsb`, `entrada_ponto_fixo` e `max_iter` devem ser recalculados manualmente e modificados |
    -- | no código.                                                                                |
    -- |                                                                                           |
    -- | Considerando:                                                                             |
    -- |     n_bits = (parte_inteira - parte_fracionaria + 1) : número de bits no nº de ponto fixo |
    -- |     n_ciclos = iteracoes + 3 : número de ciclos de clock para o cálculo da raiz quadrada  |
    -- |                                                                                           |
    -- | `lsb` e `entrada_ponto_fixo` devem ter uma quantidade de bits igual à n_bits              |
    -- |                                                                                           |
    -- | max_iter = 2^n_bits * n_ciclos                                                            |
    -- ---------------------------------------------------------------------------------------------
    constant max_iter          : integer := 655360;
    constant lsb              : ufixed(parte_inteira downto parte_fracionaria) := "0000000000000001";
    signal entrada_ponto_fixo : ufixed(parte_inteira downto parte_fracionaria) := "0000000000000000";

    -- portas do componente
    signal resultado          : ufixed(parte_inteira downto parte_fracionaria);
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
            if (entrada_ponto_fixo = 0) then
                file_open(fstatus, fptr, "sqrt.csv", write_mode);
                write(file_line, string'("x;sqrt(x)"), left, 9);
                writeline(fptr, file_line);
            end if;
            
            write(file_line, entrada_ponto_fixo, left, 16);
            write(file_line, string'(";"), left, 1);
            write(file_line, resultado, left, 16);
            writeline(fptr, file_line);
            
            -- Atualiza x
            entrada_ponto_fixo <= resize(arg=>entrada_ponto_fixo+lsb, size_res=>entrada_ponto_fixo);
        end if;
    end process incremento;
    

end architecture sim;
