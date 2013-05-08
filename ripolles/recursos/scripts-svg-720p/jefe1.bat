@echo off
set SVG=..\jefes\jefe1.svg
set OUTDIR=..\..\fpg-sources\jefe1\
echo Exportando jefe1.svg
call :a 1
call :a 11
call :a 12
call :a 13
call :a 14
call :a 21
call :a 22
call :a 23
call :a 24
call :a 31
call :a 32
call :a 33
call :a 34
call :a 41
call :a 42
call :a 43
call :a 51
call :a 61
call :a 71
call :a 72
call :a 73
call :a 74
call :a 75
call :a 81
call :a 82
call :a 83
call :a 91

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