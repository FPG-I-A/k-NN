# Normalização

## Descrição

Módulo para normalização de um número do intervalo [$x_{min}$, $x_{max}$] para [1, 0]. Por se tratar de uma unica conta, feita em um circuito combinatório, não há necessiade de um sinal de `clock` nem de uma FSM.

## Algoritmo

O método de normalização é chamado [redimensionamento](https://en.wikipedia.org/wiki/Feature_scaling#Rescaling_(min-max_normalization)). E ele é definido pela equação abaixo.

$$
x' =\frac{x - x_{min}}{x_{max} - x_{min}}
$$

## Mapeamento genérico

|        **Nome**         | **Tipo** |              **Descrição**               |
|:-----------------------:|:--------:|:----------------------------------------:|
| `gen_n_caracteristicas` |  inteiro | Número de elementos no vetor de entradas |

## Mapeamento de portas

|   **Nome**  |      **Tipo**      |              **Descrição**              |
|:-----------:|:------------------:|:---------------------------------------:|
| i_clk | bit | `Clock` para execução do algoritmo |
| i_init | bit |  Sinal para iniciar o algoritmo |
| i_reset | bit |  Sinal para resetar o algoritmo |
| i_x | vetor de sfixo | Vetor contendo os elementos a serem normalizados |
| i_max_x | vetor de sfixo | Valores máximos de cada elemento a ser normalizado |
| i_min_x | vetor de sfixo | Valores mínimos de cada elemento a ser normalizado
| o_x_norm | vetor de sfixo | Elementos normalizados |
| o_ocupado | bit | Sinal que indica que o cálculo está sendo realizado |

## Funcionamento da FSM
A máquina de estados finitos é controlada por três portas do módulo: `i_init`, `i_reset`e `o_ocupado`. A
tabela abaixo mostra a operação realizada em cada caso.

|   `i_init`   |   `i_reset`   |   `o_ocupado`   |                 **Operação**                 |
|:------------:|:-------------:|:---------------:|:--------------------------------------------:|
|       0      |       x       |        0        |                 Nada acontece                |
|       0      |       1       |        1        |       Operação iniciada é interrompida       |
|       x      |       0       |        1        | Operação, já iniciada, continua em andamento |
|       1      |       0       |        0        |              Operação é iniciada             |
|       1      |       1       |        x        |              Operação é iniciada             |

