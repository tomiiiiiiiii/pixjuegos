@echo off
set OUTDIR=..\..\fpg-sources\tiempo\
echo Exportando fpg tiempo
call :a 48 ..\interfaz\sistema.svg
call :a 49 ..\interfaz\sistema.svg
call :a 50 ..\interfaz\sistema.svg
call :a 51 ..\interfaz\sistema.svg
call :a 52 ..\interfaz\sistema.svg
call :a 53 ..\interfaz\sistema.svg
call :a 54 ..\interfaz\sistema.svg
call :a 55 ..\interfaz\sistema.svg
call :a 56 ..\interfaz\sistema.svg
call :a 57 ..\interfaz\sistema.svg
call :a 58 ..\interfaz\sistema.svg
exit
goto :eof

:a
echo Creando %1.png...
..\..\..\utils\inkscape\inkscape.com --export-id="tiempo-%1" --export-dpi="90" --export-png="%OUTDIR%%1.png" %2 > NUL
goto :eof