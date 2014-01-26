@echo off
set bits=%1
if "%bits%"==""; set bits=16
call ..\scripts\compilarfpgs.bat %bits% armas general jefe mapas objetos personaje1 personaje2 personaje3 personaje4 enemigos