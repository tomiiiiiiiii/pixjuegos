@echo off
cd src
echo Compilando...
..\..\bennu-win\bgdc -g -D GLOBAL_RESOLUTION=-2 pato.prg
move pato.dcb ..
pause
cd ..
..\bennu-win\bgdi pato.dcb

pause
exit