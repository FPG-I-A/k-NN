# Normalização

## Descrição

Módulo para normalização de um número do intervalo [$x_{min}$, $x_{max}$] para [1, 0]. Por se tratar de uma unica conta, feita em um circuito combinatório, não há necessiade de um sinal de `clock` nem de uma FSM.

## Algoritmo

O método de normalização é chamado [redimensionamento](https://en.wikipedia.org/wiki/Feature_scaling#Rescaling_(min-max_normalization)). E ele é definido pela equação abaixo.

$$
x' =\frac{x - x_{min}}{x_{max} - x_{min}}
$$

## Mapeamento genérico

|  **Nome**   | **Tipo** |                 **Descrição**                  |
|:-----------:|:--------:|:----------------------------------------------:|
| `gen_max_x` |  inteiro | Limite superior do intervalo a ser normalizado |
| `gen_min_x` |  inteiro | Limite inferior do intervalo a ser normalizado |

## Mapeamento de portas

|   **Nome**  |      **Tipo**      |              **Descrição**              |
|:-----------:|:------------------:|:---------------------------------------:|
|    `i_x`    |     ponto fixo     |             Valor de entrada            |
|  `o_x_norm` |     ponto fixo     |                Resultado                |
