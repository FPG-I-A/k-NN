# Insere

## Descrição

Módulo para inserção de um elemento em um vetor num dado índice. Utilizado para auxiliar no módulo de argmin.

## Algoritmo

A ideia é que, ao receber um vetor populado, um índice e um número para adicionar, por exemplo o vetor [1, 2, 3, 4], o índice 3 o valor 5, o número desejado seja colocado no índice informado e todos os outros números sejam deslocados para um índice atras, desta forma, no exemplo citado o resultado seria [2, 3, 5, 4].

Isso é feito ao iterar sobre o vetor colocando sempre `vetor(i) = vetor(i+1)` até que i seja igual ao índice desejado, momento em que fazemos `vetor(i) = valor`.

## Mapeamento genérico

|        **Nome**       | **Tipo** |                          **Descrição**                          |
|:---------------------:|:--------:|:---------------------------------------------------------------:|
|   `gen_n_elementos`   |  inteiro |    Quantidade de elementos no vetor|

## Mapeamento de portas

|    **Nome**   |      **Tipo**      |                    **Descrição**                    |
|:-------------:|:------------------:|:---------------------------------------------------:|
|    `i_clk`    |         bit        |         `Clock` para execução do algoritmo          |
|    `i_init`   |         bit        |            Sinal para iniciar o algoritmo           |
|   `i_reset`   |         bit        |            Sinal para resetar o algoritmo           |
| `i_elementos` | vetor de inteiros  |             Vetor contendo os inteiros              |
|   `i_valor`   |       inteiro      |           Valor a ser adicionado ao vetor           |
|  `i_indice`   |       inteiro      |      Índice no qual i_valor deve ser adicionado     |
| `o_resultado` | vetor de inteiros  |                      Resultado                      |
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

O processamento interno também é controlado por uma segunda FSM, os estados dela são ditados pelos sinais `inicias`, `o_ocupado` e `finaliza` segundo a tabela abaixo

| `iniciar` | `finaliza` | `o_ocupado` |                            **Estado**                          |
|:---------:|:----------:|:-----------:|:--------------------------------------------------------------:|
|     0     |     0      |      0      |                   Processamento não iniciado                   |
|     0     |     0      |      1      |                     Processamento em curso                     |
|     0     |     1      |      X      | Processamento terminado, saída sendo colocada em `o_resultado` |
|     1     |     0      |      X      |                  Processamento sendo iniciado                  |
|     1     |     1      |      X      |                        Estado impossível                       |
