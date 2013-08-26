@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc -g -D GLOBAL_RESOLUTION=-2 ripolles.prg
move ripolles.dcb ..
pause
cd ..
..\bennu-win\bgdi ripolles.dcb

pause
exit