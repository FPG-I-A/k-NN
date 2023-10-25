from math import modf
from pathlib import Path

import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split


def recebe_dados(seed, tamanho_teste):
    # Baixa conjunto de dados e salva dados crus
    dados_crus = Path('..', 'Dados', 'iris.csv')

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
    dados = train_test_split(
        x, y, test_size=tamanho_teste, random_state=seed
    )
    return dados


def cria_cabecalho(arquivo):
    linhas = [
        'library ieee;\n',
        'use ieee.std_logic_1164.all;\n',
        'use ieee.numeric_std.all;\n\n',
        'package pacote_aux is\n\n',
    ]
    arquivo.writelines(linhas)


def cria_costantes(arquivo, inteira, fracionaria):
    linhas = [
        f'\t---------------------------- Definições de constantes --------------------------\n',
        f'\tconstant parte_inteira     : integer := {inteira};\n',
        f'\tconstant parte_fracionaria : integer := -{fracionaria};\n',
        f'\tconstant tamanho           : integer := parte_inteira - parte_fracionaria + 1;\n\n',
        '\t-- ----------------------------- Definições de tipos ----------------------------\n',
        '\tsubtype s_fixo is signed(tamanho - 1 downto 0);\n'
        '\ttype vec_s_fixo is array (integer range <>) of s_fixo;\n'
        '\ttype vec_inteiro is array (integer range <>) of integer;\n'
        '\ttype mat_s_fixo is array(integer range <>, integer range<>) of s_fixo;\n\n'
        '\tconstant s_fixo_max : s_fixo := (tamanho - 1 => \'0\', others => \'1\');\n',
        '\tconstant s_fixo_min : s_fixo := (tamanho - 1 => \'1\', others => \'0\');\n',
        '\tconstant s_fixo_lsb : s_fixo := (0 => \'1\', others => \'0\');\n',
        '\tconstant s_fixo_msb : s_fixo := s_fixo_min;\n',
        '\tconstant s_fixo_zero : s_fixo := (others => \'0\');\n\n',
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
    arquivo.writelines(['\n'])


def escreve_matriz(
    arquivo, matriz, espacos, quantidade_linhas, elementos_por_linha, parte_inteira, parte_fracionaria
):
    linhas = []
    tamanho = len(str(quantidade_linhas))
    for id_linha, linha in enumerate(matriz):
        string = ' ' * espacos + f'{str(id_linha).ljust(tamanho)} => ('
        for id_elemento, elemento in enumerate(linha):

            if id_elemento < elementos_por_linha:
                string = (
                    string
                    + f'{id_elemento} => "{float_para_fixo(elemento, parte_inteira, parte_fracionaria)}", '
                )
            else:
                string = (
                    string
                    + f'{id_elemento} => "{float_para_fixo(elemento, parte_inteira, parte_fracionaria)}")'
                )

        if id_linha < quantidade_linhas:
            string = string + ',\n'
        else:
            string = string + '\n'

        linhas.append(string)
    linhas.append('\t);\n\n')
    arquivo.writelines(linhas)


def cria_dataset(arquivo, nome, dados, amostras_treino, amostras_teste, parte_inteira, parte_fracionaria):
    arquivo.writelines(
        [
            f'\t-- ---------------------------------- {nome} ----------------------------------\n'
        ]
    )

    # Checa se é vetor ou matriz
    if 'x' in nome:
        quantidade_caracteristicas = dados.shape[1] - 1
        if 'treino' in nome:
            declaracao = f'\tconstant {nome} : mat_s_fixo(amostras_treino - 1 downto 0, n_caracteristicas - 1 downto 0) := (\n'
        else:
            declaracao = f'\tconstant {nome} : mat_s_fixo(amostras_teste - 1 downto 0, n_caracteristicas -1 downto 0) := (\n'
        espacos = len(declaracao) + 4

        arquivo.writelines([declaracao])
        escreve_matriz(
            arquivo,
            dados,
            espacos,
            dados.shape[0] - 1,
            quantidade_caracteristicas,
            parte_inteira, 
            parte_fracionaria
        )
    else:
        quantidade = dados.shape[0] - 1
        if 'treino' in nome:
            declaracao = f'\tconstant {nome} : vec_inteiro(amostras_treino - 1 downto 0) := (\n'
        else:
            declaracao = f'\tconstant {nome} : vec_inteiro(amostras_teste - 1 downto 0) := (\n'
        espacos = len(declaracao) + 4

        arquivo.writelines([declaracao])
        escreve_vetor(arquivo, dados, espacos, quantidade, 4)
        arquivo.writelines(['\t);\n\n'])

def float_para_fixo(numero, parte_inteira, parte_fracionaria):
    if numero >= 2 ** parte_inteira:
        return '0' + '1' * (parte_inteira + parte_fracionaria)

    n_frac, n_intei = modf(abs(numero) )
    inteira = []
    while n_intei >= 1:
        # print(n_intei, inteira, n_intei % 2)
        inteira.insert(0, str(int(n_intei % 2)))
        n_intei //= 2
        

    fracionaria = []
    for i in range(parte_fracionaria):
        if (valor_bit := 2 ** (-i - 1)) <= n_frac:
            n_frac -= valor_bit
            fracionaria.append('1')
        else:
            fracionaria.append('0')
        if n_frac == 0:
            break
    
    while len(inteira) < parte_inteira:
        inteira.insert(0, '0')
    
    while len(fracionaria) < parte_fracionaria:
        fracionaria.append('0')
    if numero >= 0:
        return '0' + ''.join(inteira) + ''.join(fracionaria)
    else:
        comp_um = '1' + ''.join(['0' if bit == '1' else '1' for bit in inteira])  + ''.join(['0' if bit == '1' else '1' for bit in fracionaria])
        carry = '1'
        comp_dois = []
        for bit in comp_um[::-1]:
            if bit == '1' and carry == '1':
                comp_dois.insert(0, '0')
                carry = '1'
            elif bit == '1' or carry =='1':
                comp_dois.insert(0, '1')
                carry = '0'
            else:
                comp_dois.insert(0, '0')
                carry = '0'
        return ''.join(comp_dois)



def gera(parte_inteira, parte_fracionaria, seed=42, tamanho_teste=0.33):
    dados = recebe_dados(seed, tamanho_teste)
    nomes = ['x_treino', 'x_teste', 'y_treino', 'y_teste']

    with open('pacote_aux.vhdl', mode='w') as arquivo:
        cria_cabecalho(arquivo)
        cria_costantes(arquivo, parte_inteira, parte_fracionaria)

        amostras_treino = dados[0].shape[0]
        amostras_teste = dados[1].shape[0]
        n_classes = dados[3].shape[1]
        n_caracteristicas = dados[0].shape[1]

        linhas = [
            f'\t-- ---------------------------------- Dataset ----------------------------------\n',
            f'\tconstant amostras_treino   : integer := {amostras_treino};\n'
            f'\tconstant amostras_teste    : integer := {amostras_teste};\n'
            f'\tconstant n_classes         : integer := {n_classes};\n'
            f'\tconstant n_caracteristicas : integer := {n_caracteristicas};\n\n',
        ]
        
        linha = f'\tconstant maior_por_caracteristica : vec_s_fixo({n_caracteristicas} - 1 downto 0) := ('
        for i in range(dados[0].shape[1]):
            linha = linha + f'{i}=>"{float_para_fixo(np.max(dados[0][:,i]), parte_inteira, parte_fracionaria)}", '
        linha =  linha[:-2] + ');\n'
        linhas.append(linha)
        
        linha = f'\tconstant menor_por_caracteristica : vec_s_fixo({n_caracteristicas} - 1 downto 0) := ('
        for i in range(dados[0].shape[1]):
            linha = linha + f'{i}=>"{float_para_fixo(np.min(dados[0][:,i]), parte_inteira, parte_fracionaria)}", '
        linha =  linha[:-2] + ');\n\n'
        linhas.append(linha)

        arquivo.writelines(linhas)

        x_treino = dados[0]
        for i in range(x_treino.shape[1]):
            x_treino[:, i] = (x_treino[:, i] - np.min(x_treino[:, i])) / (
                np.max(x_treino[:, i]) - np.min(x_treino[:, i])
            )
        for nome, dado in zip(nomes, dados):
            cria_dataset(arquivo, nome, dado, amostras_treino, amostras_teste, parte_inteira, parte_fracionaria)

        arquivo.writelines(['end package pacote_aux;\n'])


if __name__ == '__main__':
    gera(3, 14)
    