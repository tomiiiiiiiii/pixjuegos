@echo off
mkdir fpg
ECHO CREANDO FPGS...
cd fpg-sources
copy ..\..\utils\pxlfpg.dcb . /y
..\..\bennu-win\bgdi pxlfpg 16 enemigos menu powerups pix pux pax pex moneda tiles premios general
del /f pxlfpg.dcb
pause