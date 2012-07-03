@echo off
ECHO CREANDO FPGS...
rd /s /q fpg
mkdir fpg
cd fpg-sources
copy ..\..\utils\pxlfpg.dcb . /y
..\..\bennu-win\bgdi pxlfpg 32 bp
del /f pxlfpg.dcb
cd ..
cd src
echo Compilando...
..\..\bennu-win\bgdc -g bp.prg
move bp.dcb ..
pause
cd ..
..\bennu-win\bgdi bp.dcb
pause
exit