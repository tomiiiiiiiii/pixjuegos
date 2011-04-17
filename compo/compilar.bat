@echo off
ECHO CREANDO FPGS...
rd /s /f fpg
mkdir fpg
cd fpg-sources
..\..\bennu-win\bgdc pxlfpg.prg
..\..\bennu-win\bgdi pxlfpg ultimo
cd ..

cd src
echo Compilando...
..\..\bennu-win\bgdc -g ultimo.prg
move ultimo.dcb ..
pause
cd ..
..\bennu-win\bgdi ultimo.dcb

pause
exit