@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc -D DEBUG=1 -g garnatron.prg
move garnatron.dcb ..
pause
cd ..
..\bennu-win\bgdi garnatron.dcb

pause
exit