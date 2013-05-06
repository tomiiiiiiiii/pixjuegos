@echo off
set SVG=..\personajes\Ripolles.svg
set OUTDIR=..\..\fpg-sources\ripolles1\
echo Exportando Ripolles.svg
call :a 1
call :a 101
call :a 11
call :a 111
call :a 112
call :a 113
call :a 114
call :a 12
call :a 121
call :a 122
call :a 13
call :a 131
call :a 132
call :a 14
call :a 141
call :a 142
call :a 143
call :a 151
call :a 161
call :a 171
call :a 172
call :a 181
call :a 191
call :a 192
call :a 193
call :a 194
call :a 201
call :a 202
call :a 203
call :a 204
call :a 21
call :a 22
call :a 31
call :a 32
call :a 41
call :a 42
call :a 51
call :a 61
call :a 71
call :a 72
call :a 73
call :a 81
call :a 82
call :a 83
call :a 84
call :a 91
call :a 92

goto :eof

:a
echo Creando %1.png...
..\..\..\utils\inkscape\inkscape.com --export-id="%1" --export-dpi="180" --export-png="%OUTDIR%%1.png" %SVG% > NUL
goto :eof

:b
REM PARA GRÁFICOS REPETIDOS
echo Creando %1.png...
..\..\..\utils\inkscape\inkscape.com --export-id="%2" --export-dpi="180" --export-png="%OUTDIR%%1.png" %SVG% > NUL
goto :eof