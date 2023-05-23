import os
from pathlib import Path

import numpy as np
import pandas as pd
import requests
from sklearn.model_selection import train_test_split


def recebe_dados(seed, tamanho_teste):
    # Baixa conjunto de dados e salva dados crus
    dir = Path('..', 'Dados')
    dir.mkdir(exist_ok=True)
    dados_crus = dir / 'iris.csv'
    response = requests.get(
        'https://archive.ics.uci.edu/ml/machine-learning-databases/iris/iris.data'
    )
    with open(dados_crus, mode='wb') as f:
        f.write(response.content)

    # Carrega conjuntos de dados
    x = np.loadtxt(dados_crus, delimiter=',', usecols=[0, 1, 2, 3])
    y = pd.read_csv(
        dados_crus,
        sep=',',
        usecols=[4],
        header=None,
        names=['Nome'],
    )

    # One-hot
    y.loc[:, 'setosa'] = 0
    y.loc[:, 'virginica'] = 0
    y.loc[:, 'versicolor'] = 0
    y.loc[y['Nome'] == 'Iris-setosa', 'setosa'] = 1
    y.loc[y['Nome'] == 'Iris-virginica', 'virginica'] = 1
    y.loc[y['Nome'] == 'Iris-versicolor', 'versicolor'] = 1
    del y['Nome']
    y = np.array(y)

    # Separa conjunto de treino e teste e calcula resultados
    separados = train_test_split(
        x, y, test_size=tamanho_teste, random_state=seed
    )
    return separados


def cria_cabecalho(arquivo):
    linhas = [
        'library ieee;\n',
        'use ieee.fixed_pkg.all;\n',
        'use ieee.std_logic_1164.all;\n\n',
        'package pacote_aux is\n\n',
    ]
    arquivo.writelines(linhas)


def cria_costantes(arquivo, inteira, fracionaria):
    linhas = [
        f'\t-- -------------------------- Definições de constantes --------------------------\n',
        f'\tconstant parte_inteira     : integer := {inteira};\n',
        f'\tconstant parte_fracionaria : integer := -{fracionaria};\n',
        f'\tconstant tamanho           : integer := parte_inteira - parte_fracionaria + 1;\n\n',
        "\tconstant vec_zero      : std_logic_vector(tamanho - 1 downto 0) := (others => '0');\n",
        "\tconstant vec_um        : std_logic_vector(tamanho - 1 downto 0) := (others => '1');\n",
        "\tconstant vec_lsb       : std_logic_vector(tamanho - 1 downto 0) := (0 => '1', others => '0');\n",
        "\tconstant vec_msb       : std_logic_vector(tamanho - 1 downto 0) := (tamanho - 1 => '1', others => '0');\n",
        "\tconstant vec_msb_m_lsb : std_logic_vector(tamanho - 1 downto 0) := (tamanho - 1 => '0', others => '1');\n\n",
        '\tconstant s_fixo_max  : sfixed(parte_inteira downto parte_fracionaria) := to_sfixed(vec_msb_m_lsb, parte_inteira, parte_fracionaria);\n',
        '\tconstant s_fixo_min  : sfixed(parte_inteira downto parte_fracionaria) := to_sfixed(vec_msb, parte_inteira, parte_fracionaria);\n',
        '\tconstant s_fixo_lsb  : sfixed(parte_inteira downto parte_fracionaria) := to_sfixed(vec_lsb, parte_inteira, parte_fracionaria);\n',
        '\tconstant s_fixo_msb  : sfixed(parte_inteira downto parte_fracionaria) := to_sfixed(vec_msb, parte_inteira, parte_fracionaria);\n',
        '\tconstant s_fixo_zero : sfixed(parte_inteira downto parte_fracionaria) := to_sfixed(vec_zero, parte_inteira, parte_fracionaria);\n\n',
        '\tconstant u_fixo_min : ufixed(parte_inteira downto parte_fracionaria) := to_ufixed(vec_zero, parte_inteira, parte_fracionaria);\n',
        '\tconstant u_fixo_max : ufixed(parte_inteira downto parte_fracionaria) := to_ufixed(vec_um, parte_inteira, parte_fracionaria);\n',
        '\tconstant u_fixo_lsb : ufixed(parte_inteira downto parte_fracionaria) := to_ufixed(vec_lsb, parte_inteira, parte_fracionaria);\n',
        '\tconstant u_fixo_msb : ufixed(parte_inteira downto parte_fracionaria) := to_ufixed(vec_msb, parte_inteira, parte_fracionaria);\n\n',
    ]
    arquivo.writelines(linhas)


def cria_tipos(arquivo):
    linhas = [
        '\t-- ----------------------------- Definições de tipos ----------------------------\n',
        '\tsubtype s_fixo is sfixed(parte_inteira downto parte_fracionaria);\n'
        '\tsubtype u_fixo is ufixed(parte_inteira downto parte_fracionaria);\n\n'
        '\ttype vec_s_fixo is array (integer range <>) of s_fixo;\n'
        '\ttype vec_u_fixo is array (integer range <>) of u_fixo;\n'
        '\ttype vec_inteiro is array (integer range <>) of integer;\n\n'
        '\ttype mat_s_fixo is array(integer range <>, integer range<>) of s_fixo;\n'
        '\ttype mat_u_fixo is array(integer range <>, integer range<>) of u_fixo;\n\n',
    ]
    arquivo.writelines(linhas)


def escreve_vetor(
    arquivo, vetor, espacos, quantidade_elementos, quantidade_por_linha
):
    tamanho = len(str(quantidade_elementos))
    inicio = ' ' * espacos
    for indice, valor in enumerate(vetor):

        if indice != quantidade_elementos:
            string = f'{str(indice).ljust(tamanho)}=>{valor.argmax()},'
        else:
            string = f'{str(indice).ljust(tamanho)}=>{valor.argmax()}'

        if indice % quantidade_por_linha == 0:
            if indice != quantidade_elementos:
                string = inicio + string
            else:
                string = inicio + string

        if indice % quantidade_por_linha == quantidade_por_linha - 1:
            string = string + '\n'
        else:
            string = string + '\t'

        arquivo.writelines([string])


def escreve_matriz(
    arquivo, matriz, espacos, quantidade_linhas, elementos_por_linha
):
    linhas = []
    tamanho = len(str(quantidade_linhas))
    for id_linha, linha in enumerate(matriz):
        string = ' ' * espacos + f'{str(id_linha).ljust(tamanho)} => ('
        for id_elemento, elemento in enumerate(linha):

            if id_elemento < elementos_por_linha:
                string = (
                    string
                    + f'{id_elemento} => to_sfixed({elemento}, parte_inteira, parte_fracionaria), '
                )
            else:
                string = (
                    string
                    + f'{id_elemento} => to_sfixed({elemento}, parte_inteira, parte_fracionaria))'
                )

        if id_linha < quantidade_linhas:
            string = string + ',\n'
        else:
            string = string + '\n'

        linhas.append(string)
    linhas.append('\t);\n')
    arquivo.writelines(linhas)


def cria_dataset(arquivo, nome, dados):
    arquivo.writelines(
        [
            f'\t-- ---------------------------------- {nome} ----------------------------------\n'
        ]
    )

    # Checa se é vetor ou matriz
    if 'x' in nome:
        quantidade_linhas = dados.shape[0] - 1
        quantidade_caracteristicas = dados.shape[1] - 1
        declaracao = f'\tconstant {nome} : mat_s_fixo({quantidade_linhas} downto 0, {quantidade_caracteristicas} downto 0) := (\n'
        espacos = len(declaracao) + 4

        arquivo.writelines([declaracao])
        escreve_matriz(
            arquivo,
            dados,
            espacos,
            quantidade_linhas,
            quantidade_caracteristicas,
        )
    else:
        quantidade = dados.shape[0] - 1
        declaracao = (
            f'\tconstant {nome} : vec_inteiro({quantidade} downto 0) := (\n'
        )
        espacos = len(declaracao) + 4

        arquivo.writelines([declaracao])
        escreve_vetor(arquivo, dados, espacos, quantidade, 4)
        arquivo.writelines(['\t);\n\n'])


def gera(parte_inteira, parte_fracionaria, seed=42, tamanho_teste=0.33):
    dados = recebe_dados(seed, tamanho_teste)
    nomes = ['x_treino', 'x_teste', 'y_treino', 'y_teste']

    with open('pacote_aux.vhdl', mode='w') as arquivo:
        cria_cabecalho(arquivo)
        cria_costantes(arquivo, parte_inteira, parte_fracionaria)
        cria_tipos(arquivo)
        for nome, dado in zip(nomes, dados):
            cria_dataset(arquivo, nome, dado)

        arquivo.writelines(['end package pacote_aux;\n'])
