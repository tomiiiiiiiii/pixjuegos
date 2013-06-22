@echo off
set OUTDIR=..\..\fpg-sources\general\
echo Exportando fpg general
call :a 21 ..\personajes\Ripolles.svg
call :b 21 22 ..\personajes\Ripolles2.svg
call :b 21 23 ..\personajes\Ripolles3.svg
call :b 21 24 ..\personajes\Ripolles4.svg
call :a 28 ..\personajes\Pato.svg
call :a 10 ..\otros\warning.svg
call :a 11 ..\otros\tram.svg
call :a 12 ..\otros\tram.svg
call :a 4 ..\interfaz\sistema.svg
call :a 5 ..\interfaz\sistema.svg
call :a 6 ..\interfaz\sistema.svg
call :a 7 ..\interfaz\sistema.svg
call :a 8 ..\interfaz\sistema.svg
exit
goto :eof

:a
echo Creando %1.png...
..\..\..\utils\inkscape\inkscape.com --export-id="general-%1" --export-dpi="180" --export-png="%OUTDIR%%1.png" %2 > NUL
goto :eof

:b
echo Creando %2.png a partir del id %1...
..\..\..\utils\inkscape\inkscape.com --export-id="general-%1" --export-dpi="180" --export-png="%OUTDIR%%2.png" %3 > NUL
goto :eof