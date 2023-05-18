# KNN

## O algoritmo

K-NN, sigla em inglês para k vizinhos mais próximos é um algoritmo simples de aprendizagem de máquina para tarefas de classificação. O algoritmo consiste em calcular a distância das características da amostra de inferência que se deseja classificar até cada uma das amostras de treino. Para o cálculo de distância utilizaremos a distância euclidiana, definida por:

$$
distancia = \sqrt{\sum_{i=0}^N(a_i - b_i)^2}
$$

Sendo $a_n$ a característica $n$ da amostra que deve ser classificada e $b_n$ a característica $n$ de uma das amostras de treino.

Após calcular todas as distâncias o algoritmo coloca a amostra de inferência na classe que é representada pela moda das classes das k amostras de teste com menor distância.

Exemplo, utilizando um valor de k = 5 e com as 5 distâncias e classificações mostradas na tabela abaixo, a amostra de inferência é colocada na classe 1.

| **Amostra** |  **Distância**  | **Classe** |
|:-----------:|:---------------:|:----------:|
|      1      |       0.35      |      1     |
|      2      |       1.42      |      0     |
|      3      |       0.57      |      1     |
|      4      |       3.97      |      0     |
|      5      |       2.3       |      1     |

## Módulos implementados

Uma descrição de hardware em VHDL é realizada criando e unindo diversos blocos de circuitos digitais. Assim, para criar o algoritmo vários blocos com funções limitadas foram criados.

O hardware de uma FPGA não possuí diversas operações matemáticas necessárias. Na realidade ele possuí apenas soma, subtração, multiplicação e divisão. Todas as outras operações devem ser implementadas de alguma forma.

Vale notar que, além disso, não há unidades de ponto flutuante, então, ao menos por enquanto, decidimos utilizar números de [ponto fixo](https://embarcados.com.br/entendendo-a-aritmetica-em-ponto-fixo/).

Cada módulo possuí uma sessão de mapeamento genérico e uma de mapeamento de portas, além de uma descrição de seu funcionamento.

- [`sqrt`](modulos/sqrt/README.md)
- [`norm`](modulos/norm/README.md)
- [`insere`](modulos/insere/README.md)
- [`argmim`](modulos/argmin/README.md)
