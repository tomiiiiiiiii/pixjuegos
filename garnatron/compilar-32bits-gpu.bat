@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc garnatron.prg
move garnatron.dcb ..
pause
cd ..
..\bennu-win-gpu\bgdi garnatron.dcb

pause
exit