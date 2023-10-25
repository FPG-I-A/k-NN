import getopt
import math
import sys
from pathlib import Path
from statistics import mean, stdev


def ajuda():
    print('Script python para verificação de erros de aproximação.')
    print('Uso:')
    print('\tpython erros.py -m {modulo} [-h]')
    print('\tmodulo: string := nome do módulo a ser testado')
    print('Argumentos opcionais:')
    print('\t-h: mostra esta mensagem ')


def parse_args():
    optlist, args = getopt.gnu_getopt(sys.argv[1:], 'm:i:f:h')
    modulo = None
    for opcao, argumento in optlist:
        if opcao == '-h':
            ajuda()
            sys.exit(0)
        elif opcao == '-m':
            modulo = argumento
        else:
            ajuda()
            print(f'\nERRO: Opção {opcao} inválida.')
            sys.exit(1)

    if modulo is None:
        ajuda()
        print('\nERRO: A opção -m é obrigatória mas não foi fornecida.')
        sys.exit(1)
    else:
        return modulo


def fixo_para_float(fixo):
    inteiro, fracionario = fixo.split('.')
    exp_max = len(inteiro) - 1
    parte_inteira = sum(
        [int(bit) * 2 ** (exp_max - ind) for ind, bit in enumerate(inteiro)]
    )
    parte_fracionaria = sum(
        [int(bit) * 2 ** (-ind - 1) for ind, bit in enumerate(fracionario)]
    )
    return parte_inteira + parte_fracionaria


def erros_sqrt():
    def processa_linha(linha):
        return list(map(fixo_para_float, linha.split(';')))

    with open(Path('resultados', 'sqrt', 'sqrt.csv')) as arquivo:
        arquivo.readline()
        dados = map(lambda string: string[:-1], arquivo.readlines())
        x, calculado = zip(*map(processa_linha, dados))
        reais = list(map(math.sqrt, x))
        calculado = list(calculado)
        erros = list(map(lambda a, b: a - b, calculado, reais))

    print(f'Erro médio: {mean(erros):.2}')
    print(
        f'Erro médio normalizado: {100 * mean(map(lambda a, b: a / b if b != 0 else a, erros, x)):.2%}'
    )
    print(f'Desvio padrão do erro: {stdev(erros):.2f}')


def erros_distancia():
    def distancia(vec_x, vec_y):
        resultado = 0
        for x, y in zip(vec_x, vec_y):
            resultado += (x - y) * (x - y)
        return abs(resultado)

    with open(Path('resultados', 'distancias', 'distancias.csv')) as arquivo:
        arquivo.readline()
        erros = []
        valores_x = []
        valores_y = []
        reais = []
        calculados = []
        for linha in arquivo.readlines():
            valores = linha.split(';')
            n_carac = int((len(valores) - 1) / 2)
            calculado = fixo_para_float(valores[-1][:-1])
            x = list(map(fixo_para_float, valores[:n_carac]))
            y = list(map(fixo_para_float, valores[n_carac:-1]))
            real = distancia(x, y)
            erros.append(calculado - real)
            valores_x.append(x)
            valores_y.append(y)
            reais.append(real)
            calculados.append(calculado)

    print(f'Erro médio: {mean(erros):.2}')
    print(f'Desvio padrão do erro: {stdev(erros):.2f}')


def acuracia():
    acertos = 0
    quantidade = 0
    with open(Path('resultados', 'knn', 'knn.csv'), mode='r') as arquivo:
        arquivo.readline()
        for linha in arquivo.readlines():
            quantidade += 1
            rotulo, predito = list(map(lambda valor: int(valor), linha.split(';')))
            if rotulo == predito:
                acertos += 1    
    print(f'Acurácia no conjunto de testes: {acertos / quantidade:.2%}')

if __name__ == '__main__':
    modulo = parse_args()
    funcao = None
    match modulo:
        case 'sqrt':
            erros_sqrt()
        case 'distancias':
            erros_distancia()
        case 'knn':
            acuracia()