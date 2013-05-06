@echo off
set OUTDIR=..\..\fpg-sources\general\
echo Exportando fpg general
call :a 21 ..\personajes\Ripolles.svg
call :a 22 ..\personajes\Ripolles2.svg
call :a 23 ..\personajes\Ripolles3.svg
call :a 24 ..\personajes\Ripolles4.svg
call :a 28 ..\personajes\Pato.svg
goto :eof

:a
echo Creando %1.png...
"c:\Program Files (x86)\Inkscape\inkscape.com" --export-id="general-%1" --export-dpi="180" --export-png="%OUTDIR%%1.png" %2 > NUL
goto :eof