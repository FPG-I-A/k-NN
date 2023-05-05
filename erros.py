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


def processa_linha(linha):
    str_x, str_sqrt_x = linha.split(';')
    return fixo_para_float(str_x), fixo_para_float(str_sqrt_x)


def sqrt(x, *args):
    return math.sqrt(x)


def norm(x):
    return x / 2


if __name__ == '__main__':
    modulo = parse_args()
    funcao = None
    match modulo:
        case 'sqrt':
            funcao = sqrt
        case 'norm':
            funcao = norm

    erros = []
    with open(Path('resultados', modulo, modulo + '.csv')) as arquivo:
        cabecalho = arquivo.readline()
        dados = map(lambda string: string[:-1], arquivo.readlines())
        x, calculado = zip(*map(processa_linha, dados))
        reais = map(funcao, x)
        reais = list(reais)
        calculado = list(calculado)
        erros = list(map(lambda a, b: a - b, calculado, reais))

    print(f'Erro médio: {mean(erros):.14f}')
    print(
        f'Erro médio normalizado: {100 * mean(map(lambda a, b: a / b if b != 0 else a, erros, x)):.12%}'
    )
    print(f'Desvio padrão do erro: {stdev(erros):.14f}')
