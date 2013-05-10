@echo off
set OUTDIR=..\..\fpg-sources\nivel1\
echo Exportando nivel1
call :a 1 ..\niveles\fondo1.svg
goto :eof

:a
echo Creando %1.png...
..\..\..\utils\inkscape\inkscape.com --export-id="general-%1" --export-dpi="90" --export-png="%OUTDIR%%1.png" %2 > NUL
goto :eof