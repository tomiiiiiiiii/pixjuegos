@echo off
ECHO CREANDO FPGS...
rd /s /f fpg
mkdir fpg
cd fpg-sources
copy ..\..\utils\pxlfpg.dcb . /y
..\..\bennu-win\bgdi pxlfpg 32 ultimo
del /f pxlfpg.dcb
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