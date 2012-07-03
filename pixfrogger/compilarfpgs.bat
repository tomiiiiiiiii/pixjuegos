@echo off
ECHO CREANDO FPGS...
cd fpg-sources
copy /y ..\..\utils\pxlfpg.dcb .
..\..\bennu-win\bgdi pxlfpg 32 pixfrogger
del /f pxlfpg.dcb