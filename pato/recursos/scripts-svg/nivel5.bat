@echo off
IF "%DPI1%."=="." set DPI1=180
set OUTDIR=..\..\fpg-sources\nivel5\
echo Exportando nivel5
call :a 1 ..\niveles\fondo5.svg
call :a 11 ..\niveles\fondo5.svg
call :a 12 ..\niveles\fondo5.svg
call :a 101 ..\otros\estatua_caida.svg
call :a 102 ..\otros\estatua_caida.svg
call :a 103 ..\otros\estatua_caida.svg
call :a 104 ..\otros\estatua_caida.svg
exit
goto :eof

:a
echo Creando %1.png...
..\..\..\utils\inkscape\inkscape.com --export-id="%1" --export-dpi="%DPI1%" --export-png="%OUTDIR%%1.png" %2 > NUL
goto :eof