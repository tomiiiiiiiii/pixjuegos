@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc -D DEBUG=1 -g inforgames.prg
move inforgames.dcb ..
pause
cd ..
..\bennu-win\bgdi inforgames.dcb

pause
exit