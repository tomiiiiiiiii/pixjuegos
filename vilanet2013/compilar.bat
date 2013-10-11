@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc -g vilanet2013.prg
move vilanet2013.dcb ..
pause
cd ..
..\bennu-win\bgdi vilanet2013.dcb

pause
exit