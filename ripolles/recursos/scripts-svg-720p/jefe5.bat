@echo off
set SVG=..\jefes\jefe5.svg
set OUTDIR=..\..\fpg-sources\jefe5\
echo Exportando jefe5.svg
call :a 1
call :a 101
call :a 102
call :a 103
call :a 11
call :a 111
call :a 12
call :a 121
call :a 131
call :a 132
call :a 133
call :a 141
call :a 142
call :a 143
call :a 151
call :a 161
call :a 171
call :a 172
call :a 173
call :a 181
call :a 182
call :a 183
call :a 191
call :a 2
call :a 201
call :a 21
call :a 211
call :a 22
call :a 23
call :a 24
call :a 3
call :a 31
call :a 4
call :a 41
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
call :a 71
call :a 81
call :a 82
call :a 83
call :a 91
call :a 92
call :a 93
rem call :a 16

copy ..\..\fpg-sources\jefe5\201.png ..\..\fpg-sources\general\14.png /y
copy ..\..\fpg-sources\jefe5\211.png ..\..\fpg-sources\general\13.png /y
copy ..\..\fpg-sources\jefe5\16.png ..\..\fpg-sources\general\16.png /y

exit
goto :eof

:a
echo Creando %1.png...
..\..\..\utils\inkscape\inkscape.com --export-id="%1" --export-dpi="117" --export-png="%OUTDIR%%1.png" "%SVG%" > NUL
goto :eof

:b
REM PARA GRÁFICOS REPETIDOS
echo Creando %1.png...
..\..\..\utils\inkscape\inkscape.com --export-id="%2" --export-dpi="117" --export-png="%OUTDIR%%1.png" "%SVG%" > NUL
goto :eof