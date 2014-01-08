@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc -D DEBUG=1 -g borderpolice.prg
move borderpolice.dcb ..
pause
cd ..
..\bennu-win\bgdi borderpolice.dcb

pause
exit