@echo off
set SVG=..\personajes\pato.svg
set OUTDIR=..\..\fpg-sources\cutscenes\
IF "%DPI2%."=="." set DPI2=360
echo Exportando pato.svg
call :a 11
call :a 12
call :a 13
call :a 14
call :b 15 13
call :a 31
call :a 32
call :a 41
call :a 42
call :a 43
call :a 44
call :b 45 43
call :a 51
call :a 52
call :a 53
call :a 54
call :a 55
call :a 56
call :a 57
call :a 58
call :a 59
call :a 60
call :a 61
call :a 62
call :a 63
call :a 64
call :a 65
call :a 66
call :a 67
call :a 68
call :a 69
call :a 70
call :a 71
call :a 72
call :a 73
call :a 74
call :a 81
call :a 82
call :a 83
call :a 84
call :b 85 83
exit
goto :eof

:a
echo Creando %1.png...
..\..\..\utils\inkscape\inkscape.com --export-id="cutscenes-%1" --export-dpi="%DPI2%" --export-png="%OUTDIR%%1.png" %SVG% > NUL
goto :eof

:b
REM PARA GRÁFICOS REPETIDOS
echo Creando %1.png...
..\..\..\utils\inkscape\inkscape.com --export-id="cutscenes-%2" --export-dpi="%DPI2%" --export-png="%OUTDIR%%1.png" %SVG% > NUL
goto :eof