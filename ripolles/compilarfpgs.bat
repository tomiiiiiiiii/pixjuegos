@echo off
ECHO CREANDO FPGS...
cd fpg-sources
copy /y ..\..\utils\pxlfpg.dcb .
..\..\bennu-win\bgdi pxlfpg 32 cutscenes enemigo1 enemigo2 enemigo3 enemigo4 general jefe1 jefe2 jefe3 jefe4 menu nivel1 nivel2 nivel3 nivel4 nivel5 objetos ripolles
del /f pxlfpg.dcb