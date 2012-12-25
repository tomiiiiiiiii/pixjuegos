@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc -g 7stars.prg
move 7stars.dcb ..
pause
cd ..
..\bennu-win\bgdi 7stars.dcb

pause
exit