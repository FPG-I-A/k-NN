# Argmin

## Descrição

Módulo para encontrar o número que mais aparece dentro de um vetor não ordenado.

## Algoritmo

O algoritmo funciona em duas etapas: contagem e comparação.

- Contagem: conta quantos elementos do vetor é um dado número, ao final deste módulo tem-se um novo vetor, cujo tamanho é igual ao número de classes em que cada elemento indica a quantidade de amostras com aquela classe no vetor de entradas. Por exemplo, entradas: [0, 1, 2, 0, 0, 2, 1, 1, 0,], vetor ao final da etapa: [4, 3, 2].
- Comparação: encontra qual classe possuí mais elementos ao encontrar o índice do maior elemento deste vetor criado na etapa anterior: um argmax.

## Mapeamento genérico

|        **Nome**       | **Tipo** |                       **Descrição**                      |
|:---------------------:|:--------:|:--------------------------------------------------------:|
|   `gen_n_elementos`   |  inteiro | Quantidade de elementos no vetor, representa o k do k-NN |
|   `gen_n_classes`     |  inteiro |          Número de classes no vetor de entradas          |

## Mapeamento de portas

|   **Nome**  |     **Tipo**      |                      **Descrição**                     |
|:-----------:|:-----------------:|:------------------------------------------------------:|
|    i_clk    |         bit       |             `Clock` para execução do algoritmo         |
|    i_init   |         bit       |              Sinal para iniciar o algoritmo            |
|   i_reset   |         bit       |              Sinal para resetar o algoritmo            |
|    i_vec    | vetor de inteiros |                    Vetor de entrada                    |
| o_resultado |      inteiro      | Índice da classe que mais aparece no vetor de entradas |
|  o_ocupado  |         bit       |   Sinal que indica que o calculo está sendo realizado  |

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

Internamente também há uma segunda FSM, ela controla os estados de cálculo do algoritmo e os estados são controlados por `iniciar` e `contar`.

- `iniciar`: prepara registradores internos para iniciar o algoritmo;
- `contar`: inicia a etapa de contagem;
- `~contar`: inicia a etapa de comparação
