@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc -D DEBUG=1 -g pixfrogger.prg
move pixfrogger.dcb ..
pause
cd ..
..\bennu-win\bgdi pixfrogger.dcb

pause
exit