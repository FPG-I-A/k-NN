library ieee;
use ieee.fixed_pkg.all;
use ieee.math_real.all;
use std.env.finish;

library work;
use work.pacote_aux.all;


entity argmin_tb is
end argmin_tb;

architecture sim of argmin_tb is
    
    constant n_elementos  : integer := 10;
    constant k            : integer := 3;

    -- portas do componente
    signal i_clk       : bit := '0';
    signal i_init      : bit := '0';
    signal i_reset     : bit := '0';
    signal o_ocupado   : bit;
    signal i_elementos : vec_s_fixo(n_elementos - 1 downto 0);
    signal o_indices   : vec_inteiro(k - 1 downto 0);

    -- contador de ciclos de clock
    signal contador : integer := 0;

begin 

    UUT: entity work.argmin
        generic map(
            gen_n_elementos=>n_elementos,
            gen_k=>k
        )
        port map(
            i_clk=>i_clk,
            i_init=>i_init,
            i_reset=>i_reset,
            o_ocupado=>o_ocupado,
            i_elementos=>i_elementos,
            o_indices=>o_indices
        );
    
    
    clock:  process
    begin
        i_clk <= not i_clk;
        wait for 400 ns; -- 50Mhz

    end process clock;


    inicia: process
    -- Variáveis do gerador de números aleatórios
    variable seed1 : positive := 51374708;
    variable seed2 : positive := 17647597;
    variable rand  : real;
    begin
        
        -- popula vetor de entradas
        for i in n_elementos - 1 downto 0 loop
            uniform(seed1, seed2, rand);
            i_elementos(i) <= to_sfixed(rand , i_elementos(i));
            wait for 10 ns;
        end loop;
        
        i_init <= '1';
        wait for 1 us;
        i_init <= '0';
        wait for 50 us;
        finish;
    end process inicia;

    process(o_ocupado, i_clk)
    begin
        if falling_edge(o_ocupado) or rising_edge(o_ocupado) then
            contador <= 0;
        elsif rising_edge(i_clk) then
            contador <= contador + 1;
        end if;

    end process;
    
end architecture sim;
