library ieee;
use std.env.finish;

library work;
use work.pacote_aux.all;


entity insere_tb is
end insere_tb;

architecture sim of insere_tb is
    
    constant n_elementos : integer := 10;
    constant max_val     : integer := 25;

    -- portas do componente
    signal i_clk       : bit := '0';
    signal i_init      : bit := '0';
    signal i_reset     : bit := '0';
    signal o_ocupado   : bit;
    signal i_elementos : vec_inteiro(n_elementos - 1 downto 0) := (
        0 => 0,
        1 => 0,
        2 => 0,
        3 => 0,
        4 => 0,
        5 => 0,
        6 => 0,
        7 => 0,
        8 => 0,
        9 => 0
    );
    signal i_indice : integer := 9;
    signal i_valor  : integer := 0;
    signal o_resultado : vec_inteiro(n_elementos - 1 downto 0);
    signal terminou : bit := '0';


    signal contador : integer := 0;

begin 

    UUT: entity work.insere
        generic map(
            gen_n_elementos=>n_elementos
        )
        port map(
            i_clk=>i_clk,
            i_init=>i_init,
            i_reset=>i_reset,
            i_elementos=>i_elementos,
            i_valor=>i_valor,
            i_indice=>i_indice,
            o_ocupado=>o_ocupado,
            o_resultado=>o_resultado
        );
    
    
    clock:  process
    begin
        i_clk <= not i_clk;
        wait for 400 ns; -- 50Mhz
        if terminou = '1' then
            wait for 800 ns;
            finish;
        end if;

    end process clock;

    -- Inicia novo cálculo após finalização do último
    inicia: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if o_ocupado = '0' then
                i_init <= '1';
                contador <= contador + 1;
                if contador > 0 then i_elementos <= o_resultado; end if;
                i_indice <= (i_indice + 1) mod (n_elementos);
                i_valor <= i_valor + 1;
            else
                i_init <= '0';
            end if;
        end if;
    end process inicia;

    process(o_ocupado) begin
        if falling_edge(o_ocupado) and contador = max_val then terminou <= '1'; end if;
    end process;

end architecture sim;
