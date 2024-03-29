library ieee;
use ieee.fixed_pkg.all;
use ieee.math_real.all;
use ieee.std_logic_1164.all;
use std.env.finish;

library work;
use work.pacote_aux.all;
entity moda_tb is
end moda_tb;

architecture sim of moda_tb is

    constant n_classes : integer := 5;
    constant k         : integer := 7;

    -- portas do componente
    signal i_clk       : std_logic := '0';
    signal i_init      : std_logic := '0';
    signal i_reset     : std_logic := '0';
    signal o_ocupado   : std_logic;
    signal i_elementos : vec_inteiro(k - 1 downto 0) := (1, 1, 1, 3, 2, 3, 2);
    signal o_resultado : integer;

    -- contador de ciclos de clock
    signal contador : integer := 0;

begin

    UUT : entity work.moda
        generic map(
            gen_n_elementos => k,
            gen_n_classes   => n_classes
        )
        port map
        (
            i_clk       => i_clk,
            i_init      => i_init,
            i_reset     => i_reset,
            o_ocupado   => o_ocupado,
            i_vec       => i_elementos,
            o_resultado => o_resultado
        );

    clock : process
    begin
        i_clk <= not i_clk;
        wait for 400 ns; -- 50Mhz
    end process clock;

    inicia : process
    begin

        i_init <= '1';
        wait for 1 us;
        i_init <= '0';
        wait for 50 us;
        finish;
    end process inicia;

    process (o_ocupado, i_clk)
    begin
        if falling_edge(o_ocupado) or rising_edge(o_ocupado) then
            contador <= 0;
        elsif rising_edge(i_clk) then
            contador <= contador + 1;
        end if;

    end process;

end architecture sim;
