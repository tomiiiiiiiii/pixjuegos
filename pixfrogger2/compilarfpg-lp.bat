@echo off
ECHO CREANDO FPGS...
del /f fpg\pixfrogger.fpg
cd fpg-sources
copy /y ..\..\utils\pxlfpg.dcb .
..\..\bennu-win\bgdi pxlfpg 32 pixfrogger-lp
del /f pxlfpg.dcb
cd ..\fpg
ren pixfrogger-lp.fpg pixfrogger.fpg