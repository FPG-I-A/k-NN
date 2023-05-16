# Argmin
Módulo para encontrar os k menores elementos em um vetor não ordenado utilizando o método de [insertion sort](https://en.wikipedia.org/wiki/Insertion_sort). Este módulo será utilizado para encontrar os índices das menores distâncias calculadas.

## Descrição
A ideia de utilização do isertion sort é que, por mais que trata-se de um algoritmo de ordenação lento, como desejamos ordenar apenas um número pequeno de elementos dentro do vetor, normalmente k é menor do que 10, faz sentido utiliza-lo por causa de sua implementação simples.



## Algoritmo
Este algoritmo funciona iterando sobre o vetor de entrada (no caso as distâncias calculadas) e ordenando-o em um outro vetor. Por exemplo, caso busca-se ordenar o vetor [5, 1, 3, 4, 2] primeiramente cria-se um vetor vazio e coloca o primeiro valor, o 5, nele, em seguida adiciona os outros valores no seu devido lugar fazendo as comparações. Assim, o vetor de resultado cresce da seguinte maneira:

```
[5]
[1, 5]
[1, 3, 5]
[1, 3, 4, 5]
[1, 2, 3, 4, 5]
```

A grande questão aqui é que buscamos os índices dos menores elementos, e não os elementos em si, então o vetor criado armazena esses índices. No exemplo anterior o vetore de resultados armazenando índices, considerando o primeiro elemento como índice 0, fica da seguinte forma:

```
[0]
[1, 0]
[1, 2, 0]
[1, 2, 3, 0]
[1, 4, 2, 3, 0]
```


## Mapeamento genérico

|        **Nome**       | **Tipo** |           **Descrição**          |
|:---------------------:|:--------:|:--------------------------------:|
|   `gen_n_elementos`   |  inteiro | Quantidade de elementos no vetor |
|       `gen_n_k`       |  inteiro |  Quantidade de menores índices   |

## Mapeamento de portas

|   **Nome**  |     **Tipo**      |                    **Descrição**                    |
|:-----------:|:-----------------:|:---------------------------------------------------:|
|    i_clk    |         bit       |           `Clock` para execução do algoritmo        | 
|    i_init   |         bit       |            Sinal para iniciar o algoritmo           |
|   i_reset   |         bit       |            Sinal para resetar o algoritmo           |
| i_elementos |    vetor de sfixo |                   Vetor de entrada                  |
|  o_indices  | vetor de inteiros | Vetor com os índices dos gen_n_k menores valores do vetor de entrada                      |
|  o_ocupado  |         bit       | Sinal que indica que o calculo está sendo realizado |

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

Internamente também há uma segunda FSM, ela controla os estados de cálculo do algoritmo e os estados são controlados por `iniciar`, `finaliza`, `inicia_insersao`, `inserindo` e `finalizou_insercao`.
 
 - `iniciar`: prepara registradores internos para iniciar o algoritmo;
 - `finaliza`: prepara registradores internos para finalizar o algoritmo e colocar o resultado na saída; 
 - `inicia_insersao`: inicia algoritmo de inserção do índice na lista de ídices utilizando o módulo [de inserção](../insere/README.md);
 - `inserindo`: algoritmo de inserção em andamento, basicamente é o `o_ocupado` do módulo [de inserção](../insere/README.md#mapeamento-de-portas);
 - `finalizou_insercao`: recebe o resultado do algoritmo de inserção e prepara registradores internos para continuar o algoritmo.