@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc -g garnatron.prg
move garnatron.dcb ..
pause
cd ..
..\bennu-win\bgdi garnatron.dcb

pause
exit