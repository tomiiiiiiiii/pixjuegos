@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc -g pixfrogger.prg
move pixfrogger.dcb ..
pause
cd ..
..\bennu-win\bgdi pixfrogger.dcb

pause
exit