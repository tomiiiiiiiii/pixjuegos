@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc -g ripolles.prg
move ripolles.dcb ..
pause
cd ..
..\bennu-win\bgdi ripolles.dcb

pause
exit