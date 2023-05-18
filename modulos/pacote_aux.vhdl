library ieee;
use ieee.fixed_pkg.all;
use ieee.std_logic_1164.all;

package pacote_aux is

    -- -------------------------- Definições de constantes --------------------------
    constant parte_inteira     : integer := 1;
    constant parte_fracionaria : integer := - 14;
    constant tamanho           : integer := parte_inteira - parte_fracionaria;

    constant vec_zero      : std_logic_vector(tamanho downto 0) := (others => '0');
    constant vec_um        : std_logic_vector(tamanho downto 0) := (others => '1');
    constant vec_lsb       : std_logic_vector(tamanho downto 0) := (0 => '1', others => '0');
    constant vec_msb       : std_logic_vector(tamanho downto 0) := (tamanho => '1', others => '0');
    constant vec_msb_m_lsb : std_logic_vector(tamanho downto 0) := (tamanho => '0', others => '1');

    constant s_fixo_max  : sfixed(parte_inteira downto parte_fracionaria) := to_sfixed(vec_msb_m_lsb, parte_inteira, parte_fracionaria);
    constant s_fixo_min  : sfixed(parte_inteira downto parte_fracionaria) := to_sfixed(vec_msb, parte_inteira, parte_fracionaria);
    constant s_fixo_lsb  : sfixed(parte_inteira downto parte_fracionaria) := to_sfixed(vec_lsb, parte_inteira, parte_fracionaria);
    constant s_fixo_msb  : sfixed(parte_inteira downto parte_fracionaria) := to_sfixed(vec_msb, parte_inteira, parte_fracionaria);
    constant s_fixo_zero : sfixed(parte_inteira downto parte_fracionaria) := to_sfixed(vec_zero, parte_inteira, parte_fracionaria);

    constant u_fixo_min : ufixed(parte_inteira downto parte_fracionaria) := to_ufixed(vec_zero, parte_inteira, parte_fracionaria);
    constant u_fixo_max : ufixed(parte_inteira downto parte_fracionaria) := to_ufixed(vec_um, parte_inteira, parte_fracionaria);
    constant u_fixo_lsb : ufixed(parte_inteira downto parte_fracionaria) := to_ufixed(vec_lsb, parte_inteira, parte_fracionaria);
    constant u_fixo_msb : ufixed(parte_inteira downto parte_fracionaria) := to_ufixed(vec_msb, parte_inteira, parte_fracionaria);

    -- ----------------------------- Definições de tipos ----------------------------
    subtype s_fixo is sfixed(parte_inteira downto parte_fracionaria);
    subtype u_fixo is ufixed(parte_inteira downto parte_fracionaria);

    type vec_s_fixo is array (integer range <>) of s_fixo;
    type vec_u_fixo is array (integer range <>) of s_fixo;
    type vec_inteiro is array (integer range <>) of integer;

    type mat_s_fixo is record
        linhas    : integer;
        colunas   : integer;
        elementos : vec_s_fixo;
    end record mat_s_fixo;

    type mat_u_fixo is record
        linhas    : integer;
        colunas   : integer;
        elementos : vec_u_fixo;
    end record mat_s_fixo;

end package pacote_aux;
