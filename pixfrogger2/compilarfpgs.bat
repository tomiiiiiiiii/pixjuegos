@echo off
ECHO CREANDO FPGS...
cd fpg-sources
copy /y ..\..\utils\pxlfpg.dcb .
..\..\bennu-win\bgdi pxlfpg 32 pixfrogger-hd pixfrogger-md pixfrogger-ld
del /f pxlfpg.dcb