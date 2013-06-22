@echo off
set SVG=..\enemigos\enemigo 6.svg
set OUTDIR=..\..\fpg-sources\enemigo6\
echo Exportando enemigo6.svg
call :a 1
call :a 11
call :a 12
call :a 13
call :a 14
call :a 31
call :a 32
call :a 33
call :a 61
call :a 71
call :a 72
call :a 73
call :a 81
call :a 82
call :a 83
call :a 84
call :a 85
call :a 86
call :a 87
call :a 151
call :a 211
call :a 212
call :a 213
exit
goto :eof

:a
echo Creando %1.png...
..\..\..\utils\inkscape\inkscape.com --export-id="%1" --export-dpi="180" --export-png="%OUTDIR%%1.png" "%SVG%" > NUL
goto :eof

:b
REM PARA GRÁFICOS REPETIDOS
echo Creando %1.png...
..\..\..\utils\inkscape\inkscape.com --export-id="%2" --export-dpi="180" --export-png="%OUTDIR%%1.png" "%SVG%" > NUL
goto :eof