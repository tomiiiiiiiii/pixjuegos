@echo off
ECHO CREANDO FPGS...
rd /s /q fpg
mkdir fpg
cd fpg-sources
..\..\bennu-win\bgdc pxlfpg.prg
..\..\bennu-win\bgdi pxlfpg pixpang
..\..\bennu-win\bgdi pxlfpg pix
..\..\bennu-win\bgdi pxlfpg pixmorao
cd ..

echo Compilando...
cd src
..\..\bennu-win\bgdc -g dx.prg
move dx.dcb ..
pause
cd ..
..\bennu-win\bgdi dx.dcb

pause
exit