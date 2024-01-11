library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Bibliotecas necessárias no quartus
-- Verificar https://github.com/LockBall/floatfixlib_VHDL1993
-- library floatfixlib;
-- use floatfixlib.fixed_pkg.all;

library work;
use work.pacote_aux.all;

entity distancias is
    generic (
        gen_n_amostras        : in integer; -- quantidade de elementos na matriz de entradas
        gen_n_caracteristicas : in integer
    );
    port (
        i_clk       : in bit;
        i_init      : in bit;
        i_reset     : in bit;
        i_elementos : in mat_s_fixo(gen_n_amostras - 1 downto 0, gen_n_caracteristicas - 1 downto 0);
        i_valor     : in vec_s_fixo(gen_n_caracteristicas - 1 downto 0);
        o_resultado : out vec_s_fixo(gen_n_amostras - 1 downto 0);
        o_amostra   : out integer;
        o_ocupado   : out bit
    );
end distancias;
architecture calcula of distancias is
    signal iniciar                 : bit := '0';
    signal finaliza                : bit := '0';
    signal elementos               : mat_s_fixo(gen_n_amostras - 1 downto 0, gen_n_caracteristicas - 1 downto 0);
    signal valor                   : vec_s_fixo(gen_n_caracteristicas - 1 downto 0);
    signal contador_elemento       : integer range 0 to gen_n_amostras        := 0;
    signal contador_caracteristica : integer range 0 to gen_n_caracteristicas := 0;
    signal ocupado : bit := '0';
    signal resultado : vec_s_fixo(gen_n_amostras - 1 downto 0);
begin

    calcula_saida : process (i_clk) begin
        if iniciar = '1' then
            ocupado               <= '1';
            elementos               <= i_elementos;
            contador_elemento       <= 0;
            contador_caracteristica <= 0;

            for id_carac in gen_n_caracteristicas - 1 downto 0 loop
                valor(id_carac) <= i_valor(id_carac);
            end loop;

            for id_amostra in gen_n_amostras - 1 downto 0 loop
                resultado(id_amostra) <= s_fixo_zero;
            end loop;

        end if;

        if ocupado = '1' and finaliza = '0' then

            -- Atualiza distância do vetor atual
            if contador_caracteristica < gen_n_caracteristicas and contador_elemento < gen_n_amostras then
                resultado(contador_elemento) <= resize(
                    resultado(contador_elemento) + (valor(contador_caracteristica) - elementos(contador_elemento, contador_caracteristica)),
                    resultado(contador_elemento)
                );
                contador_caracteristica <= contador_caracteristica + 1;

            -- Passa para o próximo vetor
            elsif contador_caracteristica = gen_n_caracteristicas then
                if resultado(contador_elemento) < 0 then
                    resultado(contador_elemento) <= resize(
                        -resultado(contador_elemento),
                        resultado(contador_elemento)
                    );
                end if;
                contador_caracteristica <= 0;
                contador_elemento <= contador_elemento + 1;
            end if;


            if contador_elemento = gen_n_amostras then
                resultado(gen_n_amostras - 1) <= resize(
                    -resultado(gen_n_amostras - 1),
                    resultado(gen_n_amostras - 1)
                );
                finaliza <= '1';
            end if;

        elsif ocupado = '1' and finaliza = '1' then
            resultado(contador_elemento - 1) <= resize(
                -resultado(contador_elemento - 1), resultado(contador_elemento - 1)
            );
            finaliza                           <= '0';
            ocupado                          <= '0';
        end if;

    end process calcula_saida;

    saida_amostra : process (contador_elemento, ocupado) begin
        if ocupado = '0' then
            o_amostra <= gen_n_amostras;
        else
            o_amostra <= contador_elemento - 1;
        end if;
    end process saida_amostra;

    inicializa : process (ocupado, i_init, i_reset) begin -- Controle dos estados da FSM
        if ocupado = '0' and i_init = '1' then
            iniciar <= '1';
        elsif ocupado = '1' and i_reset = '1' and i_init = '1' then
            iniciar <= '1';
        else
            iniciar <= '0';
        end if;
    end process inicializa;

    saida_ocupado : process(ocupado) begin
        o_ocupado <= ocupado;
    end process saida_ocupado;

    saida_resultado : process(resultado) begin
        o_resultado <= resultado;
    end process saida_resultado;
end architecture calcula;
