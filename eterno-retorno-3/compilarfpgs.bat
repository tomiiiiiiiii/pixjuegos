@echo off
rem @echo off
set bits=%1
if "%bits%"==""; set bits=32
ECHO CREANDO FPGS...
cd fpg-sources
copy ..\..\utils\pxlfpg.dcb . /y
..\..\bennu-win\bgdi pxlfpg %bits% armas general jefe mapas objetos personaje1 personaje2 personaje3 personaje4 enemigos
del /f pxlfpg.dcb
cd ..