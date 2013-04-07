@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc -g -D DEBUG=1 ripolles.prg
move ripolles.dcb ..
pause
cd ..
..\bennu-win\bgdi ripolles.dcb

pause
exit