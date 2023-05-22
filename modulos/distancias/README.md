# Distâncias

## Descrição

Módulo para encontra a distância euclidiana de um vetor até todos os vetores presentes em uma matriz. O valor calculado não é exatamente as distâncias euclidianas, como queremos simplesmente encontrar as menores distâncias, podemos utilizar o quadrado delas, ou seja, ignoramos a parte da radiciação utilizando a fórmula abaixo.

$$
dist(x, y) = \sum^{i=0}{N}(x_i - y_i)^2
$$

## Algoritmo

Consideramos a matriz de entrada como contendo um vetor em cada linha, assim como o objetivo é encontrar a distância do vetor de entradas até cada uma dessas linhas, realizamos um loop que itera sobre cada linha da matriz e calcula a distância do vetor até esta linha.

Vale notar que os loops em VHDL são feitos diretamente em hardware e podem ser muito custosos, neste caso principalmente devido à quantidade de linhas na matriz. Desta forma a iteração é feita utilizando um contador que aponta para a linha atual.

Além disso o calculo das distâncias individuais também é feito seguindo um loop interno para implementar a fórmula mencionada acima, desta é necessário $n$ ciclos de clock para calcular uma única distância, sendo $n$ o número de características no vetor de entradas e $n * m$ ciclos de clock para calcular todas as distâncias, sendo $m$ o número de vetores no "conjunto de treino", a matriz de entradas.

Da forma como o algoritmo foi feito ele utiliza um pouco de pipeline, assim a cada n ciclos de clock o vetor de saída será atualizado com um elemento a mais. O sinal `o_amostra`, desta forma, assim que `o_amostra` atingir um determinado valor $k$, isso significa que o elemento indice $k$ de `o_resultado` já é a distância calculada entre o vetor de entrada e o elemento índice $k$ da matriz de entrada.

## Mapeamento genérico

|         **Nome**        | **Tipo** |              **Descrição**              |
|:-----------------------:|:--------:|:---------------------------------------:|
|    `gen_n_amostras`     |  inteiro |    Quantidade de vetores de "treino"    |
| `gen_n_caracteristicas` |  inteiro |  Quantidade características por vetor   |

## Mapeamento de portas

|   **Nome**  |     **Tipo**      |                    **Descrição**                    |
|:-----------:|:-----------------:|:---------------------------------------------------:|
|    i_clk    |         bit       |           `Clock` para execução do algoritmo        |
|    i_init   |         bit       |            Sinal para iniciar o algoritmo           |
|   i_reset   |         bit       |            Sinal para resetar o algoritmo           |
| i_elementos |  matriz de sfixo  |                   Matriz de entrada                 |
|   i_valor   |    vetor de sfixo |                   Vetor de entrada                  |
| o_resultado |    vetor de sfixo |                   Vetor de distâncias               |
|   o_valor   |        inteiro    |      Índice da última distância calculada           |
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
