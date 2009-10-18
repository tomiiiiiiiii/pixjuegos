@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc -g pixpang.prg
move pixpang.dcb ..
pause
cd ..
..\bennu-win\bgdi pixpang.dcb

pause
exit