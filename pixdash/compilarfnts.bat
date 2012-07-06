@echo off
mkdir fnt
ECHO CREANDO FPGS...
cd fnt-sources
copy ..\..\utils\pxlfnt.dcb . /y
rem ..\..\bennu-win\bgdi pxlfnt 8 fuente_peq
del /f pxlfnt.dcb
pause