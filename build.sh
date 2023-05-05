#!/bin/bash

set -e
GHDLFLAGS=--std=08

# Checa módulos a serem compilados
ARGC=$#
if [[ $ARGC -gt 0 ]]
then
    MODULOS=()
    for MODULO in $@; do
        MODULOS+=($MODULO)
    done
else
    MODULOS=("sqrt")
fi

echo Analisando ${MODULOS[@]}

# Cria diretório de build e copia arquivos de fonte para lá
mkdir -p build
for MODULO in ${MODULOS[@]}; do
    for ARQUIVO in ${MODULO}.vhdl ${MODULO}_tb.vhdl; do
        echo cp ${MODULO}/${ARQUIVO} build/${ARQUIVO}
        cp ${MODULO}/${ARQUIVO} build/${ARQUIVO}
    done
done

cd build

for MODULO in ${MODULOS[@]}; do
    
    # Compila VHDL para ARQUIVOs de objeto
    for ARQUIVO in ${MODULO}.vhdl ${MODULO}_tb.vhdl; do
        echo ghdl -a ${GHDLFLAGS} ${ARQUIVO}
        ghdl -a ${GHDLFLAGS} ${ARQUIVO}
    done

    # Elabora bancada de testes
    echo ghdl -e ${GHDLFLAGS} ${MODULO}_tb 
    ghdl -e ${GHDLFLAGS} ${MODULO}_tb

    # Executa bancada de testes
    echo ghdl -r ${GHDLFLAGS} ${MODULO}_tb --vcd=${MODULO}_tb.vcd
    ghdl -r ${GHDLFLAGS} ${MODULO}_tb --vcd=${MODULO}_tb.vcd

    mkdir -p ../resultados/${MODULO}

    echo mv ${MODULO}.csv ../resultados/${MODULO}/${MODULO}.csv
    mv ${MODULO}.csv ../resultados/${MODULO}/${MODULO}.csv
    echo mv ${MODULO}.vcd ../resultados/${MODULO}/${MODULO}.vcd
    mv ${MODULO}_tb.vcd ../resultados/${MODULO}/${MODULO}_tb.vcd

done
