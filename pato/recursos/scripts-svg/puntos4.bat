@echo off
IF "%DPI4%."=="." set DPI4=90
set OUTDIR=..\..\fpg-sources\puntos4\
echo Exportando fpg tiempo
call :a 48 ..\interfaz\puntos4.svg
call :a 49 ..\interfaz\puntos4.svg
call :a 50 ..\interfaz\puntos4.svg
call :a 51 ..\interfaz\puntos4.svg
call :a 52 ..\interfaz\puntos4.svg
call :a 53 ..\interfaz\puntos4.svg
call :a 54 ..\interfaz\puntos4.svg
call :a 55 ..\interfaz\puntos4.svg
call :a 56 ..\interfaz\puntos4.svg
call :a 57 ..\interfaz\puntos4.svg
call :a 58 ..\interfaz\puntos4.svg
exit
goto :eof

:a
echo Creando %1.png...
..\..\..\utils\inkscape\inkscape.com --export-id="tiempo-%1" --export-dpi="%DPI4%" --export-png="%OUTDIR%%1.png" %2 > NUL
goto :eof