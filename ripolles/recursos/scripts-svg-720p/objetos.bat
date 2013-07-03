@echo off
set OUTDIR=..\..\fpg-sources\objetos\
echo Exportando objetos
call :a 1
call :a 2
call :a 3
call :a 4
call :a 5
call :a 6
call :a 7
call :a 8
call :a 9
call :a 10
call :a 100
exit
goto :eof

:a
echo Creando %1.png...
..\..\..\utils\inkscape\inkscape.com --export-id="%1" --export-dpi="180" --export-png="%OUTDIR%%1.png" ..\otros\objetos.svg > NUL
goto :eof