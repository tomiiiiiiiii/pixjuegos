@echo off
set OUTDIR=..\..\fpg-sources\nivel2\
echo Exportando nivel2
call :a 1 ..\niveles\fondo2.svg
call :a 11 ..\niveles\fondo2.svg
exit
goto :eof

:a
echo Creando %1.png...
..\..\..\utils\inkscape\inkscape.com --export-id="%1" --export-dpi="180" --export-png="%OUTDIR%%1.png" %2 > NUL
goto :eof