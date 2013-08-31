@echo off
IF "%DPI1%."=="." set DPI1=180
set OUTDIR=..\..\fpg-sources\nivel4\
echo Exportando nivel4
call :a 1 ..\niveles\fondo4.svg
call :a 2 ..\niveles\fondo4.svg
call :a 11 ..\niveles\fondo4.svg
exit
goto :eof

:a
echo Creando %1.png...
..\..\..\utils\inkscape\inkscape.com --export-id="%1" --export-dpi="%DPI1%" --export-png="%OUTDIR%%1.png" %2 > NUL
goto :eof