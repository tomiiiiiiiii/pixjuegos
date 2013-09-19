@echo off
IF "%DPI1%."=="." set DPI1=180
set SVG=..\enemigos\vaca.svg
set OUTDIR=..\..\fpg-sources\vaca\
echo Exportando vaca.svg
call :a 1
call :a 2
call :a 3
call :a 4
call :a 11
call :a 12
call :a 13
call :a 14
call :a 21
exit
goto :eof

:a
echo Creando %1.png...
..\..\..\utils\inkscape\inkscape.com --export-id="%1" --export-dpi="%DPI1%" --export-png="%OUTDIR%%1.png" "%SVG%" > NUL
goto :eof

:b
REM PARA GRÁFICOS REPETIDOS
echo Creando %1.png...
..\..\..\utils\inkscape\inkscape.com --export-id="%2" --export-dpi="%DPI1%" --export-png="%OUTDIR%%1.png" "%SVG%" > NUL
goto :eof