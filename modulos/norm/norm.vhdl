library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Bibliotecas necessárias no quartus
-- Verificar https://github.com/LockBall/floatfixlib_VHDL1993
-- library floatfixlib;
-- use floatfixlib.fixed_pkg.all;

library work;
use work.pacote_aux.all;

entity norm is
    generic (
        gen_n_caracteristicas : integer

    );
    port (
        i_clk     : in std_logic;
        i_init    : in std_logic;
        i_reset   : in std_logic;
        i_x       : in vec_s_fixo(gen_n_caracteristicas - 1 downto 0);
        i_max_x   : in vec_s_fixo(gen_n_caracteristicas - 1 downto 0);
        i_min_x   : in vec_s_fixo(gen_n_caracteristicas - 1 downto 0);
        o_x_norm  : out vec_s_fixo(gen_n_caracteristicas - 1 downto 0);
        o_ocupado : out std_logic
    );
end norm;

architecture redimensionamento of norm is
    signal iniciar   : std_logic := '0';
    signal resetar   : std_logic := '0';
    signal contador  : integer := 0;
    signal valores   : vec_s_fixo(gen_n_caracteristicas - 1 downto 0);
    signal maiores   : vec_s_fixo(gen_n_caracteristicas - 1 downto 0);
    signal menores   : vec_s_fixo(gen_n_caracteristicas - 1 downto 0);
    signal resultado : vec_s_fixo(gen_n_caracteristicas - 1 downto 0);
    signal x_norm    : vec_s_fixo(gen_n_caracteristicas - 1 downto 0);
    signal ocupado   : std_logic := '0';

begin
    calcula : process (i_clk) begin
        if resetar = '1' then
            ocupado <= '0';
            contador <= 0;
        else
            ocupado <= ocupado;
            contador <= contador;
        end if;

        if iniciar = '1' then
            ocupado <= '1';
            contador <= 0;
            
            -- Recebe entradas
            valores <= i_x;
            maiores <= i_max_x;
            menores <= i_min_x;

            -- Reinicia saída
            -- Versão do quartus
            -- resultado <= (
            --     others=>to_sfixed(0, resultado(0))
            -- );
            -- Versão do GHDL
            resultado <= (
                others=>resize(
                    arg => s_fixo_zero,
                    size_res => resultado(0)
                )
            );
        
        else
            ocupado <= ocupado;
            contador <= contador;
            
            -- Recebe entradas
            valores <= valores;
            maiores <= maiores;
            menores <= menores;

            -- Reinicia saída
            resultado <= menores;

        end if;

        if ocupado = '1' and contador < gen_n_caracteristicas then
            resultado(contador) <= resize(
                arg => (
                    valores(contador) - menores(contador)) / (maiores(contador) - menores(contador)
                ),
                size_res => resultado(contador)
            );

            contador <= contador + 1;
            
        elsif contador = gen_n_caracteristicas  then
            ocupado <= '0';
            contador <= contador;
            x_norm <= resultado;
        
        else
            ocupado <= ocupado;
            contador <= contador;
            resultado(contador) <= resultado(contador);
            x_norm <= x_norm;
        end if;
        
    end process calcula;

    inicializa : process (ocupado, i_init, i_reset) begin -- Controle dos estados da FSM
        if ocupado = '0' and i_init = '1' then
            iniciar <= '1';
            resetar <= '0';
        elsif ocupado = '1' and i_reset = '1' and i_init = '1' then
            iniciar <= '1';
            resetar <= '0';
        elsif ocupado = '1' and i_reset = '1' then
            resetar <= '1';
        else
            iniciar <= '0';
            resetar <= '0';
        end if;
    end process inicializa;

    saida_ocupada : process(ocupado) begin
		o_ocupado <= ocupado;
	 end process saida_ocupada;
	 
	 saida_x_norm : process(x_norm) begin
		o_x_norm <= x_norm;
	 end process saida_x_norm;

end redimensionamento;
