@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc -g pixparty.prg
move pixparty.dcb ..
pause
cd ..
..\bennu-win\bgdi pixparty.dcb

pause
exit