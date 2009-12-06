@echo off
ECHO CREANDO FPGS...
rd /s /q fpg
mkdir fpg
cd fpg-sources
..\..\bennu-win\bgdc pxlfpg.prg
..\..\bennu-win\bgdi pxlfpg bp
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