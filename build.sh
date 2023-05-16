#!/bin/bash

set -e
GHDLFLAGS=--std=08
CIANO='\033[38;2;139;233;253m'
VERDE='\033[38;2;80;250;123m'
LARANJA='\033[38;2;255;184;108m'
ROSA='\033[38;2;255;121;198m'
ROXO='\033[38;2;189;147;249m'
VERMELHO='\033[38;2;255;85;85m'
AMARELO='\033[38;2;241;250;140m'

# Checa módulos a serem compilados
ARGC=$#
if [[ $ARGC -gt 0 ]]
then
    MODULOS=()
    for MODULO in $@; do
        MODULOS+=($MODULO)
    done
else
    MODULOS=("sqrt" "norm" "argmin")
fi

# Checa se módulos auxiliares são necessários
for i in "${MODULOS[@]}"
do
    if [ "$i" == "argmin" ] ; then
        MODULOS=("insere" "${MODULOS[@]}")
        echo -e "${LARANJA}Módulo insere adicionado pois argmin depende dele."
    fi
done

printf -v junto '%s, ' ${MODULOS[@]}
echo -e "${VERDE}Módulos a serem analisados: ${junto::-2}"

# Cria diretório de build e copia arquivos de fonte para lá
mkdir -p build
echo -e "${VERDE}Copiando arquivos para pasta de build:"
echo -e "${ROSA}  Biblioteca:"
echo -e "${CIANO}    cp pacote_aux.vhdl build/pacote_aux.vhdl"
cp pacote_aux.vhdl build/pacote_aux.vhdl
for MODULO in ${MODULOS[@]}; do
    echo -e "${ROSA}  Módulo ${MODULO}:"
    for ARQUIVO in ${MODULO}.vhdl ${MODULO}_tb.vhdl; do
        echo -e "${CIANO}    cp ${MODULO}/${ARQUIVO} build/${ARQUIVO}"
        cp ${MODULO}/${ARQUIVO} build/${ARQUIVO}
    done
done

cd build
echo -e "${VERDE}Analisando a biblioteca:"
echo -e "  ${ROXO}ghdl -a ${GHDLFLAGS} pacote_aux.vhdl"
ghdl -a ${GHDLFLAGS} pacote_aux.vhdl

for MODULO in ${MODULOS[@]}; do
    
    echo -e "${VERDE}Analisando módulo ${MODULO}:"
    # Compila VHDL para ARQUIVOs de objeto
    for ARQUIVO in ${MODULO}.vhdl ${MODULO}_tb.vhdl; do
        echo -e "${ROXO}  ghdl -a ${GHDLFLAGS} ${ARQUIVO}"
        ghdl -a ${GHDLFLAGS} ${ARQUIVO}
    done

    # Elabora bancada de testes
    echo -e "${LARANJA}  ghdl -e ${GHDLFLAGS} ${MODULO}_tb"
    ghdl -e ${GHDLFLAGS} ${MODULO}_tb

    # Executa bancada de testes
    echo -e "${VERMELHO}  ghdl -r ${GHDLFLAGS} ${MODULO}_tb --wave=${MODULO}_tb.ghw"
    ghdl -r ${GHDLFLAGS} ${MODULO}_tb --wave=${MODULO}_tb.ghw

    mkdir -p ../resultados/${MODULO}

    if test -f "${MODULO}.csv"; then
        echo -e "${CIANO}  mv ${MODULO}.csv ../resultados/${MODULO}/${MODULO}.csv"
        mv ${MODULO}.csv ../resultados/${MODULO}/${MODULO}.csv
    fi;
    if test -f "${MODULO}_tb.ghw"; then
        echo -e "${CIANO}  mv ${MODULO}.ghw ../resultados/${MODULO}/${MODULO}_tb.ghw"
        mv ${MODULO}_tb.ghw ../resultados/${MODULO}/${MODULO}_tb.ghw
    fi;

done

echo -e "${VERDE}Removendo pasta de build:"
echo -e "${CIANO}  rm -rf build"
rm -rf build

echo -e "${VERDE}Análise de módulos finalizada, arquivos gerados estão na pasta resultados."
