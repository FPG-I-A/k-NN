library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
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
    signal resultado          : s_fixo;

    -- Escrita no arquivo de saída
    file fptr: text;

begin 

    UUT: entity work.norm
        generic map(
            gen_max_x=>s_fixo_max,
            gen_min_x=>s_fixo_min
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
        if entrada_ponto_fixo = s_fixo_max then
            finish;
        end if;
    end process clock;


    incremento: process(entrada_ponto_fixo)
    variable fstatus       :file_open_status;
    variable file_line     :line;
    begin
        if (entrada_ponto_fixo = s_fixo_min) then
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
