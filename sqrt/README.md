# Descrição
Módulo para calculo de raiz quadrada em ponto fixo.

# Algoritmo
O algoritmo utilizado para o cálculo é um algoritmo interativo chamado [método de heron](https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Heron's_method). Desta forma, uma estimativa inicial é feita e a cada iteração ela é atualizada para se aproximar do resultado correto. A atualização da estimativa é feita segundo a fórmula abaixo.

$$
y_i = \frac{1}{2}\left( y_{i-1} - x\right)
$$

Sendo $y_n$ a estimativa na iteração $n$ e $x$ o valor do qual se quer calcular a raiz quadrada.

Como pretendemos utilizar números normalizados entre $0$ e $1$, utilizamos como estimativa inicial o valor $y_0=0,5$, ou seja, o meio do intervalo.

# Mapeamento genérico
<center>

|        **Nome**       | **Tipo** |                          **Descrição**                          |
|:---------------------:|:--------:|:---------------------------------------------------------------:|
|   `gen_parte_inteira`   |  inteiro |    Quantidade de bits da parte inteira do número de ponto fixo  |
| `gen_parte_fracionaria` |  inteiro | Quantidade de bits da parte fracionária do número de ponto fixo |
|     `gen_iteracoes`     |  inteiro |                 número de iterações do algoritmo                |
</center>

# Mapeamento de portas
<center>

|  **Nome** | **Tipo** |                    **Descrição**                    |
|:---------:|:--------:|:---------------------------------------------------:|
|   `i_clk`   |         bit        |           `Clock` para execução do algoritmo          |
|   `i_init`  |         bit        |            Sinal para iniciar o algoritmo           |
|  `i_reset`  |         bit        |            Sinal para resetar o algoritmo           |
|    `i_x`    |     ponto fixo     |                   Valor de entrada                  |
|  `o_sqrt_x` |     ponto fixo     |                      Resultado                      |
| `o_ocupado` |         bit        | Sinal que indica que o calculo está sendo realizado |
</center>

# Funcionamento da FSM
A máquina de estados finitos é controlada por três portas do módulo: `i_init`, `i_reset`e `o_ocupado`. A tabela abaixo mostra a operação realizada em cada caso.
<center>

| `i_init` | `i_reset` | `o_ocupado` |                 **Operação**                 |
|:------------:|:-------------:|:---------------:|:--------------------------------------------:|
|       0      |       x       |        0        |                 Nada acontece                |
|       0      |       1       |        1        |       Operação iniciada é interrompida       |
|       x      |       0       |        1        | Operação, já iniciada, continua em andamento |
|       1      |       0       |        0        |              Operação é iniciada             |
|       1      |       1       |        x        |              Operação é iniciada             |
</center>
