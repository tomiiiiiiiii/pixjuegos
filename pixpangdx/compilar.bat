@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc -g dx.prg
move dx.dcb ..
pause
cd ..
..\bennu-win\bgdi dx.dcb

pause
exit