@echo off
ECHO CREANDO FPGS...
cd fpg-sources
copy /y ..\..\utils\pxlfpg.dcb .
..\..\bennu-win\bgdi pxlfpg 16 pixfrogger-hd pixfrogger-md pixfrogger-ld pixfrogger-hd-portrait pixfrogger-md-portrait pixfrogger-ld-portrait pixfrogger-ld-32players
del /f pxlfpg.dcb