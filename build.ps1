Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Checa módulos a serem compilados
$MODULOS = @()
if ($args.Count -gt 0) {
    for ($i = 0; $i -lt $args.Count; $i++) {
        $MODULOS += $args[$i]
    }
} else {
    $MODULOS = @("sqrt", "norm")
}

$junto = ($MODULOS -join ", ")
Write-Host "Módulos a serem analisados: $junto" -ForeGroundColor Green

# Cria diretório de build e copia arquivos de fonte para lá
if (-Not (Test-Path -Path build)) { New-Item -ItemType Directory -Path build | Out-Null }

Write-Host "Copiando arquivos para pasta de build:" -ForeGroundColor Green
Write-Host "    Biblioteca:" -ForeGroundColor Magenta
Write-Host "        Copy-Item pacote_aux.vhdl build/pacote_aux.vhdl" -ForeGroundColor Cyan
Copy-Item pacote_aux.vhdl build/pacote_aux.vhdl
foreach (${MODULO} in $MODULOS) {
    Write-Host "    Módulo ${MODULO}:" -ForeGroundColor Magenta
    foreach (${ARQUIVO} in "$MODULO.vhdl", "${MODULO}_tb.vhdl") {
        Write-Host "        Copy-Item "${MODULO}/${ARQUIVO}" "build/$ARQUIVO"" -ForeGroundColor Cyan
        Copy-Item "${MODULO}/${ARQUIVO}" "build/$ARQUIVO"
    }
}

Set-Location build
Write-Host "Analisando a biblioteca:" -ForeGroundColor Green
Write-Host "    ghdl -a --std=08 pacote_aux.vhdl" -ForeGroundColor Blue
ghdl -a --std=08 pacote_aux.vhdl

foreach ($MODULO in $MODULOS) {
    # Compila VHDL para arquivos de objeto
    Write-Host "Analisando módulo ${MODULO}:" -ForeGroundColor Green
    foreach ($ARQUIVO in "$MODULO.vhdl", "${MODULO}_tb.vhdl") {
        Write-Host "    ghdl -a --std=08 $ARQUIVO" -ForeGroundColor Blue
        ghdl -a --std=08 $ARQUIVO
    }

    # Elabora bancada de testes
    Write-Host "    ghdl -e --std=08 ${MODULO}_tb" -ForeGroundColor Yellow
    ghdl -e --std=08 "${MODULO}_tb"

    # Executa bancada de testes
    Write-Host "    ghdl -r --std=08 "${MODULO}_tb" --vcd=${MODULO}_tb.vcd" -ForeGroundColor Red
    ghdl -r --std=08 "${MODULO}_tb" --vcd="${MODULO}_tb.vcd" > $null

    if (-Not (Test-Path -Path ../resultados/$MODULO)) { New-Item -ItemType Directory -Path "../resultados/$MODULO" | Out-Null }

    if ((Test-Path -Path ../resultados/$MODULO/$MODULO.csv)) {Remove-Item "../resultados/$MODULO/$MODULO.csv"}
    Write-Host "    Move-Item $MODULO.csv ../resultados/$MODULO/$MODULO.csv" -ForeGroundColor Blue
    Move-Item "$MODULO.csv" "../resultados/$MODULO/$MODULO.csv"
    if ((Test-Path -Path ../resultados/$MODULO/${MODULO}_tb.vcd)) {Remove-Item "../resultados/$MODULO/${MODULO}_tb.vcd"}
    Write-Host "    Move-Item ${MODULO}_tb.vcd ../resultados/$MODULO/${MODULO}_tb.vcd" -ForeGroundColor Blue
    Move-Item "${MODULO}_tb.vcd" "../resultados/$MODULO/${MODULO}_tb.vcd"
}

Write-Host "Removendo pasta de build:" -ForeGroundColor Green
Set-Location ..
Write-Host "    Remove-Item -Recurse build" -ForeGroundColor Blue
Remove-Item -Recurse build

Write-Host "Análise de módulos finalizada, arquivos gerados estão na pasta resultados." -ForeGroundColor Green
