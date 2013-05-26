@echo off
set OUTDIR=..\..\fpg-sources\nivel4\
echo Exportando nivel4
call :a 1 ..\niveles\fondo4.svg
exit

goto :eof

:a
echo Creando %1.png...
..\..\..\utils\inkscape\inkscape.com --export-id="%1" --export-dpi="90" --export-png="%OUTDIR%%1.png" %2 > NUL
goto :eof