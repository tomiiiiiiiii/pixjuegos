@echo off
echo Compilando...
cd src
..\..\bennu-win\bgdc -g dx.prg
move dx.dcb ..
pause
cd ..
..\bennu-win\bgdi dx.dcb

pause
exit