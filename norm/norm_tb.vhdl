library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;
use std.textio.all;
use std.env.finish;


entity norm_tb is
end norm_tb;

architecture sim of norm_tb is
    -- parâmetros da UUT
    constant parte_inteira     : integer := 1;
    constant parte_fracionaria : integer := -14;
    
    
    
    -- _____________________________________________________________________________________________
    -- |                                          ATENÇÃO                                          |
    -- | Sempre que houver modificação em `parte_inteira`ou em `parte_fracionaria` os valores de   |
    -- | `lsb`, `entrada_ponto_fixo`, `max_x`e `min_x` devem ser recalculados manualmente e        |
    -- | modificados no código.                                                                    |
    -- |                                                                                           |
    -- | Considerando:                                                                             |
    -- |     n_bits = (parte_inteira - parte_fracionaria + 1) : número de bits no nº de ponto fixo |
    -- |                                                                                           |
    -- | Todos devem ter uma quantidade de bits igual à n_bits                                     |
    -- | `lsb` = 00...01                                                                           |
    -- | `entrada_ponto_fixo` = 00...00                                                            |
    -- | `max_x` = 10...00                                                                         | 
    -- | `min_x` = 00...00
    -- ---------------------------------------------------------------------------------------------
    constant valor_max        : ufixed(parte_inteira downto parte_fracionaria) := "1111111111111111";
    signal entrada_ponto_fixo : ufixed(parte_inteira downto parte_fracionaria) := "0000000000000000";
    constant max_x            : ufixed(parte_inteira downto parte_fracionaria) := "1000000000000000";
    constant min_x            : ufixed(parte_inteira downto parte_fracionaria) := "0000000000000000";

    -- portas do componente
    signal resultado          : ufixed(parte_inteira downto parte_fracionaria);

    -- Escrita no arquivo de saída
    file fptr: text;

begin 

    UUT: entity work.norm
        generic map(
            gen_parte_inteira=>parte_inteira,
            gen_parte_fracionaria=>parte_fracionaria,
            gen_max_x=>max_x,
            gen_min_x=>min_x
        )
        port map(
            i_x=>entrada_ponto_fixo,
            o_x_norm=>resultado
        );
    
    clock:  process
    begin
        entrada_ponto_fixo <= resize(arg=>entrada_ponto_fixo + 0.0000610352,
                                     size_res=>entrada_ponto_fixo);
        wait for 1 ns;
        if entrada_ponto_fixo = valor_max then
            finish;
        end if;
    end process clock;


    incremento: process(entrada_ponto_fixo)
    variable fstatus       :file_open_status;
    variable file_line     :line;
    begin
        if (entrada_ponto_fixo = 0) then
            file_open(fstatus, fptr, "norm.csv", write_mode);
            write(file_line, string'("x;norm(x)"), left, 9);
            writeline(fptr, file_line);
        else
            write(file_line, entrada_ponto_fixo, left, 16);
            write(file_line, string'(";"), left, 1);
            write(file_line, resultado, left, 16);
            writeline(fptr, file_line);
        end if;
        
        
    end process incremento;
    

end architecture sim;
