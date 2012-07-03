@echo off
ECHO CREANDO FPGS...
cd fpg-sources
copy ..\..\utils\pxlfpg.dcb . /y
..\..\bennu-win\bgdi pxlfpg 32 armas general jefe objetos personaje
del /f pxlfpg.dcb