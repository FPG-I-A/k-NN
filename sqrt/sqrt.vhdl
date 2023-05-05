library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;


entity sqrt is
generic (
    gen_parte_inteira     : integer;
    gen_parte_fracionaria : integer;
    gen_iteracoes         : integer
);
port (
    i_clk    : in  bit;
    i_init   : in  bit;
    i_reset  : in  bit;
    i_x      : in  ufixed(gen_parte_inteira downto gen_parte_fracionaria);
    o_sqrt_x : out ufixed(gen_parte_inteira downto gen_parte_fracionaria);
    o_ocupado: out bit
);
end sqrt;

architecture metodo_heron of sqrt is 
    signal s        : ufixed(gen_parte_inteira downto gen_parte_fracionaria);
    signal xn       : ufixed(gen_parte_inteira downto gen_parte_fracionaria);
    signal contador : integer := 0;
    signal iniciar  : bit := '0';
    
    begin
    
    calcula_saida: process(i_clk) begin
            if iniciar = '1' then
                contador <= 0;
                o_ocupado <= '1';
                xn <= to_ufixed(0.5, xn);
            end if; 

            if o_ocupado = '1' then
                xn <= resize(
                            arg=>(shift_right(xn + s / xn, 1)),     -- média entre xn e s / xn
                            size_res=>xn
                            );
                contador <= contador + 1;


                if contador = gen_iteracoes then -- Coloca resultado na saída
                    o_ocupado <= '0';
                    o_sqrt_x <= xn;
                end if;

        end if;
    end process calcula_saida;

    inicializa: process(o_ocupado, i_init, i_reset) begin -- Controle dos estados da FSM
        if o_ocupado = '0' and i_init = '1' then
            s <= i_x;
            iniciar <= '1';
        elsif o_ocupado = '1' and i_reset = '1' and i_init = '1' then
            s <= i_x;
            iniciar <= '1';
        else
            iniciar <= '0';
        end if;
    end process inicializa;

end metodo_heron;
