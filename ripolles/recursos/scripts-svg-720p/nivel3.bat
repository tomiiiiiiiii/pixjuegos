@echo off
set OUTDIR=..\..\fpg-sources\nivel3\
echo Exportando nivel3
call :a 1 ..\niveles\fondo3.svg
call :a 2 ..\niveles\fondo3.svg
call :a 3 ..\niveles\fondo3.svg
call :a 4 ..\niveles\fondo3.svg
call :a 5 ..\niveles\fondo3.svg
rem call :a 6 ..\niveles\fondo3.svg
call :a 10 ..\otros\bicicas.svg
call :a 11 ..\otros\bicicas.svg
call :a 12 ..\otros\bicicas.svg

rem call :a 11 ..\otros\fondo3.svg
rem call :a 12 ..\otros\fondo3.svg
call :a 21 ..\otros\fondo3.svg
call :a 31 ..\otros\fondo3.svg
call :a 32 ..\otros\fondo3.svg
exit
goto :eof

:a
echo Creando %1.png...
..\..\..\utils\inkscape\inkscape.com --export-id="%1" --export-dpi="180" --export-png="%OUTDIR%%1.png" %2 > NUL
goto :eof