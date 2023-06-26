# KNN
Descrição realizada em [`README.md`](../../README.md)

## Mapeamento genérico

|        **Nome**       | **Tipo** |                          **Descrição**                          |
|:---------------------:|:--------:|:---------------------------------------------------------------:|
|   `gen_n_amostras`    |  inteiro |    Quantidade de amostras de treino |
|   `gen_n_caracteristicas` | inteiro | Número de características de entrada |
|   `gen_n_classes` | inteiro | Número de classes |
|   `gen_k` | inteiro | Valor k do knn |

## Mapeamento de portas

|    **Nome**   |      **Tipo**      |                    **Descrição**                    |
|:-------------:|:------------------:|:---------------------------------------------------:|
|    `i_clk`    |         bit        |         `Clock` para execução do algoritmo          |
|    `i_init`   |         bit        |            Sinal para iniciar o algoritmo           |
|   `i_reset`   |         bit        |            Sinal para resetar o algoritmo           |
| `i_x_treino` | vetor de inteiros  |             Matriz contendo os elementos de treino              |
|   `i_y_treino`   |       inteiro      |           Matriz contendo os resultados de treino           |
|  `i_infere`   |       inteiro      |      Vetor de entrada de inferência     |
| `o_resultado` | inteiro  |                      Resultado                      |
|  `o_ocupado`  |         bit        | Sinal que indica que o calculo está sendo realizado |

## Funcionamento da FSM

A máquina de estados finitos é controlada por três portas do módulo: `i_init`, `i_reset`e `o_ocupado`. A tabela abaixo mostra a operação realizada em cada caso.

|   `i_init`   |   `i_reset`   |   `o_ocupado`   |                 **Operação**                 |
|:------------:|:-------------:|:---------------:|:--------------------------------------------:|
|       0      |       x       |        0        |                 Nada acontece                |
|       0      |       1       |        1        |       Operação iniciada é interrompida       |
|       x      |       0       |        1        | Operação, já iniciada, continua em andamento |
|       1      |       0       |        0        |              Operação é iniciada             |
|       1      |       1       |        x        |              Operação é iniciada             |

O processamento interno também é controlado por uma segunda FSM, cujo objetivo é controlar os módulos chamados. Os estados dela são ditados pelos sinais de iniciar, termino indicados por `modulo_comeou`e `modulo_terminou`.
