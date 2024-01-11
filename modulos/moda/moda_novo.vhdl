library ieee;
use ieee.std_logic_1164.all;

library work;
use work.pacote_aux.all;

entity moda is
    generic (
        gen_n_elementos : integer := 2; -- k do knn
        gen_n_classes   : integer := 3  -- n de classes no dataset treino
    );
    port (
        i_clk       : in std_logic;
        i_init      : in std_logic;
        i_reset     : in std_logic;
        i_vec       : in vec_inteiro(gen_n_elementos - 1 downto 0);
        o_ocupado   : out std_logic := '0';
        o_resultado : out integer
    );
end moda;

architecture conta of moda is
    signal classes          : vec_inteiro(gen_n_elementos - 1 downto 0); -- entrada
    signal contador_classes : vec_inteiro(gen_n_classes - 1 downto 0) := (others => 0); -- Contador de ocorrências de cada classe
    signal contador         : integer;
    signal iniciar          : std_logic := '0';
    signal ocupado          : std_logic := '0';
    signal contar           : std_logic := '0';
    signal maior            : integer   :=  0;
begin

    calcula : process (i_clk) begin
        if iniciar = '1' then
            contador_classes <= (others => 0);
            classes          <= i_vec;
            ocupado        <= '1';
            contar           <= '1';
            maior            <= 0;
            contador         <= 0;
        end if;

        if ocupado = '1' and contar = '1' then -- conta quantos elementos por classe
            contador_classes(classes(contador)) <= contador_classes(classes(contador)) + 1;
            contador                            <= contador + 1;

            -- Termina contagem
            if contador = gen_n_elementos - 1 then
                contar   <= '0';
                contador <= 0;
            end if;
        end if;

        if ocupado = '1' and contar = '0' then -- argmax
            if contador < gen_n_classes and contador_classes(contador) > contador_classes(maior) then
                maior <= contador;
            end if;
            if contador = gen_n_classes then
                o_resultado <= maior;
                ocupado   <= '0';
            end if;
            contador <= contador + 1;
        end if;
    end process calcula;

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
    
end conta;
