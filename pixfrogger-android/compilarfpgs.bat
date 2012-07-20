@echo off
ECHO CREANDO FPGS...
cd fpg-sources
copy /y ..\..\utils\pxlfpg.dcb .
..\..\bennu-win\bgdi pxlfpg 16 pixfrogger
del /f pxlfpg.dcb
cd ..\fpg
ren pixfrogger.fpg pixfrogger.fpg.gz
..\..\utils\gzip -d pixfrogger.fpg.gz
cd ..