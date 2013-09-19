@echo off
IF "%DPI1%."=="." set DPI1=180
set SVG=..\jefes\jefe3.svg
set OUTDIR=..\..\fpg-sources\jefe3\
echo Exportando jefe3.svg (jefe3)
call :a 1
call :a 2
call :a 11
call :a 21
call :a 31
call :a 32
call :a 33
call :a 34
call :a 41
call :a 42
call :a 43
call :a 51
call :a 52
call :a 53
call :a 54
call :a 61
call :a 62
call :a 63
call :a 64
call :a 71
call :a 81
call :a 82
call :a 83
call :a 91
call :a 101
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