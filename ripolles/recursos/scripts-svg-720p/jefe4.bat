@echo off
set SVG=..\jefes\jefe4.svg
set OUTDIR=..\..\fpg-sources\jefe4\
echo Exportando jefe4.svg (jefe4)
call :a 1
call :a 21
call :a 22
call :a 31
call :a 32
call :a 61
call :a 81
call :a 82
call :a 83
call :a 84
call :a 85
call :a 86
call :a 87
call :a 211
call :a 212
call :a 213
call :a 214
call :a 215
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