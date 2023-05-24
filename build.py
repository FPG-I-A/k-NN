import argparse
import contextlib
import os
import shutil
from pathlib import Path
from subprocess import DEVNULL, call

from colorama import Fore, Style
from colorama import init as colorama_init

from pacote import gera


class Mensagens:
    def erro(string, parser):
        print(Fore.RED + string + Style.RESET_ALL)
        parser.print_help()
        exit(1)

    def info(string):
        print(Fore.GREEN + string + Style.RESET_ALL)

    def comando(string, tipo=1):
        match tipo:
            case 1:
                print(Fore.CYAN + string + Style.RESET_ALL)
            case 2:
                print(Fore.BLUE + string + Style.RESET_ALL)
            case 3:
                print(Fore.RED + string + Style.RESET_ALL)
            case 4:
                print(Fore.YELLOW + string + Style.RESET_ALL)


@contextlib.contextmanager
def working_directory(path):
    prev_cwd = Path.cwd()
    os.chdir(path)
    try:
        yield
    finally:
        os.chdir(prev_cwd)


def recebe_argumentos():
    parser = argparse.ArgumentParser(
        prog=Path(__file__).stem,
        description='Script de build para projeto k-nn',
    )
    parser.add_argument(
        '-m',
        '--modulo',
        action='append',
        help='Nome do módulo para analisar, não pode ser usado com -t.',
    )
    parser.add_argument(
        '-t',
        '--todos',
        action='store_true',
        help='Analisa todos os módulos, não pode ser usado com -m.',
    )
    parser.add_argument(
        '-w',
        '--wave',
        action='store_true',
        help='Abrir formas de ondas utilizando gtkwave no final da análise de cada módulo.',
    )
    parser.add_argument(
        '-l',
        '--limpa',
        action='store_true',
        help='Limpa diretório de build após terminar.',
    )
    parser.add_argument(
        '-v',
        '--verboso',
        action='store_true',
        help='Resultados mais verbosos.',
    )
    parser.add_argument(
        '-i',
        '--parte_inteira',
        action='store',
        help='Quantidade de bits na parte real da representação de ponto fixo. Valor padrão: 3',
    )
    parser.add_argument(
        '-f',
        '--parte_fracionaria',
        action='store',
        help='Quantidade de bits na parte fracionaria da representação de ponto fixo. Valor padrão: 12',
    )
    parser.add_argument(
        '-s',
        '--seed',
        action='store',
        help='Seed do gerador de números aleatórios para separação de conjunto de treino e teste. Valor padrão: 42',
    )
    parser.add_argument(
        '-p',
        '--percentual_teste',
        action='store',
        help='Percentual do dataset utilizado para teste. Valor padrão: 33.',
    )
    args = parser.parse_args()
    if args.modulo is not None and args.todos:
        Mensagens.erro(
            'As opções -m e -t não podem ser utilizadas em conjunto.', parser
        )
    if args.modulo is None and not args.todos:
        Mensagens.erro(
            'Ao menos um dentre -t e -m deve ser utilizado.', parser
        )

    return parser, args


def ajusta_padroes(args, parser):

    if args.parte_inteira is not None:
        try:
            parte_inteira = int(args.parte_inteira)
        except ValueError:
            Mensagens.erro(
                f'O valor de parte_inteira deve ser um número inteiro, mas você forneceu {args.parte_inteira}',
                parser,
            )
    else:
        parte_inteira = 3

    if args.parte_fracionaria is not None:
        try:
            parte_fracionaria = int(args.parte_fracionaria)
        except ValueError:
            Mensagens.erro(
                f'O valor de parte_fracionaria deve ser um número inteiro, mas você forneceu {args.parte_fracionaria}',
                parser,
            )
    else:
        parte_fracionaria = 12

    if args.seed is not None:
        try:
            seed = int(args.seed)
        except ValueError:
            Mensagens.erro(
                f'O valor de seed deve ser um número inteiro, mas você forneceu {args.seed}',
                parser,
            )
    else:
        seed = 42

    if args.percentual_teste is not None:
        try:
            percentual_teste = int(args.percentual_teste) / 100
            if percentual_teste > 1 or percentual_teste < 0:
                raise ValueError
        except ValueError:
            Mensagens.erro(
                f'O valor de percentual_teste deve ser um número inteiro entre 0 e 100, mas você forneceu {args.percentual_teste}',
                parser,
            )
    else:
        percentual_teste = 33

    return parte_inteira, parte_fracionaria, seed, percentual_teste


def ajusta_dependencia(modulos, dependente, *dependencias):
    for dependencia in dependencias:
        try:
            modulos.append(
                modulos.pop(modulos.index(dependencia))
            )   # coloca o item ao final da lista
        except ValueError:
            modulos.append(dependencia)
    modulos.append(
        modulos.pop(modulos.index(dependente))
    )   # coloca o item ao final da lista
    return modulos


def seleciona_modulos(args, parser):
    if args.todos:
        modulos = [
            caminho
            for caminho in Path('modulos').glob('*')
            if caminho.is_dir()
        ]
    else:
        modulos = args.modulo
        modulos = [Path('modulos', modulo) for modulo in modulos]
        for modulo in modulos:
            if not modulo.is_dir():
                Mensagens.erro(f'Módulo {modulo.stem} não existe.', parser)

    # Garante que os módulos que dependem de outros sejam analisados
    # após suas dependências
    dict_deps = {
        Path('modulos', 'argmin'): [Path('modulos', 'insere')],
    }
    for dependente, dependencias in dict_deps.items():
        if dependente in modulos:
            modulos = ajusta_dependencia(modulos, dependente, *dependencias)
    return modulos


def chama_comando(comando, parser, verboso):
    if verboso:
        codigo = call(comando.split(' '))
    else:
        codigo = call(comando.split(' '), stdout=DEVNULL, stderr=DEVNULL)
    if codigo != 0:
        Mensagens.erro(f'\tComando retornou o código {codigo}', parser)


def move_arquivos(modulos):
    dir_build = Path('build')
    dir_build.mkdir(exist_ok=True)

    # shutil.copy(
    #    Path('modulos', 'pacote_aux.vhdl'), dir_build / 'pacote_aux.vhdl'
    # )
    for modulo in modulos:
        nome_arq = modulo + '.vhdl'
        nome_tb = modulo + '_tb.vhdl'
        shutil.copy(Path('modulos', modulo, nome_arq), dir_build / nome_arq)
        shutil.copy(Path('modulos', modulo, nome_tb), dir_build / nome_tb)


def cria_pacote(parte_inteira, parte_fracionaria, seed, percentual_teste):
    Mensagens.info('Gerando arquivo da biblioteca')
    gera(parte_inteira, parte_fracionaria, seed, percentual_teste)


def compila_pacote(argumentos, parser, verboso):
    Mensagens.info('Analisando a biblioteca:')
    comando = f'ghdl -a {argumentos} pacote_aux.vhdl'

    Mensagens.comando(f'\t{comando}')
    chama_comando(comando, parser, verboso)


def compila_modulo(modulo, argumentos, parser, verboso):
    Mensagens.info(f'\nAnalisando módulo {modulo}:')

    arquivos = [modulo + '.vhdl', modulo + '_tb.vhdl']

    # Compila módulo e tb
    for arquivo in arquivos:
        comando = f'ghdl -a {argumentos} {arquivo}'
        Mensagens.comando(f'\t{comando}')
        chama_comando(comando, parser, verboso)

    arquivo = arquivos[1].split('.')[0]

    # Elabora tb
    comando = f'ghdl -e {argumentos} {arquivo}'
    Mensagens.comando(f'\t{comando}', 2)
    chama_comando(comando, parser, verboso)

    # Executa tb
    comando = f'ghdl -r {argumentos} {arquivo} --wave={modulo}_tb.ghw'
    Mensagens.comando(f'\t{comando}', 3)
    chama_comando(comando, parser, verboso)


def gera_resultados(modulo):
    pasta_resultados = Path('..', 'resultados')

    for arquivo in [modulo + '.csv', modulo + '_tb.ghw']:

        resultados_modulo = pasta_resultados / modulo
        resultados_modulo.mkdir(exist_ok=True, parents=True)

        if Path(arquivo).is_file():
            shutil.move(arquivo, resultados_modulo / arquivo)


def mostra_ondas(modulo, parser, verboso):
    ghw = Path('resultados', modulo, f'{modulo}_tb.ghw')
    gtkw = Path('gtkw', f'{modulo}.gtkw')
    comando = f'gtkwave {ghw} -a {gtkw}'
    Mensagens.comando(f'\t{comando}', 4)
    chama_comando(comando, parser, verboso)


if __name__ == '__main__':
    colorama_init()
    parser, args = recebe_argumentos()

    parte_inteira, parte_fracionaria, seed, percentual_teste = ajusta_padroes(
        args, parser
    )
    modulos = seleciona_modulos(args, parser)
    modulos = list(map(lambda p: p.stem, modulos))

    Mensagens.info(
        f'Módulos a serem analisados: {" ".join([modulo for modulo in modulos])}'
    )

    move_arquivos(modulos)
    with working_directory('build'):
        flags = '--std=08'
        cria_pacote(parte_inteira, parte_fracionaria, seed, percentual_teste)
        compila_pacote(flags, parser, args.verboso)
        for modulo in modulos:
            compila_modulo(modulo, flags, parser, args.verboso)

            gera_resultados(modulo)

            with working_directory('..'):
                if args.wave:
                    mostra_ondas(modulo, parser, args.verboso)

        # Remove biblioteca work
        for arquivo in Path('.').glob('work-*.cf'):
            arquivo.unlink()

    if args.limpa:
        shutil.rmtree('build')
