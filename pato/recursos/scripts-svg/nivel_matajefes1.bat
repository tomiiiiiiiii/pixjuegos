@echo off
IF "%DPI1%."=="." set DPI1=180
set OUTDIR=..\..\fpg-sources\nivel_matajefes1\
echo Exportando nivelmatajefes1
call :a 1 ..\niveles\nivel_matajefes1.svg
exit
goto :eof

:a
echo Creando %1.png...
..\..\..\utils\inkscape\inkscape.com --export-id="%1" --export-dpi="%DPI1%" --export-png="%OUTDIR%%1.png" %2 > NUL
goto :eof