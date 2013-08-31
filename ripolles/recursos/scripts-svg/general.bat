@echo off
IF "%DPI1%."=="." set DPI1=180
set OUTDIR=..\..\fpg-sources\general\
echo Exportando fpg general
call :a 4 ..\interfaz\sistema.svg
call :a 5 ..\interfaz\sistema.svg
call :a 6 ..\interfaz\sistema.svg
call :a 7 ..\interfaz\sistema.svg
call :a 8 ..\interfaz\sistema.svg
call :a 21 ..\personajes\Ripolles.svg
call :b 21 22 ..\personajes\Ripolles2.svg
call :b 21 23 ..\personajes\Ripolles3.svg
call :b 21 24 ..\personajes\Ripolles4.svg
call :a 28 ..\personajes\Pato.svg
call :a 10 ..\otros\warning.svg
call :a 11 ..\otros\tram.svg
call :a 12 ..\otros\tram.svg
rem call :a 15 ..\otros\tram.svg
call :a 16 ..\jefes\jefe5.svg
call :a 17 ..\interfaz\sistema.svg
call :a 61 ..\otros\explosion.svg
call :a 62 ..\otros\explosion.svg
call :a 63 ..\otros\explosion.svg
call :a 64 ..\otros\explosion.svg
call :a 65 ..\otros\explosion.svg
call :a 66 ..\otros\explosion.svg
call :a 67 ..\otros\explosion.svg
call :a 68 ..\otros\explosion.svg
call :a 69 ..\otros\explosion.svg
call :a 70 ..\otros\explosion.svg
call :a 71 ..\otros\explosion.svg
call :a 72 ..\otros\explosion.svg
call :a 73 ..\otros\explosion.svg
call :a 74 ..\otros\explosion.svg
call :a 75 ..\otros\explosion.svg

call :a 101 ..\otros\bloqueadores.svg
call :a 102 ..\otros\bloqueadores.svg
call :a 103 ..\otros\bloqueadores.svg
call :a 104 ..\otros\bloqueadores.svg
call :a 105 ..\otros\bloqueadores.svg
call :a 106 ..\otros\bloqueadores.svg

exit
goto :eof

:a
echo Creando %1.png...
..\..\..\utils\inkscape\inkscape.com --export-id="general-%1" --export-dpi="%DPI1%" --export-png="%OUTDIR%%1.png" %2 > NUL
goto :eof

:b
echo Creando %2.png a partir del id %1...
..\..\..\utils\inkscape\inkscape.com --export-id="general-%1" --export-dpi="%DPI1%" --export-png="%OUTDIR%%2.png" %3 > NUL
goto :eof