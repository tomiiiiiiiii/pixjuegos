@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc -g vilanet.prg
move vilanet.dcb ..
pause
cd ..
..\bennu-win\bgdi vilanet.dcb

pause
exit