@echo off
title Configurar IP Fixo - Sistema Facial

:: Captura do caractere ESC para usar cores
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "ESC=%%b"
setlocal EnableDelayedExpansion
set "AM=%ESC%[93m"
set "VD=%ESC%[92m"
set "VM=%ESC%[91m"
set "CI=%ESC%[96m"
set "RS=%ESC%[0m"

:: Numero maximo de IPs secundarios que o programa aceita
set "MAX_AUX=10"

:: ============================================================
:: Precisa ser administrador
:: ============================================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    call :cabecalho "ATENCAO"
    echo %VM%Este programa precisa ser executado como ADMINISTRADOR.%RS%
    echo.
    echo Como fazer:
    echo   1. Feche esta janela
    echo   2. Clique com o botao DIREITO no arquivo .bat
    echo   3. Escolha "Executar como administrador"
    echo.
    pause
    exit /b
)

:: ============================================================
:: PASSO 1 - Escolher a conexao
:: ============================================================
:passo1
call :cabecalho "PASSO 1 de 4 - Escolha a conexao de rede"
echo Estas sao as conexoes de rede deste computador:
echo.
set N=0
for /f "tokens=1,* delims=|" %%a in ('powershell -NoProfile -Command "Get-NetAdapter | Sort-Object Name | ForEach-Object { $_.Name + '|' + $_.Status }"') do (
    set /a N+=1
    set "CON_!N!=%%a"
    if /i "%%b"=="Up" (
        echo    [!N!] %%a   - %VD%CONECTADA%RS%
    ) else (
        echo    [!N!] %%a   - %AM%sem conexao%RS%
    )
)
if %N%==0 (
    echo %VM%Nenhuma conexao encontrada automaticamente.%RS%
    set /p "NOME_CONEXAO=Digite o nome exato da conexao - ex: Ethernet: "
    if not defined NOME_CONEXAO goto passo1
    goto lerConfig
)
echo.
set "ESCOLHA="
set /p "ESCOLHA=Digite o NUMERO da conexao e aperte ENTER: "
if not defined ESCOLHA goto passo1
for /f "delims=0123456789" %%x in ("%ESCOLHA%") do goto numeroInvalido
if not defined CON_%ESCOLHA% goto numeroInvalido
set "NOME_CONEXAO=!CON_%ESCOLHA%!"
goto lerConfig

:numeroInvalido
echo.
echo %VM%Numero invalido. Digite apenas um dos numeros da lista.%RS%
pause
goto passo1

:: Le o IP, mascara e gateway que a conexao esta usando agora
:lerConfig
set "IP_ATUAL="
set "MASC_ATUAL="
set "GW_ATUAL="
for /f "delims=" %%a in ('powershell -NoProfile -Command "$a='%NOME_CONEXAO%'; $c=Get-NetIPConfiguration -InterfaceAlias $a -EA 0; $i=$c.IPv4Address | Select-Object -First 1; $g=$c.IPv4DefaultGateway | Select-Object -First 1; if($i){ 'IP_ATUAL='+$i.IPAddress; $p=$i.PrefixLength; 'MASC_ATUAL='+((0..3 | ForEach-Object { $b=[math]::Min(8,[math]::Max(0,$p-8*$_)); 256-[math]::Pow(2,8-$b) }) -join '.') }; if($g){ 'GW_ATUAL='+$g.NextHop }"') do set "%%a"

:: ============================================================
:: PASSO 2 - IP fixo, mascara e gateway
:: ============================================================
:passo2
call :cabecalho "PASSO 2 de 4 - IP fixo deste computador"
echo Conexao escolhida: %CI%%NOME_CONEXAO%%RS%
if defined IP_ATUAL echo IP que ele esta usando agora: %CI%%IP_ATUAL%%RS%
echo.
set "IP_PRINCIPAL="
if defined IP_ATUAL (
    set /p "IP_PRINCIPAL=%AM%>%RS% Aperte ENTER para manter !IP_ATUAL! ou digite outro IP: "
) else (
    set /p "IP_PRINCIPAL=%AM%>%RS% Digite o IP fixo - ex: 192.168.0.50: "
)
if not defined IP_PRINCIPAL set "IP_PRINCIPAL=%IP_ATUAL%"
if not defined IP_PRINCIPAL (
    echo %VM%O IP e obrigatorio.%RS%
    pause
    goto passo2
)
call :validaIP "%IP_PRINCIPAL%" || goto passo2

:: So testa se o IP esta em uso quando for diferente do atual
if "%IP_PRINCIPAL%"=="%IP_ATUAL%" goto mascara
echo Verificando se o IP %IP_PRINCIPAL% ja esta em uso na rede...
ping -4 -n 1 -w 1000 %IP_PRINCIPAL% | findstr /i "TTL" >nul
if %errorlevel%==0 (
    echo.
    echo %VM%O IP %IP_PRINCIPAL% ja esta sendo usado por outro aparelho.%RS%
    echo Escolha outro IP.
    pause
    goto passo2
)
echo %VD%OK, IP livre.%RS%

:mascara
echo.
set "PADRAO=255.255.255.0"
if defined MASC_ATUAL set "PADRAO=%MASC_ATUAL%"
set "MASCARA_PRINCIPAL="
set /p "MASCARA_PRINCIPAL=%AM%>%RS% Mascara [ENTER = %PADRAO%]: "
if not defined MASCARA_PRINCIPAL set "MASCARA_PRINCIPAL=%PADRAO%"
call :validaIP "%MASCARA_PRINCIPAL%" || goto mascara

:gateway
echo.
echo O GATEWAY e o IP do roteador/modem da rede.
set "GATEWAY_PRINCIPAL="
if defined GW_ATUAL (
    set /p "GATEWAY_PRINCIPAL=%AM%>%RS% Gateway [ENTER = !GW_ATUAL!]: "
) else (
    set /p "GATEWAY_PRINCIPAL=%AM%>%RS% Digite o gateway - ex: 192.168.0.1: "
)
if not defined GATEWAY_PRINCIPAL set "GATEWAY_PRINCIPAL=%GW_ATUAL%"
if not defined GATEWAY_PRINCIPAL (
    echo %VM%O gateway e obrigatorio.%RS%
    goto gateway
)
call :validaIP "%GATEWAY_PRINCIPAL%" || goto gateway

:: ============================================================
:: PASSO 3 - DNS
:: ============================================================
call :cabecalho "PASSO 3 de 4 - DNS"
echo %CI%Se nao souber o que colocar, apenas aperte ENTER nas duas perguntas.%RS%
echo.
set "DNS_PRIMARIO="
set /p "DNS_PRIMARIO=%AM%>%RS% DNS primario   [ENTER = 8.8.8.8]: "
if not defined DNS_PRIMARIO set "DNS_PRIMARIO=8.8.8.8"
set "DNS_SECUNDARIO="
set /p "DNS_SECUNDARIO=%AM%>%RS% DNS secundario [ENTER = 8.8.4.4]: "
if not defined DNS_SECUNDARIO set "DNS_SECUNDARIO=8.8.4.4"

:: ============================================================
:: PASSO 4 - IPs da catraca (aceita mais de um)
:: ============================================================
:passo4
set "NAUX=0"
call :cabecalho "PASSO 4 de 4 - IPs para comunicar com a catraca"
echo %CI%Se a catraca ja esta na mesma rede do computador, responda N.%RS%
echo Voce pode adicionar mais de um IP, um para cada rede de catraca.
echo.
choice /c SN /n /m "Adicionar IP da catraca? [S] Sim  [N] Nao: "
if errorlevel 2 (
    set "OP=N"
    goto resumo
)
set "OP=S"

:: ---------- Loop de entrada dos IPs secundarios ----------
:addAux
set /a PROX=NAUX+1
call :cabecalho "PASSO 4 de 4 - IP da catraca numero !PROX!"
if !NAUX! gtr 0 (
    echo IPs ja adicionados:
    for /l %%i in (1,1,!NAUX!) do echo    %VD%!AUX_%%i!%RS% / !MASCAUX_%%i!
    echo.
)
set "TMP_IP="
if !NAUX!==0 (
    set /p "TMP_IP=%AM%>%RS% IP secundario [ENTER = 192.168.20.1]: "
    if not defined TMP_IP set "TMP_IP=192.168.20.1"
) else (
    set /p "TMP_IP=%AM%>%RS% IP secundario numero !PROX!: "
    if not defined TMP_IP goto pergUltimo
)
call :validaIP "!TMP_IP!" || goto addAux

:: Nao pode repetir o IP principal
if /i "!TMP_IP!"=="%IP_PRINCIPAL%" (
    echo.
    echo %VM%Esse IP e o mesmo do IP fixo do computador.%RS%
    pause
    goto addAux
)

:: Nao pode repetir um IP secundario ja informado
set "DUP="
for /l %%i in (1,1,!NAUX!) do if /i "!AUX_%%i!"=="!TMP_IP!" set "DUP=1"
if defined DUP (
    echo.
    echo %VM%Esse IP ja foi adicionado na lista.%RS%
    pause
    goto addAux
)

:: Aviso de IP em uso - nao bloqueia, porque ao rodar o programa de novo
:: o proprio computador pode responder nesse IP
echo Verificando se o IP !TMP_IP! ja esta em uso na rede...
ping -4 -n 1 -w 1000 !TMP_IP! | findstr /i "TTL" >nul
if !errorlevel!==0 (
    echo.
    echo %AM%AVISO: alguem respondeu no IP !TMP_IP!.%RS%
    echo Pode ser outro aparelho, ou este proprio computador se voce
    echo ja rodou este programa antes.
    echo.
    choice /c SN /n /m "Usar esse IP mesmo assim? [S] Sim  [N] Escolher outro: "
    if errorlevel 2 goto addAux
) else (
    echo %VD%OK, IP livre.%RS%
)

:auxMascara
echo.
set "TMP_MASC="
set /p "TMP_MASC=%AM%>%RS% Mascara       [ENTER = 255.255.255.0]: "
if not defined TMP_MASC set "TMP_MASC=255.255.255.0"
call :validaIP "!TMP_MASC!" || goto auxMascara

:: Guarda na lista
set /a NAUX+=1
set "AUX_!NAUX!=!TMP_IP!"
set "MASCAUX_!NAUX!=!TMP_MASC!"
echo.
echo %VD%Adicionado: !TMP_IP! / !TMP_MASC!%RS%

:: Chegou no limite?
if !NAUX! geq %MAX_AUX% (
    echo.
    echo %AM%Limite de %MAX_AUX% IPs secundarios atingido.%RS%
    pause
    goto resumo
)

:pergUltimo
echo.
choice /c SN /n /m "Adicionar OUTRO IP para a catraca? [S] Sim  [N] Nao, continuar: "
if errorlevel 2 goto resumo
goto addAux

:: ============================================================
:: RESUMO
:: ============================================================
:resumo
call :cabecalho "RESUMO - confira antes de aplicar"
echo    Conexao ............ %CI%%NOME_CONEXAO%%RS%
echo    IP fixo ............ %CI%%IP_PRINCIPAL%%RS%
echo    Mascara ............ %CI%%MASCARA_PRINCIPAL%%RS%
echo    Gateway ............ %CI%%GATEWAY_PRINCIPAL%%RS%
echo    DNS primario ....... %CI%%DNS_PRIMARIO%%RS%
echo    DNS secundario ..... %CI%%DNS_SECUNDARIO%%RS%
if "%OP%"=="S" (
    echo    IPs da catraca ..... %CI%!NAUX! no total%RS%
    for /l %%i in (1,1,!NAUX!) do echo                         %CI%!AUX_%%i! / !MASCAUX_%%i!%RS%
) else (
    echo    IPs da catraca ..... nao adicionar
)
echo.
choice /c SNV /n /m "Esta tudo certo? [S] Aplicar  [V] Voltar e corrigir  [N] Cancelar: "
if errorlevel 3 goto passo2
if errorlevel 2 (
    echo.
    echo Cancelado. Nada foi alterado.
    pause
    exit /b
)

:: ============================================================
:: APLICAR
:: ============================================================
echo.
echo Aplicando configuracao, aguarde...
echo.

echo  - Definindo IP fixo, mascara e gateway...
netsh interface ip set address "%NOME_CONEXAO%" static %IP_PRINCIPAL% %MASCARA_PRINCIPAL% %GATEWAY_PRINCIPAL% >nul
if %errorlevel% neq 0 (
    set "ERRO=Falha ao definir o IP fixo."
    goto endERROR
)

echo  - Definindo DNS primario...
netsh interface ip set dns "%NOME_CONEXAO%" static %DNS_PRIMARIO% validate=no >nul
if %errorlevel% neq 0 (
    set "ERRO=Falha ao definir o DNS primario."
    goto endERROR
)

echo  - Definindo DNS secundario...
netsh interface ip add dns "%NOME_CONEXAO%" %DNS_SECUNDARIO% index=2 validate=no >nul
if %errorlevel% neq 0 (
    set "ERRO=Falha ao definir o DNS secundario."
    goto endERROR
)

if "%OP%"=="N" goto endFim

:: Adiciona todos os IPs secundarios da lista
for /l %%i in (1,1,!NAUX!) do (
    echo  - Adicionando IP da catraca !AUX_%%i! ...
    netsh interface ip add address "%NOME_CONEXAO%" !AUX_%%i! !MASCAUX_%%i! >nul
    if !errorlevel! neq 0 (
        set "ERRO=Falha ao adicionar o IP da catraca !AUX_%%i!."
        goto endERROR
    )
)

:endFim
echo.
echo %VD%============================================================%RS%
echo %VD%   PRONTO! Configuracao concluida com sucesso.%RS%
echo %VD%============================================================%RS%
echo.
pause
exit /b

:endERROR
echo.
echo %VM%ERRO: %ERRO%%RS%
echo.
echo Para o computador nao ficar sem internet, a conexao foi
echo devolvida para o modo automatico - DHCP.
netsh interface ip set address name="%NOME_CONEXAO%" source=dhcp >nul
netsh interface ip set dnsservers name="%NOME_CONEXAO%" source=dhcp >nul
echo %AM%DHCP ATIVADO%RS%
echo.
echo Confira os dados digitados e rode o programa de novo.
pause
exit /b

:: ============================================================
:: FUNCOES
:: ============================================================
:cabecalho
cls
echo %CI%============================================================%RS%
echo %CI%   CONFIGURAR IP FIXO - SISTEMA FACIAL%RS%
echo %CI%============================================================%RS%
echo.
echo %AM%%~1%RS%
echo.
exit /b

:validaIP
echo %~1| findstr /r "^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$" >nul
if %errorlevel% neq 0 (
    echo %VM%"%~1" nao e um endereco valido. Use o formato 192.168.0.10%RS%
    pause
    exit /b 1
)
exit /b 0
