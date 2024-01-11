library work;
use work.pacote_aux.all;

entity insere is
    generic (
        gen_n_elementos : in integer := 2 -- quantidade de elementos no vetor de entradas
    );
    port (
        i_clk       : in bit;
        i_init      : in bit;
        i_reset     : in bit;
        i_elementos : in vec_inteiro(gen_n_elementos - 1 downto 0);
        i_valor     : in integer;
        i_indice    : in integer;
        o_resultado : out vec_inteiro(gen_n_elementos - 1 downto 0);
        o_ocupado   : out bit
    );
end insere;

architecture shift of insere is
    signal iniciar      : bit := '0';
    signal finaliza     : bit := '0';
    signal elementos    : vec_inteiro(gen_n_elementos - 1 downto 0);
    signal valor        : integer;
    signal indice       : integer;
    signal indice_atual : integer := 0;
    signal ocupado     : bit := '0';

begin

    calcula_saida : process (i_clk) begin
        if iniciar = '1' then
            ocupado    <= '1';
            elementos    <= i_elementos;
            valor        <= i_valor;
            indice       <= i_indice;
            indice_atual <= 0;
        end if;

        if ocupado = '1' and finaliza = '0'then
            if indice_atual < indice - 1 then
                elementos(indice_atual) <= elementos(indice_atual + 1);
                indice_atual            <= indice_atual + 1;
            else
                elementos(indice) <= valor;
                finaliza          <= '1';
            end if;

        end if;

        if finaliza = '1' then
            finaliza    <= '0';
            o_resultado <= elementos;
            ocupado   <= '0';
        end if;
    end process calcula_saida;

    inicializa : process (ocupado, i_init, i_reset) begin -- Controle dos estados da FSM
        if ocupado = '0' and i_init = '1' then
            iniciar <= '1';
        elsif ocupado = '1' and i_reset = '1' and i_init = '1' then
            iniciar <= '1';
        else
            iniciar <= '0';
        end if;
    end process inicializa;

    saida_ocupada : process(ocupado) begin
        o_ocupado <= ocupado;
    end process saida_ocupada;

end shift;