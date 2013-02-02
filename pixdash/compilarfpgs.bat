rem @echo off
set bits=%1
if "%bits%"==""; set bits=16
ECHO CREANDO FPGS...
cd fpg-sources
copy ..\..\utils\pxlfpg.dcb . /y
..\..\bennu-win\bgdi pxlfpg %bits% enemigos menu powerups pix pux pax pex moneda tiles premios general
del /f pxlfpg.dcb

cd ..\fpg
ren *.fpg *.fpg.gz
..\..\utils\gzip -d *.fpg.gz
ren durezas.fpg.gz durezas.fpg

cd ..
exit