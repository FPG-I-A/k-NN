# Descrição
Módulo para normalização de um número do intervalo [$x_{min}$, $x_{max}$] para [1, 0]. Por se tratar de uma unica conta, feita em um circuito combinatório, não há necessiade de um sinal de `clock` nem de uma FSM.

# Algoritmo
O método de normalização é chamado [redimensionamento](https://en.wikipedia.org/wiki/Feature_scaling#Rescaling_(min-max_normalization)). E ele é definido pela equação abaixo.

$$
x' =\frac{x - x_{min}}{x_{max} - x_{min}}
$$



# Mapeamento genérico
<center>

|        **Nome**       | **Tipo** |                          **Descrição**                          |
|:---------------------:|:--------:|:---------------------------------------------------------------:|
|   `gen_parte_inteira`   |  inteiro |    Quantidade de bits da parte inteira do número de ponto fixo  |
| `gen_parte_fracionaria` |  inteiro | Quantidade de bits da parte fracionária do número de ponto fixo |
</center>

# Mapeamento de portas
<center>

|  **Nome** | **Tipo** |                    **Descrição**                    |
|:---------:|:--------:|:---------------------------------------------------:|
|    `i_x`    |     ponto fixo     |                   Valor de entrada                  |
|  `o_x_norm` |     ponto fixo     |                      Resultado                      |
</center>
