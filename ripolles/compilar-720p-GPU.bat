@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc -D GLOBAL_RESOLUTION=-2 ripolles.prg
move ripolles.dcb ..
pause
cd ..
..\bennu-win-gpu\bgdi ripolles.dcb

pause
exit