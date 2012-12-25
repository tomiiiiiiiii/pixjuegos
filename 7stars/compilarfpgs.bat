rem @echo off
set bits=%1
if "%bits%"==""; set bits=32
ECHO CREANDO FPGS...
cd fpg-sources
copy ..\..\utils\pxlfpg.dcb . /y
..\..\bennu-win\bgdi pxlfpg %bits% ficher
del /f pxlfpg.dcb

cd ..\fpg
ren *.fpg *.fpg.gz
..\..\utils\gzip -d *.fpg.gz

cd ..
exit