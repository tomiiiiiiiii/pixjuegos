@echo off
IF "%DPI1%."=="." set DPI1=180
set OUTDIR=..\..\fpg-sources\menu\
echo Exportando fpg menu
rem call :a 50 ..\interfaz\sistema.svg
exit
goto :eof

:a
echo Creando %1.png...
..\..\..\utils\inkscape\inkscape.com --export-id="menu-%1" --export-dpi="%DPI1%" --export-png="%OUTDIR%%1.png" %2 > NUL
goto :eof